// =====================================================================
//  Flaschen-Unscrambler K-3906.004 -> KE-50   (ESP32, Arduino)
//
//  Ablauf je Flasche:
//   1. Sperre A oeffnet -> Flasche X2 rutscht in die Wendetrommel bis zum Anschlag
//   2. Praesenz-Lichtschranke belegt & ruhig -> Sperre A zu, Klemme B auf,
//      Warteschlange rutscht nach, Klemme B zu (Vereinzelung, parallel)
//   3. Orientierung messen: Lichtschranke belegt -> Boden am Anschlag
//                           frei              -> Hals steckt in der Halsnut
//   4. Schacht frei & kein Band-Stau -> abwerfen:
//        Boden am Anschlag: -62 Grad  (Anschlagende nach unten)
//        Hals am Anschlag : +58 Grad halten (Hals rutscht aus Nut), dann +118 Grad
//   5. Flasche faellt Boden voraus in den Fallschacht und steht auf dem Band
//   6. Rotor zurueck in Ladestellung, Sperre A oeffnet schon waehrend der Rueckfahrt
//  Stufenfoerderer laeuft, solange die Rinne nicht voll ist; haelt unten an.
// =====================================================================
#include <Arduino.h>
#include <Preferences.h>
#include <FastAccelStepper.h>
#include "config.h"

static Params P;
static Preferences prefs;
static FastAccelStepperEngine engine;
static FastAccelStepper *stRot = nullptr;
static FastAccelStepper *stFeed = nullptr;

// ---------------------------------------------------------------------
// Lichtschranke (analog, mit Mindest-Stabilzeit)
// ---------------------------------------------------------------------
struct Beam {
  const char *name; uint8_t pin; uint16_t *thr;
  bool blocked = false; uint32_t since = 0; uint16_t raw = 0;
  Beam(const char *n, uint8_t p, uint16_t *t) : name(n), pin(p), thr(t) {}
  void update(uint32_t now) {
    raw = analogRead(pin);
    // Hysterese 3 % des Bereichs
    int t = *thr;
    bool b = blocked ? ((int)raw > t - 120) : ((int)raw > t + 120);
    if (b != blocked) { blocked = b; since = now; }
  }
  bool blockedFor(uint32_t ms, uint32_t now) const { return blocked && now - since >= ms; }
  bool freeFor(uint32_t ms, uint32_t now) const { return !blocked && now - since >= ms; }
};
static Beam bPres  {"praesenz", PIN_PT_PRES,    &P.thr_pres};
static Beam bOrient{"orient",   PIN_PT_ORIENT,  &P.thr_orient};
static Beam bFull  {"voll",     PIN_PT_FULL,    &P.thr_full};
static Beam bShaftA{"schachtA", PIN_PT_SHAFT_A, &P.thr_shaftA};
static Beam bShaftB{"schachtB", PIN_PT_SHAFT_B, &P.thr_shaftB};
static Beam *beams[] = {&bPres, &bOrient, &bFull, &bShaftA, &bShaftB};

struct DigIn {   // aktiv LOW, entprellt
  uint8_t pin; uint16_t deb; bool active = false; uint32_t since = 0; bool raw = false; uint32_t rawSince = 0;
  bool rose = false;          // wird beim Aktivwerden gesetzt, vom Verbraucher geloescht
  DigIn(uint8_t p, uint16_t d) : pin(p), deb(d) {}
  void update(uint32_t now) {
    bool r = digitalRead(pin) == LOW;
    if (r != raw) { raw = r; rawSince = now; }
    if (raw != active && now - rawSince >= deb) { active = raw; since = now; if (active) rose = true; }
  }
  bool takeRose() { bool r = rose; rose = false; return r; }
  bool activeFor(uint32_t ms, uint32_t now) const { return active && now - since >= ms; }
  bool inactiveFor(uint32_t ms, uint32_t now) const { return !active && now - since >= ms; }
};
static DigIn inHallRot{PIN_HALL_ROT, 1}, inHallFeed{PIN_HALL_FEED, 2}, inStau{PIN_STAU, 20};
static DigIn inStart{PIN_BTN_START, 30}, inStopNC{PIN_BTN_STOP, 30}, inEstopOk{PIN_ESTOP_FB, 30};

