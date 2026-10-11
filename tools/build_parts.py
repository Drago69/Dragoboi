#!/usr/bin/env python3
"""Exportiert alle Druckteile (cad/print.scad) als STL in stl/, legt sie aufs Bett,
prueft: wasserdicht, ein Koerper, passt in Bauraum (Standard 256x256x256, Rand 3 mm),
und schreibt docs/druckteile.csv (Masse, Volumen, Gewicht PETG)."""
import os, re, sys, subprocess, csv, threading
from concurrent.futures import ThreadPoolExecutor
import numpy as np, trimesh
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CAD = os.path.join(ROOT, "cad"); STL = os.path.join(ROOT, "stl"); os.makedirs(STL, exist_ok=True)
BED = float(os.environ.get("BED", 256)); MARGIN = 3
src = open(os.path.join(CAD, "print.scad")).read()
parts = re.findall(r'\[\s*"([A-Za-z0-9_]+)",\s*(\d+),\s*"([^"]*)",\s*"([^"]*)"\s*\]', src)
DENS = {"PETG": 1.27, "PETG schwarz": 1.27, "TPU 95A": 1.21}

def build(p):
    name = p[0]; out = os.path.join(STL, name + ".stl"); tmp = out + ".tmp.stl"
    r = subprocess.run(["openscad", "-D", f'PART="{name}"', "-o", tmp, os.path.join(CAD, "print.scad")],
                       capture_output=True, text=True, timeout=3600)
    if r.returncode != 0 or not os.path.exists(tmp):
        return name, None, r.stderr[-800:]
    m = trimesh.load(tmp); os.remove(tmp)
    b = m.bounds; m.apply_translation([-(b[0][0]+b[1][0])/2, -(b[0][1]+b[1][1])/2, -b[0][2]])
    m.export(out)
    return name, m, r.stderr

rows = []; ok = True
with ThreadPoolExecutor(max_workers=os.cpu_count() or 4) as ex:
    for (name, qty, mat, note), (n2, m, err) in zip(parts, ex.map(build, parts)):
        if m is None:
            print(f"FEHLER {name}: {err}"); ok = False; continue
        ext = m.extents
        bodies = len(m.split(only_watertight=False))
        fits = sorted(ext[:2])[1] <= BED - 2*MARGIN and sorted(ext[:2])[0] <= BED - 2*MARGIN and ext[2] <= BED - MARGIN
        # diagonal moeglich?
        diag = (ext[0] + ext[1]) / np.sqrt(2) <= BED - 2*MARGIN
        warn = [w for w in re.findall(r"WARNING: .*", err) if "Viewall" not in w]
        good = m.is_watertight and bodies == 1 and fits and not warn
        ok &= good
        # Masse: Huelle (Flaeche x 1.6 mm = 4 Waende/Lagen) + 15 % Fuellung im Inneren
        shell = min(m.area * 1.6, m.volume); g = (shell + 0.15*(m.volume - shell))/1000 * DENS.get(mat, 1.27)
        rows.append([name, qty, mat, f"{ext[0]:.1f}", f"{ext[1]:.1f}", f"{ext[2]:.1f}", f"{m.volume/1000:.1f}", f"{g:.0f}", note])
        print(f"{'OK ' if good else 'XX '} {name:22s} x{qty:<2} {ext[0]:6.1f} x {ext[1]:6.1f} x {ext[2]:6.1f}  "
              f"Vol {m.volume/1000:7.1f} cm3  ~{g:4.0f} g  dicht={m.is_watertight} Koerper={bodies} passt={fits} {warn[:1]}")
with open(os.path.join(ROOT, "docs", "druckteile.csv"), "w", newline="") as f:
    w = csv.writer(f, delimiter=";")
    w.writerow(["Teil", "Anzahl", "Material", "X mm", "Y mm", "Z mm", "Volumen cm3", "Gewicht ca. g (4 Waende, 15% Fuellung)", "Hinweis"])
    w.writerows(rows)
tot = sum(float(r[7])*int(r[1]) for r in rows)
print(f"Filament gesamt ca. {tot/1000:.1f} kg")
sys.exit(0 if ok else 1)
