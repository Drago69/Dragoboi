// Einfaches 3-Achs-Gantry in Auslegerbauweise
// 3 × V-Slot 2040 (40x20 mm), 3 × NEMA17, 3 × V-Rad-Schlitten
//
//   X: Grundprofil liegt auf dem Tisch, GT2-Riemen
//   Y: Ausleger, sitzt quer auf dem X-Schlitten, GT2-Riemen
//   Z: senkrecht am Y-Schlitten, T8-Trapezgewindespindel
//
// Alle Maße in mm. "teil" wählen und rendern (F6 -> STL).
// Jedes Teil liegt dabei schon in Druckrichtung auf z = 0.
// "baugruppe" zeigt die ganze Maschine (Vorschau mit F5).

/* [Ansicht / Export] */
teil = "baugruppe"; // [baugruppe, schlitten_x, schlitten_y, motorkappe, spannkappe, spannschlitten, z_adapter, z_schlitten, z_kopf, z_fuss]
// Schlittenposition in der Baugruppe (0 = Motorseite, 1 = Gegenseite)
pos_x = 0.45; // [0:0.01:1]
pos_y = 0.65; // [0:0.01:1]
pos_z = 0.35; // [0:0.01:1]

/* [Profillängen] */
laenge_x = 500;
laenge_y = 450;   // Ausleger: über 500 mm wird es weich
laenge_z = 250;
// Höhe der Z-Profil-Unterkante über dem Tisch
z_unten  = 16;

/* [Schlitten] */
schlitten_l   = 100; // X/Y-Schlitten: Länge in Fahrtrichtung
schlitten_b   = 100; // X/Y-Schlitten: Breite quer zum Profil
schlitten_t   = 12;  // Plattendicke (alle Schlitten)
radstand      = 70;  // X/Y: Radabstand in Fahrtrichtung
z_schlitten_l = 90;
z_radstand    = 60;

/* [Antrieb] */
motor_l   = 48;   // NEMA17-Gehäuselänge (nur Darstellung)
spindel_l = 250;  // T8-Spindel

/* [Hidden] */
$fn = 48;
eps = 0.01;

// ---------- V-Slot 2040 ----------
P_B = 40;   // Breite (quer, v)
P_T = 20;   // Tiefe (w), Oberseite bei w = 0

// ---------- V-Rad (Solid V-Wheel, 2× 625ZZ) ----------
rad_d  = 23.9;
rad_h  = 10.23;
rad_v  = P_B/2 + 9.85;             // 29.85 -> 59,7 mm Lochabstand quer (Standard)
dist_h = 6.35;                     // Distanzhülse / Exzenterbuchse
spalt  = dist_h - (P_T/2 - rad_h/2);  // 1.465: Schlittenunterseite über Profil

// ---------- Bohrungen ----------
m5      = 5.4;
m5_kopf = 10;
m5_sw   = 8;
m3      = 3.4;
m3_sw   = 5.5;
exz_d   = 7.2;    // Exzenterbuchse
einsatz = 5.6;    // M4-Gewindeeinsatz (einschmelzen)

// ---------- GT2-Riemen 6 mm, Scheiben mit 20 Zähnen ----------
riemen_b  = 6;
riemen_w0 = 2.5;                        // Unterkante über Profiloberseite
riemen_wm = riemen_w0 + riemen_b/2;     // 5.5 Riemenmitte
od_r      = (20*2/PI - 2*0.254) / 2;    // 6.11 Außenradius Zahnscheibe
riemen_vi = od_r - 0.75;                // 5.36 Zahnspitzen
riemen_va = od_r + 0.63;                // 6.74 Riemenrücken

rs_h  = 16;   // Zahnscheibe GT2 20Z, Bohrung 5: Gesamthöhe
rs_d  = 16;
rs_zm = 4.5;  // Zahnmitte über Unterkante (Nabe oben)
ur_h  = 8.5;  // Umlenkrolle GT2 20Z verzahnt, Bohrung 5
ur_d  = 18;

