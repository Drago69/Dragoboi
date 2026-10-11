// =====================================================================
//  Kleinteile: Lichtschrankenhalter (Laser / Fototransistor), E18-Halter,
//  Keil (Stuetze -> schraeger Holm)
// =====================================================================

// Lichtschrankenhalter. Montageflaeche z=0, Strahlachse +z (nach aussen),
// 2 x M3 bei y = +-SENS_INS_OFF.  type "laser" (D6-Modul) / "pt" (5 mm Fototransistor)
SH_TUBE_L = 16;
module sensorhalter(type="laser") {
    bore = type == "laser" ? 6.15 : 5.15;
    ap   = type == "laser" ? 2.5 : 1.5;     // Blende
    difference() {
        union() {
            translate([-7, -SENS_INS_OFF - 5, 0]) chamfer_box([14, 2*SENS_INS_OFF + 10, 4], 1.5);
            cylinder(d=11, h=SH_TUBE_L, $fn=48);
        }
        translate([0,0,-1]) cylinder(d=ap, h=3, $fn=24);                 // Blende (1 mm)
        translate([0,0,1]) cylinder(d=bore, h=SH_TUBE_L, $fn=32);         // Aufnahme
        for (y=[-SENS_INS_OFF, SENS_INS_OFF]) translate([0, y, -1]) {
            cylinder(d=M3_D, h=10, $fn=24);
            translate([0,0,3.5]) cylinder(d=M3_HEAD_D+0.4, h=10, $fn=24);
        }
        // Klemmschlitz + Madenschraube M3 radial
        translate([0,0,SH_TUBE_L - 6]) rotate([0,90,0]) cylinder(d=2.6, h=10, $fn=16);
        // Kabelschlitz
        translate([-1, 0, SH_TUBE_L - 4]) cube([2, 10, 5]);
    }
}
module sensorhalter_laser() sensorhalter("laser");
module sensorhalter_pt() sensorhalter("pt");

// E18-D80NK Halter (Stau-Sensor), haengt unter dem Sensorausleger.
// Lokal: Auslegerunterseite z=0, Sensorplatte bei z = -drop, Sensorachse z.
E18_DROP = (ROT_Z + 105) - (BELT_Z + 190);
module e18_halter() {
    d = E18_DROP;
    difference() {
        union() {
            translate([-20, -10, -6]) cube([40, 20, 6]);                     // an Ausleger
            translate([-20, 10, -d - 6]) cube([40, 6, d + 6]);               // Steg (seitlich)
            translate([-20, -16, -d - 6]) cube([40, 32, 6]);                 // Sensorplatte
            for (x=[-20, 14]) hull() {                                      // Rippen
                translate([x, -10, -6]) cube([6, 20, 0.01]);
                translate([x, 10, -d + 10]) cube([6, 0.01, 0.01]);
            }
        }
        for (x=[-12, 12]) translate([x, 0, -10]) cylinder(d=M5_D, h=20, $fn=24);
        translate([0, -2, -d - 10]) cylinder(d=18.4, h=12, $fn=64);
    }
}

// ---------------------------------------------------------------------
// Keil (generisch): Unterseite waagerecht auf Stuetze, Oberseite um ang geneigt.
// Lokaler Rahmen: Stuetzenachse z, Neigung steigt in +y.
//  w = Breite quer, l = Laenge (waagerecht), tmin = Mindestdicke
KEIL_L = 64; KEIL_TMIN = 6;
function keil_c(ang) = KEIL_TMIN + KEIL_L/2*tan(ang);      // Hoehe Mitte Oberseite
module keil(ang, w=20, l=KEIL_L, tmin=KEIL_TMIN) {
    h1 = tmin + l*tan(ang);
    difference() {
        hull() {
            translate([-w/2, -l/2, 0]) cube([w, l, tmin]);
            translate([-w/2, l/2 - 0.01, 0]) cube([w, 0.01, h1]);
        }
        // M5 senkrecht in Kernbohrung der Stuetze (Kopf von oben, tief versenkt)
        translate([0,0,-1]) cylinder(d=M5_D, h=50, $fn=24);
        translate([0,0,tmin - 1.5]) cylinder(d=M5_HEAD_D + 0.6, h=200, $fn=32);
        // 2 x M5 senkrecht zur Schraegflaeche in Traeger-Nut (Kopf unten)
        for (v=[-l/2 + 8, l/2 - 14]) translate([0, v, tmin + (v + l/2)*tan(ang)]) rotate([ang,0,0]) {
            translate([0,0,-60]) cylinder(d=M5_D, h=70, $fn=24);
            translate([0,0,-60 - 3]) cylinder(d=M5_HEAD_D + 0.6, h=60 - 4, $fn=32);
        }
    }
}