// ---------------------------------------------------------------------
// Ventile
// ---------------------------------------------------------------------
static void gateOpen(bool open)  { digitalWrite(PIN_VALVE_GATE, open ? HIGH : LOW); }
static void clampClose(bool cl)  { digitalWrite(PIN_VALVE_CLAMP, cl ? HIGH : LOW); }

// ---------------------------------------------------------------------
// Rotor (Winkel relativ zur Ladestellung)
// ---------------------------------------------------------------------
static int32_t rotSteps(float deg) { return lroundf(deg * ROT_STEPS_PER_DEG * P.rot_dir); }
static float rotAngle() { return stRot->getCurrentPosition() / (ROT_STEPS_PER_DEG * P.rot_dir); }
static void rotMoveTo(float deg, float v = -1, float a = -1) {
  if (v < 0) v = P.rot_vmax;
  if (a < 0) a = P.rot_amax;
  stRot->setSpeedInHz((uint32_t)(v * ROT_STEPS_PER_DEG));
  stRot->setAcceleration((int32_t)(a * ROT_STEPS_PER_DEG));
  stRot->moveTo(rotSteps(deg));
}
static bool rotBusy() { return stRot->isRunning(); }
// Dauer einer Trapezfahrt (ms)
static uint32_t moveTimeMs(float deg) {
  deg = fabsf(deg); float v = P.rot_vmax, a = P.rot_amax;
  float dacc = v * v / a;
  float t = deg < dacc ? 2.0f * sqrtf(deg / a) : 2.0f * v / a + (deg - dacc) / v;
  return (uint32_t)(t * 1000.0f);
}

// ---------------------------------------------------------------------
// Hubantrieb
// ---------------------------------------------------------------------
static bool feedRunning = false, feedStopReq = false;
static uint32_t feedLastEdge = 0;
static void feedStart() {
  stFeed->setSpeedInHz((uint32_t)(P.feed_rpm / 60.0f * FEED_STEPS_PER_REV));
  stFeed->setAcceleration((int32_t)(P.feed_acc_rps2 * FEED_STEPS_PER_REV));
  stFeed->runForward();
  feedRunning = true; feedStopReq = false; feedLastEdge = millis();
}
static void feedStopAtBottom() { if (feedRunning) feedStopReq = true; }
static void feedStopNow() { stFeed->stopMove(); feedRunning = false; feedStopReq = false; }

// ---------------------------------------------------------------------
// Zustaende
// ---------------------------------------------------------------------
enum Mode { M_FAULT, M_HOMING, M_IDLE, M_RUN, M_STOPPING };
enum RotState { R_WAIT_READY, R_LOADING, R_MEASURE, R_WIGGLE, R_WAIT_SHAFT, R_DUMP, R_HOLD, R_DROP, R_RETURN };
enum EscState { E_INIT_RELEASE, E_INIT_CLAMP, E_READY, E_GATE_OPEN, E_CLOSE_GATE, E_RELEASE, E_RECLAMP };
enum HomeState { H_START, H_LEAVE, H_SEEK_ON, H_SEEK_OFF, H_GOTO, H_FEED, H_DONE };

static Mode mode = M_HOMING;
static RotState rs = R_WAIT_READY;
static EscState es = E_INIT_RELEASE;
static HomeState hs = H_START;
static uint32_t rsT = 0, esT = 0, hsT = 0;
static const char *faultMsg = "";
static bool warnEmpty = false, stau = false, gutterFull = false, gateEarlyDone = false, arrivalSeen = false;
static uint32_t gateEarlyAt = 0;
static bool neckAtStop = false; static uint8_t retries = 0;
static uint32_t orientN = 0, orientBlocked = 0;
static float homeA = 0, homeB = 0;
static uint32_t cntTotal = 0, cntNeck = 0, cntWarnArrive = 0; static uint32_t rateT0 = 0, rateN = 0; static float rate = 0;

