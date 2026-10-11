// =====================================================================
//  Hubantrieb Stufenfoerderer: Exzenter-Nocke, Rollenhalter, Lagerboecke,
//  Motorbock, Schlittenadapter (MGN12H), Hallhalter, Keile
//  Rahmen: Modulkoordinaten (ausser Weltkeil).
// =====================================================================

// Rollenhoehe ueber Welle bei Nockenwinkel phi (0 = Hub oben)
function cam_h(phi) = CAM_E*cos(phi) + sqrt(pow(CAM_R + ROLL_R, 2) - pow(CAM_E*sin(phi), 2));
function cam_lift(phi) = cam_h(phi) - cam_h(180);          // 0 .. ST_STROKE

FLANGE_PCD = 16;   // Flanschkupplung D8 (Flansch D22, 4 x M3 auf LK16)

// ---------------------------------------------------------------------
// Nocke: Scheibe in x-z Ebene, Welle entlang y bei (CAM_X, CAM_ZS)
module nocke(phi=0) translate([CAM_X, 0, CAM_ZS]) rotate([90,0,0]) rotate([0,0,-phi]) translate([0,0,-CAM_T/2]) nocke_local();
// Nocke flach (Druckrahmen): Wellenmitte im Ursprung, Scheibe z 0..CAM_T
module nocke_local() {
    difference() {
        translate([0, CAM_E, 0]) cylinder(r=CAM_R, h=CAM_T, $fn=180);
        translate([0,0,-1]) cylinder(d=10.5, h=CAM_T+2, $fn=48);
        for (a=[45:90:315]) rotate(a) translate([FLANGE_PCD/2,0,-1]) cylinder(d=M3_D, h=CAM_T+2, $fn=24);
        // Erleichterungen (ausserhalb Flansch D22)
        for (a=[-50, 50]) rotate(a) translate([0, CAM_E + 14, -1]) cylinder(r=17, h=CAM_T+2, $fn=64);
        translate([0, CAM_E + 34, -1]) cylinder(r=9, h=CAM_T+2, $fn=48);
    }
}

// ---------------------------------------------------------------------
// Rollenhalter (Gabel) unter Mittel-Querholm des Schlittens, Lage bei Hub u
ROLL_FORK_IN = 5;     // halber Innenabstand der Gabel
module rollenhalter(u=0) {
    zb = CAR_Z0 - PROF + u;          // UK Querholm
    za = zb - ROLL_OFF;              // Achse
    translate([CAM_X, 0, 0]) difference() {
        union() {
            translate([-10, -25, zb - 6]) cube([20, 50, 6]);
            for (m=[0,1]) mirror([0,m,0]) hull() {
                translate([-10, ROLL_FORK_IN, zb - 6]) cube([20, 5, 6]);
                translate([0, ROLL_FORK_IN, za]) rotate([-90,0,0]) cylinder(r=10, h=5, $fn=48);
            }
            // Versteifung zwischen Platte und Gabelwangen
            for (m=[0,1]) mirror([0,m,0]) hull() {
                translate([-4, ROLL_FORK_IN + 5, zb - 6]) cube([8, 10, 6]);
                translate([-4, ROLL_FORK_IN + 5, zb - 16]) cube([8, 0.01, 1]);
            }
        }
        translate([0, 0, za]) rotate([90,0,0]) cylinder(d=8.3, h=40, center=true, $fn=32);
        for (y=[-18, 18]) translate([0, y, zb - 7]) {
            cylinder(d=M5_D, h=10, $fn=24);
        }
        // Mutter M8 Sechskant gegen Verdrehen (aussen)
        translate([0, ROLL_FORK_IN + 5 - 3, za]) rotate([-90,0,0]) cylinder(d=15.0, h=10, $fn=6);
    }
}

// ---------------------------------------------------------------------
// Lagerbock 608 (y = +100), reitet auf Grundtraeger
module bearing_saddle(yc) {
    xc = CAM_X;
    difference() {
        translate([xc - 13, yc - 14, BASE_Z0]) cube([26, 28, CAM_ZS + 17 - BASE_Z0]);
        // Sattel ueber Grundtraeger (Profil + 0.15 Spiel)
        translate([xc - 14, yc - PROF/2 - 0.15, BASE_Z0 - 1]) cube([28, PROF + 0.3, PROF + 1.15]);
        // Lagersitz 608 (22x7) + Wellendurchgang
        translate([xc, yc, CAM_ZS]) rotate([90,0,0]) {
            cylinder(d=22.05, h=7, center=true, $fn=64);
            cylinder(d=12, h=40, center=true, $fn=32);
        }
        // M5 seitlich in die Nuten des Grundtraegers (Hammermutter)
        for (s=[-1,1]) translate([xc, yc + s*12, BASE_Z0 + PROF/2]) rotate([90,0,0]) cylinder(d=M5_D, h=6, center=true, $fn=24);
    }
}
module lagerbock() bearing_saddle(LEG_Y_F);

