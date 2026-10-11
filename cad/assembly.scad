// =====================================================================
//  GESAMTBAUGRUPPE  Flaschen-Unscrambler fuer KE-50 (Hakenteller-Zufuehrung)
//  Aufruf:  openscad assembly.scad
//  Parameter (per -D ueberschreibbar):
//    TD_PHI   : Tellerwinkel (Grad, 0 = eine Tasche steht im Uebergabepunkt T)
//    ROT_ANG  : Rotorwinkel relativ zur Ladestellung (0 / ROT_DUMP_STOP / ROT_DUMP_ENTRY)
//    GATE_EXT : true = Sperrstift A ausgefahren (geschlossen)
//    GROUP    : "all" oder eine Gruppe (fuer Kollisionspruefung / Export)
//    SHOW_BOTTLES, SHOW_SHEETS, SHOW_BELT, SHOW_HOOD
// =====================================================================
include <config.scad>
include <lib/basics.scad>
include <parts/gutter.scad>
include <parts/teller.scad>
include <parts/rotor.scad>
include <parts/misc.scad>
include <sheets.scad>

TD_PHI   = 12;
ROT_ANG  = 0;
GATE_EXT = true;
GROUP    = "all";
SHOW_BOTTLES = true;
SHOW_SHEETS  = true;
SHOW_BELT    = true;
SHOW_HOOD    = true;

function g(name) = GROUP == "all" || GROUP == name;
ALL = GROUP == "all";

FOOT_H = 25;                    // Stellfuesse
FLOOR_Z1 = FOOT_H + PROF;       // OK Bodenrahmen

// ---------------------------------------------------------------------
// Profil-Helfer (Weltkoordinaten bzw. aktueller Rahmen)
module beam_x(x0, x1, y, z0, name="Profil 20x20 Nut 6 B-Typ") translate([x0, y, z0 + PROF/2]) rotate([0,90,0]) prof(x1 - x0, name);
module beam_y(y0, y1, x, z0, name="Profil 20x20 Nut 6 B-Typ") translate([x, y0, z0 + PROF/2]) rotate([-90,0,0]) prof(y1 - y0, name);
module post_z(x, y, z0, z1, name="Profil 20x20 Nut 6 B-Typ") translate([x, y, z0]) prof(z1 - z0, name);
module pc(c) color(c) children();

// =====================================================================
// TELLER-RAHMEN: Rueckwand, Holme, Querholme, Lagerbock, Motor (D-Frame)
// =====================================================================
TF_ZC = TF_Z1 - PROF/2;         // Mitte Rahmenholme (z)
TC_ZC = TC_Z1 - PROF/2;         // Mitte Querholme
module grp_teller_frame() {
    to_tellerD() {
        // Rahmen hinter der Rueckwand
        for (s=[-1,1]) prof_between([-BP_X, s*TF_YB, TF_ZC], [BP_X, s*TF_YB, TF_ZC], "Tellerrahmen waagerecht");
        prof_between([TF_XS, -TF_YB + PROF/2, TF_ZC], [TF_XS, TF_YB - PROF/2, TF_ZC], "Tellerrahmen Seite rechts");
        prof_between([-TF_XS, -TF_YB + PROF/2, TF_ZC], [-TF_XS, LS_Y[0], TF_ZC], "Tellerrahmen Seite links unten");
        prof_between([-TF_XS, LS_Y[1], TF_ZC], [-TF_XS, TF_YB - PROF/2, TF_ZC], "Tellerrahmen Seite links oben");
        for (s=[-1,1]) prof_between([s*TC_X, -BP_Y, TC_ZC], [s*TC_X, BP_Y, TC_ZC], "Querholm Lagerung");
        if (SHOW_SHEETS) place_rueckwand();
    }
    to_teller() {
        pc(C_PRINT2) render() lagerbock_teller();
        translate([0,0,GB_Z]) nema17_pg();
    }
    if (ALL) {
        bom("Platte","Rueckwand (sheet_rueckwand.dxf) 4 mm","",1);
        bom("Druckteil","lagerbock_teller","",1);
        bom("Zukauf","Schrittmotor NEMA17 1,7 A mit Planetengetriebe 13,73:1 (z.B. 17HS19-1684S-PG14), Abtrieb D8","",1);
        bom("Zukauf","Rillenkugellager 6001-2RS (12x28x8)","",2);
        bom("Zukauf","Hallsensor A3144 (TO-92) fuer Tellerdrehung","",1);
    }
}