static void setRs(RotState s) { rs = s; rsT = millis(); }
static void setEs(EscState s) { es = s; esT = millis(); }
static void fault(const char *msg) {
  if (mode == M_FAULT) return;
  mode = M_FAULT; faultMsg = msg;
  feedStopNow(); stRot->forceStop();
  gateOpen(false);                       // Sperre zu (stromlos)
  digitalWrite(PIN_LAMP_FAULT, HIGH);
  Serial.printf("!! STOERUNG: %s\n", msg);
}
static bool escReady() { return es == E_READY; }
static void escOpenGate() { if (es == E_READY) { gateOpen(true); setEs(E_GATE_OPEN); } }
static void escBottleArrived() { if (es == E_GATE_OPEN) { gateOpen(false); setEs(E_CLOSE_GATE); } }

// Vereinzelung: Sperre A / Klemme B
static void escUpdate(uint32_t now) {
  switch (es) {
    case E_INIT_RELEASE: clampClose(false); gateOpen(false); if (now - esT > P.t_slide2) { clampClose(true); setEs(E_INIT_CLAMP); } break;
    case E_INIT_CLAMP:   if (now - esT > P.t_clamp) setEs(E_READY); break;
    case E_READY: case E_GATE_OPEN: break;
    case E_CLOSE_GATE:   if (now - esT > P.t_gate) { clampClose(false); setEs(E_RELEASE); } break;
    case E_RELEASE:      if (now - esT > P.t_slide2) { clampClose(true); setEs(E_RECLAMP); } break;
    case E_RECLAMP:      if (now - esT > P.t_clamp) setEs(E_READY); break;
  }
}

// Referenzfahrt: Rotor auf Hall-Fenster-Mitte, Hubantrieb nach unten
static void homingUpdate(uint32_t now) {
  switch (hs) {
    case H_START:
      gateOpen(false); clampClose(false); setEs(E_INIT_RELEASE);
      stRot->setCurrentPosition(0);
      if (inHallRot.active) { rotMoveTo(-40, P.rot_home_v, 2000); hs = H_LEAVE; }   // erst aus dem Fenster
      else { rotMoveTo(420, P.rot_home_v, 2000); hs = H_SEEK_ON; }
      hsT = now; break;
    case H_LEAVE:
      if (!inHallRot.active) { stRot->stopMove(); if (!rotBusy()) { rotMoveTo(rotAngle() + 420, P.rot_home_v, 2000); hs = H_SEEK_ON; } }
      else if (!rotBusy()) fault("Referenz Rotor: Hallsensor dauernd aktiv");
      break;
    case H_SEEK_ON:
      if (inHallRot.active) { homeA = rotAngle(); hs = H_SEEK_OFF; }
      else if (!rotBusy()) fault("Referenz Rotor: Hallsensor nicht gefunden");
      break;
    case H_SEEK_OFF:
      if (!inHallRot.active) {
        homeB = rotAngle(); stRot->stopMove();
        float center = 0.5f * (homeA + homeB);
        // neue Null = Mitte + Offset
        int32_t pos = stRot->getCurrentPosition();
        int32_t centerSteps = rotSteps(center + P.rot_home_ofs);
        stRot->setCurrentPosition(pos - centerSteps);
        hs = H_GOTO;
      } else if (!rotBusy()) fault("Referenz Rotor: Fenster nicht verlassen");
      break;
    case H_GOTO:
      if (!rotBusy()) { rotMoveTo(0, P.rot_home_v * 2, 4000); hs = H_FEED; hsT = now; }
      break;
    case H_FEED:
      if (rotBusy()) break;
      if (inHallFeed.active) { if (feedRunning) feedStopNow(); hs = H_DONE; break; }
      if (!feedRunning) {
        stFeed->setSpeedInHz((uint32_t)(10.0f / 60.0f * FEED_STEPS_PER_REV));
        stFeed->setAcceleration((int32_t)(FEED_STEPS_PER_REV)); stFeed->runForward(); feedRunning = true; hsT = now;
      }
      if (now - hsT > 15000) fault("Referenz Hubantrieb: Hallsensor nicht gefunden");
      break;
    case H_DONE:
      mode = M_IDLE; Serial.println("Referenz OK -> BEREIT (Start druecken)"); break;
  }
}

