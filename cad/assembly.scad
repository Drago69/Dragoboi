// =====================================================================
//  GESAMTBAUGRUPPE  Flaschen-Unscrambler fuer KE-50
//  Aufruf:  openscad assembly.scad
//  Parameter (per -D ueberschreibbar):
//    CAM_PHI  : Nockenwinkel 0..360 (0 = Hub oben, 180 = unten)
//    ROT_ANG  : Rotorwinkel relativ zur Ladestellung (0 / ROT_DUMP_STOP / ROT_DUMP_ENTRY)
//    GATE_EXT : true = Sperrstift A ausgefahren (geschlossen)
//    GROUP    : "all" oder eine Gruppe (fuer Kollisionspruefung / Export)
//    SHOW_BOTTLES, SHOW_SHEETS, SHOW_BELT
// =====================================================================
include <config.scad>
include <lib/basics.scad>
include <parts/stair.scad>
include <parts/gutter.scad>
include <parts/rotor.scad>
include <parts/drive.scad>
include <parts/misc.scad>
include <sheets.scad>

CAM_PHI  = 180;
ROT_ANG  = 0;
GATE_EXT = true;
GROUP    = "all";
SHOW_BOTTLES = true;
SHOW_SHEETS  = true;
SHOW_BELT    = true;

U = cam_lift(CAM_PHI);          // aktueller Hub (0 unten .. 80 oben)
function g(name) = GROUP == "all" || GROUP == name;
ALL = GROUP == "all";

FOOT_H = 25;                    // Stellfuesse M8/M5
function zt(x) = floor_z(x) - SHEET_T/cos(FLOOR_SLOPE);   // UK Bodenplatte
FLOOR_Z1 = FOOT_H + PROF;       // OK Bodenrahmen

// ---------------------------------------------------------------------
// Profil-Helfer (Modul- oder Weltkoordinaten)
module beam_x(x0, x1, y, z0, name="Profil 20x20 Nut 6 B-Typ") translate([x0, y, z0 + PROF/2]) rotate([0,90,0]) prof(x1 - x0, name);
module beam_y(y0, y1, x, z0, name="Profil 20x20 Nut 6 B-Typ") translate([x, y0, z0 + PROF/2]) rotate([-90,0,0]) prof(y1 - y0, name);
module post_z(x, y, z0, z1, name="Profil 20x20 Nut 6 B-Typ") translate([x, y, z0]) prof(z1 - z0, name);
module pc(c) color(c) children();