// =====================================================================
// TELLER drehend (TD-Frame): Platte, Haken, Nabe, Welle, Kupplung, Taschenflaschen
// =====================================================================
// Taschenflaschen: steigende Seite (D 270..360) am Randring, oben an der Leiste
function pocket_has_bottle(a) = let(d = ((a - TD_DROT) % 360 + 360) % 360) (d >= 268 || d <= 127.5);
function pocket_r(a) = let(d = ((a - TD_DROT) % 360 + 360) % 360) (d >= 268 ? sqrt(RING_RI*RING_RI - B_L*B_L/4) - B_D/2 - 0.3 : TD_RB);
module grp_disc(phi=TD_PHI) {
    to_teller() rotate([0,0,phi]) {
        pc([0.92,0.92,0.88]) render() tellerplatte();
        pc(C_PRINT) for (k=[0:TD_N-1]) rotate([0,0,k*TD_PITCH]) render() haken();
        pc(C_PRINT2) render() nabe();
        welle_teller();
        kupplung_teller();
        stellring_teller();
        distanzhuelse_teller();
        if (ALL) for (k=[0:TD_N-1]) color(C_STEEL) rotate(k*TD_PITCH) translate([MAG_R, 0, HUB_Z0]) cylinder(d=6, h=3);
    }
    if (SHOW_BOTTLES) to_teller() for (k=[0:TD_N-1]) let(a = phi + k*TD_PITCH) if (pocket_has_bottle(a))
        rotate(a) translate([pocket_r(a), -B_L/2 + 0.2, B_D/2]) rotate([-90,0,0])
            if (GROUP == "all") bottle(); else cylinder(d=B_D, h=B_L, $fn=40);
    if (ALL) {
        bom("Zukauf","Tellerplatte PE-HD 10 mm, D500 nach DXF (sheet_tellerplatte.dxf)","",1);
        bom("Druckteil","haken","",TD_N);
        bom("Druckteil","nabe","",1);
        bom("Zukauf","Welle D12 h6, Silberstahl, 2 Abflachungen","118 mm",1);
        bom("Zukauf","Klauenkupplung D25 L30, 8-12 mm","",1);
        bom("Zukauf","Stellring D12 (DIN 705)","",1);
        bom("Zukauf","Distanzhuelse 12/18 x 6 (Stahl oder Messing), zwischen Nabe und Lager","",1);
        bom("Zukauf","Neodym-Magnet 6x3 (Nabe, je Tasche)","",TD_N);
    }
}

// =====================================================================
// BUNKER: Randring, Bleche, Kantenwinkel, Bodenauflagen (D-Frame)
// =====================================================================
module grp_hopper() {
    to_tellerD() {
        pc(C_PRINT) for (s=[0:len(RING_SEG)-2]) render() randring(s);
        if (SHOW_SHEETS) place_bunkerbleche();
        pc(C_PRINT2) for (k=[0:len(HOP_VALLEYS)-1], t=KW_POS) render() kantenwinkel_at(k, t);
        pc(C_PRINT2) for (x=BA_X) render() bodenauflage_at(x);
    }
    if (ALL) {
        for (s=[0:len(RING_SEG)-2]) bom("Druckteil", str("randring_", s + 1), "", 1);
        bom("Platte","Bunkerboden (sheet_bunker_boden.dxf) 4 mm","",1);
        bom("Platte","Bunkerseite unten (sheet_bunker_seite_unten.dxf) 4 mm, 1x gespiegelt","",2);
        bom("Platte","Bunkerseite oben (sheet_bunker_seite_oben.dxf) 4 mm, 1x gespiegelt","",2);
        bom("Druckteil","kantenwinkel_1 (Boden/Seite)","",4);
        bom("Druckteil","kantenwinkel_2 (Seite/Seite)","",4);
        bom("Druckteil","bodenauflage","",2);
    }
}

// =====================================================================
// UEBERGABE: Pflug/Dach, Auslauf, Deckel, Abstreifer (+ Haube)
// =====================================================================
module grp_transfer() {
    to_gutter() {
        pc(C_PRINT) { render() uebergabe(); render() auslauf(); }
        pc(C_SHEET) deckel_auslauf();
    }
    to_tellerD() pc(C_PRINT2) render() abstreifer();
    if (ALL) for (n=["uebergabe","auslauf","deckel_auslauf","abstreifer"]) bom("Druckteil", n, "", 1);
}
module grp_hood() {
    to_tellerD() {
        pc(C_PRINT2) for (p=HOOD_PTS) translate([p[0], p[1], 0]) haubenhalter();
        if (SHOW_SHEETS && SHOW_HOOD) place_haube();
    }
    if (ALL) { bom("Platte","Haube transparent (sheet_haube.dxf) 4 mm PETG/PC","",1); bom("Druckteil","haubenhalter","",len(HOOD_PTS)); }
}