// Hubantrieb: laeuft solange Rinne nicht voll
static void feederUpdate(uint32_t now, bool want) {
  if (inHallFeed.takeRose()) feedLastEdge = now;
  if (feedRunning && now - feedLastEdge > (uint32_t)(2.5f * 60000.0f / max(P.feed_rpm, 5.0f)) && !feedStopReq)
    { fault("Hubantrieb blockiert (kein Hall-Impuls)"); return; }
  if (want && !feedRunning) feedStart();
  if (!want && feedRunning) feedStopAtBottom();
  if (feedStopReq && inHallFeed.active) feedStopNow();
}

// Haupt-Zyklus Wendetrommel
static void rotorUpdate(uint32_t now, bool running) {
  switch (rs) {
    case R_WAIT_READY:
      if (!running) break;
      if (rotBusy()) break;
      if (bPres.blocked) { fault("Rotor belegt in Ladestellung (Flasche haengt?)"); break; }
      if (escReady()) { escOpenGate(); warnEmpty = false; setRs(R_LOADING); }
      break;
    case R_LOADING:
      // Sperre sofort schliessen, sobald die Flasche die Praesenz-Schranke erreicht:
      // ihr Ende hat den Sperrstift dann bereits passiert (s = 30 - 102,5 = -72,5 > -73,5)
      if (bPres.blocked && es == E_GATE_OPEN) escBottleArrived();
      if (bPres.blockedFor(P.t_settle, now)) {
        orientN = orientBlocked = 0; retries = 0; setRs(R_MEASURE);
      } else if (now - rsT > P.t_load_to) {
        warnEmpty = true;
        if (!running) { gateOpen(false); setEs(E_READY); setRs(R_WAIT_READY); }   // Stop bei leerer Rinne
      }
      break;
    case R_MEASURE:
      orientN++; if (bOrient.blocked) orientBlocked++;
      if (now - rsT >= P.t_measure) {
        if (!bPres.blocked) { setRs(R_LOADING); break; }   // Flasche zurueckgeprallt
        float f = (float)orientBlocked / max<uint32_t>(orientN, 1);
        if (f > 0.85f)      { neckAtStop = false; setRs(R_WAIT_SHAFT); }
        else if (f < 0.15f) { neckAtStop = true;  setRs(R_WAIT_SHAFT); }
        else if (retries++ < P.max_retry) { rotMoveTo(-6, 300, 6000); setRs(R_WIGGLE); }
        else fault("Orientierung nicht eindeutig");
      }
      break;
    case R_WIGGLE: {       // -6 Grad und zurueck: Flasche setzt sich neu ins V
      static uint32_t backAt = 0;
      if (rotBusy()) { backAt = 0; break; }
      if (fabsf(rotAngle()) > 0.5f) { rotMoveTo(0, 300, 6000); break; }
      if (!backAt) backAt = now;
      if (now - backAt >= 40) { backAt = 0; orientN = orientBlocked = 0; setRs(R_MEASURE); }
      break;
    }
    case R_WAIT_SHAFT:
      if (bShaftA.freeFor(P.t_shaft_ok, now) && bShaftB.freeFor(P.t_shaft_ok, now) && !stau) {
        arrivalSeen = false;
        rotMoveTo(neckAtStop ? ANG_ENTRY_HOLD : ANG_DUMP_STOP);
        setRs(neckAtStop ? R_HOLD : R_DUMP);
      }
      break;
    case R_HOLD:          // Hals rutscht aus der Nut
      if (rotBusy()) { rsT = now; break; }
      if (now - rsT >= P.t_hold) { rotMoveTo(ANG_DUMP_ENTRY); setRs(R_DUMP); }
      break;
    case R_DUMP:
      if (bShaftA.blocked) arrivalSeen = true;
      if (!rotBusy()) setRs(R_DROP);
      break;
    case R_DROP:
      if (bShaftA.blocked) arrivalSeen = true;
      if (now - rsT >= P.t_drop) {
        float back = rotAngle();
        rotMoveTo(0);
        uint32_t dur = moveTimeMs(back);
        gateEarlyDone = false;
        gateEarlyAt = now + (dur > P.t_early ? dur - P.t_early : 0);
        cntTotal++; if (neckAtStop) cntNeck++; rateN++;
        setRs(R_RETURN);
      }
      break;
    case R_RETURN:
      if (bShaftA.blocked) arrivalSeen = true;
      if (!gateEarlyDone && running && now >= gateEarlyAt && escReady()) { escOpenGate(); gateEarlyDone = true; }
      if (!rotBusy()) {
        // Rueckfahrt dauert <= 160 ms, die naechste Flasche erreicht die Praesenz-Schranke fruehestens
        // ~350 ms nach Oeffnen der Sperre -> belegt heisst: alte Flasche haengt im Rotor
        if (bPres.blocked) { gateOpen(false); fault("Flasche haengt im Rotor"); break; }
        if (!arrivalSeen) { cntWarnArrive++; Serial.println("Warnung: Flasche im Schacht nicht erkannt"); }
        if (gateEarlyDone) setRs(R_LOADING); else setRs(R_WAIT_READY);
      }
      break;
  }
}

