// =====================================================================
//  Flaschen-Unscrambler  --  Pinbelegung und Standardparameter
//  ESP32 DevKitC (38 Pin).  Alle Zeiten in ms, Winkel in Grad.
// =====================================================================
#pragma once
#include <Arduino.h>

// ---------------- Pins ------------------------------------------------
// Schrittmotor Wendetrommel (TMC2209 #1, standalone, MS1/MS2 -> 1/16)
constexpr uint8_t PIN_ROT_STEP   = 25;
constexpr uint8_t PIN_ROT_DIR    = 26;
constexpr uint8_t PIN_ROT_EN     = 27;   // LOW = aktiv
// Schrittmotor Hubantrieb (TMC2209 #2, 1/16)
constexpr uint8_t PIN_FEED_STEP  = 18;
constexpr uint8_t PIN_FEED_DIR   = 19;
constexpr uint8_t PIN_FEED_EN    = 21;
// Ventile / Ausgaenge (Logic-Level-MOSFET, HIGH = an)
constexpr uint8_t PIN_VALVE_GATE = 16;   // Sperre A: bestromt = Stift EINGEFAHREN (offen)
constexpr uint8_t PIN_VALVE_CLAMP= 17;   // Klemme B: bestromt = Klemme ZU
constexpr uint8_t PIN_LASER      = 15;   // Laser-Versorgung (5 V ueber MOSFET)
constexpr uint8_t PIN_LAMP_FAULT = 33;   // Stoerleuchte gelb
constexpr uint8_t PIN_LED        = 2;    // Onboard-LED: Betrieb
// Lichtschranken-Empfaenger (Fototransistor, Kollektor -> 10k -> 3,3 V, Emitter -> GND)
// ADC1-Kanaele; frei = Licht = niedrige Spannung, belegt = hoch
constexpr uint8_t PIN_PT_PRES    = 36;   // Rotor: Praesenz
constexpr uint8_t PIN_PT_ORIENT  = 39;   // Rotor: Orientierung (belegt = Boden am Anschlag)
constexpr uint8_t PIN_PT_FULL    = 34;   // Rinne G1 voll
constexpr uint8_t PIN_PT_SHAFT_A = 35;   // Fallschacht X=+3
constexpr uint8_t PIN_PT_SHAFT_B = 32;   // Fallschacht X=+22
// Digitale Eingaenge (aktiv LOW, interne Pull-ups + extern 4k7 an 3,3 V)
constexpr uint8_t PIN_HALL_ROT   = 13;   // A3144 Rotor-Referenz (Ladestellung)
constexpr uint8_t PIN_HALL_FEED  = 14;   // A3144 Schlitten unten
constexpr uint8_t PIN_STAU       = 4;    // E18-D80NK (NPN) Band-Stau: LOW = Flasche erkannt
constexpr uint8_t PIN_BTN_START  = 22;   // Schliesser (NO) nach GND: LOW = gedrueckt
constexpr uint8_t PIN_BTN_STOP   = 23;   // Oeffner (NC) nach GND: HIGH = Stop gedrueckt oder Drahtbruch
constexpr uint8_t PIN_ESTOP_FB   = 5;    // Rueckmeldung Not-Halt-Kreis: LOW = Kreis geschlossen (OK)

// ---------------- Mechanik --------------------------------------------
constexpr float ROT_STEPS_PER_DEG  = 200.0f * 16.0f / 360.0f;            // direkt, 1/16
constexpr float FEED_STEPS_PER_REV = 200.0f * 16.0f * 13.73f;            // Getriebe 13,73:1, Nockenwelle

// Winkel relativ zur Ladestellung (aus CAD: ROT_DUMP_STOP / ROT_DUMP_ENTRY)
constexpr float ANG_DUMP_STOP  = -62.0f;   // Boden am Anschlag -> Anschlagende nach unten
constexpr float ANG_DUMP_ENTRY = 118.0f;   // Hals am Anschlag  -> Einlaufende nach unten
constexpr float ANG_ENTRY_HOLD = 58.0f;    // Haltepunkt: Hals rutscht aus der Nut (muss < 84 Grad sein)

// ---------------- Einstellbare Parameter (Standard) --------------------
struct Params {
  // Rotor
  float rot_vmax      = 1440;   // Grad/s
  float rot_amax      = 20000;  // Grad/s^2
  float rot_home_v    = 90;     // Grad/s Referenzfahrt
  float rot_home_ofs  = 0;      // Grad: Ladestellung relativ zur Mitte des Hall-Fensters
  int8_t rot_dir      = 1;      // +1/-1: Drehsinn anpassen (Inbetriebnahme)
  // Zeiten
  uint16_t t_settle   = 60;     // Flasche am Anschlag beruhigen
  uint16_t t_measure  = 20;     // Mittelung Orientierung
  uint16_t t_hold     = 100;    // Halt bei +58 Grad (Hals rutscht aus Nut)
  uint16_t t_drop     = 160;    // Flasche faellt aus dem Rotor
  uint16_t t_early    = 120;    // Sperre oeffnet so viel vor Erreichen der Ladestellung
  uint16_t t_load_to  = 1500;   // keine Flasche -> "Rinne leer" (Warnung)
  uint16_t t_gate     = 60;     // Schaltzeit Zylinder A
  uint16_t t_clamp    = 60;     // Schaltzeit Zylinder B
  uint16_t t_slide2   = 380;    // Nachrutschen X3 -> Sperre
  uint16_t t_shaft_ok = 60;     // Schacht muss so lange frei sein
  uint16_t t_arrive   = 450;    // (Reserve) Flasche muss im Schacht erkannt werden
  uint16_t t_stau_on  = 1500;   // Band-Stau erkannt nach
  uint16_t t_stau_off = 800;
  uint16_t t_full_on  = 900;    // Rinne voll (Lichtschranke dauernd belegt)
  uint16_t t_full_off = 400;
  // Hubantrieb
  float feed_rpm      = 40;     // Nockenwelle U/min (30..60)
  float feed_acc_rps2 = 2.0;    // Hochlauf Nockenwelle U/s^2
  // Lichtschranken: Schwellwerte ADC (0..4095), belegt wenn > thr
  uint16_t thr_pres   = 2000;
  uint16_t thr_orient = 2000;
  uint16_t thr_full   = 2000;
  uint16_t thr_shaftA = 2000;
  uint16_t thr_shaftB = 2000;
  uint8_t  max_retry  = 2;      // Nachmessen bei unklarer Orientierung
};