// Motorbock: Sattel y=-100 (mit Lager) + Kasten bis Getriebeflansch y=-148
MB_Y_FLANGE = -148;     // Getriebeflanschflaeche (Motorseite)
GB_PCD = 28;            // Getriebe-Lochkreis 4 x M4 (bitte am Motor pruefen)
module motorbock() {
    xc = CAM_X; yb = -LEG_Y_F;
    difference() {
        union() {
            bearing_saddle(yb);
            // Kasten
            difference() {
                translate([xc - 22, MB_Y_FLANGE, BASE_Z1 - 0]) cube([44, yb - 14 - MB_Y_FLANGE + 0.01, CAM_ZS + 26 - BASE_Z1]);
                translate([xc - 18, MB_Y_FLANGE + 6, BASE_Z1 + 5]) cube([36, yb - 16 - MB_Y_FLANGE - 6, 100]);
            }
        }
        // Getriebe: Zentrierung D22 + 4 x M4
        translate([xc, MB_Y_FLANGE - 1, CAM_ZS]) rotate([-90,0,0]) {
            cylinder(d=22.4, h=10, $fn=64);
            for (a=[45:90:315]) rotate(a) translate([GB_PCD/2, 0, 0]) cylinder(d=M4_D, h=10, $fn=24);
        }
        // Wellendurchgang in Sattelwand
        translate([xc, yb - 14 - 1, CAM_ZS]) rotate([-90,0,0]) cylinder(d=12, h=6, $fn=32);
    }
}

// ---------------------------------------------------------------------
// Schlittenadapter MGN12H -> Querholm.  Lage bei Hub u.
// side = -1: Saeule 1 (Wagenflaeche bei x = CB1_X0 - ADAPT_T), +1: Saeule 2
module schlitten_adapter(side=-1, u=0) {
    zc = CAR_Z0 - PROF/2 + u;
    x0 = side < 0 ? CB1_X0 - ADAPT_T : CB2_X1;
    difference() {
        translate([x0, -30, zc - 25]) cube([ADAPT_T, 60, 50]);
        // MGN12H: 4 x M3 (20 x 20), Kopf auf Holmseite versenkt
        for (y=[-10,10], z=[-10,10]) translate([x0 + ADAPT_T/2, y, zc + z]) rotate([0,90,0]) {
            cylinder(d=M3_D, h=ADAPT_T+2, center=true, $fn=24);
            translate([0,0, side < 0 ? ADAPT_T/2 - 3.4 : -ADAPT_T/2 - 1.6]) cylinder(d=6.5, h=5, $fn=32);
        }
        // M5 in Holmnut, Kopf auf Wagenseite (ausserhalb Wagenbreite 27)
        for (y=[-22, 22]) translate([x0 + ADAPT_T/2, y, zc]) rotate([0,90,0]) cylinder(d=M5_D, h=ADAPT_T+2, center=true, $fn=24);
        // Magnet 6x3 fuer "Hub unten" (nur Saeule 1)
        if (side < 0) translate([x0 - EPS_CUT, 22, zc - 18]) rotate([0,90,0]) cylinder(d=6.2, h=3.2, $fn=32);
    }
}

// Hallsensor-Halter an Saeule 1 (+y Nut), Sensor blickt nach +x auf Magnet
module hallhalter_hub() {
    xp = POST1_X; zc = CAR_Z0 - PROF/2 - 18;   // Magnethoehe bei u=0
    xt = CB1_X0 - ADAPT_T - 1.5;               // Sensorflaeche 1.5 vor Adapter
    difference() {
        union() {
            translate([xp - 10, PROF/2, zc - 12]) cube([20, 19, 24]);       // an Saeule (+y Nut)
            translate([xp - 10, 15, zc - 12]) cube([xt - (xp - 10), 14, 7]); // Arm neben Wagen
            translate([xt - 6, 15, zc - 12]) cube([6, 14, 20]);            // Sensorkopf
        }
        translate([xp, PROF/2 - 1, zc + 4]) rotate([-90,0,0]) {
            cylinder(d=M5_D, h=30, $fn=24);
            translate([0,0,6]) cylinder(d=M5_HEAD_D+0.6, h=30, $fn=32);
        }
        // TO-92 Tasche (flache Seite zeigt +x), Kabel nach unten
        translate([xt - 3.7, 22 - 2.5, zc - 3]) cube([3.8, 5, 12]);
        translate([xt - 3.7, 22 - 1.5, zc - 13]) cube([2, 3, 12]);
    }
}

// ---------------------------------------------------------------------
// Keil (generisch): Unterseite waagerecht auf Stuetze, Oberseite um ang geneigt.
// Lokaler Rahmen: Stuetzenachse z, Neigung steigt in +v.
//  w = Breite quer, l = Laenge entlang Neigung, tmin = Mindestdicke
module keil(ang, w=20, l=64, tmin=6) {
    h1 = tmin + l*tan(ang);
    difference() {
        union() {
            hull() {
                translate([-w/2, -l/2, 0]) cube([w, l, tmin]);
                translate([-w/2, l/2 - 0.01, 0]) cube([w, 0.01, h1]);
            }
        }
        // M5 senkrecht in Kernbohrung der Stuetze (Kopf von oben, tief versenkt)
        translate([0,0,-1]) cylinder(d=M5_D, h=50, $fn=24);
        translate([0,0,tmin - 1.5]) cylinder(d=M5_HEAD_D + 0.6, h=50, $fn=32);
        // 2 x M5 senkrecht zur Schraegflaeche in Traeger-Nut (Kopf unten)
        for (v=[-l/2 + 8, l/2 - 14]) translate([0, v, tmin + (v + l/2)*tan(ang)]) rotate([ang,0,0]) {
            translate([0,0,-40]) cylinder(d=M5_D, h=50, $fn=24);
            translate([0,0,-40 - 3]) cylinder(d=M5_HEAD_D + 0.6, h=40 - 4, $fn=32);
        }
    }
}
module keil28() keil(ALPHA);
module keil15() keil(FLOOR_SLOPE);