// ---------------------------------------------------------------------
// Parameter (Name -> Feld) + Speicherung
// ---------------------------------------------------------------------
struct PDesc { const char *n; char t; void *p; };
static PDesc PD[] = {
  {"rot_vmax",'f',&P.rot_vmax},{"rot_amax",'f',&P.rot_amax},{"rot_home_v",'f',&P.rot_home_v},
  {"rot_home_ofs",'f',&P.rot_home_ofs},{"rot_dir",'b',&P.rot_dir},
  {"t_settle",'u',&P.t_settle},{"t_measure",'u',&P.t_measure},{"t_hold",'u',&P.t_hold},{"t_drop",'u',&P.t_drop},
  {"t_early",'u',&P.t_early},{"t_load_to",'u',&P.t_load_to},{"t_gate",'u',&P.t_gate},{"t_clamp",'u',&P.t_clamp},
  {"t_slide2",'u',&P.t_slide2},{"t_shaft_ok",'u',&P.t_shaft_ok},{"t_arrive",'u',&P.t_arrive},
  {"t_stau_on",'u',&P.t_stau_on},{"t_stau_off",'u',&P.t_stau_off},{"t_full_on",'u',&P.t_full_on},{"t_full_off",'u',&P.t_full_off},
  {"feed_rpm",'f',&P.feed_rpm},{"feed_acc",'f',&P.feed_acc_rps2},
  {"thr_pres",'u',&P.thr_pres},{"thr_orient",'u',&P.thr_orient},{"thr_full",'u',&P.thr_full},
  {"thr_shaftA",'u',&P.thr_shaftA},{"thr_shaftB",'u',&P.thr_shaftB},{"max_retry",'c',&P.max_retry},
};
static void printParams() {
  for (auto &d : PD) {
    if (d.t == 'f') Serial.printf("  %-12s %.1f\n", d.n, *(float *)d.p);
    else if (d.t == 'u') Serial.printf("  %-12s %u\n", d.n, *(uint16_t *)d.p);
    else if (d.t == 'b') Serial.printf("  %-12s %d\n", d.n, *(int8_t *)d.p);
    else Serial.printf("  %-12s %u\n", d.n, *(uint8_t *)d.p);
  }
}
static bool setParam(const String &n, float v) {
  for (auto &d : PD) if (n == d.n) {
    if (d.t == 'f') *(float *)d.p = v; else if (d.t == 'u') *(uint16_t *)d.p = (uint16_t)v;
    else if (d.t == 'b') *(int8_t *)d.p = (int8_t)v; else *(uint8_t *)d.p = (uint8_t)v;
    return true;
  }
  return false;
}
static void saveParams() { prefs.putBytes("p", &P, sizeof(P)); Serial.println("gespeichert"); }
static void loadParams() { if (prefs.getBytesLength("p") == sizeof(P)) prefs.getBytes("p", &P, sizeof(P)); }

