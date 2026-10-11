// =====================================================================
//  Wendetrommel (Rotor), Gehaeuse (2 Haelften), Motorstutzen, Fallschacht
//  Rotor/Gehaeuse im Rotor-Frame R: Achse z_R (= Welt X),
//  x_R = Welt Y, y_R = Welt Z - ROT_Z.  Platzierung: to_rotorR().
// =====================================================================

ROT_SCREWS = [[35,35],[-35,35],[35,-38],[-35,-38]];   // Rotorhaelften M3x40
GRUB_Z   = -34.4;                                     // Madenschraube M3
HOU_BOLTS = [[87,-30],[87,35],[72,110],[72,200],[72,-128]];  // [r, theta] M3x35
SHAFT_SCREWS = [[-12,-26],[12,-26],[-12,26],[12,26]];       // (Welt X, Welt Y)
SHAFT_FL_Y = 32;

function polar(r, a) = [r*cos(a), r*sin(a)];
P_PRES   = sn2R(SENS_PRES, THETA_LOAD);
P_ORIENT = sn2R(SENS_ORIENT, THETA_LOAD);
P_HALL   = polar(HALL_ROT_R, THETA_LOAD + 90);

// Kanal C als Prisma entlang x_R (Querschnitt: X -> z_R, n -> y_R)
module slot_c(len, grow=0, roof=CH_ROOF) {
    // Prisma mit Querschnitt (z_R = a, y_R = n) entlang x_R
    multmatrix([[0,0,1,0],[0,1,0,0],[-1,0,0,0],[0,0,0,1]])   // (a,b,c) -> (c, b, -a)
        linear_extrude(len, center=true)
            offset(delta=grow) polygon([[0,-CH_APEX],[CH_W/2,CH_VTOP],[CH_W/2,roof],[-CH_W/2,roof],[-CH_W/2,CH_VTOP]]);
}

// ---------------------------------------------------------------------
// ROTOR (eigener Rahmen: Schacht entlang +x_R = Anschlagende)
// ---------------------------------------------------------------------
module rotor_full() {
    difference() {
        union() {
            cylinder(r=ROT_R, h=ROT_T, center=true, $fn=160);
            translate([0,0,ROT_BOSS_Z1]) cylinder(d=ROT_BOSS_D, h=-ROT_BOSS_Z1 - ROT_T/2 + 0.5, $fn=48);
        }
        // Schacht + Einlauffasen an beiden Enden
        slot_c(2*ROT_R + 2);
        for (m=[0,1]) mirror([m,0,0]) hull() {
            translate([ROT_R + 0.5, 0, 0]) slot_c(1, CH_CHAMF + 0.5);
            translate([ROT_R - 2, 0, 0]) slot_c(1, 0);
        }
        // Motorwelle D5 mit Abflachung (Flat zeigt nach +y_R)
        translate([0,0,ROT_BOSS_Z1 - EPS_CUT]) intersection() {
            cylinder(d=5.15, h=-ROT_BOSS_Z1 - 20.5, $fn=32);
            translate([-5, -5, 0]) cube([10, 5 + 2.05, 40]);
        }
        // Mutternschlitz M3 + Madenschraube radial +y_R
        translate([-2.95, 3.4, ROT_BOSS_Z1 - EPS_CUT]) cube([5.9, 2.7, GRUB_Z - ROT_BOSS_Z1 + 2.95]);
        translate([0, 0, GRUB_Z]) rotate([-90,0,0]) cylinder(d=3.3, h=20, $fn=24);
        // Lagersitz 688 (Leerlaufseite)
        translate([0,0,ROT_T/2 - B688_W]) cylinder(d=B688_D - 0.05, h=B688_W + 1, $fn=64);
        // Magnet 6x3 (Referenz Ladestellung) auf +z Flaeche
        translate([0, HALL_ROT_R, ROT_T/2 - 3.2]) cylinder(d=6.2, h=4, $fn=32);
        // Lichtschranken-Bohrungen
        for (p=[SENS_PRES, SENS_ORIENT]) translate([p[0], p[1], 0]) cylinder(d=5, h=ROT_T+2, center=true, $fn=24);
        // Verschraubung der Haelften: Kopf -z, Mutter +z
        for (p=ROT_SCREWS) translate([p[0], p[1], 0]) {
            cylinder(d=M3_D, h=ROT_T+2, center=true, $fn=24);
            translate([0,0,-ROT_T/2 - 1]) cylinder(d=6.5, h=1 + 3.5, $fn=32);
            translate([0,0, ROT_T/2 - 3.5]) cylinder(d=6.35, h=5, $fn=6);
        }
    }
}
module rotor_half(side) {  // side = -1: Motorseite, +1: Lagerseite
    intersection() {
        rotor_full();
        translate([-100,-100, side < 0 ? -100 : 0]) cube([200,200,100]);
    }
}
module rotor_motorseite() rotor_half(-1);
module rotor_lagerseite() rotor_half(+1);

