// Ansichten fuer die Dokumentation (tools/build_all.sh)
include <assembly.scad>
GROUP = "none";
VIEW  = "rotor_section";
CASE  = "boden";          // "boden" / "hals"

module bottle_case(c) to_gutter() {
    if (c == "boden") bottle_lying(S_STOP - 0.5, -1);            // Boden am Anschlag
    else bottle_lying(S_STOP + 16.8 - B_L, 1);                   // Hals in der Nut
}
// Schnitt Rotor/Gehaeuse in der Ebene X = 0 (Blick von +X)
if (VIEW == "rotor_section") {
    difference() {
        union() {
            to_rotorR() { color(C_PRINT) { gehaeuse_motorseite(); gehaeuse_lagerseite(); } }
            to_rotorR() rotate([0,0,THETA_LOAD + ROT_ANG]) color(C_PRINT2) { rotor_motorseite(); rotor_lagerseite(); }
            to_gutter() color(C_PRINT) rinne_G2();
            to_gutter() color(C_PRINT2) { sperrkonsole(); sperrstift(GATE_TOP_EXT); }
            color(C_PRINT) fallschacht();
        }
        translate([0, -500, 0]) cube([500, 1000, 3000]);      // vordere Haelfte weg
    }
    if (ROT_ANG == 0) bottle_case(CASE);
    to_rotorR() rotate([0,0,THETA_LOAD]) for (p=[SENS_PRES, SENS_ORIENT]) color("red")
        translate([p[0], p[1], 0]) cylinder(d=1.5, h=80, center=true, $fn=12);
}
// Teller mit Haken, Ring, Uebergabe (ohne Haube, Bleche durchsichtig), Flasche in T
if (VIEW == "teller") {
    grp_teller_frame(); grp_disc(); grp_hopper(); grp_transfer();
    to_gutter() for (s=[S_T + 30, S_T + 160]) bottle_lying(s - B_L/2, 1);
}
// Uebergabe im Schnitt senkrecht zur Rinne (Ebene s = S_T + DS), Blick entlang der Rinne
DS = 40;
module w2sec() multmatrix([[1,0,0,0],[0,0,1,0],[0,1,0,-(S_T + DS)],[0,0,0,1]]) rotate([ALPHA,0,0]) translate([0,0,-ROT_Z]) children();
module sec(c) color(c) linear_extrude(1) projection(cut=true) w2sec() children();
if (VIEW == "uebergabe_schnitt") {
    sec([0.85,0.85,0.8]) to_teller() rotate([0,0,TD_PHI]) tellerplatte();
    sec(C_PRINT) to_teller() rotate([0,0,TD_PHI]) for (k=[0:TD_N-1]) rotate([0,0,k*TD_PITCH]) haken();
    sec(C_PRINT) to_gutter() uebergabe();
    sec(C_SHEET) to_tellerD() place_rueckwand();
    sec(C_BOTTLE) to_gutter() bottle_lying(S_T + DS - B_L/2, 1);
    sec(C_PRINT2) to_tellerD() place_haube();
}
