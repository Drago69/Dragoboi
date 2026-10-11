#!/usr/bin/env bash
# Erzeugt alle Ausgaben neu und prueft das Modell.
#   tools/build_all.sh            (alles)
#   tools/build_all.sh --no-check (ohne Kollisions-/Funktionspruefung)
# Benoetigt: openscad (2021.01+), xvfb-run (fuer Bilder), python3 mit trimesh, manifold3d, numpy
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "== Druckteile (STL) =="
python3 tools/build_parts.py

echo "== Platten (DXF) =="
mkdir -p dxf
for s in side_neg side_pos back floor apron; do
  openscad -D "SHEET=\"$s\"" -o "dxf/sheet_$s.dxf" cad/sheets_export.scad 2>/dev/null
done

echo "== Stueckliste + Auslegung =="
python3 tools/bom.py | sed -n 1p
python3 tools/calc.py --write > /dev/null

echo "== Bilder =="
mkdir -p docs/img
R() { xvfb-run -a openscad -o "$1" --imgsize=1800,1200 --colorscheme=Tomorrow "${@:2}" >/dev/null 2>&1; echo "  $1"; }
cd cad
R ../docs/img/gesamt_bandseite.png   --camera=-350,-450,850,60,0,215,3600 assembly.scad
R ../docs/img/gesamt_bedienseite.png --camera=-500,-550,850,58,0,320,3800 assembly.scad
R ../docs/img/seitenansicht.png      --projection=o --camera=-500,-450,700,90,0,90,3400 assembly.scad
R ../docs/img/rotor_rinne.png        --camera=-20,-170,1120,62,0,215,1100 assembly.scad
R ../docs/img/stufen_hub_oben.png    -D CAM_PHI=0   -D SHOW_SHEETS=false --camera=-650,-700,950,55,0,300,2000 assembly.scad
R ../docs/img/stufen_hub_unten.png   -D CAM_PHI=180 -D SHOW_SHEETS=false --camera=-650,-700,950,55,0,300,2000 assembly.scad
for c in boden hals; do
  R ../docs/img/schnitt_$c.png -D 'VIEW="rotor_section"' -D "CASE=\"$c\"" --camera=0,-60,1040,90,0,90,560 views.scad
done
R ../docs/img/abwurf_boden.png -D 'VIEW="rotor_section"' -D 'ROT_ANG=-62' --camera=0,-60,1040,90,0,90,560 views.scad
R ../docs/img/abwurf_hals.png  -D 'VIEW="rotor_section"' -D 'ROT_ANG=118' --camera=0,-60,1040,90,0,90,560 views.scad
cd "$ROOT"

if [[ "${1:-}" != "--no-check" ]]; then
  echo "== Kollisionspruefung =="
  python3 tools/check_collisions.py | tail -n 2
  echo "== Funktionspruefung =="
  python3 tools/check_function.py | tail -1
fi
echo "fertig."
