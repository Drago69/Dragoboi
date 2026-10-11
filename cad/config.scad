// =====================================================================
//  Flaschen-Unscrambler fuer KE-50 Band  --  zentrale Parameter
//  Flasche: Rebhan FPS K-3906.004 (50 ml HD-PE, D30 x 102,5, Hals 24/410)
//
//  Alle Masse in mm, Winkel in Grad.  Diese Datei NUR einbinden
//  (include <config.scad>), sie erzeugt selbst keine Geometrie.
//
//  KOORDINATENSYSTEME
//  ------------------
//  Welt  W : X = Bandlaufrichtung (Flaschen laufen nach +X),
//            Y = quer zum Band (Maschine steht auf -Y Seite),
//            Z = oben, Z=0 Fussboden.  Rotorachse liegt auf der
//            X-Achse bei Y=0, Z=ROT_Z.  Rotormitte bei X=0.
//  Rinne G : Ursprung Rotormitte.  X wie Welt,
//            y = s  (entlang der Rinne, bergab Richtung Anschlag),
//            z = n  (senkrecht zur Rinne, "oben").
//            n = 0 ist die Flaschenachse in der Rinne.
//            G = translate([0,0,ROT_Z]) rotate([-ALPHA,0,0])
//  Modul M : Stufenfoerderer (komplett um ALPHA gekippt)
//            x = Stufen steigen in +x (Bunker bei -x),
//            y = entlang der Stufen (+y bergab = s-Richtung),
//            z = Hubrichtung.
//            M = G * translate([-XT, C_S, -ZT])
//  Rotor R : Achse = z_R (= Welt X), Winkel theta in x_R/y_R Ebene,
//            x_R = Welt Y, y_R = Welt Z - ROT_Z.
// =====================================================================

$fn = 64;
EPS_CUT = 0.01;            // fuer saubere Boolesche Schnitte

// ---------------------------------------------------------------------
// Flasche K-3906.004 (Zeichnung Rebhan, Index B)
// ---------------------------------------------------------------------
B_L       = 102.5;  // Gesamthoehe +-1
B_L_TOL   = 1.0;
B_D       = 30.0;   // Rumpf +-0,3
B_D_TOL   = 0.3;
B_NECK_D  = 23.8;   // Gewinde aussen +-0,2  (24/410)
B_NECK_DR = 21.7;   // Gewindegrund
B_NECK_ID = 18.8;   // Muendung innen
B_NECK_L  = 17.0;   // Halslaenge bis Schulter +-0,2
B_SHOULDER_R = 2.5; // Schulterradius (angenommen)
B_BOTTOM_R   = 2.0; // Bodenradius (angenommen)
B_MASS    = 7;      // g leer

// ---------------------------------------------------------------------
// Band KE-50 (Referenz, bitte vor Ort messen!)
// ---------------------------------------------------------------------
BELT_Z      = 900;  // Oberkante Gurt ueber Boden  <<< MESSEN
BELT_W      = 50;   // Gurtbreite
BELT_FRAME_W= 90;   // Rahmenbreite (nur Darstellung)
GUIDE_GAP   = 34;   // Abstand Seitenfuehrungen (D30 + 4)

// ---------------------------------------------------------------------
// Allgemein
// ---------------------------------------------------------------------
ALPHA   = 28;       // Neigung Stufenfoerderer/Rinne gegen Waagerechte
PROF    = 20;       // Profil 20x20 Nut 6 B-Typ
SLOT_W  = 6.2;
CORE_D  = 4.2;      // Kernbohrung (M5 Gewinde schneidbar)
SHEET_T = 4;        // Plattenstaerke (PETG/PC-Platte)
M3_INS_D = 4.2;  M3_INS_L = 5.7;   // Gewindeeinsatz M3 (Ruthex o.ae.)
M4_INS_D = 5.6;  M4_INS_L = 8.1;
M3_D  = 3.4; M3_HEAD_D = 6.2; M3_HEAD_H = 3.2;
M4_D  = 4.5; M4_HEAD_D = 7.5; M4_HEAD_H = 4.2;
M5_D  = 5.5; M5_HEAD_D = 9.0; M5_HEAD_H = 5.2;

