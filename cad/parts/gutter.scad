// =====================================================================
//  Rinne G1 (mit Klemme B + Lichtschranke "voll"), Rinne G2 (Sperre A),
//  Deckel, Klemmbock, Sperrkonsole, Stempel, Sperrstift.
//  Rahmen: Rinnenkoordinaten G  (x = X quer, y = s laengs, z = n).
// =====================================================================

CH_COVER_T = 3;
CH_COVER_X = 26;
CH_FL_T    = 6;           // Stossflansch-Dicke

// Kanal innen (X,n) -- oben offen (wird vom Deckel geschlossen)
module ch_inner2d(grow=0, top=CH_ROOF+5) {
    offset(delta=grow) polygon([
        [0, -CH_APEX], [CH_W/2, CH_VTOP], [CH_W/2, top], [-CH_W/2, top], [-CH_W/2, CH_VTOP]]);
}
// Rinnenkoerper aussen (X,n)
module ch_outer2d() {
    w = CH_W/2 + CH_T;   // 19.5
    polygon([[-w, CH_KEEL], [w, CH_KEEL], [w, 8], [CH_COVER_X, 14.5], [CH_COVER_X, CH_ROOF],
             [-CH_COVER_X, CH_ROOF], [-CH_COVER_X, 14.5], [-w, 8]]);
}
// 2D -> entlang s extrudieren (von s0 bis s1)
module along_s(s0, s1) { translate([0, s1, 0]) rotate([90,0,0]) linear_extrude(s1 - s0) children(); }

// Einlauffase am stromaufwaertigen Ende (s0)
module entry_chamfer(s0) {
    hull() {
        translate([0, s0 - EPS_CUT, 0]) rotate([90,0,0]) linear_extrude(0.01) ch_inner2d(CH_CHAMF);
        translate([0, s0 + CH_CHAMF*1.5, 0]) rotate([90,0,0]) linear_extrude(0.01) ch_inner2d(0);
    }
}

// Stossflansch (Platte senkrecht zu s), s_face = Kontaktflaeche, dir = +1: Platte liegt in +s
module ch_flange(s_face, dir) {
    translate([-CH_FLANGE_X, dir > 0 ? s_face : s_face - CH_FL_T, CH_FLANGE_N0])
        cube([2*CH_FLANGE_X, CH_FL_T, CH_ROOF - CH_FLANGE_N0]);
}
// Bohrungen im Flansch: type "clear" (Durchgang+Kopfseite), "insert" (Gewindeeinsatz)
module ch_flange_holes(s_face, dir, type) {
    for (h = CH_FLANGE_HOLES) translate([h[0], s_face, h[1]]) rotate([-90,0,0]) {
        if (type == "insert") translate([0,0, dir>0 ? -EPS_CUT : -M3_INS_L-0.5]) cylinder(d=M3_INS_D, h=M3_INS_L+0.5+EPS_CUT, $fn=24);
        else cylinder(d=M3_D, h=4*CH_FL_T, center=true, $fn=24);
    }
    for (p = CH_PIN) translate([p[0], s_face, p[1]]) rotate([-90,0,0])
        cylinder(d=4.1, h=2*8, center=true, $fn=20);
}

// Deckel-Gewindeeinsaetze in den Flanschleisten
module cover_inserts(slist) {
    for (s = slist, x = [-23, 23]) translate([x, s, CH_ROOF + EPS_CUT]) mirror([0,0,1]) cylinder(d=M3_INS_D, h=M3_INS_L+0.5, $fn=24);
}

// Lichtschranken-Aufnahme an beiden Waenden bei (s, n=0)
module sensor_pads(s) {
    for (m=[0,1]) mirror([m,0,0]) translate([CH_W/2, s - 16, -7]) cube([CH_T + 6, 32, 14]);
}
module sensor_pad_holes(s) {
    translate([0, s, 0]) rotate([0,90,0]) cylinder(d=SENS_HOLE_D, h=80, center=true, $fn=24);
    for (m=[0,1], ds=[-SENS_INS_OFF, SENS_INS_OFF]) mirror([m,0,0])
        translate([CH_W/2 + CH_T + 6 + EPS_CUT, s + ds, 0]) rotate([0,-90,0]) cylinder(d=M3_INS_D, h=M3_INS_L+0.5, $fn=24);
}

