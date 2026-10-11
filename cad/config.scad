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
//  Teller TD: schraeger Hakenteller, siehe Abschnitt "Hakenteller".
//            TD = G * translate(TD_C) rotate([0,-45,0])
//  Teller D : wie TD, um z gedreht: x_D waagerecht, y_D bergauf.
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
ALPHA   = 28;       // Neigung Rinne gegen Waagerechte (bestimmt auch die Tellerlage)
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
// Hakenteller (schraeger Drehteller mit Haken)  --  Teller-Frame TD
//   Ursprung = Tellermitte auf der Tellerflaeche, z = Flaechennormale
//   (Seite der Flaschen), x = radial zum Uebergabepunkt T, y = Laufrichtung
//   der Flasche in T (= +s der Rinne).  Die Tellerflaeche ist die +X-Flanke
//   der 90-Grad-V-Rinne, die Hakenleiste/der Pflug die -X-Flanke.
//   Winkel "D" (Bunker): x_D waagerecht, y_D bergauf;  Winkel_TD = Winkel_D + TD_DROT.
// ---------------------------------------------------------------------
S_EXIT  = -344.25;      // Stoss Auslauf -> Rinne G1
TD_R    = 250;          // Tellerplatte D500 (PE-HD 10 mm, Zukauf/Zuschnitt)
TD_T    = 10;
TD_RB   = 228.7;        // Bahnradius Flaschenachse
TD_RL   = TD_RB - B_D/2;        // 213.7  Hakenleiste aussen = Pflugflaeche = -X-Flanke
TD_N    = 10;           // Anzahl Haken
TD_PITCH= 360/TD_N;
TD_RPM  = 15;           // Nenndrehzahl (Firmware: feed_rpm)
HK_RI   = 196;          // Haken innen
HK_H    = 17;           // Hakenhoehe ueber Tellerflaeche
HK_PT   = 8;            // Mitnehmer tangential
HK_PR   = 232.2;        // Mitnehmer aussen (ueber Flaschenmitte hinaus)
HK_YR   = -B_L/2 - 0.75;        // Mitnehmerflaeche -52
HK_YF   = 44;           // Leistenende vorn
HK_SCREW= [[205,-30],[205,22]]; // M4-Senkschrauben von hinten (Haken-Frame)
PLOW_Z0 = HK_H + 1;     // Unterkante Pflug ueber Tellerflaeche
S_T     = -590;         // Uebergabepunkt T (Flaschenmitte, Rinne s)
TD_GRAV = [-cos(ALPHA)/sqrt(2), sin(ALPHA), -cos(ALPHA)/sqrt(2)];   // Schwerkraft im TD
TD_BOT_ANG = atan2(TD_GRAV[1], TD_GRAV[0]);     // 143.06 tiefster Punkt (TD)
TD_TOP_ANG = TD_BOT_ANG - 180;                  // -36.94 hoechster Punkt (TD)
TD_DROT = TD_TOP_ANG - 90;                      // D-Frame = TD um z gedreht
TD_INCL = acos(cos(ALPHA)/sqrt(2));             // 51.37 Tellerneigung gegen Waagerechte
TD_C    = [(B_D/2 - TD_RB)/sqrt(2), S_T, -(TD_RB + B_D/2)/sqrt(2)];  // Tellermitte (Rinne)
// Randring (D-Frame): haelt die Flaschen in den Taschen auf der steigenden Seite
RING_RI  = 251.5;       // innen = Ausschnitt Rueckwand (Flaschenecken reichen bis r 249)
RING_H   = 40;          // Hoehe (z), darauf stehen die Bunkerbleche
TD_HOLE  = 251.5;       // Ausschnitt Rueckwand
RING_A0  = 160;         // D-Winkel Anfang (links oben, wird am Auslauf beschnitten)
RING_A1  = 395;         // D-Winkel Ende (rechts, 35 Grad)
RING_SEG = [160, 205, 250, 290, 330, 365, 395];   // Teilung Druckteile
STRIP_A  = 57;          // Abstreifer zweite Lage (D-Winkel)
// Bunker: Facetten-Trichter auf dem Randring (D-Frame)
//   Jede Facette: Gerade in z = RING_H tangential an Kreis HOP_RT bei D-Winkel,
//   um 'tilt' nach aussen gekippt.  Boden: Weltneigung HOP_FLOOR.
HOP_RT    = 252;
HOP_FLOOR = 28;
HOP_TF    = 90 - TD_INCL - HOP_FLOOR;           // 10.63
HOP_FACETS = [[270, HOP_TF], [230, 20], [195, 25], [310, 20], [345, 25]];
Z_RIM   = BELT_Z + 340;  // Fuellhoehe = Bunkerrand (waagerecht), unter dem Auslauf
// Haube ueber der oberen Tellerhaelfte (Schutz + Ueberfuellung)
HOOD_Z  = 70;
// Rueckwand (Platte) + Tellerrahmen (D-Frame, hinter der Rueckwand)
BP_X    = 334;  BP_Y = 282;      // Rueckwand +-BP_X, +-BP_Y
TF_Z1   = -SHEET_T;              // Vorderseite Rahmen
TF_XS   = BP_X - PROF/2;         // Seitenholme (Mitte)
TF_YB   = BP_Y - PROF/2;         // oberer/unterer Holm (Mitte)
TC_X    = 50;                    // Querholme Lagerung (Mitte), hinter dem Rahmen
TC_Z1   = TF_Z1 - PROF;          // Vorderseite Querholme (-24)
// Antrieb
HUB_D   = 66;  HUB_L = 30;  HUB_PCD = 40;  HUB_SPIGOT = 20;
SHAFT_D = 12;  SHAFT_L = 118;          // Welle von z=-6 bis -124
MAG_R   = 27;                    // Magnete in Nabe (je Tasche einer)
LB_Z0   = TC_Z1 - PROF;          // Lagerbock Vorderseite (-44) an Querholmen
LB_B1   = LB_Z0 - 2;             // vorderes Lager 6001 (Vorderkante)
LB_B2   = LB_Z0 - 48;            // hinteres Lager (Hinterkante)
GB_Z    = LB_Z0 - 100;           // Getriebeflansch
WORLD_POST_X = 250;              // Stuetzen unter den Rahmenholmen (x_D)
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
module to_teller()  { to_gutter() translate(TD_C) rotate([0,-45,0]) children(); }
module to_tellerD() { to_teller() rotate([0,0,TD_DROT]) children(); }
// Rotor-Frame: z_R = Welt X, x_R = Welt Y, y_R = Welt Z
module to_rotorR()  { translate([0,0,ROT_Z]) multmatrix([[0,0,1,0],[1,0,0,0],[0,1,0,0],[0,0,0,1]]) children(); }