// =====================================================================
// MODUL fest
// =====================================================================
module grp_module_fixed() {
    // Stufen
    pc(C_PRINT) {
        stufe_F0();
        for (i=[1:ST_N-1]) place_F(i) stufe_F();
        rinne_trog();
    }
    if (ALL) { bom("Druckteil","stufe_F0","",1); bom("Druckteil","stufe_F","",ST_N-1); bom("Druckteil","rinne_trog","",1); }
    // Beine feste Stufen (y = +-100)
    for (s=[-1,1]) {
        post_z(F0_X1 - ST_D/2, s*LEG_Y_F, BASE_Z1, F0_ZB + F0_POCKET, "Bein F0");
        for (i=[1:ST_N-1]) post_z(x_F(i) + ST_D/2, s*LEG_Y_F, BASE_Z1, zF_back(i) - CAP_H + CAP_POCKET, str("Bein F", i));
        post_z(TR_LEGX, s*LEG_Y_F, BASE_Z1, TR_ZB + CAP_POCKET, "Bein Trog");
    }
    // Grundtraeger y=+-100 und Stationsquerholme
    for (s=[-1,1]) beam_x(STATIONS[0] - PROF/2, POST2_X + PROF/2, s*LEG_Y_F, BASE_Z0, "Grundtraeger");
    for (st=STATIONS) beam_y(-XBEAM_HALF, XBEAM_HALF, st, XBEAM_Z0, "Stationsquerholm");
    // MGN-Saeulen + Schienen
    for (px=[POST1_X, POST2_X]) post_z(px, 0, XBEAM_Z1, 15, "MGN-Saeule");
    color(C_STEEL) {
        translate([POST1_X + PROF/2, 0, -185]) mgn12_rail(200);
        translate([POST2_X - PROF/2, 0, -185]) mirror([1,0,0]) mgn12_rail(200);
    }
    if (ALL) bom("Zukauf","Linearfuehrung MGN12H, Schiene 200 mm + 1 Wagen","",2);
    // Aussenstaender fuer Seitenwaende
    for (st=STATIONS, s=[-1,1]) if (!(s > 0 && st == POST2_X))
        post_z(st, s*OUT_Y, XBEAM_Z1, st < X_BACK ? z_rim(s*OUT_Y) - 5 : side_top(st, s) - 5, "Aussenstaender");
    // Lagerbock, Motorbock, Motor, Welle
    pc(C_PRINT) { lagerbock(); motorbock(); }
    if (ALL) { bom("Druckteil","lagerbock","",1); bom("Druckteil","motorbock","",1); }
    translate([CAM_X, MB_Y_FLANGE, CAM_ZS]) rotate([-90,0,0]) nema17_pg();
    color(C_STEEL) {
        translate([CAM_X, -140, CAM_ZS]) rotate([-90,0,0]) cylinder(d=20, h=25);       // Klauenkupplung
        translate([CAM_X, -127, CAM_ZS]) rotate([-90,0,0]) cylinder(d=8, h=233);       // Welle
        for (y=[-85.5, 77.5]) translate([CAM_X, y, CAM_ZS]) rotate([-90,0,0]) cylinder(d=16, h=8); // Stellringe
        for (y=[-LEG_Y_F, LEG_Y_F]) translate([CAM_X, y - 3.5, CAM_ZS]) rotate([-90,0,0]) bearing(8, 22, 7);
    }
    if (ALL) {
        bom("Zukauf","Schrittmotor NEMA17 1,7 A mit Planetengetriebe 13,73:1 (z.B. 17HS19-1684S-PG14), Abtrieb D8","",1);
        bom("Zukauf","Klauenkupplung D20 L25, 8-8 mm","",1);
        bom("Zukauf","Welle D8 h6, Silberstahl","233 mm",1);
        bom("Zukauf","Rillenkugellager 608-2RS","",3);
        bom("Zukauf","Stellring D8 (DIN 705)","",2);
        bom("Zukauf","Flanschkupplung starr D8 (Flansch D22, 4xM3 LK16)","",1);
    }
    // Bunkerboden: Traeger 15 Grad, Stuetzen, Keile
    nrm = [sin(FLOOR_SLOPE), 0, cos(FLOOR_SLOPE)];
    for (s=[-1,1]) {
        p0 = [-50, s*LEG_Y_F, zt(-50)] - 10*nrm;  p1 = [X_BACK + 2, s*LEG_Y_F, zt(X_BACK + 2)] - 10*nrm;
        prof_between(p0, p1, "Bodentraeger 15 Grad");
        for (xs=[-80, X_BACK + 40]) {
            zk = zt(xs) - PROF/cos(FLOOR_SLOPE) - (6 + 32*tan(FLOOR_SLOPE));
            post_z(xs, s*LEG_Y_F, BASE_Z1, zk, "Bodenstuetze");
            pc(C_PRINT) translate([xs, s*LEG_Y_F, zk]) rotate([0,0,90]) keil15();
        }
    }
    if (ALL) bom("Druckteil","keil15","",4);
    // Platten
    if (SHOW_SHEETS) {
        place_sheet_side(-1); place_sheet_side(1); place_sheet_back(); place_sheet_floor(); place_sheet_apron();
        pc(C_PRINT2) for (s=[-1,1]) {
            for (z=[APRON_Z + 15, (APRON_Z + z_rim(s*SIDE_IN))/2]) translate([APRON_X, s*SIDE_IN, z]) mirror([0, s>0?1:0, 0]) mirror([1,0,0]) schuerzenwinkel();
            for (z=[floor_z(X_BACK) + 20, z_rim(s*SIDE_IN) - 45]) translate([X_BACK, s*SIDE_IN, z]) mirror([0, s>0?1:0, 0]) schuerzenwinkel();
        }
        if (ALL) {
            bom("Platte","Seitenwand links  (sheet_side_neg.dxf) 4 mm","",1);
            bom("Platte","Seitenwand rechts (sheet_side_pos.dxf) 4 mm","",1);
            bom("Platte","Rueckwand (sheet_back.dxf) 4 mm","",1);
            bom("Platte","Bunkerboden (sheet_floor.dxf) 4 mm","",1);
            bom("Platte","Schuerze (sheet_apron.dxf) 4 mm","",1);
            bom("Druckteil","schuerzenwinkel","",8);
        }
    }
    // Hallsensor "Hub unten"
    pc(C_PRINT2) hallhalter_hub();
    if (ALL) bom("Druckteil","hallhalter_hub","",1);
}