// ---------------------------------------------------------------------
// GEHAEUSE
// ---------------------------------------------------------------------
function groove_depth_at(a) =
    (a >= GROOVE_A0 && a <= GROOVE_A1) ? GROOVE_DEPTH :
    (a < GROOVE_A0) ? (a >= -60 ? GROOVE_DEPTH + (2-GROOVE_DEPTH)*(GROOVE_A0-a)/5 : (a >= -80 ? 2*(a+80)/20 : 0))
                    : (a <= 75 ? GROOVE_DEPTH*(75-a)/20 : 0);

module sector(r0, r1, a0, a1, z0, z1) {
    rotate([0,0,a0]) rotate_extrude(angle=a1-a0, $fn=180) translate([r0, z0]) square([r1-r0, z1-z0]);
}
module sector_slice(r0, r1, a, z0, z1) { sector(r0, r1, a-0.05, a+0.05, z0, z1); }

module housing_lobe() {
    sector(HOU_RI-1, LOBE_RO, LOBE_A0, LOBE_A1, -HOU_XO, HOU_XO);
    hull() { sector_slice(HOU_RI-1, LOBE_RO, LOBE_A0, -HOU_XO, HOU_XO); sector_slice(HOU_RI-1, HOU_RO+2, LOBE_A0-6, -HOU_XO, HOU_XO); }
    hull() { sector_slice(HOU_RI-1, LOBE_RO, LOBE_A1, -HOU_XO, HOU_XO); sector_slice(HOU_RI-1, HOU_RO+2, LOBE_A1+6, -HOU_XO, HOU_XO); }
}
module housing_groove() {
    gz = GROOVE_W/2;
    sector(HOU_RI-1, HOU_RI + GROOVE_DEPTH, GROOVE_A0, GROOVE_A1, -gz, gz);
    // Rampen als Huellkoerper duenner Scheiben
    angs = [-80,-75,-70,-65,-60,-57.5,-55, 55,60,65,70,75];
    for (i=[0:len(angs)-2]) if (angs[i+1] - angs[i] <= 5.01)
        hull() {
            sector_slice(HOU_RI-1, HOU_RI + max(groove_depth_at(angs[i]),0.01), angs[i], -gz, gz);
            sector_slice(HOU_RI-1, HOU_RI + max(groove_depth_at(angs[i+1]),0.01), angs[i+1], -gz, gz);
        }
}
// Platzierung im Rinnenrahmen relativ zur Rotorachse (fuer Einlaufflansch)
module in_gutterR() { rotate([0,0,THETA_LOAD]) multmatrix([[0,1,0,0],[0,0,1,0],[1,0,0,0],[0,0,0,1]]) children(); }
// in_gutterR: Rinnen-(X,s,n) -> R-(s*cos.., .., X): x->z_R, y(s)->x', z(n)->y'