// ---------------------------------------------------------------------
// Kanalprofil C (Rinne, Rotorschacht) -- Querschnitt in (X, n)
// ---------------------------------------------------------------------
CH_W    = 33;                 // lichte Breite
CH_APEX = B_D/2*sqrt(2);      // 21.213: 90-Grad-V, Achse ueber Spitze
CH_ROOF = 18.5;               // Decke ueber Achse (Flasche +15,15)
CH_T    = 3;                  // Wandstaerke
CH_VTOP = -CH_APEX + CH_W/2;  // -4.71: Uebergang V -> senkrechte Wand
CH_KEEL = -27;                // Unterkante Kiel (flach)
CH_CHAMF = 1.2;               // Einlauffase an Stoessen
// Flanschbild (X, n) der Kanalstoesse: Trog->G1->G2->Gehaeuse
CH_FLANGE_HOLES = [[-24,-8],[-24,-22],[24,-22],[24,12]];
CH_PIN = [[-12,-20],[12,-20]];   // Zentrierstifte D4 an allen Kanalstoessen
CH_FLANGE_X = 29;  CH_FLANGE_N1 = CH_ROOF + 3; // 21.5
CH_FLANGE_N0 = CH_KEEL;   // buendig mit Kiel (stuetzfrei druckbar)

// ---------------------------------------------------------------------
// Wendetrommel (Rotor) + Gehaeuse
// ---------------------------------------------------------------------
ROT_Z     = BELT_Z + 172;     // Rotorachse ueber Boden
ROT_R     = 58;               // Rotorradius
ROT_T     = 45;               // Rotordicke (Welt X)
ROT_WALL  = (ROT_T - CH_W)/2; // 6
HOU_RI    = 59;               // Gehaeuse innen
HOU_RO    = 64;               // Gehaeuse aussen
HOU_GAPX  = 1;
HOU_XI    = ROT_T/2 + HOU_GAPX;     // 23.5
HOU_PLATE = 9;
HOU_XO    = HOU_XI + HOU_PLATE;     // 30.5
HOU_BOTTOM = -63.5;                 // flache Unterseite (rel. Rotorachse)
GROOVE_W  = 26.5;             // Halsnut: Hals 23.8 passt, Rumpf 30 nicht
GROOVE_DEPTH = 22;            // Hals taucht ~17 mm ein
LOBE_RO   = 93;
GROOVE_A0 = -55;  GROOVE_A1 = 55;   // volle Tiefe
GROOVE_RAMP_LO = [[-55,22],[-60,2],[-80,0]];  // [Winkel, Tiefe]
GROOVE_RAMP_HI = [[55,22],[75,0]];
LOBE_A0 = -56; LOBE_A1 = 76;   // volle Hoehe, Enden verjuengt
THETA_LOAD = -ALPHA;          // Richtung Schacht-Anschlagende (Ladestellung)
ROT_DUMP_STOP  = -90 - THETA_LOAD;   // -62 : Boden war am Anschlag
ROT_DUMP_ENTRY =  90 - THETA_LOAD;   // +118: Hals war am Anschlag
INLET_S   = -66;              // Anschlussflansch Rinne an Gehaeuse
DROP_Y_IN = 22;               // Abwurfoeffnung (Welt Y) innen
SHAFT_IN_Y = 17.0;            // Fallschacht lichte halbe Breite (Y)
SHAFT_IN_XB = -17.25;         // Fallschacht Rueckwand innen (X)
SHAFT_WALL = 3;
SHAFT_X1  = 50;               // Seitenwaende laufen bis X=+50 aus
SHAFT_GAP = 1.5;              // Abstand Schacht-Unterkante zum Gurt

// Motor (NEMA17, 24 mm Welle) an -X Seite, Abstand-Stutzen
MOT_STUTZEN = 14;
ROT_BOSS_D  = 18;
ROT_BOSS_Z1 = -39;            // Nabe motorseitig bis z_R=-39
NEMA_HOLE = 31/2;             // 15.5
// Leerlaufseite: Lager 688 im Rotor, Stift 8x20 im Gehaeuse
B688_D = 16; B688_W = 5;
PIN8_L = 16;          // Stift 8x16, 9 mm eingepresst + geklebt

// Lichtschranken im Rotor (Schachtkoordinaten s, n bei Ladestellung)
//  Praesenz: von jeder Flasche verdeckt
//  Orient:   nur verdeckt, wenn BODEN am Anschlag (Hals am Einlauf)
SENS_PRES   = [30, 8];
SENS_ORIENT = [-35.2, 0];
SENS_HOLE_D = 4;
SENS_INS_OFF = 11;            // Halter: 2 x M3 im Abstand +-11
HALL_ROT_R  = 45;             // Magnet im Rotor (Referenz Ladestellung)