// ---------- Endkappen X/Y ----------
kf = 10;                                 // Flanschdicke (Senkung 5 mm)
// Motorkappe (u <= 0)
mk_up  = -kf - 12;                       // Achse Zahnscheibe (Motor bleibt hinter dem Profilende)
mk_mp0 = riemen_wm - rs_zm + rs_h + 1;   // 18 Unterkante Motorplatte
mk_mpt = 6;
mk_mp1 = mk_mp0 + mk_mpt;                // 24 Motorflansch
mk_u0  = mk_up - 24;
mk_u1  = mk_up + 24;                     // ragt 2 mm über das Profil (Schlitten läuft darunter)
mk_wv0 = 22;                             // Seitenwände |v|
mk_wv1 = 28;
// Spannschlitten (Maße relativ zur Rollenachse)
ss_o0     = riemen_wm + ur_h/2 + 1;      // 10.75 Unterkante Oberplatte
ss_o1     = ss_o0 + 4;
ss_u1     = riemen_wm - ur_h/2 - 1;      // 0.25 Oberkante Unterarm
ss_u0     = ss_u1 - 6;
ss_vorn   = -14;                         // Steg vor der Rolle
ss_block0 = ur_d/2 + 1;                  // 10
ss_block_l = 18;
ss_hinten = ss_block0 + ss_block_l;      // 28
// Spannkappe (u' >= 0 ab Profilende)
sk_wv0 = 12.5;
sk_wv1 = 18.5;
sk_ai0 = 15;                             // Rollenachse vorn ...
sk_ai1 = 25;                             // ... und hinten (10 mm Spannweg)
sk_ew0 = sk_ai1 + ss_hinten + 1;         // Endwand
sk_ew1 = sk_ew0 + 6;
sk_oben = ss_o1 + 2;
ld_top  = ss_o0 - 0.2;                   // Leisten tragen die Oberplatte

// ---------- Z ----------
zs_v  = 53;          // Spindelachse quer zum Z-Profil (Kupplung frei vom Rad)
zs_w  = -P_T/2;      // mittig in der Profiltiefe
zm_w0 = -23;         // Mutternlasche reicht bis hier nach hinten
zk_t  = 10;          // Kopfplatte
// Z-Adapter (im Y-Schlitten-Rahmen)
za_v0 = schlitten_b/2;   // Wand innen
za_t  = 10;
za_w0 = -18;             // 2 mm über dem X-Schlitten
za_w1 = 85;
za_tb = 8;

// ---------- Lage der Achsen ----------
y_hoehe = P_T + spalt + schlitten_t + P_T;   // Oberseite Y-Profil über Tisch
z_zb    = z_unten - y_hoehe;                 // Z-Unterkante im Y-Rahmen
z_front = za_v0 + za_t + P_T;                // Z-Vorderseite im Y-Rahmen

// Verfahrwege (Schlittenmitte)
xy_min = schlitten_l/2;
z_min  = z_schlitten_l/2;
z_max  = laenge_z - z_schlitten_l/2;
y_soft = schlitten_b/2 + 41.85 + mk_wv1 + 3; // Z-Säule frei von X-Profil/Kappen

function lage(p, l, smin) = smin + p * (l - 2*smin);

// ============================================================
// Zukaufteile (nur Darstellung)
// ============================================================

module nut_2d() {   // V-Nut, öffnet bei x = 0 nach +x
    polygon([[-0.01,-4.6],[1.6,-3.0],[1.6,-5.2],[4.2,-5.2],[5.8,-3],
             [5.8,3],[4.2,5.2],[1.6,5.2],[1.6,3.0],[-0.01,4.6]]);
}

module profil_2d() { // x = Tiefe (0 = Oberseite), y = quer
    difference() {
        translate([0, -P_B/2]) square([P_T, P_B]);
        for (y = [-10, 10]) {
            translate([0, y]) nut_2d();
            translate([P_T, y]) rotate(180) nut_2d();
            translate([P_T/2, y]) circle(d = 4.2);
        }
        translate([P_T/2, -P_B/2]) rotate(90) nut_2d();
        translate([P_T/2,  P_B/2]) rotate(-90) nut_2d();
    }
}

