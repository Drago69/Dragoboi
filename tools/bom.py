#!/usr/bin/env python3
"""Stueckliste aus der Gesamtbaugruppe (ECHO "BOM;...") + Normteile/Elektrik.
Schreibt docs/stueckliste.md und docs/stueckliste.csv"""
import os, re, subprocess, csv, collections, math
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
r = subprocess.run(["openscad", "-o", "/dev/stdout", "--export-format", "echo", "-D", "SIMPLE=true",
                    os.path.join(ROOT, "cad", "assembly.scad")], capture_output=True, text=True)
lines = re.findall(r'"BOM;([^"]*)"', r.stdout + r.stderr)

profiles = collections.Counter(); other = collections.OrderedDict()
for l in lines:
    cat, name, size, qty = (l.split(";") + ["", "", "", "1"])[:4]
    qty = int(float(qty or 1))
    if cat == "Profil":
        L = float(size.replace(" mm", ""))
        profiles[(name, round(L, 1))] += qty
    else:
        key = (cat, name, size)
        other[key] = other.get(key, 0) + qty

# ---- Zuschnitt
def group_name(n):
    for k in ["Bein", "Grundtraeger", "Stationsquerholm", "MGN-Saeule", "Aussenstaender", "Bodentraeger",
              "Bodenstuetze", "Schlitten", "Bodenrahmen", "Modulstuetze", "Rotorsaeule", "Rotorarm",
              "Sensorausleger", "Strebe"]:
        if n.startswith(k): return k
    return n
cut = collections.Counter()
for (n, L), q in profiles.items():
    cut[(group_name(n) if not n.startswith("Bein") else n, L)] += q
total_len = sum(L*q for (n, L), q in cut.items())
bars = math.ceil(total_len*1.05/2000)

# ---- Normteile (Herleitung siehe Kommentar)
NM = [
 # Stufen
 ("M5x50 ISO 4762", 14, "Kappen M1..M7 an Beine (Stirnseite)"),
 ("M5x10 ISO 4762", 14, "Kappen F1..F6 + F0 an Beine"),
 ("M5x20 ISO 4762", 2,  "Trog an Beine (Vorderflaeche)"),
 ("Hammermutter M5 Nut 6", 30, "fuer die 30 Kappenschrauben"),
 # Profilverbindungen
 ("Winkel 20x20 Nut 6 (Druckguss) inkl. 2x M5x10 + 2x Hammermutter", 160,
  "Beine (30 Stk. x 2), Holme Schlitten (12), Grundtraeger/Querholme (24), Aussenstaender (22), "
  "MGN-Saeulen (4), Bodenrahmen (20), Stuetzen/Saeulen (14), Arm/Ausleger (4)"),
 ("Gelenkverbinder 20x20 Nut 6", 4, "Diagonalstreben Rotorsaeule"),
 ("M3x8 ISO 4762 + Hammermutter M3 Nut 6", 16, "MGN12-Schienen an Saeulen (Teilung 25 mm)"),
 ("M3x8 ISO 4762", 8, "MGN12H-Wagen an Schlittenadapter"),
 ("M5x12 ISO 4762 + Hammermutter M5", 4, "Schlittenadapter an Querholme"),
 ("M5x10 ISO 4762 + Hammermutter M5", 2, "Rollenhalter an Mittelholm"),
 ("M5x12 ISO 4762 + Hammermutter M5", 4, "Lagerbock + Motorbock seitlich am Grundtraeger"),
 ("M4x10 ISO 4762", 4, "Getriebeflansch an Motorbock"),
 ("M3x12 ISO 4762 + Mutter M3", 4, "Flanschkupplung an Nocke"),
 ("M5x20 ISO 4762 (in Profilkernloch, M5 schneiden)", 10, "Keile 28 (6) und 15 (4) senkrecht"),
 ("M5x12 ISO 4762 + Hammermutter M5", 20, "Keile an Traeger (2 je Keil)"),
 ("M5x10 ISO 4762 + Scheibe + Hammermutter", 48, "Seitenwaende/Rueckwand an Aussenstaender"),
 ("M5x12 ISO 10642 (Senkkopf) + Hammermutter", 10, "Bunkerboden an Bodentraeger"),
 ("M4x12 ISO 4762 + Mutter + Scheibe", 32, "Schuerzen-/Eckwinkel (8 Winkel x 4)"),
 # Rinne / Rotor
 ("Gewindeeinsatz M3 (z.B. Ruthex RX-M3x5,7)", 76,
  "Trogflansch 4, G2 8 (Flansch 4 + Konsole 4), Deckel 16, Gehaeuse 4 (Flansch) + 4 (Schacht) + 5 (Haelften) "
  "+ 8 (Sensoren), Rinne G1 4 (Sensor), Schacht 8 (Sensoren), Reserve 15"),
 ("M3x16 ISO 4762", 12, "Kanalstoesse Trog-G1, G1-G2, G2-Gehaeuse"),
 ("M3x8 ISO 4762", 32, "Deckel (12), Sensorhalter (20)"),
 ("M3x20 ISO 4762", 8, "Klemmbock (4), Motor Rotor (4)"),
 ("M3x10 ISO 4762", 8, "Sperrkonsole (4), Fallschacht (4)"),
 ("M3x35 ISO 4762", 5, "Gehaeusehaelften"),
 ("M3x40 ISO 4762 + Mutter M3", 4, "Rotorhaelften"),
 ("Madenschraube M3x6 ISO 4026 + Mutter M3", 1, "Rotornabe auf Motorwelle (Flat)"),
 ("Madenschraube M3x4", 10, "Sensorhalter Klemmung"),
 ("M5x12 ISO 4762 + Hammermutter M5", 2, "Gehaeuselasche an Rotorarm"),
 ("Mutter M4 (Stempel)", 1, "Klemmstempel auf Kolbenstange"),
]
EL = [
 ("ESP32 DevKitC V4 (38 Pin)", 1, "Steuerung"),
 ("Schrittmotortreiber TMC2209 (Modul, z.B. BTT V1.3)", 2, "Rotor + Hubantrieb"),
 ("Netzteil 24 V / 6,5 A (150 W, z.B. Mean Well LRS-150-24)", 1, ""),
 ("DC/DC-Wandler 24 V -> 5 V / 3 A", 1, "ESP32, Laser, Sensoren"),
 ("MOSFET-Modul 4-fach (z.B. IRLZ44N/AOD4184, Logic-Level) + Freilaufdioden", 1, "2 Ventile + Reserve"),
 ("Magnetventil 5/2 monostabil 24 VDC, M5 (z.B. Airtac 4V110-M5)", 2, "Sperre A, Klemme B"),
 ("Druckregler mit Manometer 0-4 bar, Wartungseinheit", 1, "Klemme B mit 1-2 bar"),
 ("Steckverschraubung M5 auf 4 mm + Drosselrueckschlag M5", 4, "Zylinderanschluesse"),
 ("PU-Schlauch 4 mm", 3, "m"),
 ("Not-Halt-Taster 1 Oeffner + Schuetz/Relais 24 V fuer Motor-/Ventilspannung", 1, ""),
 ("Taster Start (gruen) / Stop (rot), Leuchtmelder Stoerung (gelb)", 1, "Satz"),
 ("Kabel LiYY 4x0,25 (Sensoren), LiYY 4x0,5 (Motoren)", 1, "Satz"),
 ("Gehaeuse ABS ca. 200x150x75, Kabelverschraubungen M16", 1, ""),
]

