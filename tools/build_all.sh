#!/usr/bin/env bash
# Erzeugt alle Ausgaben neu und prueft das Modell.
#   tools/build_all.sh            (alles)
#   tools/build_all.sh --no-check (ohne Kollisions-/Funktionspruefung)
# Benoetigt: openscad (2021.01+), xvfb-run (fuer Bilder), python3 mit trimesh, manifold3d, numpy, scipy
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "== Druckteile (STL) =="
python3 tools/build_parts.py

echo "== Platten (DXF) =="
mkdir -p dxf
rm -f dxf/*.dxf
for s in rueckwand haube bunker_boden bunker_seite_unten bunker_seite_oben tellerplatte; do
  openscad -D "SHEET=\"$s\"" -o "dxf/sheet_$s.dxf" cad/sheets_export.scad 2>/dev/null
  echo "  dxf/sheet_$s.dxf"
done

echo "== Stueckliste + Auslegung =="
python3 tools/bom.py | sed -n 1p
python3 tools/calc.py --write > /dev/null

echo "== Bilder =="
mkdir -p docs/img
R() { xvfb-run -a openscad -o "$1" --imgsize=1800,1200 --colorscheme=Tomorrow "${@:2}" >/dev/null 2>&1; echo "  $1"; }
cd cad
# Tellermitte (-151,-602,1197), Normale (-0.707,0.332,0.624)
R ../docs/img/gesamt_bandseite.png   --camera=-300,-450,1000,60,0,215,3300 assembly.scad &
R ../docs/img/gesamt_bedienseite.png --camera=-300,-500,1000,55,0,320,3300 assembly.scad &
R ../docs/img/seitenansicht.png      --projection=o --camera=-2162,-4523,750,-250,-450,750 assembly.scad &
wait
R ../docs/img/teller_vorn.png        -D 'VIEW="teller"' --camera=-1494,29,2383,-151,-602,1197 views.scad &
R ../docs/img/uebergabe_schnitt.png  -D 'VIEW="uebergabe_schnitt"' -D TD_PHI=30 --projection=o --camera=0,0,0,0,0,0,450 views.scad &
R ../docs/img/rotor_rinne.png        --camera=-20,-170,1120,62,0,215,1100 assembly.scad &
wait
for c in boden hals; do
  R ../docs/img/schnitt_$c.png -D 'VIEW="rotor_section"' -D "CASE=\"$c\"" --camera=0,-60,1040,90,0,90,560 views.scad &
done
R ../docs/img/abwurf_boden.png -D 'VIEW="rotor_section"' -D 'ROT_ANG=-62' --camera=0,-60,1040,90,0,90,560 views.scad &
R ../docs/img/abwurf_hals.png  -D 'VIEW="rotor_section"' -D 'ROT_ANG=118' --camera=0,-60,1040,90,0,90,560 views.scad &
wait
cd "$ROOT"
rm -f docs/img/stufen_hub_oben.png docs/img/stufen_hub_unten.png

if [[ "${1:-}" != "--no-check" ]]; then
  echo "== Kollisionspruefung =="
  python3 tools/check_collisions.py | tail -n 2
  echo "== Funktionspruefung =="
  python3 tools/check_function.py | tail -1
fi
echo "fertig."