module profil(l) {
    color([0.78, 0.80, 0.83]) rotate([0, 90, 0]) linear_extrude(l) profil_2d();
}

module nema17() {    // Flanschfläche bei z = 0, Gehäuse nach +z
    color([0.2, 0.2, 0.22]) translate([-21.15, -21.15, 0]) cube([42.3, 42.3, motor_l]);
    color([0.65, 0.65, 0.68]) {
        translate([0, 0, -2]) cylinder(d = 22, h = 2);
        translate([0, 0, -24]) cylinder(d = 5, h = 24);
    }
}

module zahnscheibe() {  // Unterkante z = 0, Nabe oben
    color([0.75, 0.75, 0.78]) {
        cylinder(d = rs_d, h = 1);
        cylinder(d = 2*od_r, h = 9);
        translate([0, 0, 8]) cylinder(d = rs_d, h = 1);
        translate([0, 0, 9]) cylinder(d = rs_d, h = rs_h - 9);
    }
}

module umlenkrolle() {  // Mitte z = 0
    color([0.75, 0.75, 0.78]) {
        cylinder(d = 2*od_r, h = ur_h, center = true);
        for (s = [-1, 1]) translate([0, 0, s*(ur_h/2 - 0.5)]) cylinder(d = ur_d, h = 1, center = true);
    }
}

module rad() {          // Achse z, Mitte z = 0
    color([0.12, 0.12, 0.12]) difference() {
        hull() {
            cylinder(r = rad_d/2 - 2.3, h = rad_h, center = true);
            cylinder(r = rad_d/2, h = 1.2, center = true);
        }
        cylinder(d = 5, h = rad_h + 1, center = true);
    }
}

module raeder(rs) {     // im Schlittenrahmen
    for (su = [-1, 1], sv = [-1, 1])
        translate([su*rs/2, sv*rad_v, -P_T/2]) {
            rad();
            color([0.6, 0.6, 0.62]) {
                translate([0, 0, rad_h/2]) cylinder(d = sv > 0 ? 10 : 8, h = dist_h, $fn = sv > 0 ? 6 : 24);
                // Linsenkopf ISO 7380 unter dem Rad, Mutter oben in der Senkung
                translate([0, 0, -rad_h/2 - 2.75]) cylinder(d = 9.5, h = 2.75);
                translate([0, 0, -rad_h/2]) cylinder(d = 5, h = 30);
                translate([0, 0, P_T/2 + spalt + schlitten_t - 6 + 1]) cylinder(d = 8.8, h = 5, $fn = 6);
            }
        }
}

module bogen(rechts) {  // Riemen um Scheibe/Rolle, Unterkante z = 0
    intersection() {
        difference() {
            cylinder(r = riemen_va, h = riemen_b);
            translate([0, 0, -1]) cylinder(r = riemen_vi, h = riemen_b + 2);
        }
        translate([rechts ? 0 : -10, -10, -1]) cube([10, 20, riemen_b + 2]);
    }
}

module riemen(up, ua, c) {
    d = riemen_va - riemen_vi;
    k = c - schlitten_l/2 + 20;     // Riemenenden stecken 20 mm in den Klemmen
    color([0.1, 0.1, 0.1]) translate([0, 0, riemen_w0]) {
        translate([up, -riemen_va, 0]) cube([ua - up, d, riemen_b]);   // Rücklauf
        translate([up, riemen_vi, 0]) cube([k - up, d, riemen_b]);
        translate([c + schlitten_l/2 - 20, riemen_vi, 0]) cube([ua - c - schlitten_l/2 + 20, d, riemen_b]);
        translate([up, 0, 0]) bogen(false);
        translate([ua, 0, 0]) bogen(true);
    }
}

module druckteil() { color([0.95, 0.5, 0.1]) children(); }

// ============================================================
// Druckteile
// Rahmen jeder Achse: u = entlang Profil (x), v = quer (y),
// w = senkrecht zur Schlittenseite (z), Profiloberseite bei w = 0.
// ============================================================