// =====================================================================
// RINNE (Rinnenkoordinaten)
// =====================================================================
module grp_gutter(gate_ext=GATE_EXT) {
    to_gutter() {
        pc(C_PRINT) { render() rinne_G1(); render() rinne_G2(); }
        pc(C_SHEET) { deckel_G1(); deckel_G2(); }
        pc(C_PRINT2) { klemmbock(); klemmstempel(); sperrkonsole(); sperrstift(gate_ext ? GATE_TOP_EXT : GATE_TOP_EXT - GATE_STROKE); }
        pc(C_TPU) klemmpad();
        translate([0, S_CLAMP, CLAMP_NOSE_N]) mirror([0,0,1]) iso6432(10, 10, 16, 55);
        translate([0, S_CLAMP, CLAMP_PLATE_N - 6]) color(C_STEEL) cylinder(d=21.9, h=6, $fn=6);
        translate([0, S_GATE, GATE_NOSE_N]) iso6432(10, GATE_STROKE, gate_ext ? 16 + GATE_STROKE : 16, 60);
        translate([0, S_GATE, GATE_PLATE_N1]) color(C_STEEL) cylinder(d=21.9, h=6, $fn=6);
        pc(C_PRINT2) {
            translate([-(CH_W/2 + CH_T + 6), S_FULL, 0]) rotate([0,-90,0]) sensorhalter_laser();
            translate([ (CH_W/2 + CH_T + 6), S_FULL, 0]) rotate([0, 90,0]) sensorhalter_pt();
        }
    }
    if (ALL) {
        for (n=["rinne_G1","rinne_G2","deckel_G1","deckel_G2","klemmbock","klemmstempel","sperrkonsole","sperrstift"]) bom("Druckteil", n, "", 1);
        bom("Druckteil","klemmpad (TPU 95A)","",1);
        bom("Zukauf","Pneumatikzylinder ISO 6432 D10 Hub 25, doppeltwirkend (Sperre A)","",1);
        bom("Zukauf","Pneumatikzylinder ISO 6432 D10 Hub 10, doppeltwirkend (Klemme B)","",1);
        bom("Zukauf","Zylinderstift D4x12 ISO 8734 (Kanalstoesse)","",8);
    }
}

// =====================================================================
// GEHAEUSE, ROTOR, SCHACHT, ARM
// =====================================================================
module grp_housing() {
    to_rotorR() {
        pc(C_PRINT) { render() gehaeuse_motorseite(); render() gehaeuse_lagerseite(); }
        pc(C_PRINT2) motorstutzen();
        translate([0,0,-HOU_XO - MOT_STUTZEN]) nema17(shaft_d=4.0);
        color(C_STEEL) translate([0,0,17.9]) cylinder(d=8, h=PIN8_L);
        pc(C_PRINT2) for (p=[P_PRES, P_ORIENT]) {
            translate([p[0], p[1], -HOU_XO]) rotate([180,0,0]) sensorhalter_laser();
            translate([p[0], p[1],  HOU_XO]) sensorhalter_pt();
        }
    }
    pc(C_PRINT) render() fallschacht();
    pc(C_PRINT2) for (x=SENS_SHAFT_X) {
        translate([x, -(SHAFT_IN_Y + SHAFT_WALL + 5), SENS_SHAFT_Z]) rotate([90,0,0]) sensorhalter_laser();
        translate([x,  (SHAFT_IN_Y + SHAFT_WALL + 5), SENS_SHAFT_Z]) rotate([-90,0,0]) sensorhalter_pt();
    }
    beam_y(RPOST_Y - PROF/2, ARM_Y1, RPOST_X, ARM_Z0, "Rotorarm");
    beam_x(RPOST_X - PROF/2, BOOM_X1, 0, ARM_Z0 + PROF, "Sensorausleger");
    pc(C_PRINT2) translate([STAU_X, 0, ARM_Z0 + PROF]) e18_halter();
    translate([STAU_X, -2, BELT_Z + 149]) e18_sensor();
    if (ALL) {
        for (n=["gehaeuse_motorseite","gehaeuse_lagerseite","rotor_motorseite","rotor_lagerseite","motorstutzen","fallschacht","e18_halter"])
            bom("Druckteil", n, "", 1);
        bom("Druckteil","sensorhalter_laser","",5); bom("Druckteil","sensorhalter_pt","",5);
        bom("Zukauf","Schrittmotor NEMA17 42x40, Welle D5x24 mit Abflachung (Rotor)","",1);
        bom("Zukauf","Rillenkugellager 688-2RS (8x16x5)","",1);
        bom("Zukauf","Zylinderstift D8x20 ISO 8734 (Rotorachse Lagerseite)","",1);
        bom("Zukauf","Laserdiodenmodul 650 nm, <1 mW (Klasse 2), D6 mm, 5 V","",5);
        bom("Zukauf","Fototransistor 5 mm (z.B. SFH 300 / LPT80A)","",5);
        bom("Zukauf","Naeherungssensor E18-D80NK (M18, NPN, 3-80 cm)","",1);
        bom("Zukauf","Hallsensor A3144 (TO-92) + Neodym-Magnet 6x3 (Rotor)","",1);
    }
}
module grp_rotor(ang=ROT_ANG) {
    to_rotorR() rotate([0,0,THETA_LOAD + ang]) {
        pc(C_PRINT2) { render() rotor_motorseite(); render() rotor_lagerseite(); }
        color(C_STEEL) translate([0,0,ROT_T/2 - B688_W]) bearing(8.05, 16, 5);
    }
}