module housing_full() {
    difference() {
        union() {
            cylinder(r=HOU_RO, h=2*HOU_XO, center=true, $fn=180);
            housing_lobe();
            // Einlaufblock
            in_gutterR() translate([-CH_FLANGE_X, INLET_S, CH_FLANGE_N0]) cube([2*CH_FLANGE_X, -INLET_S - 40, CH_FLANGE_N1 - CH_FLANGE_N0]);
            // Sockel unten
            translate([-36, HOU_BOTTOM, -HOU_XO]) cube([72, -HOU_BOTTOM - 45, 2*HOU_XO]);
            // Augen fuer Verbindungsschrauben
            for (b=HOU_BOLTS) if (b[0] < 80) hull() {
                translate(concat(polar(b[0], b[1]), [-HOU_XO])) cylinder(r=5.5, h=2*HOU_XO, $fn=32);
                translate(concat(polar(HOU_RO-3, b[1]), [-HOU_XO])) cylinder(r=5.5, h=2*HOU_XO, $fn=32);
            }
        }
        // Rotorraum
        cylinder(r=HOU_RI, h=2*HOU_XI, center=true, $fn=180);
        housing_groove();
        // Einlaufkanal (0.4 groesser als Rinne)
        in_gutterR() along_s(INLET_S - 1, -30)
            offset(delta=0.4) polygon([[0,-CH_APEX],[CH_W/2,CH_VTOP],[CH_W/2,CH_ROOF],[-CH_W/2,CH_ROOF],[-CH_W/2,CH_VTOP]]);
        // Flanscheinsaetze + Stifte
        in_gutterR() {
            for (h=CH_FLANGE_HOLES) translate([h[0], INLET_S - EPS_CUT, h[1]]) rotate([-90,0,0]) cylinder(d=M3_INS_D, h=M3_INS_L+0.5, $fn=24);
            for (p=CH_PIN) translate([p[0], INLET_S - EPS_CUT, p[1]]) rotate([-90,0,0]) cylinder(d=4.1, h=8, $fn=20);
        }
        // Abwurfoeffnung mit Trichter
        hull() {
            translate([-DROP_Y_IN, -50, -17.25]) cube([2*DROP_Y_IN, 2, 34.5]);
            translate([-SHAFT_IN_Y + 0.25, HOU_BOTTOM - 1, -17.25]) cube([2*SHAFT_IN_Y - 0.5, 1.5, 34.5]);
        }
        // Gewindeeinsaetze Fallschacht (von unten)
        for (p=SHAFT_SCREWS) translate([p[1], HOU_BOTTOM - EPS_CUT, p[0]]) rotate([-90,0,0]) cylinder(d=M3_INS_D, h=M3_INS_L+0.5, $fn=24);
        // Lichtschranken: Strahlbohrungen + Halter-Einsaetze beidseitig
        for (p=[P_PRES, P_ORIENT]) {
            translate([p[0], p[1], 0]) cylinder(d=SENS_HOLE_D, h=2*HOU_XO+2, center=true, $fn=24);
            for (dz=[-1,1], dy=[-SENS_INS_OFF, SENS_INS_OFF])
                translate([p[0], p[1]+dy, dz*(HOU_XO + EPS_CUT)]) mirror([0,0,dz>0?1:0]) cylinder(d=M3_INS_D, h=M3_INS_L+0.5, $fn=24);
        }
        // Verbindungsschrauben der Haelften: Kopf aussen -z, Einsatz in +z Haelfte an Trennebene
        for (b=HOU_BOLTS) translate(polar(b[0], b[1])) {
            translate([0,0,-HOU_XO-1]) cylinder(d=M3_D, h=HOU_XO + 1 + 10, $fn=24);
            translate([0,0,-HOU_XO-1]) cylinder(d=6.5, h=1+3.5, $fn=32);
            translate([0,0,-EPS_CUT]) cylinder(d=M3_INS_D, h=M3_INS_L+0.5, $fn=24);
        }
        // Mittelbohrung Motorseite (Nabe D18)
        translate([0,0,-HOU_XO-1]) cylinder(d=ROT_BOSS_D + 4, h=HOU_XO - HOU_XI + 1.01, $fn=64);
        // Motorschrauben M3x20 von innen (Kopf versenkt in Platte)
        for (x=[-NEMA_HOLE,NEMA_HOLE], y=[-NEMA_HOLE,NEMA_HOLE]) translate([x,y,0]) {
            translate([0,0,-HOU_XO-1]) cylinder(d=M3_D, h=HOU_XO - HOU_XI + 2, $fn=24);
            translate([0,0,-HOU_XI - 7]) cylinder(d=6.5, h=7 + 0.01, $fn=32);   // M3x20, 2 mm unter Kopf
        }
        // Zentrieransatz Motorstutzen
        translate([0,0,-HOU_XO - EPS_CUT]) cylinder(d=26.3, h=2.2, $fn=64);
        // Stift 8x20 Leerlaufseite (Presssitz)
        translate([0,0,HOU_XI - 1]) cylinder(d=7.9, h=30, $fn=48);
        // Hallsensor A3144 (TO-92) Tasche von aussen, 1 mm Restwand
        translate([P_HALL[0], P_HALL[1], HOU_XI + 1]) translate([-2.5,-2,0]) cube([5, 4, 10]);
        translate([P_HALL[0]-1.6, P_HALL[1], HOU_XO - 1.5]) cube([3.2, 30, 2]);
    }
}