static void calibrate() {   // alle Strahlen frei! (Rotor, Rinne, Schacht leer)
  for (Beam *b : beams) {
    uint32_t s = 0; for (int i = 0; i < 200; i++) { s += analogRead(b->pin); delay(1); }
    uint16_t free = s / 200;
    *b->thr = free + (uint16_t)(0.4f * (4095 - free));
    Serial.printf("  %-9s frei=%4u -> Schwelle %4u\n", b->name, free, *b->thr);
  }
}

static void status() {
  static const char *MN[] = {"STOERUNG", "REFERENZ", "BEREIT", "BETRIEB", "STOPPT"};
  static const char *RN[] = {"warte", "laden", "messen", "wackeln", "warte_schacht", "abwurf", "halt58", "fall", "rueck"};
  Serial.printf("Modus %s | Rotor %s %.1f Grad | Vereinzelung %d | Hub %s | Rinne %s | Stau %s | %s\n",
    MN[mode], RN[rs], rotAngle(), es, feedRunning ? "laeuft" : "steht", gutterFull ? "voll" : "frei",
    stau ? "JA" : "nein", warnEmpty ? "Rinne leer" : "");
  Serial.printf("Flaschen %lu (davon Hals am Anschlag %lu), %.1f /min, Warn. Schacht %lu %s%s\n",
    (unsigned long)cntTotal, (unsigned long)cntNeck, rate, (unsigned long)cntWarnArrive,
    mode == M_FAULT ? "| Fehler: " : "", mode == M_FAULT ? faultMsg : "");
}
static void sensors() {
  for (Beam *b : beams) Serial.printf("  %-9s %4u (Schwelle %4u) %s\n", b->name, b->raw, *b->thr, b->blocked ? "BELEGT" : "frei");
  Serial.printf("  Hall Rotor %d  Hall Hub %d  Stau %d  Start %d  Stop(NC) %d  NotHalt-OK %d\n",
    inHallRot.active, inHallFeed.active, inStau.active, inStart.active, inStopNC.active, inEstopOk.active);
}
static void help() {
  Serial.println(
    "Befehle: status | sens | params | set <name> <wert> | save | cal | start | stop | reset | home\n"
    "         rot <grad> | gate 0/1 | clamp 0/1 | feed <U/min|0> | laser 0/1");
}
static void command(String l) {
  l.trim(); if (!l.length()) return;
  int sp = l.indexOf(' '); String c = sp < 0 ? l : l.substring(0, sp); String a = sp < 0 ? "" : l.substring(sp + 1);
  if (c == "help") help();
  else if (c == "status") status();
  else if (c == "sens") sensors();
  else if (c == "params") printParams();
  else if (c == "set") { int s2 = a.indexOf(' '); if (s2 > 0 && setParam(a.substring(0, s2), a.substring(s2 + 1).toFloat())) Serial.println("ok"); else Serial.println("?"); }
  else if (c == "save") saveParams();
  else if (c == "cal") { if (mode == M_IDLE || mode == M_FAULT) calibrate(); else Serial.println("nur im Stillstand"); }
  else if (c == "start") { if (mode == M_IDLE) { mode = M_RUN; rateT0 = millis(); rateN = 0; } }
  else if (c == "stop") { if (mode == M_RUN) mode = M_STOPPING; }
  else if (c == "reset" || c == "home") { digitalWrite(PIN_LAMP_FAULT, LOW); mode = M_HOMING; hs = H_START; setRs(R_WAIT_READY); }
  else if (mode != M_IDLE && mode != M_FAULT) Serial.println("Handbefehle nur im Stillstand");
  else if (c == "rot") rotMoveTo(a.toFloat(), 200, 3000);
  else if (c == "gate") gateOpen(a.toInt());
  else if (c == "clamp") clampClose(a.toInt());
  else if (c == "laser") digitalWrite(PIN_LASER, a.toInt() ? HIGH : LOW);
  else if (c == "feed") { float r = a.toFloat(); if (r > 0) { P.feed_rpm = r; feedStart(); } else feedStopNow(); }
  else help();
}