module senk_oben(d, dk, tief) {    // Bohrung mit Senkung von der Plattenoberseite
    translate([0, 0, -1]) cylinder(d = d, h = 50);
    translate([0, 0, spalt + schlitten_t - tief]) cylinder(d = dk, h = tief + 1);
}

// Riemenklemme am +u-Ende: Schlitz von oben, Zähne innen, Boden unten
module klemmschlitz(l) {
    kl = 22;
    difference() {
        translate([l/2 - kl, riemen_vi - 0.05, riemen_w0]) cube([kl + 1, riemen_va - riemen_vi + 0.15, 50]);
        for (i = [0 : 8])
            translate([l/2 - kl + 1 + i*2, riemen_vi - 0.1, riemen_w0 - 1]) cube([0.9, 0.75, 52]);
    }
}

// X/Y-Schlitten. typ "x": Bohrungen für den Y-Ausleger (Hammermuttern),
// typ "y": Bohrungen mit Mutternfallen für den Z-Adapter.
module schlitten(typ) {
    L = schlitten_l; B = schlitten_b; t = schlitten_t;
    difference() {
        translate([0, 0, spalt]) linear_extrude(t)
            offset(r = 4) offset(delta = -4) square([L, B], center = true);
        for (su = [-1, 1]) {
            translate([su*radstand/2, -rad_v, 0]) senk_oben(m5, 10.5, 6);
            translate([su*radstand/2,  rad_v, 0]) senk_oben(exz_d, 10.5, 6);
        }
        // Kanal für das rücklaufende Trum
        translate([-L/2 - 1, -riemen_va - 2.5, -1])
            cube([L + 2, riemen_va - riemen_vi + 5, 1 + riemen_w0 + riemen_b + 1]);
        klemmschlitz(L);
        mirror([1, 0, 0]) klemmschlitz(L);
        if (typ == "x")
            for (u = [-10, 10], v = [-40, -20, 20, 40]) translate([u, v, 0]) {
                translate([0, 0, -1]) cylinder(d = m5, h = 50);
                translate([0, 0, -1]) cylinder(d = m5_kopf, h = spalt + 1 + 5);
            }
        if (typ == "y")
            for (u = [-16, 16], v = [14, 36]) translate([u, v, 0]) {
                translate([0, 0, -1]) cylinder(d = m5, h = 50);
                translate([0, 0, -1]) cylinder(d = m5_sw/cos(30) + 0.3, h = spalt + 1 + 4.5, $fn = 6);
            }
    }
}

// Profilbohrungen M5 in die Stirnseite, Senkung 5 mm auf der Außenseite
module flanschbohrungen(richtung) {   // richtung +1: Flansch bei u = 0..kf, -1: u = -kf..0
    for (v = [-10, 10])
        translate([0, v, -P_T/2]) rotate([0, richtung*90, 0]) {
            translate([0, 0, -1]) cylinder(d = m5, h = kf + 2);
            translate([0, 0, kf - 5]) cylinder(d = m5_kopf, h = 10);
        }
}

// Motorkappe (Profilanfang, u <= 0): NEMA17 senkrecht, Welle nach unten
module motorkappe() {
    difference() {
        union() {
            translate([-kf, -mk_wv1, -P_T]) cube([kf, 2*mk_wv1, P_T + eps]);   // Flansch
            for (s = [-1, 1])                                                   // Pfosten = Anschlag
                translate([-kf, s > 0 ? 12 : -mk_wv1, -eps]) cube([kf, mk_wv1 - 12, mk_mp0 + 2*eps]);
            for (s = [-1, 1])                                                   // Seitenwände
                translate([mk_u0, s > 0 ? mk_wv0 : -mk_wv1, -P_T]) cube([-mk_u0, mk_wv1 - mk_wv0, mk_mp1 + P_T]);
            translate([mk_u0, -mk_wv1, mk_mp0]) cube([mk_u1 - mk_u0, 2*mk_wv1, mk_mpt]);  // Motorplatte
        }
        flanschbohrungen(-1);
        translate([mk_up, 0, mk_mp0 - 1]) cylinder(d = 24, h = mk_mpt + 2);
        for (a = [-1, 1], b = [-1, 1])
            translate([mk_up + a*15.5, b*15.5, mk_mp0 - 1]) cylinder(d = m3, h = mk_mpt + 2);
    }
}

