#!/usr/bin/env python3
"""Auslegungsrechnung Flaschen-Unscrambler (liest Masse aus der CAD-Konfiguration).
Schreibt docs/auslegung.md."""
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

# ------------------------------------------------------------------ Bunker
def z_rim(y, Zrim): return V["ZT"] + (Zrim - V["ROT_Z"] + (y + V["C_S"])*sa)/ca
def hopper_volume(Zrim=V["Z_RIM"], xback=V["X_BACK"], slope=V["FLOOR_SLOPE"]):
    xs = np.linspace(xback, V["APRON_X"], 600); ys = np.linspace(-V["SIDE_IN"], V["SIDE_IN"], 200)
    X, Y = np.meshgrid(xs, ys)
    floor = np.where(X < -0.75, -X*math.tan(math.radians(slope)),
                     np.floor(np.maximum(X, 0)/(2*V["ST_P"]))*V["ST_H"])     # Treppe grob (untere Lage)
    h = np.clip(z_rim(Y, Zrim) - floor, 0, None)
    return h.mean()*(xs[-1]-xs[0])*(ys[-1]-ys[0])/1e6   # Liter
B_ENV = math.pi/4*30**2*102.5/1000   # cm3 Huellvolumen Flasche
PACK = 0.55
vol = hopper_volume()
P("## Bunker")
P(f"- Bunkerrand waagerecht bei Z = {V['Z_RIM']:.0f} mm (Band OK {V['BELT_Z']:.0f} mm + {V['Z_RIM']-V['BELT_Z']:.0f})")
P(f"- Nutzvolumen ca. {vol:.1f} l  ->  ca. {vol*1000*PACK/B_ENV:.0f} Flaschen (Schuettdichte {PACK:.2f} bezogen auf Huellvolumen {B_ENV:.1f} cm3)")

# ------------------------------------------------------------------ Rutschen
P("\n## Rinne (Neigung %.0f Grad)" % V["ALPHA"])
for mu in (0.20, 0.25, 0.35):
    acc = g*(math.sin(a) - mu*math.cos(a))
    d1 = (V["S_STOP"] - 0.4) - V["S_X2_FRONT"]           # Sperre -> Anschlag (Front)
    t1 = math.sqrt(2*d1/1000/acc); t2 = math.sqrt(2*0.1025/acc)
    P(f"- mu={mu:.2f}: a={acc:.2f} m/s2, Sperre->Anschlag {d1:.0f} mm in {t1*1000:.0f} ms, Nachrutschen 102,5 mm in {t2*1000:.0f} ms")
P(f"- Reibwinkel PETG/HDPE ca. 11-19 Grad -> Neigung {V['ALPHA']:.0f} Grad hat Reserve")

# ------------------------------------------------------------------ Rotor-Takt
P("\n## Takt (Modell der Firmware-Ablaufsteuerung)")
acc = g*(math.sin(a) - 0.25*math.cos(a))
d_slide = (V["S_STOP"] - 0.4) - V["S_X2_FRONT"]
t_slide = math.sqrt(2*d_slide/1000/acc)                 # Sperre -> Anschlag
t_q     = math.sqrt(2*0.1025/acc)                       # Warteschlange rutscht 102,5 mm nach
def move_time(deg, vmax=1440.0, amax=20000.0):
    d_acc = vmax**2/amax
    return 2*math.sqrt(deg/amax) if deg < d_acc else 2*vmax/amax + (deg - d_acc)/vmax
# Firmware-Standardwerte (firmware/unscrambler/config.h)
T = dict(valve=0.03, settle=0.06, measure=0.02, hold=0.10, drop=0.16, early=0.12, gate=0.06, slide2=0.38, clamp=0.06)
esc_ready = T["gate"] + T["slide2"] + T["clamp"]        # ab Ankunft (Praesenz) bis Vereinzelung bereit
def cycle(neck):
    dump = move_time(58) + T["hold"] + move_time(60) if neck else move_time(62)
    ret  = move_time(118 if neck else 62)
    rot_gate = T["settle"] + T["measure"] + dump + T["drop"] + max(ret - T["early"], 0)   # Rotor erlaubt Sperre
    gate_at  = max(rot_gate, esc_ready)
    return gate_at + T["valve"] + t_slide, rot_gate, esc_ready