module housing_tab() {     // Laschen fuer Arm (nur Motorhaelfte, -z)
    ztab0 = -HOU_XO; ztab1 = -HOU_XI;
    ytop  = ARM_Z0 + PROF - ROT_Z - 1;
    difference() {
        union() {
            translate([-30, 40, ztab0]) cube([70, ytop - 40, ztab1 - ztab0]);
            for (x=[-28, 34]) translate([x, 58, ztab1 - 0.01]) cube([4, ytop - 58, 13.5]);
        }
        for (x=[-18, 28]) translate([x, ARM_Z0 + PROF/2 - ROT_Z, ztab0 - 1]) cylinder(d=M5_D, h=20, $fn=24);
    }
}
module gehaeuse_motorseite() {
    difference() {
        union() {
            intersection() { housing_full(); translate([-200,-200,-100]) cube([400,400,100]); }
            difference() { housing_tab(); cylinder(r=HOU_RI, h=2*HOU_XI, center=true, $fn=180); }
        }
        // Bolzenkoepfe auch durch die Lasche zugaenglich
        for (b=HOU_BOLTS) translate(polar(b[0], b[1])) translate([0,0,-HOU_XO-1]) cylinder(d=6.5, h=1+3.5, $fn=32);
    }
}
module gehaeuse_lagerseite() {
    difference() {
        union() {
            intersection() { housing_full(); translate([-200,-200,0]) cube([400,400,100]); }
        }
    }
}

// ---------------------------------------------------------------------
// MOTORSTUTZEN (zwischen Gehaeuse -z und NEMA17), R-Frame
// ---------------------------------------------------------------------
module motorstutzen() {
    z1 = -HOU_XO; z0 = z1 - MOT_STUTZEN;
    difference() {
        union() {
            translate([0,0,z0]) linear_extrude(MOT_STUTZEN) offset(r=3) offset(delta=-3) square(42.3, center=true);
            translate([0,0,z1 - 0.01]) cylinder(d=26, h=2, $fn=64);
        }
        translate([0,0,z0 - 1]) cylinder(d=ROT_BOSS_D + 4, h=MOT_STUTZEN + 4, $fn=64);
        translate([0,0,z0 - EPS_CUT]) cylinder(d=22.3, h=2.2, $fn=64);
        for (x=[-NEMA_HOLE,NEMA_HOLE], y=[-NEMA_HOLE,NEMA_HOLE]) translate([x,y,z0-1]) cylinder(d=M3_D, h=MOT_STUTZEN+4, $fn=24);
        // Fenster fuer Madenschraube (+y)
        translate([0, 0, GRUB_Z]) rotate([-90,0,0]) cylinder(d=7, h=30, $fn=32);
        // Material sparen an den Seiten
        for (a=[0,180]) rotate(a) translate([15, -8, z0 + 3]) cube([10, 16, MOT_STUTZEN - 6]);
    }
}