// =====================================================================
// MODUL bewegt (Schlitten) bei Hub u
// =====================================================================
module grp_carriage(u=U) {
    pc(C_PRINT) for (i=[1:ST_N]) place_M(i, u) stufe_M();
    if (ALL) bom("Druckteil","stufe_M","",ST_N);
    translate([0,0,u]) {
        for (s=[-1,1]) {
            beam_x(CB1_X0 + PROF, CB2_X1 - PROF, s*CAR_LONG_Y, CAR_Z0 - PROF, "Schlitten-Laengstraeger");
            for (i=[1:ST_N]) post_z(x_M(i) + ST_D/2, s*LEG_Y_M, CAR_Z0, zM_back(i,0) - CAP_H + CAP_POCKET, str("Bein M", i));
        }
        for (x0=[CB1_X0, CB2_X1 - PROF]) beam_y(-CAR_LONG_Y - PROF/2, CAR_LONG_Y + PROF/2, x0 + PROF/2, CAR_Z0 - PROF, "Schlitten-Querholm");
        beam_y(-CAR_LONG_Y + PROF/2, CAR_LONG_Y - PROF/2, CAM_X, CAR_Z0 - PROF, "Schlitten-Mittelholm");
        // MGN-Wagen
        translate([POST1_X + PROF/2, 0, 0]) mgn12h_block(CAR_Z0 - PROF/2);
        translate([POST2_X - PROF/2, 0, 0]) mirror([1,0,0]) mgn12h_block(CAR_Z0 - PROF/2);
        color(C_STEEL) translate([CAM_X, -3.5, CAR_Z0 - PROF - ROLL_OFF]) rotate([-90,0,0]) bearing(8, 22, 7);
        color(C_STEEL) translate([CAM_X, -17, CAR_Z0 - PROF - ROLL_OFF]) rotate([-90,0,0]) cylinder(d=8, h=34);
        if (ALL) magnet6x3();
    }
    pc(C_PRINT2) { schlitten_adapter(-1, u); schlitten_adapter(1, u); rollenhalter(u); }
    if (ALL) { bom("Druckteil","schlitten_adapter","",2); bom("Druckteil","rollenhalter","",1);
               bom("Normteil","Schraube M8x40 ISO 4762 + Mutter M8 + 2 Scheiben (Rollenachse)","",1); }
}

module grp_cam(phi=CAM_PHI) {
    pc(C_PRINT2) nocke(phi);
    if (ALL) bom("Druckteil","nocke","",1);
}

