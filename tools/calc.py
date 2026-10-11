#!/usr/bin/env python3
"""Auslegungsrechnung Flaschen-Unscrambler mit Hakenteller (liest Masse aus der CAD-Konfiguration).
Schreibt docs/auslegung.md (mit --write)."""
import os, re, subprocess, math, sys
import numpy as np
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
out = subprocess.run(["openscad", "-o", "/dev/stdout", "--export-format", "echo",
                      os.path.join(ROOT, "cad", "checks", "values.scad")], capture_output=True, text=True)
txt = out.stdout + out.stderr
line = re.search(r'VAL;([^"]+)', txt).group(1)
V = {k: float(v) for k, v in (p.split("=") for p in line.split(";") if "=" in p)}
g = 9.81
a = math.radians(V["ALPHA"]); ca, sa = math.cos(a), math.sin(a)
lines = []
def P(s=""): lines.append(s); print(s)

B_ENV = math.pi/4*30**2*102.5/1000   # cm3 Huellvolumen Flasche
PACK = 0.55                          # Schuettdichte bezogen auf Huellvolumen
M_B = 0.007                          # kg

# ------------------------------------------------------------------ Bunker (Volumen aus CAD)
def hopper_volume():
    os.makedirs(os.path.join(ROOT, "build"), exist_ok=True)
    stl = os.path.join(ROOT, "build", "hopper_fill.stl")
    subprocess.run(["openscad", "-o", stl, "-D", 'MODE="hopper_fill"', "-D", "SIMPLE=true",
                    os.path.join(ROOT, "cad", "checks", "function.scad")], capture_output=True, text=True)
    import trimesh
    return trimesh.load(stl).volume/1e6
vol = hopper_volume()
n_b = vol*1000*PACK/B_ENV
P("## Bunker")
P(f"- Trichter aus 5 Blechen auf dem Randring, Rand waagerecht bei Z = {V['Z_RIM']:.0f} mm (Band + {V['Z_RIM']-V['BELT_Z']:.0f})")
P(f"- Fuellraum bis zum Rand {vol:.1f} l  ->  ca. **{n_b:.0f} Flaschen** (Schuettdichte {PACK:.2f} bezogen auf das Huellvolumen {B_ENV:.1f} cm3), Masse ca. {n_b*M_B:.1f} kg")
P(f"- Hoeher geht nicht: der Auslauf (Kanal vom Teller zur Rinne) laeuft links ueber den Bunker; Abstand Fuellraum -> Auslauf ca. 8 mm (Pruefung 8)")
P(f"- Bei {60:.0f} Fl./min reicht eine Fuellung ca. {n_b/60:.1f} min; ein Karton (500 Stueck) wird in zwei Portionen nachgefuellt")

# ------------------------------------------------------------------ Rinne (90-Grad-V: Normalkraft sqrt(2)*m*g*cos)
P("\n## Rinne (90-Grad-V, Neigung %.0f Grad)" % V["ALPHA"])
def acc_v(mu): return g*(sa - math.sqrt(2)*mu*ca)
mu_max = sa/(math.sqrt(2)*ca)
P(f"- Im 90-Grad-V wirkt die Reibung beider Flanken: a = g (sin a - sqrt(2) mu cos a). Rutschen bis mu < {mu_max:.3f} "
  f"(Reibwinkel {math.degrees(math.atan(mu_max)):.1f} Grad). PE-HD auf PETG trocken: mu ca. 0,15-0,30")
for mu in (0.15, 0.20, 0.25, 0.30):
    acc = acc_v(mu)
    d1 = (V["S_STOP"] - 0.4) - V["S_X2_FRONT"]
    t1 = math.sqrt(2*d1/1000/acc); t2 = math.sqrt(2*0.1025/acc)
    P(f"- mu={mu:.2f}: a={acc:.2f} m/s2, Sperre->Anschlag {d1:.0f} mm in {t1*1000:.0f} ms, Nachrutschen 102,5 mm in {t2*1000:.0f} ms")