// Spannkappe (Profilende, u' >= 0): Tunnel für den Spannschlitten
module spannkappe() {
    difference() {
        union() {
            translate([0, -P_B/2, -P_T]) cube([kf, P_B, P_T + eps]);            // Flansch
            for (s = [-1, 1])                                                   // Seitenwände
                translate([0, s > 0 ? sk_wv0 : -sk_wv1, -P_T]) cube([sk_ew1, sk_wv1 - sk_wv0, sk_oben + P_T]);
            for (s = [0, 1]) mirror([0, s, 0])                                  // Leisten
                translate([kf - eps, 0, 0]) rotate([90, 0, 90]) linear_extrude(sk_ew0 - kf + 2*eps)
                    polygon([[sk_wv0 + eps, ld_top - 5.5], [sk_wv0 + eps, ld_top], [10, ld_top], [10, ld_top - 2.5]]);
            translate([sk_ew0, -sk_wv1, -P_T]) cube([sk_ew1 - sk_ew0, 2*sk_wv1, sk_oben + P_T]);  // Endwand
        }
        flanschbohrungen(1);
        for (v = [-10, 10])                    // Schlüsselzugang durch die Endwand
            translate([sk_ew0 - 1, v, -P_T/2]) rotate([0, 90, 0]) cylinder(d = m5_kopf, h = 10);
        translate([-1, -8, ss_u0 - 0.75]) cube([kf + 2, 16, 10]);   // Durchgang Unterarm
        translate([sk_ew0 - 1, 0, riemen_wm]) rotate([0, 90, 0]) cylinder(d = m3, h = 10);  // Spannschraube
    }
}

// Spannschlitten mit Umlenkrolle (Rollenachse im Ursprung)
module spannschlitten() {
    difference() {
        union() {
            translate([ss_vorn, -12, ss_o0]) cube([ss_hinten - ss_vorn, 24, ss_o1 - ss_o0]);   // Oberplatte
            translate([ss_vorn, -7, ss_u0]) cube([ss_hinten - ss_vorn, 14, ss_u1 - ss_u0]);    // Unterarm
            translate([ss_vorn, -3.5, ss_u0]) cube([4, 7, ss_o1 - ss_u0]);                     // Steg zwischen den Trums
            translate([ss_block0, -9, ss_u0]) cube([ss_block_l, 18, ss_o1 - ss_u0]);           // Block
        }
        translate([0, 0, ss_u0 - 1]) cylinder(d = m5, h = 30);
        translate([0, 0, ss_u0 - 1]) cylinder(d = m5_sw/cos(30) + 0.3, h = 4.2 + 1, $fn = 6);
        translate([ss_block0 - 1, 0, riemen_wm]) rotate([0, 90, 0]) cylinder(d = m3, h = ss_block_l + 2);
        translate([ss_hinten - 3 - 2.6, -(m3_sw + 0.4)/2, riemen_wm - (m3_sw/cos(30) + 0.4)/2])
            cube([2.6, m3_sw + 0.4, 30]);   // M3-Mutter von oben
    }
}

// Z-Schlitten: 4 Räder, Mutternlasche für T8, Lochbild für das Werkzeug
module z_schlitten() {
    L = z_schlitten_l; t = schlitten_t;
    difference() {
        union() {
            translate([0, 0, spalt]) linear_extrude(t)
                offset(r = 4) offset(delta = -4) translate([-L/2, -42]) square([L, 84]);
            translate([-4, 36, zm_w0]) cube([8, zs_v + 16 - 36, spalt + t - zm_w0]);   // Lasche
            hull() {                                                                  // Rippe
                translate([-4 - eps, 38, zm_w0]) cube([eps, 4, spalt - zm_w0 + 1]);
                translate([-16, 38, spalt]) cube([eps, 4, 1]);
            }
        }
        for (su = [-1, 1]) {
            translate([su*z_radstand/2, -rad_v, 0]) senk_oben(m5, 10.5, 6);
            translate([su*z_radstand/2,  rad_v, 0]) senk_oben(exz_d, 10.5, 6);
        }
        translate([-10, zs_v, zs_w]) rotate([0, 90, 0]) cylinder(d = 10.5, h = 20);
        for (a = [45 : 90 : 315])
            translate([-10, zs_v + 8*cos(a), zs_w + 8*sin(a)]) rotate([0, 90, 0]) cylinder(d = m3, h = 20);
        for (u = [-20, 0, 20], v = [-10, 10])
            translate([u, v, spalt + t - 8]) cylinder(d = einsatz, h = 9);
    }
}