// =====================================================================
// RINNE (Rinnenkoordinaten)
// =====================================================================
module grp_gutter(gate_ext=GATE_EXT) {
    to_gutter() {
        pc(C_PRINT) { rinne_G1(); rinne_G2(); }
        pc(C_SHEET) { deckel_G1(); deckel_G2(); }
        pc(C_PRINT2) { klemmbock(); klemmstempel(); sperrkonsole(); sperrstift(gate_ext ? GATE_TOP_EXT : GATE_TOP_EXT - GATE_STROKE); }
        pc(C_TPU) klemmpad();
        // Zylinder B (Klemme, eingefahren) und A (Sperre)
        translate([0, S_CLAMP, CLAMP_NOSE_N]) mirror([0,0,1]) iso6432(10, 10, 16, 55);
        translate([0, S_CLAMP, CLAMP_PLATE_N - 6]) color(C_STEEL) cylinder(d=21.9, h=6, $fn=6);
        translate([0, S_GATE, GATE_NOSE_N]) iso6432(10, GATE_STROKE, gate_ext ? 16 + GATE_STROKE : 16, 60);
        translate([0, S_GATE, GATE_PLATE_N1]) color(C_STEEL) cylinder(d=21.9, h=6, $fn=6);
        // Lichtschranke "Rinne voll"
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
        bom("Zukauf","Zylinderstift D4x12 ISO 8734 (Kanalstoesse)","",6);
    }
}

// =====================================================================
// GEHAEUSE, ROTOR, SCHACHT, ARM
// =====================================================================
module grp_housing() {
    to_rotorR() {
        pc(C_PRINT) { gehaeuse_motorseite(); gehaeuse_lagerseite(); }
        pc(C_PRINT2) motorstutzen();
        translate([0,0,-HOU_XO - MOT_STUTZEN]) nema17(shaft_d=4.0);   // D-Welle vereinfacht
        color(C_STEEL) translate([0,0,17.9]) cylinder(d=8, h=PIN8_L);
        pc(C_PRINT2) for (p=[P_PRES, P_ORIENT]) {
            translate([p[0], p[1], -HOU_XO]) rotate([180,0,0]) sensorhalter_laser();
            translate([p[0], p[1],  HOU_XO]) sensorhalter_pt();
        }
    }
    pc(C_PRINT) fallschacht();
    pc(C_PRINT2) for (x=SENS_SHAFT_X) {
        translate([x, -(SHAFT_IN_Y + SHAFT_WALL + 5), SENS_SHAFT_Z]) rotate([90,0,0]) sensorhalter_laser();
        translate([x,  (SHAFT_IN_Y + SHAFT_WALL + 5), SENS_SHAFT_Z]) rotate([-90,0,0]) sensorhalter_pt();
    }
    // Arm + Sensorausleger + Stau-Sensor
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
        bom("Zukauf","Hallsensor A3144 (TO-92) + Neodym-Magnet 6x3","",2);
    }
}
module grp_rotor(ang=ROT_ANG) {
    to_rotorR() rotate([0,0,THETA_LOAD + ang]) {
        pc(C_PRINT2) { rotor_motorseite(); rotor_lagerseite(); }
        color(C_STEEL) translate([0,0,ROT_T/2 - B688_W]) bearing(8.05, 16, 5);
    }
}

// =====================================================================
// GESTELL (Welt)
// =====================================================================
SUP_STATIONS = [STATIONS[0], STATIONS[2], STATIONS[5]];
function sup_top(st, s) = m2w([st, s*OUT_Y, XBEAM_Z0]);
Y_NEG = sup_top(STATIONS[0], -1)[1];
Y_POS = sup_top(STATIONS[0],  1)[1];
X_MIN = STATIONS[0] - XT - 40;
X_MAX = POST2_X - XT + 40;
KEIL_C = 6 + 32*tan(ALPHA);        // Hoehe Keilmitte