// ---------------------------------------------------------------------
// Rinne / Vereinzelung (s-Positionen, s=0 Rotormitte)
// ---------------------------------------------------------------------
S_STOP   = HOU_RI;            // Anschlag (Zylinder r=59)
S_GATE   = -77;               // Sperrstift A (Mitte)
GATE_D   = 7;                 // Stiftdurchmesser
S_X2_FRONT = S_GATE - GATE_D/2;                  // -80.5
S_CLAMP  = S_X2_FRONT - B_L - B_L/2;            // -234.25 (Mitte X3)
S_FULL   = -300;              // Lichtschranke "Rinne voll" (in X4)
S_SPLIT  = -190;              // Stoss G1/G2
CLAMP_LEN = 40;               // Klemmstempel Laenge (s)
GATE_TOP_EXT = -CH_APEX + 15; // Stiftoberkante ausgefahren (n)
GATE_STROKE  = 25;

// ---------------------------------------------------------------------
// Stufenfoerderer (Modul-Koordinaten)
// ---------------------------------------------------------------------
ST_N     = 7;          // Anzahl bewegte Stufen
ST_L     = 240;        // Stufenlaenge (y) = Druckteillaenge
ST_D     = 32;         // Stufentiefe (x)
ST_GAP   = 0.75;       // Spalt zwischen Stufen
ST_P     = ST_D + ST_GAP;
ST_BETA  = 10;         // Stufenoberseite faellt nach +x
ST_EPS   = 2.5;        // Ueberhoehung bei Uebergabe
ST_STROKE= 80;         // Hub (= 2 x Exzentrizitaet)
ST_DELTA = ST_D*tan(ST_BETA);                       // 5.64
ST_H     = ST_STROKE - 2*ST_DELTA - 2*ST_EPS;       // 63.7 Stufenhoehe
CAP_H    = 100;        // Hoehe Stufenkappe (an Hinterkante)
CAP_POCKET = 35;       // Tasche fuer Profilbein
LEG_Y_M  = 60;         // Beine bewegte Stufen y=+-60
LEG_Y_F  = 100;        // Beine feste Stufen y=+-100
FLOOR_SLOPE = 10;      // Bunkerboden steigt nach -x (mit 28 Grad Kippung: 29,6 Grad Gefaelle)
SIDE_IN  = ST_L/2 + ST_GAP;   // 120.75 Innenflaeche Seitenwand

function f_lvl(i) = i*ST_H;                    // Vorderkante feste Stufe i
function x_plate(k) = k*ST_P;                  // k=0:M1, 1:F1, 2:M2 ...
function x_M(i) = x_plate(2*(i-1));
function x_F(i) = x_plate(2*i-1);
// Oberkante hinten (hoechster Punkt) bewegte Stufe i bei Hub u (u=0 unten)
function zM_back(i,u) = f_lvl(i-1) - ST_EPS + u;
function zF_back(i)   = f_lvl(i) + ST_DELTA;

// Trog (= feste Stufe N) mit V-Rinne
TR_XL   = x_plate(2*ST_N-1);                 // Lippe (Hinterkante)
TR_ZLIP = f_lvl(ST_N) + ST_DELTA;            // Lippenhoehe
ZT      = TR_ZLIP - 8;                       // Flaschenachse im Trog
XT      = TR_XL + 8 + CH_APEX;               // Rinnenmitte x
TR_FRONT_T = 12;                             // Vorderwand
TR_X1   = XT + CH_W/2 + TR_FRONT_T;          // Vorderkante Trog
TR_WALL_TOP = ZT + 50;
TR_Y0   = -ST_L/2;  TR_Y1 = 126;             // Trog laeuft durch Seitenwand
ABW_Y0  = 60;                                // Abweiser beginnt

// Rinne <-> Modul
S_EXIT  = -344.25;                           // Trogende = Start G1
C_S     = S_EXIT - TR_Y1;                    // s = y + C_S