# ------------------------------------------------------------------ Rotor-Takt
MU = 0.20
P(f"\n## Takt (Modell der Firmware-Ablaufsteuerung, mu = {MU:.2f})")
acc = acc_v(MU)
d_slide = (V["S_STOP"] - 0.4) - V["S_X2_FRONT"]
t_slide = math.sqrt(2*d_slide/1000/acc)
t_q     = math.sqrt(2*0.1025/acc)
def move_time(deg, vmax=1440.0, amax=20000.0):
    d_acc = vmax**2/amax
    return 2*math.sqrt(deg/amax) if deg < d_acc else 2*vmax/amax + (deg - d_acc)/vmax
T = dict(valve=0.03, settle=0.06, measure=0.02, hold=0.10, drop=0.16, early=0.12, gate=0.06, slide2=0.38, clamp=0.06)
T["slide2"] = max(T["slide2"], t_q + 0.05)
esc_ready = T["gate"] + T["slide2"] + T["clamp"]
def cycle(neck):
    dump = move_time(58) + T["hold"] + move_time(60) if neck else move_time(62)
    ret  = move_time(118 if neck else 62)
    rot_gate = T["settle"] + T["measure"] + dump + T["drop"] + max(ret - T["early"], 0)
    gate_at  = max(rot_gate, esc_ready)
    return gate_at + T["valve"] + t_slide, rot_gate, esc_ready
c_stop, r1, e1 = cycle(False); c_neck, r2, e2 = cycle(True)
c_mean = (c_stop + c_neck)/2
P(f"- Einrutschen Sperre->Anschlag {t_slide*1000:.0f} ms, Nachrutschen Warteschlange {t_q*1000:.0f} ms (Firmware t_slide2 = {T['slide2']*1000:.0f} ms)")
P(f"- Boden am Anschlag: Rotor gibt Sperre frei nach {r1*1000:.0f} ms, Vereinzelung bereit nach {e1*1000:.0f} ms -> Takt {c_stop*1000:.0f} ms")
P(f"- Hals am Anschlag : Rotor gibt Sperre frei nach {r2*1000:.0f} ms, Vereinzelung bereit nach {e2*1000:.0f} ms -> Takt {c_neck*1000:.0f} ms")
P(f"- Mittel (50/50) {c_mean*1000:.0f} ms  ->  ca. **{60/c_mean:.0f} Flaschen/min** Dauerleistung (Ziel 30-60)")
P(f"- Begrenzend ist die Vereinzelung (Nachrutschen); t_slide2 bei der Inbetriebnahme so kurz wie sicher einstellen.")

# ------------------------------------------------------------------ Fall
h_fall = (V["ROT_Z"] - 59) - V["BELT_Z"]
P("\n## Fall in den Schacht")
P(f"- Fallhoehe max. {h_fall:.0f} mm, Auftreffgeschwindigkeit {math.sqrt(2*g*h_fall/1000):.2f} m/s, Fallzeit {math.sqrt(2*h_fall/1000/g)*1000:.0f} ms")

# ------------------------------------------------------------------ Hakenteller
P("\n## Hakenteller")
R, RB, N, RPM = V["TD_R"], V["TD_RB"], int(V["TD_N"]), V["TD_RPM"]
incl = math.radians(V["TD_INCL"])
v_rim = 2*math.pi*RB/1000*RPM/60
pockets = N*RPM
P(f"- Teller D{2*R:.0f}, Neigung {V['TD_INCL']:.1f} Grad, {N} Haken, {RPM:.0f} U/min -> Taschengeschwindigkeit {v_rim:.2f} m/s, "
  f"{pockets:.0f} Taschen/min. Fuer {60/c_mean:.0f} Fl./min muessen nur {60/c_mean/pockets*100:.0f} % der Taschen gefuellt sein")
P(f"- Uebergabe T liegt {abs(V['TD_TOP_ANG']):.1f} Grad hinter dem hoechsten Punkt; dort zeigt die Flaschenachse genau in Rinnenrichtung (28 Grad Gefaelle)")
# Vorrutschen in der Tasche vor T
g_ip = math.sin(incl); g_n = math.cos(incl)
bot = math.radians(180 + V["TD_TOP_ANG"])     # tiefster Punkt (TD)
def slide_start(mu):
    for phi in np.arange(-60, 0.01, 0.1):
        p = math.radians(phi)
        gt = g_ip*math.cos(bot - p - math.pi/2)
        gr = -g_ip*math.cos(bot - p)
        if gt > mu*(g_n + gr): return phi
    return None