// =====================================================================
// GESTELL (Welt): Stuetzen mit Keil unter den Seitenholmen, Bunker-Frontholm,
// Bodenrahmen (waagerechter Rahmen F: u = x_D, w = Tellernormale waagerecht), Rotorsaeule
// =====================================================================
WP_Y = 200;                                         // Stuetzpunkte auf den Seitenholmen (y_D)
KEIL_T = TD_INCL;                                   // Keilwinkel (Holm-Rueckseite)
function wpost(sx, sy) = D2w([sx*TF_XS, sy*WP_Y, TF_Z1 - PROF]);      // Kontakt Keil/Holm
FB_X = 250;                                         // Frontholm-Stuetzen (x_D)
function fb_axis(x) = let(c = D2w(ba_pt(x))) [c[0], c[1], FB_ZTOP - PROF/2];   // Achse Frontholm
// Stuetzfuesse im F-Frame
function uF(p) = w2F(p)[0];
function wF(p) = w2F(p)[1];
U_L  = uF(wpost(-1,-1));  U_R = uF(wpost(1,-1));
W_RE = wF(wpost(1, 1));   W_MI = wF(wpost(1,-1));
U_LF = uF(fb_axis(-FB_X)); W_FR = wF(fb_axis(0));
U_ROT = uF([RPOST_X, RPOST_Y, 0]);  W_ROT = wF([RPOST_X, RPOST_Y, 0]);
FR_E = PROF/2;
module beam_u(u0, u1, w, name) to_floorF() translate([u0, w, FOOT_H + PROF/2]) rotate([0,90,0]) prof(u1 - u0, name);
module beam_w(w0, w1, u, name) to_floorF() translate([u, w0, FOOT_H + PROF/2]) rotate([-90,0,0]) prof(w1 - w0, name);
module grp_world() {
    // Stuetzen + Keile unter den Seitenholmen (Keil steigt Richtung -F_W)
    for (sx=[-1,1], sy=[-1,1]) let(p = wpost(sx, sy)) {
        post_z(p[0], p[1], FLOOR_Z1, p[2] - keil_c(KEIL_T), "Stuetze Tellerrahmen");
        pc(C_PRINT2) translate([p[0], p[1], p[2] - keil_c(KEIL_T)]) rotate([0,0,atan2(-F_W[1], -F_W[0]) - 90]) keil(KEIL_T);
    }
    // Frontholm unter dem Bunkerboden + Stuetzen
    let(a = fb_axis(-FB_X - 30), b = fb_axis(FB_X + 30)) prof_between(a, b, "Bunker-Frontholm");
    for (sx=[-1,1]) let(p = fb_axis(sx*FB_X)) post_z(p[0], p[1], FLOOR_Z1, p[2] - PROF/2, "Stuetze Bunkerfront");
    // Bodenrahmen
    beam_w(W_RE - FR_E, W_FR + FR_E, U_R, "Bodenrahmen laengs");
    beam_w(W_RE - FR_E, W_MI + FR_E, U_L, "Bodenrahmen laengs");
    beam_w(W_MI + FR_E, W_FR + FR_E, U_LF, "Bodenrahmen laengs");
    beam_u(U_L + FR_E, U_R - FR_E, W_RE, "Bodenrahmen quer");
    beam_u(U_L + FR_E, U_R - FR_E, W_MI, "Bodenrahmen quer");
    beam_u(U_LF + FR_E, U_R - FR_E, W_FR, "Bodenrahmen quer");
    // Rotorsaeule: Ausleger + Querholm + Saeule + Streben
    beam_u(U_ROT + FR_E, U_L - FR_E, W_ROT, "Bodenrahmen Rotor");
    beam_w(W_ROT - 140, W_ROT + 100, U_ROT, "Bodenrahmen Rotor");
    post_z(RPOST_X, RPOST_Y, FLOOR_Z1, ARM_Z0, "Rotorsaeule");
    let(pu = F2w([U_ROT + 330, W_ROT, 0]), pw = F2w([U_ROT, W_ROT - 125, 0])) {
        prof_between([RPOST_X, RPOST_Y, 690] + 12*F_U, [pu[0], pu[1], FLOOR_Z1 + 12], "Strebe Rotorsaeule (Gehrung nach Bedarf)");
        prof_between([RPOST_X, RPOST_Y, 690] - 12*F_W, [pw[0], pw[1], FLOOR_Z1 + 12], "Strebe Rotorsaeule (Gehrung nach Bedarf)");
    }
    // Stellfuesse
    color(C_BLACK) for (p=[[U_L,W_RE],[U_R,W_RE],[U_R,W_FR],[U_LF,W_FR],[U_L,W_MI],[U_ROT,W_ROT-130],[U_ROT,W_ROT+90]])
        let(q = F2w([p[0], p[1], 0])) translate([q[0], q[1], 0]) cylinder(d=30, h=FOOT_H);
    if (ALL) {
        bom("Druckteil","keil_teller","",4);
        bom("Zukauf","Stellfuss M8 (oder M5 je nach Profil) D30","",7);
        bom("Zukauf","Gelenkverbinder 20x20 Nut 6","",4);
    }
}

