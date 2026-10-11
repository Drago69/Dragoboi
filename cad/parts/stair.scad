// =====================================================================
//  Stufenfoerderer: Stufenkappen M/F, Bunkerkante F0, Trog mit Abweiser
//  Kanonischer Rahmen der Kappen: x in [0,ST_D], y in [-ST_L/2,ST_L/2],
//  Unterkante z=0, Oberkante hinten (x=0) z=CAP_H, vorne CAP_H-ST_DELTA.
// =====================================================================

CAP_EDGE_R = 1.0;     // Rundung Oberkanten
LEG_CLR    = 0.2;     // Spiel Tasche/Profil je Seite
CAP_SCREW_Z = 15;     // Hoehe Querschraube M5 ueber UK
CAP_CB_D   = 10;  CAP_CB_DEPTH = 5.5;

// 2D-Profil (x,z) einer Kappe mit gerundeten Oberkanten
module cap_profile2d(d=ST_D, h_back=CAP_H, drop=ST_DELTA, r=CAP_EDGE_R) {
    hull() {
        square([d, 0.01]);
        translate([r, h_back - r - r*tan(ST_BETA/2)]) circle(r, $fn=24);
        translate([d - r, h_back - drop - r + r*tan(ST_BETA/2)]) circle(r, $fn=24);
        translate([0, 0]) square([0.01, h_back - 2*r]);
        translate([d-0.01, 0]) square([0.01, h_back - drop - 2*r]);
    }
}

// Tasche fuer Bein 20x20 + Querschraube von der Stirnseite
module leg_pocket(yleg, d=ST_D, depth=CAP_POCKET) {
    s = PROF + 2*LEG_CLR;
    translate([d/2 - s/2, yleg - s/2, -EPS_CUT]) cube([s, s, depth + EPS_CUT]);
    // Einfuehrschraege
    translate([d/2, yleg, -EPS_CUT]) linear_extrude(1.5, scale=(s)/(s+3)) square(s+3, center=true);
}
module end_screw(yleg, d=ST_D, zs=CAP_SCREW_Z) {
    sgn = yleg > 0 ? 1 : -1;
    yend = sgn*ST_L/2;
    // Bohrung von Stirnseite bis Tasche
    translate([d/2, (yend + yleg)/2, zs]) rotate([90,0,0])
        cylinder(d=M5_D, h=abs(yend-yleg)+2, center=true, $fn=24);
    // Senkung an Stirnseite
    translate([d/2, yend - sgn*CAP_CB_DEPTH/2, zs]) rotate([90,0,0])
        cylinder(d=CAP_CB_D, h=CAP_CB_DEPTH + 0.02, center=true, $fn=32);
}

module stair_cap(leg_y) {
    difference() {
        // Profil entlang y extrudieren, Stirnkanten 0.6 gefast
        intersection() {
            rotate([90,0,0]) linear_extrude(ST_L, center=true) cap_profile2d();
            hull() {
                translate([-1, -ST_L/2+0.6, -1]) cube([ST_D+2, ST_L-1.2, CAP_H+2]);
                translate([0.6, -ST_L/2, 0.6]) cube([ST_D-1.2, ST_L, CAP_H-1.8]);
            }
        }
        for (s=[-1,1]) { leg_pocket(s*leg_y); end_screw(s*leg_y); }
        // Beschriftung (Unterseite) eingesenkt
        translate([ST_D/2, 0, -EPS_CUT]) linear_extrude(0.6) mirror([1,0]) rotate(90)
            text(leg_y==LEG_Y_M ? "M" : "F", size=10, halign="center", valign="center");
    }
}
module stufe_M() stair_cap(LEG_Y_M);
module stufe_F() stair_cap(LEG_Y_F);

// Platzierung in Modulkoordinaten
module place_M(i, u=0) translate([x_M(i), 0, zM_back(i,u) - CAP_H]) children();
module place_F(i)      translate([x_F(i), 0, zF_back(i)   - CAP_H]) children();

// ---------------------------------------------------------------------
// F0: Bunkerkante vor M1.  Oberseite = Bunkerboden (steigt 15 Grad nach -x),
// hinten Falz fuer Bodenplatte (4 mm).
// Rahmen: Modulkoordinaten direkt.
// ---------------------------------------------------------------------
F0_X1 = -ST_GAP;            // Vorderflaeche
F0_X0 = -ST_P - 12;         // inkl. Falz
F0_ZB = -40;                // flach: Schlitten-Laengstraeger laufen darunter (OK -45 bei Hub oben)
F0_POCKET = 25;
F0_RABBET = 14;             // Falzbreite (x)
function floor_z(x) = -x*tan(FLOOR_SLOPE);       // OK Boden bei x (x<0)
module stufe_F0() {
    t_perp = SHEET_T / cos(FLOOR_SLOPE);
    difference() {
        intersection() {
            rotate([90,0,0]) linear_extrude(ST_L, center=true) polygon([
                [F0_X1, F0_ZB],
                [F0_X1, floor_z(F0_X1) - CAP_EDGE_R],
                [F0_X1 - CAP_EDGE_R, floor_z(F0_X1)],
                [F0_X0 + F0_RABBET, floor_z(F0_X0 + F0_RABBET)],
                [F0_X0 + F0_RABBET, floor_z(F0_X0 + F0_RABBET) - t_perp],
                [F0_X0, floor_z(F0_X0) - t_perp],
                [F0_X0, F0_ZB]]);
            translate([F0_X0-1, -ST_L/2+0.0, F0_ZB-1]) cube([F0_X1-F0_X0+2, ST_L, 400]);
        }
        for (s=[-1,1]) translate([F0_X1 - ST_D, 0, F0_ZB]) { leg_pocket(s*LEG_Y_F, depth=F0_POCKET); end_screw(s*LEG_Y_F, zs=12); }
    }
}