// ---------------------------------------------------------------------
// FALLSCHACHT  (Weltkoordinaten relativ: X, Y, Z ab Gurt)
// ---------------------------------------------------------------------
SHAFT_Z0 = BELT_Z + SHAFT_GAP;
SHAFT_Z1 = ROT_Z + HOU_BOTTOM;
SHAFT_FL_T = 5;
SENS_SHAFT_X = [3, 22];
SENS_SHAFT_Z = BELT_Z + 30;
module fallschacht() {
    yi = SHAFT_IN_Y; yo = yi + SHAFT_WALL; xb = SHAFT_IN_XB; xbo = xb - SHAFT_WALL;
    h = SHAFT_Z1 - SHAFT_Z0;
    difference() {
        union() {
            // Seitenwaende mit Auslauf-Spreizung
            for (m=[0,1]) mirror([0,m,0]) {
                translate([xbo, yi, SHAFT_Z0]) cube([SHAFT_X1 - 10 - xbo, SHAFT_WALL, h]);
                hull() {
                    translate([SHAFT_X1 - 10, yi, SHAFT_Z0]) cube([0.01, SHAFT_WALL, h]);
                    translate([SHAFT_X1, yi + 3, SHAFT_Z0]) cube([0.01, SHAFT_WALL, h - 40]);
                }
                // Sensorpolster (Halter senkrecht, Einsaetze bei z +-11)
                translate([-6, yo - 0.01, SENS_SHAFT_Z - 17]) cube([37, 5, 34]);
                // Kopfflansch seitlich
                translate([xbo, yi, SHAFT_Z1 - SHAFT_FL_T]) cube([20 - xbo, SHAFT_FL_Y - yi, SHAFT_FL_T]);
                // Rippe unter Flansch
                hull() {
                    translate([-8, yo, SHAFT_Z1 - SHAFT_FL_T]) cube([16, SHAFT_FL_Y - yo, 0.01]);
                    translate([-8, yo, SHAFT_Z1 - SHAFT_FL_T - 25]) cube([16, 0.01, 0.01]);
                }
            }
            // Rueckwand + Rueckflansch
            translate([xbo, -yo, SHAFT_Z0]) cube([SHAFT_WALL, 2*yo, h]);
            translate([-HOU_XO, -SHAFT_FL_Y, SHAFT_Z1 - SHAFT_FL_T]) cube([xbo + HOU_XO, 2*SHAFT_FL_Y, SHAFT_FL_T]);
        }
        // Schrauben M3 in Gehaeuseeinsaetze
        for (p=SHAFT_SCREWS) translate([p[0], p[1], SHAFT_Z1 - SHAFT_FL_T - 1]) {
            cylinder(d=M3_D, h=10, $fn=24);
        }
        // Lichtschranken Schacht (2 Strahlen) + Halter-Einsaetze
        for (x=SENS_SHAFT_X) {
            translate([x, 0, SENS_SHAFT_Z]) rotate([90,0,0]) cylinder(d=SENS_HOLE_D, h=80, center=true, $fn=24);
        }
        for (m=[0,1]) mirror([0,m,0]) for (x=SENS_SHAFT_X, dz=[-SENS_INS_OFF, SENS_INS_OFF])
            translate([x, yo + 5 + EPS_CUT, SENS_SHAFT_Z + dz]) rotate([90,0,0]) cylinder(d=M3_INS_D, h=M3_INS_L+0.5, $fn=24);
    }
}