module grp_world() {
    // Bodenrahmen Modul
    for (y=[Y_NEG, Y_POS]) beam_x(X_MIN, X_MAX, y, FOOT_H, "Bodenrahmen Laengs");
    for (x=[X_MIN + PROF/2, X_MAX - PROF/2, (STATIONS[2]-XT)]) beam_y(Y_NEG + PROF/2, Y_POS - PROF/2, x, FOOT_H, "Bodenrahmen Quer");
    // Stuetzen + Keile unter den Stationsquerholmen
    for (st=SUP_STATIONS, s=[-1,1]) {
        p = sup_top(st, s);
        post_z(p[0], p[1], FLOOR_Z1, p[2] - KEIL_C - 0.05, "Modulstuetze");
        pc(C_PRINT2) translate([p[0], p[1], p[2] - KEIL_C - 0.05]) rotate([0,0,180]) keil28();
    }
    // Rotorsaeule + Bodenrahmen Rotor
    beam_y(Y_POS + PROF/2, RPOST_Y + PROF/2, RPOST_X, FOOT_H, "Bodenrahmen Rotor");
    beam_y(Y_POS + PROF/2, RPOST_Y + PROF/2, -410, FOOT_H, "Bodenrahmen Rotor");
    beam_x(-410 + PROF/2, RPOST_X - PROF/2, RPOST_Y, FOOT_H, "Bodenrahmen Rotor");
    post_z(RPOST_X, RPOST_Y, FLOOR_Z1, ARM_Z0, "Rotorsaeule");
    // Diagonalstreben (Gelenkverbinder an beiden Enden)
    prof_between([RPOST_X, RPOST_Y - PROF/2 - 2, 690], [RPOST_X, -470, FLOOR_Z1 + 12], "Strebe Rotorsaeule (Gehrung nach Bedarf)");
    prof_between([RPOST_X - PROF/2 - 2, RPOST_Y, 690], [-385, RPOST_Y, FLOOR_Z1 + 12], "Strebe Rotorsaeule (Gehrung nach Bedarf)");
    // Fuesse
    color(C_BLACK) for (p=[[X_MIN+10,Y_NEG],[X_MAX-10,Y_NEG],[X_MIN+10,Y_POS],[X_MAX-10,Y_POS],[-410,RPOST_Y],[RPOST_X,RPOST_Y]])
        translate([p[0], p[1], 0]) cylinder(d=30, h=FOOT_H);
    if (ALL) {
        bom("Druckteil","keil28","",6);
        bom("Zukauf","Stellfuss M8 (oder M5 je nach Profil) D30","",6);
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
// FLASCHEN (Nominallagen)
// =====================================================================
module grp_bottles() {
    // Rinne / Rotor (Rinnenkoordinaten; Rotor in Ladestellung)
    to_gutter() {
        bottle_lying(S_STOP - 0.42, -1);                 // X1 im Rotor, Boden am Anschlag
        bottle_lying(S_X2_FRONT - B_L, 1);               // X2 an Sperre A (Hals vorn)
        bottle_lying(S_X2_FRONT - B_L, -1);              // X3 unter Klemme B (Boden vorn)
        bottle_lying(S_X2_FRONT - 3*B_L, 1);             // X4 (Lichtschranke voll)
    }
    // auf Stufen (Modul)
    to_module() {
        for (k=[[2, 50], [4, -30], [5, 60], [6, 10]]) let(i=k[0])
            translate([x_F(i) + ST_D - B_D/2 - 1, k[1] - B_L/2, zF_back(i) - ST_DELTA/2 + B_D/2/cos(ST_BETA) + 0.3]) rotate([-90,0,0]) bottle();
        // ein paar im Bunker
        for (k=[[-120, -40], [-200, 30], [-300, -50], [-420, 20]])
            translate([k[0], k[1] - B_L/2, floor_z(k[0]) + B_D/2/cos(FLOOR_SLOPE) + 0.3]) rotate([-90,0,0]) bottle();
    }
    // Schacht / Band
    for (x=[0, 130, 260]) translate([x, 0, BELT_Z]) bottle();
}

// =====================================================================
if (g("module_fixed")) to_module() grp_module_fixed();
if (g("carriage"))     to_module() grp_carriage();
if (g("cam"))          to_module() grp_cam();
if (g("gutter"))       grp_gutter();
if (g("housing"))      grp_housing();
if (g("rotor"))        grp_rotor();
if (g("world"))        grp_world();
if (ALL && SHOW_BELT)  grp_belt();
if (ALL && SHOW_BOTTLES) grp_bottles();
if (GROUP == "bottles") grp_bottles();
