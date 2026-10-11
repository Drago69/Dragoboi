// DXF-Export der Platten:  openscad -D 'SHEET="rueckwand"' -o sheet_rueckwand.dxf sheets_export.scad
include <config.scad>
include <lib/basics.scad>
include <parts/gutter.scad>
include <parts/teller.scad>
include <sheets.scad>
SHEET = "rueckwand";
if (SHEET == "rueckwand")    rueckwand_2d();
if (SHEET == "haube")        haube_2d();
if (SHEET == "bunker_boden") bunkerblech_2d(0);
if (SHEET == "bunker_seite_unten") bunkerblech_2d(1);
if (SHEET == "bunker_seite_oben")  bunkerblech_2d(2);
if (SHEET == "tellerplatte") tellerplatte_2d();