c_stop, r1, e1 = cycle(False); c_neck, r2, e2 = cycle(True)
c_mean = (c_stop + c_neck)/2
P(f"- Einrutschen Sperre->Anschlag {t_slide*1000:.0f} ms (mu 0,25), Nachrutschen Warteschlange {t_q*1000:.0f} ms (Firmware: 380 ms)")
P(f"- Boden am Anschlag: Rotor gibt Sperre frei nach {r1*1000:.0f} ms, Vereinzelung bereit nach {e1*1000:.0f} ms -> Takt {c_stop*1000:.0f} ms")
P(f"- Hals am Anschlag : Rotor gibt Sperre frei nach {r2*1000:.0f} ms, Vereinzelung bereit nach {e2*1000:.0f} ms -> Takt {c_neck*1000:.0f} ms")
P(f"- Mittel (50/50) {c_mean*1000:.0f} ms  ->  ca. {60/c_mean:.0f} Flaschen/min Dauerleistung (Ziel 30-60)")
P(f"- Begrenzend ist die Vereinzelung (Nachrutschen). Mehr Leistung: Rinne steiler (ALPHA) oder t_slide2 per Inbetriebnahme kuerzen.")

# ------------------------------------------------------------------ Fall
h_fall = (V["ROT_Z"] - 59) - V["BELT_Z"]
P("\n## Fall in den Schacht")
P(f"- Fallhoehe max. {h_fall:.0f} mm, Auftreffgeschwindigkeit {math.sqrt(2*g*h_fall/1000):.2f} m/s, Fallzeit {math.sqrt(2*h_fall/1000/g)*1000:.0f} ms")

# ------------------------------------------------------------------ Nocke / Antrieb
P("\n## Hubantrieb (Exzenter, Rolle, Schwerkraftrueckstellung)")
E, R, r = V["CAM_E"], V["CAM_R"], V["ROLL_R"]
phi = np.radians(np.linspace(0, 360, 3601))
h = E*np.cos(phi) + np.sqrt((R+r)**2 - (E*np.sin(phi))**2)
dh = np.gradient(h, phi)            # mm/rad
d2h = np.gradient(dh, phi)
m_car = 5.0                         # kg (Kappen ~1,9 kg, Beine/Holme ~2 kg, Adapter, Flaschen)
F_static = m_car*g*ca*1.15          # +15 % Reibung Fuehrung
press = np.degrees(np.arctan(np.abs(dh)/np.sqrt(np.maximum((R+r)**2 - (E*np.sin(phi))**2, 1))))
for rpm in (30, 45, 60):
    w = rpm*2*math.pi/60
    acc_lift = d2h/1000*w**2        # m/s2
    T = (F_static + m_car*acc_lift)*dh/1000            # Nm an Nockenwelle
    lift_off = (g*ca + acc_lift.min() < 0)
    I_GB = 13.73
    P(f"- {rpm} U/min: Hubfrequenz {rpm/60:.2f} Hz, Nockenwellenmoment max {T.max():.2f} Nm "
      f"-> Motor (Getriebe i={I_GB}, eta 0,8) {T.max()/I_GB/0.8:.2f} Nm bei {rpm*I_GB:.0f} U/min; Abheben der Rolle: {'JA' if lift_off else 'nein'} "
      f"(min. Beschl. {acc_lift.min():.2f} m/s2 vs. g*cos = {g*ca:.2f})")
P(f"- Hub {h.max()-h.min():.1f} mm, max. Druckwinkel {press.max():.1f} Grad")
P(f"- Stufenhoehe {V['ST_H']:.1f} mm x {V['ST_N']:.0f} Stufen = Foerderhoehe {V['ST_H']*V['ST_N']:.0f} mm (lokal)")
P(f"- Foerdermenge: je Hub 0..2 Flaschen (Stufe {V['ST_L']:.0f} mm = 2,3 Flaschenlaengen). "
  f"Bei 1,5 Fl./Hub: 60 Fl/min ab {60/1.5:.0f} Huebe/min = {60/1.5:.0f} U/min Nockenwelle")
P("- Motor NEMA17 1,7 A an 24 V liefert bei 400-600 U/min ca. 0,30-0,38 Nm -> Reserve ca. 1,5")

# ------------------------------------------------------------------ Varianten Bunker
P("\n## Bunkergroesse (Varianten)")
P("| Rand Z ueber Band | Rueckwand x | Bodengefaelle | Volumen | Flaschen |")
P("|---|---|---|---|---|")
for dz in (300, 350, 400):
    for xb in (-650, -750):
        for sl in (15, 10):
            v = hopper_volume(V["BELT_Z"] + dz, xb, sl)
            P(f"| +{dz} | {xb} | {sl} Grad | {v:.1f} l | {v*1000*PACK/B_ENV:.0f} |")

if "--write" in sys.argv:
    with open(os.path.join(ROOT, "docs", "auslegung.md"), "w") as f:
        f.write("# Auslegungsrechnung (automatisch aus der CAD-Konfiguration)\n\n")
        f.write("Erzeugt mit `python3 tools/calc.py --write`. Annahmen siehe Quelltext.\n\n")
        f.write("\n".join(lines) + "\n")