// Punkt Rinne (X,s,n) -> Welt
function g2w(p) = let(a=ALPHA) [p[0], p[1]*cos(a)+p[2]*sin(a), ROT_Z - p[1]*sin(a) + p[2]*cos(a)];
// Punkt Teller-Frame -> Rinne / Welt
function td2g(p) = TD_C + [p[0]*cos(45) - p[2]*sin(45), p[1], p[0]*sin(45) + p[2]*cos(45)];
function td2w(p) = g2w(td2g(p));
function D2td(p) = let(a = TD_DROT) [p[0]*cos(a) - p[1]*sin(a), p[0]*sin(a) + p[1]*cos(a), p[2]];
function D2w(p)  = td2w(D2td(p));
function Dv2w(v) = D2w(v) - D2w([0,0,0]);
// Bodenrahmen-Frame F (waagerecht): u = x_D, w = waagerechter Anteil der Tellernormale
F_U = Dv2w([1,0,0]);
F_W = let(n = Dv2w([0,0,1])) [n[0], n[1], 0]/norm([n[0], n[1], 0]);
module to_floorF() multmatrix([[F_U[0], F_W[0], 0, 0], [F_U[1], F_W[1], 0, 0], [0,0,1,0], [0,0,0,1]]) children();
function F2w(p) = [p[0]*F_U[0] + p[1]*F_W[0], p[0]*F_U[1] + p[1]*F_W[1], p[2]];
function w2F(p) = [p[0]*F_U[0] + p[1]*F_U[1], p[0]*F_W[0] + p[1]*F_W[1], p[2]];
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
