// DXF-Export der Platten:  openscad -D 'SHEET="side_neg"' -o sheet_side_neg.dxf sheets_export.scad
include <config.scad>
include <lib/basics.scad>
include <parts/stair.scad>
include <sheets.scad>
SHEET = "side_neg";
if (SHEET == "side_neg") sheet_side2d(-1);
if (SHEET == "side_pos") sheet_side2d(1);
if (SHEET == "back")     sheet_back2d();
if (SHEET == "floor")    sheet_floor2d();
if (SHEET == "apron")    sheet_apron2d();