// ---------------------------------------------------------------------
void setup() {
  Serial.begin(115200);
  for (uint8_t p : {PIN_VALVE_GATE, PIN_VALVE_CLAMP, PIN_LAMP_FAULT, PIN_LED}) { pinMode(p, OUTPUT); digitalWrite(p, LOW); }
  pinMode(PIN_LASER, OUTPUT); digitalWrite(PIN_LASER, HIGH);
  for (uint8_t p : {PIN_HALL_ROT, PIN_HALL_FEED, PIN_STAU, PIN_BTN_START, PIN_BTN_STOP, PIN_ESTOP_FB}) pinMode(p, INPUT_PULLUP);
  analogReadResolution(12); analogSetAttenuation(ADC_11db);
  prefs.begin("unscr", false); loadParams();

  engine.init();
  stRot = engine.stepperConnectToPin(PIN_ROT_STEP);
  stFeed = engine.stepperConnectToPin(PIN_FEED_STEP);
  if (!stRot || !stFeed) { Serial.println("Stepper-Init fehlgeschlagen"); while (true) delay(1000); }
  stRot->setDirectionPin(PIN_ROT_DIR);   stRot->setEnablePin(PIN_ROT_EN);   stRot->setAutoEnable(false); stRot->enableOutputs();
  stFeed->setDirectionPin(PIN_FEED_DIR); stFeed->setEnablePin(PIN_FEED_EN); stFeed->setAutoEnable(false); stFeed->enableOutputs();
  Serial.println("\nFlaschen-Unscrambler K-3906.004  ('help' fuer Befehle)");
  delay(300);
}

void loop() {
  static uint32_t lastSample = 0, lastLed = 0;
  uint32_t now = millis();
  // Eingaenge (1 kHz)
  if (now != lastSample) {
    lastSample = now;
    for (Beam *b : beams) b->update(now);
    for (DigIn *d : {&inHallRot, &inHallFeed, &inStau, &inStart, &inStopNC, &inEstopOk}) d->update(now);
  }
  // Not-Halt / Stop
  if (!inEstopOk.active && now > 2000 && mode != M_FAULT) fault("NOT-HALT / Leistungskreis aus");
  if (!inStopNC.active && (mode == M_RUN)) mode = M_STOPPING;          // NC offen = Stop
  if (inStart.takeRose()) {
    if (mode == M_IDLE) { mode = M_RUN; rateT0 = now; rateN = 0; }
    else if (mode == M_FAULT && inEstopOk.active) { digitalWrite(PIN_LAMP_FAULT, LOW); mode = M_HOMING; hs = H_START; setRs(R_WAIT_READY); }
  }
  // Rinne voll / Stau mit Zeitfiltern
  if (!gutterFull && bFull.blockedFor(P.t_full_on, now)) gutterFull = true;
  if (gutterFull && bFull.freeFor(P.t_full_off, now)) gutterFull = false;
  if (!stau && inStau.activeFor(P.t_stau_on, now)) stau = true;
  if (stau && inStau.inactiveFor(P.t_stau_off, now)) stau = false;

  switch (mode) {
    case M_HOMING: homingUpdate(now); escUpdate(now); break;
    case M_RUN:
      escUpdate(now); rotorUpdate(now, true); feederUpdate(now, !gutterFull);
      break;
    case M_STOPPING:
      escUpdate(now); rotorUpdate(now, false); feederUpdate(now, false);
      if ((rs == R_WAIT_READY) && !rotBusy() && !feedRunning) { mode = M_IDLE; Serial.println("gestoppt"); }
      break;
    case M_IDLE: escUpdate(now); break;
    case M_FAULT: break;
  }

  // Leistung / LED
  if (now - rateT0 >= 60000 && mode == M_RUN) { rate = rateN * 60000.0f / (now - rateT0); rateT0 = now; rateN = 0; }
  if (now - lastLed > (mode == M_RUN ? 500u : 150u)) { lastLed = now; digitalWrite(PIN_LED, !digitalRead(PIN_LED)); }

  if (Serial.available()) command(Serial.readStringUntil('\n'));
}
