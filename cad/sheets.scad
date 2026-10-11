// =====================================================================
//  Platten 4 mm (PETG- oder PC-Platte, lebensmittelgeeignet)
//  2D-Konturen fuer DXF (Laser/CNC/Handzuschnitt) + 3D-Platzierung
//  Modulkoordinaten.
// =====================================================================

// Bunkerrand (waagerecht in Welt bei Z_RIM) als lokale z-Hoehe bei y
function z_rim(y) = ZT + (Z_RIM - ROT_Z + (y + C_S)*sin(ALPHA))/cos(ALPHA);
SIDE_TOP_STAIR = TR_WALL_TOP + 12;            // OK Seitenwand ueber Treppe
SIDE_X0 = X_BACK;                             // stoesst an Rueckwand
SIDE_X1 = TR_X1 + 15;
SIDE_STEP_X = APRON_X + SHEET_T + 24;         // Uebergang Bunker -> Treppe
SIDE_BOT_STAIR = -130;
FLOOR_X0 = F0_X0 + F0_RABBET;                 // Vorderkante Bodenplatte (-30.75)
UPRIGHT_STATIONS_POS = [STATIONS[0], STATIONS[1], STATIONS[2], STATIONS[3], STATIONS[4]];
UPRIGHT_STATIONS_NEG = STATIONS;              // -y Seite auch bei POST2

function side_bot(x) = x < -45 ? floor_z(x) - 25 : SIDE_BOT_STAIR;
function side_top(x, sgn) = x <= SIDE_STEP_X ? z_rim(sgn*(SIDE_IN + SHEET_T)) : SIDE_TOP_STAIR;

// Lochpositionen (x,z) fuer Aussenstaender
function upright_holes(sgn) = [
    for (st = (sgn > 0 ? UPRIGHT_STATIONS_POS : UPRIGHT_STATIONS_NEG))
        let(xs = st < X_BACK ? X_BACK + 8 : st,  // Rueckstation: Loch knapp vor Rueckwand
            z0 = side_bot(xs) + 25, z1 = side_top(xs, sgn) - 20,
            n  = max(2, ceil((z1 - z0)/140) + 1))
        if (st >= X_BACK) for (k=[0:n-1]) [st, z0 + k*(z1-z0)/(n-1)] ];

module sheet_side2d(sgn) {
    rimz = z_rim(sgn*(SIDE_IN + SHEET_T));
    difference() {
        polygon(concat(
            [[SIDE_X0, side_bot(SIDE_X0)], [-45, side_bot(-45)], [-45, SIDE_BOT_STAIR], [SIDE_X1, SIDE_BOT_STAIR],
             [SIDE_X1, SIDE_TOP_STAIR], [SIDE_STEP_X, SIDE_TOP_STAIR], [SIDE_STEP_X, rimz], [SIDE_X0, rimz]]));
        for (h = upright_holes(sgn)) translate(h) circle(d=M5_D, $fn=24);
        // Durchbruch Trog (+y Seite), U-foermig nach oben offen
        // Durchbruch fuer Trogende (+y): Trogkontur + Kanal + Abweiser, 0.6 Spiel
        if (sgn > 0) offset(delta=0.6) union() {
            trough_profile2d();
            polygon([[XT-CH_W/2, ZT+CH_VTOP],[XT, ZT-CH_APEX],[XT+CH_W/2, ZT+CH_VTOP],[XT+CH_W/2, ZT+CH_ROOF],[XT-CH_W/2, ZT+CH_ROOF]]);
            polygon([[TR_XL, TR_ZLIP],[XT-CH_W/2, ZT+CH_VTOP],[XT-CH_W/2, ZT+CH_ROOF],[XT-CH_W/2-6, ZT+CH_ROOF]]);
        }
        // Rueckwand-Station: Loecher in Rueckwand, nicht hier
    }
}
module sheet_back2d() {   // (y, z)
    zb = floor_z(X_BACK) - 30;
    difference() {
        polygon([[-XBEAM_HALF, zb], [XBEAM_HALF, zb], [XBEAM_HALF, z_rim(XBEAM_HALF)], [-XBEAM_HALF, z_rim(-XBEAM_HALF)]]);
        for (y=[-OUT_Y, OUT_Y]) let(z0 = zb + 25, z1 = z_rim(y) - 20, n = ceil((z1-z0)/140)+1)
            for (k=[0:n-1]) translate([y, z0 + k*(z1-z0)/(n-1)]) circle(d=M5_D, $fn=24);
        // Bodenleisten-Anschluss (Profil-Enden der Bodentraeger) frei
    }
}
FLOOR_L = (FLOOR_X0 - X_BACK)/cos(FLOOR_SLOPE);
FLOOR_W = 2*(SIDE_IN - 0.5);
module sheet_floor2d() {  // (u entlang Gefaelle ab Vorderkante, y)
    difference() {
        translate([0, -FLOOR_W/2]) square([FLOOR_L - 0.5, FLOOR_W]);
        // Senkkopf M5 (DIN 7991) in Bodentraeger y=+-100
        for (y=[-LEG_Y_F, LEG_Y_F], u=[60 : 140 : FLOOR_L - 40]) translate([u, y]) circle(d=M5_D, $fn=24);
    }
}
module sheet_apron2d() {  // (y, z)
    w = SIDE_IN - 0.5;
    polygon([[-w, APRON_Z], [w, APRON_Z], [w, z_rim(w)], [-w, z_rim(-w)]]);
}

// ------------------------- 3D Platzierung ---------------------------
module sheet3d() { color(C_SHEET) linear_extrude(SHEET_T) children(); }
module place_sheet_side(sgn) {
    y0 = sgn > 0 ? SIDE_IN : -SIDE_IN - SHEET_T;
    translate([0, y0, 0]) rotate([90,0,0]) translate([0,0,-SHEET_T]) sheet3d() sheet_side2d(sgn);
}
module place_sheet_back() {
    translate([X_BACK - SHEET_T, 0, 0]) rotate([90,0,90]) sheet3d() sheet_back2d();
}
module place_sheet_floor() {
    translate([FLOOR_X0, 0, floor_z(FLOOR_X0)]) rotate([0, FLOOR_SLOPE, 0]) rotate([0,0,180]) mirror([0,1,0])
        translate([0,0,-SHEET_T]) sheet3d() sheet_floor2d();
}
module place_sheet_apron() {
    translate([APRON_X, 0, 0]) rotate([90,0,90]) sheet3d() sheet_apron2d();
}