// ---------------------------------------------------------------------
G1_COVER_S = [S_EXIT+14, (S_EXIT+S_CLAMP)/2 - 4, S_CLAMP-12, S_CLAMP+12, S_SPLIT-16];
module rinne_G1() {
    difference() {
        union() {
            along_s(S_EXIT, S_SPLIT) ch_outer2d();
            ch_flange(S_EXIT, +1);
            ch_flange(S_SPLIT, -1);
            sensor_pads(S_FULL);
        }
        along_s(S_EXIT - 1, S_SPLIT + 1) ch_inner2d();
        entry_chamfer(S_EXIT);
        ch_flange_holes(S_EXIT, +1, "clear");
        ch_flange_holes(S_SPLIT, -1, "clear");
        cover_inserts(G1_COVER_S);
        sensor_pad_holes(S_FULL);
        // Gewichtsersparnis im Kiel (nicht durchgehend)
        for (s=[S_EXIT+20 : 40 : S_SPLIT-30]) translate([0, s, CH_KEEL-EPS_CUT]) hull() {
            translate([-6, 0, 0]) cube([12, 22, 0.01]);
            translate([-1, 4, 0]) cube([2, 14, 8]);
        }
    }
}

G2_COVER_S = [S_SPLIT+16, (S_SPLIT+INLET_S)/2, INLET_S-18];
GATE_INS = [[-8, S_GATE-13], [8, S_GATE-13], [-8, S_GATE-23], [8, S_GATE-23]];
module rinne_G2() {
    difference() {
        union() {
            along_s(S_SPLIT, INLET_S) ch_outer2d();
            ch_flange(S_SPLIT, +1);
            ch_flange(INLET_S, -1);
        }
        along_s(S_SPLIT - 1, INLET_S + 1) ch_inner2d();
        entry_chamfer(S_SPLIT);
        ch_flange_holes(S_SPLIT, +1, "insert");
        ch_flange_holes(INLET_S, -1, "clear");
        cover_inserts(G2_COVER_S);
        // Sperrstift-Fuehrung
        translate([0, S_GATE, CH_KEEL - 1]) cylinder(d=GATE_D + 0.6, h=30, $fn=32);
        // Einsaetze fuer Sperrkonsole (von unten)
        for (p = GATE_INS) translate([p[0], p[1], CH_KEEL - EPS_CUT]) cylinder(d=M3_INS_D, h=M3_INS_L+0.5, $fn=24);
    }
}

// ---------------------------------------------------------------------
// Deckel (PETG, 3 mm), optional Fenster fuer Klemmstempel
module deckel(s0, s1, holes, window=false, lead_in=false) {
    difference() {
        translate([-CH_COVER_X, s0, CH_ROOF]) cube([2*CH_COVER_X, s1 - s0, CH_COVER_T]);
        for (s = holes, x = [-23, 23]) translate([x, s, CH_ROOF - 1]) cylinder(d=M3_D, h=10, $fn=24);
        if (window) translate([-12, S_CLAMP - CLAMP_LEN/2 - 1, CH_ROOF - 1]) cube([24, CLAMP_LEN + 2, 10]);
        // Einlauffase unten am stromaufwaertigen Ende
        if (lead_in) translate([-CH_COVER_X-1, s0, CH_ROOF]) rotate([45,0,0]) cube([2*CH_COVER_X+2, 3, 3]);
    }
}
module deckel_G1() deckel(S_EXIT, S_SPLIT, G1_COVER_S, window=true, lead_in=true);
module deckel_G2() deckel(S_SPLIT, INLET_S, G2_COVER_S);

