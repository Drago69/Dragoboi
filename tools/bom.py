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
    for k in ["Tellerrahmen", "Querholm", "Stuetze", "Bunker-Frontholm", "Bodenrahmen", "Rotorsaeule",
              "Rotorarm", "Sensorausleger", "Strebe"]:
        if n.startswith(k): return n
    return n
cut = collections.Counter()
for (n, L), q in profiles.items():
    cut[(group_name(n), L)] += q
total_len = sum(L*q for (n, L), q in cut.items())
bars = math.ceil(total_len*1.05/2000)

# ---- Normteile (Herleitung siehe Verwendung)
NM = [
 # Hakenteller
 ("Senkschraube M4x16 ISO 10642", 20, "Haken: von hinten durch die Tellerplatte in den Einsatz"),
 ("Senkschraube M5x40 ISO 10642 + Mutter M5", 4, "Nabe: von vorn durch Teller + Nabe, Mutter in der Nabe"),
 ("Schraube M4x16 ISO 4762 + Mutter M4", 1, "Nabe: Klemmung auf der Wellenabflachung (Kopf frei im Senkloch)"),
 ("Gewindeeinsatz M4 (z.B. Ruthex RX-M4x8,1)", 45,
  "Haken 20, Randring 12, Uebergabe 3, Abstreifer 4, Bodenauflage 2, Reserve 4"),
 ("Schraube M5x12 ISO 4762 + Hammermutter M5 Nut 6", 4, "Lagerbock an die Querholme"),
 ("Schraube M4x10 ISO 4762", 4, "Getriebeflansch an Lagerbock (Laenge am Motor pruefen)"),
 ("Schraube M5x10 ISO 4762 + Scheibe + Hammermutter M5", 17, "Rueckwand an Tellerrahmen"),
 ("Senkschraube M4x10 ISO 10642", 19, "von hinten durch die Rueckwand: Randring 12, Uebergabe 3, Abstreifer 4"),
 ("Schraube M4x90 ISO 4762 + Mutter + 2 Scheiben", 4, "Haube mit Distanzrohr an Rueckwand"),
 ("Senkschraube M4x16 ISO 10642 + Mutter M4", 16, "Kantenwinkel (8 Stueck) an den Bunkerblechen"),
 ("Senkschraube M4x12 ISO 10642", 2, "Bunkerboden auf Bodenauflage"),
 ("Schraube M5x12 ISO 4762 + Hammermutter M5", 4, "Bodenauflage auf Bunker-Frontholm"),
 ("Schraube M5x20 ISO 4762 (in Profilkernloch, M5 schneiden)", 4, "Keile auf Stuetzen"),
 ("Schraube M5x12 ISO 4762 + Hammermutter M5", 8, "Keile an Tellerrahmen (2 je Keil)"),
 # Profilverbindungen
 ("Winkel 20x20 Nut 6 (Druckguss) inkl. 2x M5x10 + 2x Hammermutter", 52,
  "Tellerrahmen 8, Querholme 4, Bodenrahmen 16, Stuetzen 12, Frontholm 2, Rotorsaeule/Arm/Ausleger 6, Reserve 4"),
 ("Gelenkverbinder 20x20 Nut 6", 4, "Diagonalstreben Rotorsaeule"),
 # Rinne / Rotor
 ("Gewindeeinsatz M3 (z.B. Ruthex RX-M3x5,7)", 76,
  "Auslauf 8 (Flansche) + 4 (Deckel), G2 8 (Flansch 4 + Konsole 4), Deckel G1/G2 16, Gehaeuse 4 (Flansch) + 4 (Schacht) + 5 (Haelften) "
  "+ 8 (Sensoren), Rinne G1 4 (Sensor), Schacht 8 (Sensoren), Reserve 3"),
 ("M3x16 ISO 4762", 15, "Kanalstoesse Uebergabe-Auslauf (3), Auslauf-G1, G1-G2, G2-Gehaeuse (je 4)"),
 ("M3x8 ISO 4762", 36, "Deckel (16), Sensorhalter (20)"),
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
 ("Schrittmotortreiber TMC2209 (Modul, z.B. BTT V1.3)", 2, "Rotor + Tellerantrieb"),
 ("Netzteil 24 V / 6,5 A (150 W, z.B. Mean Well LRS-150-24)", 1, ""),
 ("DC/DC-Wandler 24 V -> 5 V / 3 A", 1, "ESP32, Laser, Sensoren"),
 ("MOSFET-Modul 4-fach (z.B. IRLZ44N/AOD4184, Logic-Level) + Freilaufdioden", 1, "2 Ventile + Laser + Leuchte"),
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