rows = []
for (n, L), q in sorted(cut.items(), key=lambda x: (x[0][0], -x[0][1])):
    rows.append(("Profil 20x20 Nut 6 B-Typ (Zuschnitt)", f"{n}", f"{L} mm", q))
for (cat, n, s), q in other.items():
    rows.append((cat, n, s, q))
for n, q, w in NM: rows.append(("Normteil", n, w, q))
for n, q, w in EL: rows.append(("Elektrik/Pneumatik", n, w, q))

os.makedirs(os.path.join(ROOT, "docs"), exist_ok=True)
with open(os.path.join(ROOT, "docs", "stueckliste.csv"), "w", newline="") as f:
    w = csv.writer(f, delimiter=";"); w.writerow(["Kategorie", "Bezeichnung", "Groesse/Verwendung", "Anzahl"])
    w.writerows(rows)
with open(os.path.join(ROOT, "docs", "stueckliste.md"), "w") as f:
    f.write("# Stueckliste Flaschen-Unscrambler\n\n")
    f.write("Automatisch erzeugt aus `cad/assembly.scad` (`python3 tools/bom.py`). Profil- und Plattenmasse gelten fuer "
            f"`BELT_Z = {re.search(r'BELT_Z\s*=\s*(\d+)', open(os.path.join(ROOT,'cad','config.scad')).read()).group(1)} mm` "
            "(Band-Oberkante). Bei anderer Bandhoehe in `cad/config.scad` aendern und neu erzeugen.\n\n")
    f.write(f"**Profile gesamt: {total_len/1000:.1f} m 20x20 Nut 6 B-Typ** (entspricht ca. {bars} Stangen a 2 m inkl. 5 % Verschnitt; "
            "besser: Zuschnitt beim Haendler bestellen, Toleranz +-0,2 mm, Beine besonders genau).\n\n")
    cats = collections.OrderedDict()
    for r_ in rows: cats.setdefault(r_[0], []).append(r_)
    for c, rs in cats.items():
        f.write(f"## {c}\n\n| Bezeichnung | Groesse / Verwendung | Anzahl |\n|---|---|---|\n")
        for _, n, s, q in rs: f.write(f"| {n} | {s} | {q} |\n")
        f.write("\n")
print(f"{len(rows)} Positionen, Profile {total_len/1000:.1f} m")
for (n, L), q in sorted(cut.items()): print(f"  {n:28s} {L:7.1f} mm x {q}")
