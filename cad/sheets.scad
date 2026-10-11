// =====================================================================
//  Platten 4 mm (PETG- oder PC-Platte, lebensmittelgeeignet) + Tellerplatte
//  2D-Konturen fuer DXF (Laser/CNC/Handzuschnitt)
//  Rueckwand und Haube im D-Frame (x waagerecht, y bergauf in Tellerebene),
//  Bunkerbleche im eigenen Blech-Frame (Innenseite oben).
//  Benoetigt parts/gutter.scad und parts/teller.scad.
// =====================================================================

// Ausschnitt fuer den Auslauf (Teil hinter der Rueckwandebene), D-Frame
module bp_slot2d() {
    offset(delta=2) projection() intersection() {
        G_to_D() union() { auslauf(); along_s(S_EXIT, S_EXIT + 80) polygon([[-CH_FLANGE_X, CH_KEEL], [CH_FLANGE_X, CH_KEEL], [CH_FLANGE_X, CH_ROOF], [-CH_FLANGE_X, CH_ROOF]]); }
        translate([-1000, -1000, -200]) cube([2000, 2000, 200 - EPS_CUT]);
    }
}
// Rahmen-Schrauben M5 (Rueckwand -> Nut der Rahmenholme)
LS_Y = [-12, 96];             // Unterbrechung linker Seitenholm (Auslauf)
function bp_frame_holes() = concat(
    [for (x=[-300:150:300], s=[-1,1]) [x, s*TF_YB]],
    [for (y=[-180:120:180]) [TF_XS, y]],
    [for (y=[-180, -60, 160]) [-TF_XS, y]]);
module rueckwand_2d() {
    difference() {
        translate([-BP_X, -BP_Y]) square([2*BP_X, 2*BP_Y]);
        circle(r=TD_HOLE, $fn=360);
        bp_slot2d();
        for (p=bp_frame_holes()) translate(p) circle(d=M5_D, $fn=24);
        // Randring (M4 Senkkopf von hinten)
        for (a=ring_screws()) translate(RING_SCREW_R*[cos(a), sin(a)]) circle(d=M4_D, $fn=24);
        // Uebergabe-Fuss
        for (p=UE_SCREWS) rotate(p[1] - TD_DROT) translate([p[0], 0]) circle(d=M4_D, $fn=24);
        // Abstreifer
        rotate(STRIP_A) for (x=[TD_HOLE + 12, RING_RO - 9], y=[-11, 11]) translate([x, y]) circle(d=M4_D, $fn=24);
        // Haubenhalter
        for (p=HOOD_PTS) translate(p) circle(d=M4_D, $fn=24);
    }
}
// Haube (transparent), D-Frame bei z = HOOD_Z
HOOD_Y0 = (FILL_D - FILL_N[2]*HOOD_Z)/FILL_N[1] + 10;       // 10 mm ueber Bunkerrand
module haube_2d() {
    difference() {
        union() {
            translate([-292, HOOD_Y0]) square([600, BP_Y - 8 - HOOD_Y0]);
            // Laschen zu den unteren Haltern (ausserhalb des Bunkers)
            hull() { translate(HOOD_PTS[3]) circle(r=12, $fn=48); translate([-292, HOOD_Y0]) square([8, 30]); }   // schmal: bleibt ausserhalb Blech L195
            hull() { translate(HOOD_PTS[0]) circle(r=12, $fn=48); translate([284, HOOD_Y0]) square([24, 30]); }
        }
        for (p=HOOD_PTS) translate(p) circle(d=M4_D, $fn=24);
    }
}
// Bunkerbleche: 0 Boden, 1 Seite unten links (rechts gespiegelt), 2 Seite oben links (rechts gespiegelt)
module bunkerblech_2d(i) hopper_sheet_2d(i);

// ------------------------- 3D Platzierung (D-Frame) ------------------------
module sheet3d() { color(C_SHEET) linear_extrude(SHEET_T) children(); }
module place_rueckwand() translate([0,0,-SHEET_T]) sheet3d() render() rueckwand_2d();
module place_haube() translate([0,0,HOOD_Z]) sheet3d() haube_2d();
module place_bunkerbleche() color(C_SHEET) for (i=[0:len(HOP_FACETS)-1]) render() hopper_sheet(i);