P("- Die Flasche beginnt in der Tasche vor T nach vorn zu rutschen (Leiste + Tellerflaeche reiben):")
for mu in (0.15, 0.20, 0.25, 0.30):
    s0 = slide_start(mu)
    P(f"  - mu={mu:.2f}: ab {s0:.0f} Grad vor T" if s0 is not None else f"  - mu={mu:.2f}: erst in T, der Mitnehmer schiebt sie in die Rinne")
P("  Der Einlauf ist dafuer aufgeweitet (Pruefung 7: Vorrutschen bis 32 mm frei). Den Weg nach vorn begrenzt der vorauslaufende Mitnehmer.")
# Hakenfreigang zur Warteschlange
sweep = math.sqrt(V["HK_PR"]**2 - V["TD_RL"]**2)
x5_rear = V["S_X2_FRONT"] - 4*102.5
P(f"- Mitnehmer (Aussenkante r = {V['HK_PR']:.1f}) streicht bis s = {V['S_T'] + sweep:.0f} durch die Rinne; "
  f"die hinterste ruhende Flasche X5 endet bei s = {x5_rear:.1f} (mit +1 mm je Flasche {x5_rear - 4:.1f}) -> frei")
# Stoppzeit bei "Rinne voll"
P("- Abschalten bei 'Rinne voll' (X4 liegt an der Lichtschranke): die naechste Tasche darf nicht mehr uebergeben.")
dt_p = 60/pockets
for mu in (0.15, 0.20, 0.25):
    acc_ = acc_v(mu); d = (V["S_CLAMP"] - 102.5) - V["S_T"]
    # Zeit T -> Ruhelage X4 (Startgeschwindigkeit = Taschengeschwindigkeit)
    t4 = (-v_rim + math.sqrt(v_rim**2 + 2*acc_*d/1000))/acc_
    budget = 2*dt_p - t4
    P(f"  - mu={mu:.2f}: X4 braucht {t4*1000:.0f} ms von T; X6 kaeme {2*dt_p*1000:.0f} ms nach X4 -> Teller muss {budget*1000:.0f} ms nach 'voll' stehen")
P("  Firmware: t_full_on = 120 ms (Entprellung, eine vorbeirutschende Flasche verdeckt die Schranke ca. 80 ms), Bremsrampe < 60 ms.")
P("  Kommt doch eine Flasche zu viel, laeuft der Mitnehmer gegen sie: Motor blockiert (max. ca. 13 N an der Flasche), "
  "die Firmware erkennt das am fehlenden Hall-Takt, haelt an und faehrt erst bei freier Rinne wieder an.")
# Moment
m_pile_on_disc = 0.5*n_b*M_B
T_lift = 3*M_B*g*g_ip*RB/1000
T_fric = 0.30*m_pile_on_disc*g*g_n*0.17
T_hooks = 3*2.0*0.21
T_tot = T_lift + T_fric + T_hooks + 0.2
P(f"- Moment (Abschaetzung): Heben 3 Flaschen {T_lift:.2f} Nm + Reibung Schuettgut ({m_pile_on_disc:.1f} kg auf dem Teller, mu 0,3) {T_fric:.2f} Nm "
  f"+ Haken im Schuettgut (3 x 2 N) {T_hooks:.2f} Nm + Ring/Abstreifer 0,2 Nm = **{T_tot:.1f} Nm**")
P(f"- Antrieb NEMA17 + Planetengetriebe 13,73:1: {RPM*13.73:.0f} U/min am Motor, ca. 0,35 Nm x 13,73 x 0,8 = 3,8 Nm, Getriebe zul. ca. 3 Nm "
  f"-> Reserve {3/T_tot:.1f}")

if "--write" in sys.argv:
    with open(os.path.join(ROOT, "docs", "auslegung.md"), "w") as f:
        f.write("# Auslegungsrechnung (automatisch aus der CAD-Konfiguration)\n\n")
        f.write("Erzeugt mit `python3 tools/calc.py --write`. Annahmen siehe Quelltext.\n\n")
        f.write("\n".join(lines) + "\n")
