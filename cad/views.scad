// Ansichten fuer die Dokumentation (tools/render.sh)
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
if (VIEW == "stair") {
    to_module() { grp_module_fixed(); grp_carriage(); grp_cam(); }
}
