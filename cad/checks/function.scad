// Funktionspruefungen (wird von tools/check_function.py gesteuert)
include <../assembly.scad>
GROUP = "none";
MODE  = "none";
A     = 0;        // Rotorwinkel relativ Ladestellung
S0    = 0;        // Flaschenlage (Boden) in s
DIR   = 1;        // +1 Hals nach +s
SHIFT = 0;        // Verschiebung entlang s
BL    = B_L;      // Flaschenlaenge (Toleranz)
BD    = B_D;      // Flaschendurchmesser
PX = 0; PY = 0; PZ = 0;
PN = (BD - B_D)/2*sqrt(2);   // Achslage im 90-Grad-V haengt vom Durchmesser ab
BEAM = "orient";

module gmap() multmatrix([[0,1,0,0],[0,0,1,0],[1,0,0,0],[0,0,0,1]]) children();   // (X,s,n) -> (s,n,X)
module bottle_l(s0, dir) translate([0, s0, PN]) rotate([dir>0 ? -90 : 90, 0, 0]) rotate_extrude($fn=48) bottle_profile(BL, BD);

if (MODE == "rotor_bottle")   // Flasche starr im Rotor, gedreht um A
    to_rotorR() rotate([0,0,THETA_LOAD + A]) gmap() bottle_l(S0 + SHIFT, DIR);
if (MODE == "housing_only")
    to_rotorR() { gehaeuse_motorseite(); gehaeuse_lagerseite(); }
if (MODE == "rotor_housing_at") to_rotorR() {
    gehaeuse_motorseite(); gehaeuse_lagerseite(); rotate([0,0,THETA_LOAD + A]) { rotor_motorseite(); rotor_lagerseite(); } }
if (MODE == "rotor_at")
    to_rotorR() rotate([0,0,THETA_LOAD + A]) { rotor_motorseite(); rotor_lagerseite(); }
if (MODE == "beam") {
    p = BEAM == "orient" ? SENS_ORIENT : SENS_PRES;
    to_rotorR() rotate([0,0,THETA_LOAD]) translate([p[0], p[1], 0]) cylinder(d=1.5, h=2*HOU_XO, center=true, $fn=16);
}
if (MODE == "bottle_world")   // stehend, Boden bei (PX,PY,PZ)
    translate([PX, PY, PZ]) rotate_extrude($fn=48) bottle_profile(BL, BD);
if (MODE == "bottle_gutter")  // liegend in Rinnenkoordinaten
    to_gutter() bottle_l(S0, DIR);
if (MODE == "shaft_only") fallschacht();