// Schlitten / Fuehrung
CAR_Z0   = -125;      // OK Laengstraeger Schlitten bei u=0
CAR_LONG_Y = 60;
POST1_X  = -95;       // MGN-Saeule 1 (unter Bunkerboden)
POST2_X  = 540;       // MGN-Saeule 2 (unter Trog)
MGN_H = 13; MGN_RAIL_W = 12; MGN_RAIL_H = 8; MGN_BLK_W = 27; MGN_BLK_L = 45.4;
ADAPT_T  = 8;
CB1_X0 = POST1_X + PROF/2 + MGN_H + ADAPT_T;    // Querholm 1 von x
CB2_X1 = POST2_X - PROF/2 - MGN_H - ADAPT_T;    // Querholm 2 bis x
CAM_X   = (x_F(3) + x_F(4))/2 + ST_D/2;         // zwischen Beinen F3/F4
CAM_E   = ST_STROKE/2;    // 40
CAM_R   = 58;
CAM_T   = 8;
ROLL_R  = 11;             // 608
ROLL_OFF= 22;             // Rollenmitte unter Querholm-UK
CAM_ZS  = (CAR_Z0 - PROF) - ROLL_OFF - (CAM_R + ROLL_R - CAM_E);   // Wellenhoehe
BASE_Z1 = CAM_ZS - 25;    // OK Grundtraeger (y=+-100)
BASE_Z0 = BASE_Z1 - PROF;
XBEAM_Z1 = BASE_Z0;       // OK Querholme unter Grundtraegern
XBEAM_Z0 = XBEAM_Z1 - PROF;
X_BACK  = -750;           // Bunkerrueckwand innen (Bunker ca. 530 Flaschen)
APRON_X = x_F(2) + 12;    // Schuerze ueber F2
APRON_Z = zF_back(2) + 40;
STATIONS = [X_BACK-14, (X_BACK+POST1_X)/2, POST1_X, CAM_X-120, CAM_X+120, POST2_X];
OUT_Y   = SIDE_IN + SHEET_T + PROF/2;   // 134.75 Aussenstaender
XBEAM_HALF = OUT_Y + PROF/2;            // 144.75
Z_RIM   = BELT_Z + 350;   // Bunkerrand (waagerecht, Welt) = Einfuellhoehe

// Schuettvolumen-Schaetzung siehe tools/check.py

// ---------------------------------------------------------------------
// Rotorsaeule / Arm
// ---------------------------------------------------------------------
RPOST_X = -(HOU_XO + PROF/2);   // -40.5
RPOST_Y = -130;
ARM_Z0  = ROT_Z + 85;           // UK Arm (auf Saeule)
ARM_Y1  = 45;
BOOM_X1 = 260;                  // Sensorausleger Stau
STAU_X  = 250;

// ---------------------------------------------------------------------
// Abgeleitete Transformationen
// ---------------------------------------------------------------------
module to_gutter()  { translate([0,0,ROT_Z]) rotate([-ALPHA,0,0]) children(); }
module to_module()  { to_gutter() translate([-XT, C_S, -ZT]) children(); }
// Rotor-Frame: z_R = Welt X, x_R = Welt Y, y_R = Welt Z
module to_rotorR()  { translate([0,0,ROT_Z]) multmatrix([[0,0,1,0],[1,0,0,0],[0,1,0,0],[0,0,0,1]]) children(); }

// Punkt Modul -> Welt (fuer Berechnungen)
function m2w(p) = let(a=ALPHA, y=p[1]+C_S, z=p[2]-ZT)
    [p[0]-XT, y*cos(a) + z*sin(a), ROT_Z - y*sin(a) + z*cos(a)];
// Punkt Rinne (X,s,n) -> Welt
function g2w(p) = let(a=ALPHA) [p[0], p[1]*cos(a)+p[2]*sin(a), ROT_Z - p[1]*sin(a) + p[2]*cos(a)];
// Schachtkoordinaten (s,n) bei Rotorwinkel phi (Grad, Richtung Anschlagende) -> Rotor-Frame (x_R,y_R)
function sn2R(sn, phi) = [sn[0]*cos(phi) - sn[1]*sin(phi), sn[0]*sin(phi) + sn[1]*cos(phi)];

// Farben
C_PRINT  = [0.95,0.55,0.10];
C_PRINT2 = [0.20,0.55,0.85];
C_ALU    = [0.78,0.80,0.83];
C_SHEET  = [0.75,0.88,0.95,0.35];
C_STEEL  = [0.55,0.57,0.60];
C_BLACK  = [0.15,0.15,0.17];
C_BOTTLE = [0.97,0.97,0.93];
C_TPU    = [0.25,0.25,0.25];