// ---------------------------------------------------------------------
// Trog (feste Stufe N mit 90-Grad V-Rinne) + Abweiser + Flansch zu G1
// Rahmen: Modulkoordinaten direkt.  Rinnenachse x=XT, z=ZT.
// ---------------------------------------------------------------------
TR_ZB = TR_ZLIP - CAP_H;
TR_LEGX = (TR_XL + TR_X1)/2;   // Beinmitte x
module trough_profile2d() {
    apx = ZT - CH_APEX;
    polygon([
        [TR_XL, TR_ZB],
        [TR_XL, TR_ZLIP],
        [XT, apx],
        [XT + CH_W/2, ZT + CH_VTOP],
        [XT + CH_W/2, TR_WALL_TOP],
        [TR_X1, TR_WALL_TOP],
        [TR_X1, TR_ZB]]);
}
// Abweiser: hebt zweite Lage an und rollt sie Richtung -x zurueck
module abweiser() {
    xw = XT - CH_W/2;
    hull() {
        // Linie auf der Flanke bei y = ABW_Y0
        // (Punkte 4 mm unter der Flanke -> verschmilzt mit dem Trogkoerper)
        for (p=[[TR_XL+1, TR_ZLIP-1], [xw, ZT + CH_VTOP], [TR_XL+1, TR_ZLIP-5], [xw, ZT + CH_VTOP-4]])
            translate([p[0], ABW_Y0, p[1]]) cube(0.01);
        // Dreieck am Trogende
        for (p=[[TR_XL+1, TR_ZLIP-1], [xw, ZT + CH_VTOP], [xw, ZT + CH_ROOF], [xw-6, ZT+CH_ROOF],
                [TR_XL+1, TR_ZLIP-5], [xw, ZT + CH_VTOP-4]])
            translate([p[0], TR_Y1-0.01, p[1]]) cube(0.01);
    }
}
// Kanal C als 2D (X,n)  -- innen
module channel_inner2d(grow=0) {
    offset(delta=grow) polygon([
        [0, -CH_APEX], [CH_W/2, CH_VTOP], [CH_W/2, CH_ROOF], [-CH_W/2, CH_ROOF], [-CH_W/2, CH_VTOP]]);
}
module rinne_trog() {
    difference() {
        union() {
            rotate([90,0,0]) translate([0,0,-TR_Y1]) linear_extrude(TR_Y1 - TR_Y0) trough_profile2d();
            intersection() {
                abweiser();
                rotate([90,0,0]) translate([0,0,-TR_Y1]) linear_extrude(TR_Y1 - TR_Y0)
                    polygon([[TR_XL, TR_ZB],[TR_XL, ZT+CH_ROOF],[XT+CH_W/2, ZT+CH_ROOF],[XT+CH_W/2,TR_ZB]]);
            }
        }
        // Beine (fest, y=+-100), Querschrauben M5 von der Vorderflaeche (+x)
        for (s=[-1,1]) {
            translate([TR_LEGX - ST_D/2, 0, TR_ZB]) leg_pocket(s*LEG_Y_F);
            translate([(TR_LEGX + TR_X1)/2, s*LEG_Y_F, TR_ZB + CAP_SCREW_Z]) rotate([0,90,0])
                cylinder(d=M5_D, h=TR_X1 - TR_LEGX + 1, center=true, $fn=24);
            translate([TR_X1 - CAP_CB_DEPTH, s*LEG_Y_F, TR_ZB + CAP_SCREW_Z]) rotate([0,90,0])
                cylinder(d=CAP_CB_D, h=CAP_CB_DEPTH + 1, $fn=32);
        }
        // Flansch-Gewindeeinsaetze M3 an Stirnseite y=TR_Y1 (Bild CH_FLANGE_HOLES)
        for (h=CH_FLANGE_HOLES) translate([XT + h[0], TR_Y1 + EPS_CUT, ZT + h[1]]) rotate([90,0,0])
            cylinder(d=M3_INS_D, h=M3_INS_L + 0.5, $fn=24);
        // Lichtschranke ist in G1 -- hier nichts
        // Zentrierstift-Bohrungen 4 mm fuer Flucht zu G1
        for (p=CH_PIN) translate([XT + p[0], TR_Y1 + EPS_CUT, ZT + p[1]]) rotate([90,0,0]) cylinder(d=4.1, h=8, $fn=20);
    }
}