// ---------------------------------------------------------------------
// Klemmbock fuer Zylinder B (ISO 6432 D10 x 10), sitzt auf Deckel G1
CLAMP_PLATE_N = 54;          // UK Zylinderplatte
CLAMP_NOSE_N  = 44;          // Nasenflaeche Zylinder (Gewinde M12 bis 60)
CLAMP_STEMPEL_N0 = 19.0;     // UK Pad (eingefahren)
CLAMP_PAD_T   = 3;
CLAMP_STEMPEL_N1 = 34;
module klemmbock() {
    b = CH_ROOF + CH_COVER_T;   // 21.5 Auflage
    difference() {
        union() {
            for (m=[0,1]) mirror([m,0,0]) {
                translate([13.5, S_CLAMP - 18, b]) cube([CH_COVER_X - 13.5, 36, CLAMP_PLATE_N + 6 - b]);
            }
            translate([-CH_COVER_X, S_CLAMP - 18, CLAMP_PLATE_N]) cube([2*CH_COVER_X, 36, 6]);
        }
        // Zylinderbohrung
        translate([0, S_CLAMP, CLAMP_PLATE_N - 1]) cylinder(d=12.3, h=10, $fn=48);
        // Schrauben M3 durch Fuss + Deckel in Flanscheinsaetze, Kopf versenkt von oben (lang: M3x40)
        for (s=[S_CLAMP-12, S_CLAMP+12], x=[-23,23]) translate([x, s, b-1]) {
            cylinder(d=M3_D, h=60, $fn=24);
            translate([0,0,13]) cylinder(d=M3_HEAD_D+0.6, h=60, $fn=24);   // M3x20
        }
    }
}
// Stempel + Pad (eingefahrene Lage)
module klemmstempel() {
    difference() {
        translate([-10, S_CLAMP - CLAMP_LEN/2, CLAMP_STEMPEL_N0 + CLAMP_PAD_T]) chamfer_box([20, CLAMP_LEN, CLAMP_STEMPEL_N1 - CLAMP_STEMPEL_N0 - CLAMP_PAD_T], 1);
        // Stange M4 + Mutterschlitz seitlich
        translate([0, S_CLAMP, 27]) cylinder(d=4.4, h=20, $fn=24);
        translate([-4, S_CLAMP - 3.6, 26.5]) cube([20, 7.2, 3.4]);
    }
}
module klemmpad() {   // TPU 95A, unter den Stempel kleben
    translate([-10, S_CLAMP - CLAMP_LEN/2, CLAMP_STEMPEL_N0]) chamfer_box([20, CLAMP_LEN, CLAMP_PAD_T], 1);
}

// ---------------------------------------------------------------------
// Sperrkonsole unter G2 (Zylinder A ISO 6432 D10 x 25)
GATE_CAP_L   = 25;
GATE_NOSE_N  = GATE_TOP_EXT - GATE_CAP_L + 8 - (16 + GATE_STROKE);  // -64.2 Nase
GATE_PLATE_N1 = GATE_NOSE_N - 10;     // OK Platte (Mutter dazwischen)
GATE_PLATE_N0 = GATE_PLATE_N1 - 6;
module sperrkonsole() {
    top0 = CH_KEEL - 6;
    s0 = S_GATE - 29; s1 = INLET_S - CH_FL_T - 0.5;
    difference() {
        union() {
            translate([-20, s0, top0]) cube([40, s1 - s0, 6]);                      // Kopfplatte
            for (m=[0,1]) mirror([m,0,0]) translate([12, s0, GATE_PLATE_N0]) cube([5, s1 - s0, top0 - GATE_PLATE_N0]);
            translate([-17, s0, GATE_PLATE_N0]) cube([34, s1 - s0, 6]);           // Zylinderplatte
        }
        translate([0, S_GATE, top0 - 1]) cylinder(d=GATE_D + 0.6, h=10, $fn=32);   // Stiftfuehrung
        translate([0, S_GATE, GATE_PLATE_N0 - 1]) cylinder(d=12.3, h=10, $fn=48);   // M12x1.25
        for (p = GATE_INS) translate([p[0], p[1], top0 - 1]) {
            cylinder(d=M3_D, h=10, $fn=24);
            translate([0,0,-20]) cylinder(d=M3_HEAD_D+0.6, h=20+1+3, $fn=24);
        }
        // Zugang Inbusschluessel durch Zylinderplatte
        for (p = GATE_INS) translate([p[0], p[1], GATE_PLATE_N0 - 1]) cylinder(d=5, h=10, $fn=24);
    }
}
// Sperrstift (Kappe auf Kolbenstange M4, Einsatz M4), ausgefahrene Lage
module sperrstift(n_top = GATE_TOP_EXT) {
    difference() {
        translate([0, S_GATE, n_top - GATE_CAP_L]) hull() {
            cylinder(d=GATE_D, h=GATE_CAP_L - GATE_D/2, $fn=32);
            translate([0,0,GATE_CAP_L - GATE_D/2]) sphere(d=GATE_D, $fn=32);
        }
        // M4 Gewinde schneiden (Kernloch 3.3), mit Schraubensicherung auf Kolbenstange
        translate([0, S_GATE, n_top - GATE_CAP_L - EPS_CUT]) cylinder(d=3.3, h=12, $fn=24);
    }
}