// Z-Kopf: Deckel oben, trägt den Motor neben dem Profil
module z_kopf() {
    difference() {
        union() {
            hull() {
                translate([0, -P_B/2, -P_T]) cube([zk_t, P_B, P_T]);
                translate([0, zs_v - 21.15, zs_w - 21.15]) cube([zk_t, 42.3, 42.3]);
            }
            translate([-22, -P_B/2, -P_T - 5]) cube([22 + zk_t, P_B, 5]);   // Schürze an der Rückseite
        }
        flanschbohrungen(1);
        for (v = [-10, 10]) translate([-12, v, -P_T - 6]) cylinder(d = m5, h = 7);
        translate([-1, zs_v, zs_w]) rotate([0, 90, 0]) cylinder(d = 24, h = zk_t + 2);
        for (a = [-1, 1], b = [-1, 1])
            translate([-1, zs_v + a*15.5, zs_w + b*15.5]) rotate([0, 90, 0]) {
                cylinder(d = m3, h = zk_t + 2);
                cylinder(d = 6.5, h = 1 + 4);
            }
    }
}

// Z-Fuß: Deckel unten, zugleich unterer Anschlag
module z_fuss() {
    difference() {
        translate([-8, -22, -P_T]) cube([8, 44, P_T + spalt + schlitten_t + 0.5]);
        for (v = [-10, 10])
            translate([0, v, -P_T/2]) rotate([0, -90, 0]) {
                translate([0, 0, -1]) cylinder(d = m5, h = 10);
                translate([0, 0, 3]) cylinder(d = m5_kopf, h = 10);
            }
    }
}

// Z-Adapter: Winkel auf dem Y-Schlitten, hält das Z-Profil an seiner Rückseite
module z_adapter() {
    w0 = spalt + schlitten_t;
    difference() {
        union() {
            translate([-28, 8, w0]) cube([56, za_v0 - 8 + eps, za_tb]);
            translate([-28, za_v0, za_w0]) cube([56, za_t, za_w1 - za_w0]);
            for (u = [-28, 23]) hull() {
                translate([u, za_v0 - 30, w0]) cube([5, 30, za_tb]);
                translate([u, za_v0 - 1, w0]) cube([5, 1 + eps, 50]);
            }
        }
        for (u = [-16, 16], v = [14, 36]) translate([u, v, w0 - 1]) cylinder(d = m5, h = za_tb + 2);
        for (u = [-10, 10], w = [-9, 35, 70])
            translate([u, za_v0 - 1, w]) rotate([-90, 0, 0]) cylinder(d = m5, h = za_t + 2);
    }
}

// ============================================================
// Baugruppe
// ============================================================

module riemenachse(L, c, typ) {
    ua = L + (sk_ai0 + sk_ai1)/2;
    profil(L);
    druckteil() motorkappe();
    druckteil() translate([L, 0, 0]) spannkappe();
    druckteil() translate([ua, 0, 0]) spannschlitten();
    translate([mk_up, 0, mk_mp1]) nema17();
    translate([mk_up, 0, riemen_wm - rs_zm]) zahnscheibe();
    translate([ua, 0, riemen_wm]) umlenkrolle();
    riemen(mk_up, ua, c);
    translate([c, 0, 0]) {
        druckteil() schlitten(typ);
        raeder(radstand);
        children();
    }
}