// =====================================================================
// BAND KE-50 (nur Referenz)
// =====================================================================
module grp_belt() {
    color([0.2,0.2,0.22]) translate([-700, -BELT_W/2, BELT_Z - 3]) cube([1600, BELT_W, 3]);
    color([0.5,0.5,0.55,0.6]) translate([-700, -BELT_FRAME_W/2, BELT_Z - 60]) cube([1600, BELT_FRAME_W, 57]);
    color([0.3,0.6,0.3,0.8]) for (s=[-1,1]) translate([SHAFT_X1 + 5, s*(GUIDE_GAP/2 + 1.5) - 1.5, BELT_Z + 15]) cube([850, 3, 30]);
}

// =====================================================================
// FLASCHEN (Nominallagen Rinne, Band)
// =====================================================================
X5_S0 = S_X2_FRONT - 4*B_L - 4*B_L_TOL;          // X5 mit Laengentoleranz (hinterste Lage)
module grp_bottles() {
    to_gutter() {
        bottle_lying(S_STOP - 0.42, -1);                 // X1 im Rotor, Boden am Anschlag
        bottle_lying(S_X2_FRONT - B_L, 1);               // X2 an Sperre A (Hals vorn)
        bottle_lying(S_X2_FRONT - B_L, -1);              // X3 unter Klemme B (Boden vorn)
        bottle_lying(S_X2_FRONT - 3*B_L, 1);             // X4 (Lichtschranke voll)
        bottle_lying(X5_S0, 1);                          // X5 im Auslauf (Hakenbereich frei?)
    }
    for (x=[0, 130, 260]) translate([x, 0, BELT_Z]) bottle();
}

// =====================================================================
if (g("teller_frame")) grp_teller_frame();
if (g("disc"))         grp_disc();
if (g("hopper"))       grp_hopper();
if (g("transfer"))     grp_transfer();
if (g("hood"))         grp_hood();
if (g("gutter"))       grp_gutter();
if (g("housing"))      grp_housing();
if (g("rotor"))        grp_rotor();
if (g("world"))        grp_world();
if (ALL && SHOW_BELT)  grp_belt();
if (ALL && SHOW_BOTTLES) grp_bottles();
if (GROUP == "bottles") grp_bottles();