module z_achse(c) {
    profil(laenge_z);
    druckteil() z_fuss();
    druckteil() translate([laenge_z, 0, 0]) z_kopf();
    translate([laenge_z + zk_t, zs_v, zs_w]) rotate([0, 90, 0]) nema17();
    translate([0, zs_v, zs_w]) rotate([0, 90, 0]) {
        color([0.7, 0.7, 0.72]) translate([0, 0, laenge_z - 25.5]) cylinder(d = 20, h = 25);  // Kupplung
        color([0.55, 0.55, 0.58]) translate([0, 0, laenge_z - 14 - spindel_l]) cylinder(d = 8, h = spindel_l);
    }
    translate([c, 0, 0]) {
        druckteil() z_schlitten();
        raeder(z_radstand);
        translate([4, zs_v, zs_w]) rotate([0, 90, 0]) color([0.8, 0.65, 0.2]) {   // T8-Mutter
            cylinder(d = 22, h = 3.5);
            translate([0, 0, 3.5 - 15]) cylinder(d = 10.2, h = 15);
        }
    }
}

module baugruppe() {
    cx = lage(pos_x, laenge_x, xy_min);
    cy = y_soft + pos_y * (laenge_y - xy_min - y_soft);
    cz = z_min + pos_z * (z_max - z_min);
    translate([0, 0, P_T])
    riemenachse(laenge_x, cx, "x")
        translate([0, -schlitten_b/2, spalt + schlitten_t + P_T]) rotate([0, 0, 90])
        riemenachse(laenge_y, cy, "y") {
            druckteil() z_adapter();
            translate([0, z_front, z_zb])
                multmatrix([[0, 1, 0, 0], [0, 0, 1, 0], [1, 0, 0, 0], [0, 0, 0, 1]])
                z_achse(cz);
        }
}

// ============================================================
// Ausgabe
// ============================================================

if (teil == "baugruppe")      baugruppe();
if (teil == "schlitten_x")    translate([0, 0, -spalt]) schlitten("x");
if (teil == "schlitten_y")    translate([0, 0, -spalt]) schlitten("y");
if (teil == "motorkappe")     translate([0, 0, mk_mp1]) rotate([180, 0, 0]) motorkappe();
if (teil == "spannkappe")     translate([0, 0, P_T]) spannkappe();
if (teil == "spannschlitten") translate([0, 0, ss_o1]) rotate([180, 0, 0]) spannschlitten();
if (teil == "z_adapter")      translate([0, 0, 28]) rotate([0, -90, 0]) z_adapter();
if (teil == "z_schlitten")    translate([0, 0, spalt + schlitten_t]) rotate([180, 0, 0]) z_schlitten();
if (teil == "z_kopf")         translate([0, 0, zk_t]) rotate([0, 90, 0]) z_kopf();
if (teil == "z_fuss")         translate([0, 0, 8]) rotate([0, -90, 0]) z_fuss();

// ---------- Kennwerte ----------
riemen_x = 2*laenge_x + 2*(sk_ai0 + sk_ai1)/2 - 2*mk_up + 2*PI*(riemen_vi + riemen_va)/2 - schlitten_l + 40;
riemen_y = 2*laenge_y + 2*(sk_ai0 + sk_ai1)/2 - 2*mk_up + 2*PI*(riemen_vi + riemen_va)/2 - schlitten_l + 40;
echo(str("Verfahrweg X = ", laenge_x - 2*xy_min, " mm"));
echo(str("Verfahrweg Y = ", laenge_y - xy_min - y_soft, " mm (Y-Schlitten nicht unter ", y_soft, " mm ab Profilanfang fahren)"));
echo(str("Verfahrweg Z = ", z_max - z_min, " mm"));
echo(str("GT2-Riemen X ≈ ", round(riemen_x), " mm, Y ≈ ", round(riemen_y), " mm"));
echo(str("Werkzeugplatte: ", z_front + spalt + schlitten_t, " mm neben der X-Schlittenmitte (in -X)"));
if (z_unten + laenge_z - 14 - spindel_l < 0) echo("WARNUNG: Spindel ragt unter die Tischfläche, z_unten erhöhen oder Spindel kürzen");
