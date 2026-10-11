// Einfaches 3-Achs-Gantry in Auslegerbauweise mit Vakuumgreifer
// 3 × V-Slot 2040 hochkant, 3 × Alu-Schlittenplatte 65,5 × 65,5 × 3 mm
// (Radabstand 39,7 × 40 mm, für die 20-mm-Profilseite), 3 × NEMA17
//
//   X: Grundprofil steht hochkant auf dem Grundbrett, GT2-Riemen
//   Y: Ausleger, quer auf dem X-Schlitten, GT2-Riemen
//   Z: senkrecht am Y-Schlitten, T8-Trapezgewindespindel, Vakuumgreifer
//
// Alle Maße in mm. "teil" wählen und rendern (F6 -> STL).
// Jedes Teil liegt dabei schon in Druckrichtung auf z = 0.
// "baugruppe" zeigt die ganze Maschine (Vorschau mit F5).

/* [Ansicht / Export] */
teil = "baugruppe"; // [baugruppe, x_aufsatz, y_aufsatz, klemme, motorkappe, rollenkappe, z_halter, z_aufsatz, z_kopf, z_fuss, greifer]
// Schlittenposition in der Baugruppe (0 = Motorseite, 1 = Gegenseite)
pos_x = 0.45; // [0:0.01:1]
pos_y = 0.55; // [0:0.01:1]
pos_z = 0.35; // [0:0.01:1]

/* [Profillängen] */
laenge_x = 500;
laenge_y = 450;   // Ausleger: über 500 mm wird es weich
laenge_z = 250;
// Höhe der Z-Profil-Unterkante über dem Tisch
z_unten  = 16;

/* [Antrieb] */
motor_l   = 48;   // NEMA17-Gehäuselänge (nur Darstellung)
spindel_l = 250;  // T8-Spindel

/* [Vakuumgreifer] */
saug_d = 20;      // Saugnapf-Durchmesser (nur Darstellung)

/* [Hidden] */
$fn = 48;
eps = 0.01;

// ---------- V-Slot 2040, hochkant ----------
P_B = 20;   // Breite quer (v), diese Seite zeigt zur Schlittenplatte
P_H = 40;   // Höhe (w), Oberseite bei w = 0

// ---------- Alu-Schlittenplatte (Zukaufteil) ----------
pl_a  = 65.5;
pl_t  = 3;
pl_r  = 3;
rad_v = P_B/2 + 9.85;   // 19.85 -> 39,7 mm Lochabstand quer
rad_u = 20;             // 40 mm Radabstand längs
// Bohrungen relativ zur Plattenmitte: [u, v, Ø]. Exzenterseite ist -v.
pl_loecher = concat(
    [for (u = [-20, 0, 20]) [u, -rad_v, 7.2]],
    [for (u = [-10, 10]) [u, -rad_v, 5.1]],
    [for (u = [-20 : 10 : 20]) [u, rad_v, 5.1]],
    [for (u = [-10, 0, 10]) [u, 0, 5.1]],
    [[0, -10, 5.1], [0, 10, 5.1]]
);

// ---------- V-Rad (Solid V-Wheel, 2× 625ZZ) ----------
rad_d  = 23.9;
rad_h  = 10.23;
dist_h = 6.35;                      // Distanzhülse / Exzenterbuchse
spalt  = dist_h - (10 - rad_h/2);   // 1.465: Plattenunterseite über Profil
pl_o   = spalt + pl_t;              // 4.465: Plattenoberseite

// ---------- Bohrungen ----------
m5      = 5.4;
m5_kopf = 10;
m5_sw   = 8;
m3      = 3.4;
m3_sw   = 5.5;
exz_d   = 7.2;
einsatz = 5.6;    // M4-Gewindeeinsatz (einschmelzen)

// ---------- Aufsätze auf den Alu-Platten ----------
ba_t = 4;                  // Grundplatte X/Y
ba_o = pl_o + ba_t;        // 8.465: Auflage der Riemenklemme
kl_e = 14;                 // Klemmzunge ragt so weit über die Platte
kl_b = 11;                 // halbe Breite der Klemmzunge
ax   = pl_a/2 + kl_e;      // 46.75: halbe Länge über alles
kl_u = ax - 6.5;           // Lage der M3-Klemmschrauben

// ---------- GT2-Riemen 6 mm, Scheiben mit 20 Zähnen ----------
// Riemenschlaufe senkrecht über der Profilmitte: unteres Trum liegt in der
// oberen Profilnut, oberes Trum über der Platte, an den Aufsatz geklemmt.
riemen_b = 6;
teil_r   = 20*2/PI/2;                     // 6.37 Wirkradius
od_r     = teil_r - 0.254;                // 6.11 Außenradius Zahnscheibe
w_hi     = ba_o + 0.1 + 0.75 + 0.254;     // Teilkreislinie oberes Trum
w_p      = w_hi - teil_r;                 // Achshöhe Zahnscheibe/Rolle
w_lo     = w_p - teil_r;                  // unteres Trum (in der Nut)

rs_h  = 16;   // Zahnscheibe GT2 20Z, Bohrung 5
rs_d  = 16;
rs_zm = 4.5;  // Zahnmitte vom nabenfernen Ende
ur_h  = 8.5;  // Umlenkrolle GT2 20Z verzahnt, Bohrung 5
ur_d  = 18;

// ---------- Endkappen X/Y ----------
kf     = 10;                  // Flanschdicke (Senkung 5 mm)
pf_w   = 13;                  // Anschlagpfosten bis zu dieser Höhe
mk_up0 = -27.15;              // Motorachse: Langlöcher zum Riemenspannen
mk_up1 = -21.15;              // (Motorgehäuse bleibt hinter dem Profilende)
mk_up  = (mk_up0 + mk_up1)/2;
mp_v0  = -12.5;               // Motorplatte innen
mp_v1  = -18.5;               // Motorplatte außen = Motorflansch
mp_u0  = mk_up0 - 24;
fuss_b = 25;                  // halbe Fußbreite
rk_ui  = kf + 10;             // Achse Umlenkrolle
rk_wv0 = ur_h/2 + 1;          // Wangen der Rollenkappe
rk_wv1 = rk_wv0 + 5;
rk_l   = rk_ui + 10;

// ---------- Z ----------
zs_v  = 44;           // Spindelachse neben dem Z-Profil
zs_w  = -10;
zk_t  = 10;           // Z-Kopfplatte
za_t  = 10;           // Z-Aufsatz
za_o  = pl_o + za_t;  // 14.465 Vorderseite Z-Aufsatz
// Z-Halter (im Y-Schlittenrahmen)
zh_v0 = pl_a/2 + 0.5; // Wand innen
zh_t  = 8;
zh_v1 = zh_v0 + zh_t; // Wand außen = Rückseite Z-Profil
zh_b  = 29;
zh_ft = 8;
zh_w0 = -P_H;
zh_w1 = ba_o + zh_ft + 45;

// ---------- Vakuumgreifer (relativ zur Z-Schlittenmitte) ----------
gr_t  = 6;
gr_ax = za_o + gr_t + 9;  // Achse der Hülse vor dem Profil
gr_u0 = -14;              // Unterkante Halter/Hülse
gr_u1 = 14.5;             // Oberkante Halteplatte
hu_u1 = 18;               // Oberkante Hülse
rohr_u0 = -40;            // Messingrohr 6 × 1, 80 mm
rohr_u1 = 40;
saug_u  = -50;            // Saugnapf-Unterkante

// ---------- Lage der Achsen ----------
y_hoehe = P_H + ba_o + P_H;           // Oberseite Y-Profil über Tisch
z_zb    = z_unten - y_hoehe;          // Z-Unterkante im Y-Rahmen
z_front = zh_v1 + P_H;                // Z-Vorderseite im Y-Rahmen

// Verfahrwege (Schlittenmitte)
xy_min = ax;
z_min  = pl_a/2;
z_max  = min(laenge_z - pl_a/2, laenge_z - 25.5 - 7.5 - 1);   // Platte bzw. T8-Mutter unter der Kupplung
y_soft = pl_a/2 + pl_a/2 + fuss_b + 3;   // Z-Säule frei von X-Profil und X-Kappen

// ============================================================
// Zukaufteile (nur Darstellung)
// ============================================================

module nut_2d() {   // V-Nut, öffnet bei x = 0 nach +x
    polygon([[-0.01,-4.6],[1.6,-3.0],[1.6,-5.2],[4.2,-5.2],[5.8,-3],
             [5.8,3],[4.2,5.2],[1.6,5.2],[1.6,3.0],[-0.01,4.6]]);
}

module profil_2d() { // x = Tiefe (0 = Oberseite .. 40), y = quer (-10 .. 10)
    difference() {
        translate([0, -P_B/2]) square([P_H, P_B]);
        translate([0, 0]) nut_2d();
        translate([P_H, 0]) rotate(180) nut_2d();
        for (x = [10, 30]) {
            translate([x, -P_B/2]) rotate(90) nut_2d();
            translate([x,  P_B/2]) rotate(-90) nut_2d();
            translate([x, 0]) circle(d = 4.2);
        }
    }
}

module profil(l) {
    color([0.78, 0.80, 0.83]) rotate([0, 90, 0]) linear_extrude(l) profil_2d();
}

module alu_platte() {
    color([0.85, 0.86, 0.9]) translate([0, 0, spalt]) difference() {
        linear_extrude(pl_t) offset(r = pl_r) offset(delta = -pl_r) square(pl_a, center = true);
        for (l = pl_loecher) translate([l[0], l[1], -1]) cylinder(d = l[2], h = pl_t + 2);
        for (u = [-27.7, 27.7], v = [-20.15, 0, 20.15])
            hull() for (dv = [-1.75, 1.75]) translate([u, v + dv, -1]) cylinder(d = 3, h = pl_t + 2);
        for (u = [-20, 20])
            hull() for (dv = [-8, 8]) translate([u, dv, -1]) cylinder(d = 5, h = pl_t + 2);
    }
}

module nema17() {    // Flanschfläche bei z = 0, Gehäuse nach +z
    color([0.2, 0.2, 0.22]) translate([-21.15, -21.15, 0]) cube([42.3, 42.3, motor_l]);
    color([0.65, 0.65, 0.68]) {
        translate([0, 0, -2]) cylinder(d = 22, h = 2);
        translate([0, 0, -24]) cylinder(d = 5, h = 24);
    }
}

module zahnscheibe() {  // nabenfernes Ende bei z = 0, Nabe nach +z
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

// Räder im Schlittenrahmen: Linsenkopf ISO 7380 unter dem Rad,
// Scheibe + Stoppmutter oben auf w_m (je Seite -v / +v)
module raeder(w_m_minus, w_m_plus) {
    for (su = [-1, 1], sv = [-1, 1])
        translate([su*rad_u, sv*rad_v, -10]) {
            rad();
            w_m = sv < 0 ? w_m_minus : w_m_plus;
            color([0.6, 0.6, 0.62]) {
                translate([0, 0, rad_h/2]) cylinder(d = sv < 0 ? 10 : 8, h = dist_h, $fn = sv < 0 ? 6 : 24);
                translate([0, 0, -rad_h/2 - 2.75]) cylinder(d = 9.5, h = 2.75);
                translate([0, 0, -rad_h/2]) cylinder(d = 5, h = w_m + 10 + rad_h/2 + 7);
                translate([0, 0, w_m + 10]) cylinder(d = 10, h = 1);
                translate([0, 0, w_m + 10 + 1]) cylinder(d = 8.8, h = 5, $fn = 6);
            }
        }
}

// Riemen als senkrechte Schlaufe (Bänder liegen flach, Breite in v)
module bogen(rechts, wm) {
    translate([0, 0, wm]) rotate([-90, 0, 0]) translate([0, 0, -riemen_b/2]) intersection() {
        difference() {
            cylinder(r = od_r + 0.63, h = riemen_b);
            translate([0, 0, -1]) cylinder(r = od_r - 0.75, h = riemen_b + 2);
        }
        translate([rechts ? 0 : -10, -10, -1]) cube([10, 20, riemen_b + 2]);
    }
}

module riemen(up, ua, c) {
    d = 1.38;
    k = pl_a/2 + 1;   // Klemmauflage beginnt hier
    color([0.1, 0.1, 0.1]) {
        translate([up, -riemen_b/2, w_lo - 0.376]) cube([ua - up, riemen_b, d]);           // unten, in der Nut
        translate([up, -riemen_b/2, w_hi - 1.004]) cube([c - k - up, riemen_b, d]);        // oben, Enden in den Klemmen
        translate([c + k, -riemen_b/2, w_hi - 1.004]) cube([ua - c - k, riemen_b, d]);
        translate([up, 0, 0]) bogen(false, w_p);
        translate([ua, 0, 0]) bogen(true, w_p);
    }
}

module druckteil() { color([0.95, 0.5, 0.1]) children(); }

// ============================================================
// Druckteile
// Rahmen jeder Achse: u = entlang Profil, v = quer, w = zur Schlittenplatte,
// Profiloberseite (20-mm-Seite) bei w = 0. Schlittenteile: Plattenmitte bei u = 0.
// ============================================================

function sechskant(sw) = sw/cos(30) + 0.3;

// Aufsatz auf der X- bzw. Y-Platte: Riemenklemmen an beiden Enden.
// typ "x": zusätzlich Wiege für den Y-Ausleger.
module aufsatz(typ) {
    difference() {
        union() {
            translate([0, 0, pl_o]) linear_extrude(ba_t)
                offset(r = 3) offset(delta = -3) square(pl_a, center = true);
            for (s = [-1, 1])                                       // Klemmzungen
                translate([s > 0 ? pl_a/2 - 3 : -ax, -kl_b, pl_o]) cube([kl_e + 3, 2*kl_b, ba_t]);
            for (s = [-1, 1], i = [0 : 5])                           // Rippen für die Riemenzähne
                translate([s*(ax - 1.5 - i*2) - 0.45, -riemen_b/2 - 1, ba_o - eps]) cube([0.9, riemen_b + 2, 0.6]);
            if (typ == "x")                                          // Wiege, greift in die untere Seitennut
                for (s = [-1, 1]) translate([s > 0 ? 10 : -16, -14, ba_o - eps]) cube([6, 28, 18]);
        }
        for (u = [-rad_u, rad_u]) {                                  // Radschrauben
            translate([u, -rad_v, 0]) cylinder(d = exz_d, h = 50);
            translate([u,  rad_v, 0]) cylinder(d = m5, h = 50);
        }
        if (typ == "x")                                              // Y-Profil von unten (Hammermutter)
            for (v = [-rad_v, rad_v]) translate([0, v, 0]) cylinder(d = v < 0 ? exz_d : m5, h = 50);
        if (typ == "y") translate([0, rad_v, 0]) cylinder(d = m5, h = 50);   // Z-Halter
        for (s = [-1, 1], v = [-7.5, 7.5])                           // Klemmschrauben, Mutter unten
            translate([s*kl_u, v, 0]) {
                cylinder(d = m3, h = 50);
                translate([0, 0, pl_o - 1]) cylinder(d = sechskant(m3_sw), h = 2, $fn = 6);
            }
        if (typ == "x")
            for (v = [-7, 7]) translate([0, v, ba_o + 10]) rotate([0, 90, 0]) cylinder(d = m5, h = 50, center = true);
    }
}

module klemme() {
    difference() {
        translate([-6, -kl_b, 0]) cube([12, 2*kl_b, 5]);
        for (v = [-7.5, 7.5]) translate([0, v, -1]) cylinder(d = m3, h = 7);
    }
}

// M5 in die beiden Kernbohrungen der Stirnseite, Senkung 5 mm außen
module flanschbohrungen(richtung) {   // +1: Flansch bei u = 0..kf, -1: bei u = -kf..0
    for (w = [-10, -30])
        translate([0, 0, w]) rotate([0, richtung*90, 0]) {
            translate([0, 0, -1]) cylinder(d = m5, h = kf + 2);
            translate([0, 0, kf - 5]) cylinder(d = m5_kopf, h = 10);
        }
}

module nutdurchgang() {   // unteres Trum läuft durch den Flansch in die Profilnut
    translate([-kf - 1, -4, w_lo - 1.5]) cube([2*kf + 2, 8, 10]);
}

// Motorkappe (Profilanfang, u <= 0): Motor liegend, Welle quer (+v)
module motorkappe() {
    difference() {
        union() {
            translate([-kf, mp_v1, -P_H]) cube([kf, P_B/2 - mp_v1, P_H + eps]);          // Flansch
            for (s = [-1, 1])                                                          // Anschlag
                translate([-kf, s > 0 ? 5 : -P_B/2, -eps]) cube([kf, 5, pf_w]);
            translate([mp_u0, mp_v1, -P_H]) cube([-kf - mp_u0 + eps, mp_v0 - mp_v1, P_H + w_p + 24]);  // Motorplatte
            translate([mp_u0, -fuss_b, -P_H]) cube([-mp_u0, 2*fuss_b, 5]);                // Fuß
        }
        flanschbohrungen(-1);
        nutdurchgang();
        translate([0, mp_v1 - 1, w_p]) rotate([-90, 0, 0]) {                             // Motor, Langlöcher
            hull() for (u = [mk_up0, mk_up1]) translate([u, 0, 0]) cylinder(d = 24, h = 8);
            for (a = [-1, 1], b = [-1, 1])
                hull() for (u = [mk_up0, mk_up1]) translate([u + a*15.5, b*15.5, 0]) cylinder(d = m3, h = 8);
        }
        for (u = [-15, -45]) translate([u, 18, -P_H - 1]) cylinder(d = 4.5, h = 7);
    }
}

// Rollenkappe (Profilende, u' >= 0): Umlenkrolle auf M5-Achse zwischen zwei Wangen
module rollenkappe() {
    difference() {
        union() {
            translate([0, -P_B/2, -P_H]) cube([kf, P_B, P_H + eps]);                     // Flansch
            for (s = [0, 1]) mirror([0, s, 0])                                          // Wangen = Anschlag
                translate([0, rk_wv0, -P_H]) cube([rk_l, rk_wv1 - rk_wv0, P_H + w_p + 10]);
            translate([0, -fuss_b, -P_H]) cube([rk_l, 2*fuss_b, 5]);                     // Fuß
        }
        flanschbohrungen(1);
        nutdurchgang();
        translate([rk_ui, 0, w_p]) rotate([90, 0, 0]) cylinder(d = m5, h = 30, center = true);
        for (v = [-18, 18]) translate([rk_ui, v, -P_H - 1]) cylinder(d = 4.5, h = 7);
    }
}

// Z-Halter (im Y-Schlittenrahmen): Flansch auf dem Y-Aufsatz, Wand mit Nutfeder
// für die Rückseite des Z-Profils
module z_halter() {
    difference() {
        union() {
            translate([-zh_b, 12, ba_o]) cube([2*zh_b, zh_v0 - 12 + eps, zh_ft]);
            translate([-zh_b, zh_v0, zh_w0]) cube([2*zh_b, zh_t, zh_w1 - zh_w0]);
            translate([-2.9, zh_v1 - eps, zh_w0]) cube([5.8, 1.5 + eps, zh_w1 - zh_w0]);
            for (u = [-zh_b, zh_b - 4]) hull() {
                translate([u, 14, ba_o]) cube([4, zh_v0 - 14 + eps, zh_ft]);
                translate([u, zh_v0 - 1, ba_o]) cube([4, 1 + eps, 40]);
            }
        }
        for (u = [-rad_u, 0, rad_u]) translate([u, rad_v, 0]) cylinder(d = m5, h = 50);
        for (w = [-30, -8, 35, 55])
            translate([0, zh_v0 - 1, w]) rotate([-90, 0, 0]) cylinder(d = m5, h = zh_t + 4);
    }
}

// Z-Aufsatz (Z-Schlittenrahmen): Lasche für die T8-Mutter, Einsätze für den Greifer
module z_aufsatz() {
    difference() {
        union() {
            translate([0, 0, pl_o]) linear_extrude(za_t) offset(r = 3) offset(delta = -3)
                translate([-pl_a/2, -pl_a/2]) square([pl_a, pl_a/2 + 40]);
            translate([-4, 33, -23]) cube([8, zs_v + 14 - 33, za_o + 23]);
            hull() {
                translate([-4 - eps, 33, -23]) cube([eps, 4, pl_o + 23 + 1]);
                translate([-16, 33, pl_o]) cube([eps, 4, 1]);
            }
        }
        for (u = [-rad_u, rad_u], v = [-rad_v, rad_v]) translate([u, v, 0]) {
            cylinder(d = v < 0 ? exz_d : m5, h = 50);
            translate([0, 0, za_o - 6]) cylinder(d = 10.5, h = 7);
        }
        translate([-10, zs_v, zs_w]) rotate([0, 90, 0]) cylinder(d = 10.5, h = 20);
        for (a = [45 : 90 : 315])
            translate([-10, zs_v + 8*cos(a), zs_w + 8*sin(a)]) rotate([0, 90, 0]) cylinder(d = m3, h = 20);
        for (u = [-10, 10], v = [-15, 15]) translate([u, v, za_o - 8]) cylinder(d = einsatz, h = 9);
    }
}

// Z-Kopf: Deckel oben, trägt den Motor neben dem Profil
module z_kopf() {
    difference() {
        union() {
            hull() {
                translate([0, -P_B/2, -P_H]) cube([zk_t, P_B, P_H]);
                translate([0, zs_v - 21.15, zs_w - 21.15]) cube([zk_t, 42.3, 42.3]);
            }
            translate([-25, P_B/2 - eps, -P_H]) cube([25 + zk_t, 5, 21]);   // Schürze, hintere Seitennut
        }
        flanschbohrungen(1);
        translate([-12, P_B/2 - 1, -30]) rotate([-90, 0, 0]) cylinder(d = m5, h = 7);
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
        translate([-8, -P_B/2 - 2, -P_H]) cube([8, P_B + 4, P_H + za_o + 0.5]);
        for (w = [-10, -30])
            translate([0, 0, w]) rotate([0, -90, 0]) {
                translate([0, 0, -1]) cylinder(d = m5, h = 10);
                translate([0, 0, 3]) cylinder(d = m5_kopf, h = 10);
            }
    }
}

// Vakuumgreifer: Halter mit Führungshülse für ein Messingrohr 6 × 1 mm.
// Das Rohr ist zugleich Luftkanal; eine Feder drückt es nach unten (Höhenausgleich).
module greifer() {
    difference() {
        union() {
            translate([gr_u0, -21, za_o]) cube([gr_u1 - gr_u0, 42, gr_t]);
            translate([gr_u0, -5, za_o + gr_t - eps]) cube([hu_u1 - gr_u0, 10, gr_ax - za_o - gr_t + eps]);
            translate([gr_u0, 0, gr_ax]) rotate([0, 90, 0]) cylinder(d = 16, h = hu_u1 - gr_u0);
        }
        translate([gr_u0 - 1, 0, gr_ax]) rotate([0, 90, 0]) {
            cylinder(d = 6.3, h = 50);                                  // Führung oben und unten
            translate([0, 0, 1 + 8]) cylinder(d = 7, h = hu_u1 - gr_u0 - 16);
        }
        for (u = [-10, 10], v = [-15, 15]) translate([u, v, za_o - 1]) {
            cylinder(d = 4.4, h = gr_t + 2);
            translate([0, 0, gr_t + 1 - 3]) cylinder(d = 7.5, h = 10);
        }
    }
}

module greifer_zukauf() {   // Rohr, Stellringe, Feder, Saugnapf
    translate([0, 0, gr_ax]) rotate([0, 90, 0]) {
        color([0.8, 0.65, 0.3]) translate([0, 0, rohr_u0]) difference() {
            cylinder(d = 6, h = rohr_u1 - rohr_u0);
            translate([0, 0, -1]) cylinder(d = 4, h = rohr_u1 - rohr_u0 + 2);
        }
        color([0.6, 0.6, 0.62]) {
            translate([0, 0, hu_u1]) cylinder(d = 12, h = 6);              // Stellring oben
            translate([0, 0, -34]) cylinder(d = 12, h = 6);                // Stellring unten
        }
        color([0.5, 0.5, 0.55]) translate([0, 0, -28]) difference() {    // Feder
            cylinder(d = 9, h = gr_u0 + 28);
            translate([0, 0, -1]) cylinder(d = 7.4, h = gr_u0 + 30);
        }
        color([0.3, 0.45, 0.8]) {                                         // Saugnapf
            translate([0, 0, saug_u + 8]) cylinder(d = 10, h = 8);
            translate([0, 0, saug_u]) cylinder(d1 = saug_d, d2 = 8, h = 8);
        }
    }
}

// ============================================================
// Baugruppe
// ============================================================

module riemenachse(L, c, typ) {
    ua = L + rk_ui;
    profil(L);
    druckteil() motorkappe();
    druckteil() translate([L, 0, 0]) rollenkappe();
    translate([mk_up, mp_v1, w_p]) rotate([90, 0, 0]) nema17();
    translate([mk_up, rs_zm, w_p]) rotate([90, 0, 0]) zahnscheibe();
    translate([ua, 0, w_p]) rotate([90, 0, 0]) umlenkrolle();
    riemen(mk_up, ua, c);
    translate([c, 0, 0]) {
        alu_platte();
        druckteil() aufsatz(typ);
        for (s = [-1, 1]) druckteil() translate([s*kl_u, 0, ba_o + 1.3]) klemme();
        raeder(ba_o, typ == "y" ? ba_o + zh_ft : ba_o);
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
        alu_platte();
        druckteil() z_aufsatz();
        raeder(za_o - 6, za_o - 6);
        translate([4, zs_v, zs_w]) rotate([0, 90, 0]) color([0.8, 0.65, 0.2]) {   // T8-Mutter
            cylinder(d = 22, h = 3.5);
            translate([0, 0, 3.5 - 15]) cylinder(d = 10.2, h = 15);
        }
        druckteil() greifer();
        greifer_zukauf();
    }
}

ZM = [[0, 1, 0, 0], [0, 0, 1, 0], [1, 0, 0, 0], [0, 0, 0, 1]];   // Z-Rahmen -> Y-Rahmen

module baugruppe() {
    cx = xy_min + pos_x * (laenge_x - 2*xy_min);
    cy = y_soft + pos_y * (laenge_y - xy_min - y_soft);
    cz = z_min + pos_z * (z_max - z_min);
    translate([0, 0, P_H])
    riemenachse(laenge_x, cx, "x")
        translate([0, -pl_a/2, ba_o + P_H]) rotate([0, 0, 90])
        riemenachse(laenge_y, cy, "y") {
            druckteil() z_halter();
            translate([0, z_front, z_zb]) multmatrix(ZM) z_achse(cz);
        }
}

// ============================================================
// Ausgabe
// ============================================================

if (teil == "baugruppe")   baugruppe();
if (teil == "x_aufsatz")   translate([0, 0, -pl_o]) aufsatz("x");
if (teil == "y_aufsatz")   translate([0, 0, -pl_o]) aufsatz("y");
if (teil == "klemme")      klemme();
if (teil == "motorkappe")  translate([0, 0, P_H]) motorkappe();
if (teil == "rollenkappe") translate([0, 0, P_H]) rollenkappe();
if (teil == "z_halter")    translate([0, 0, zh_b]) rotate([0, -90, 0]) z_halter();
if (teil == "z_aufsatz")   translate([0, 0, za_o]) rotate([180, 0, 0]) z_aufsatz();
if (teil == "z_kopf")      translate([0, 0, zk_t]) rotate([0, 90, 0]) z_kopf();
if (teil == "z_fuss")      translate([0, 0, 8]) rotate([0, -90, 0]) z_fuss();
if (teil == "greifer")     translate([0, 0, -gr_u0]) rotate([0, -90, 0]) greifer();

// ---------- Kennwerte ----------
function riemen_l(L) = 2*L + 2*rk_ui - 2*mk_up + 2*PI*teil_r - 2*(pl_a/2 + 1);
werkzeug = z_front + gr_ax;
echo(str("Verfahrweg X = ", laenge_x - 2*xy_min, " mm"));
echo(str("Verfahrweg Y = ", laenge_y - xy_min - y_soft, " mm (Y-Schlittenmitte nicht unter ", y_soft, " mm ab Profilanfang)"));
echo(str("Verfahrweg Z = ", z_max - z_min, " mm"));
echo(str("GT2-Riemen X ≈ ", round(riemen_l(laenge_x)), " mm, Y ≈ ", round(riemen_l(laenge_y)), " mm"));
echo(str("Saugnapf: ", werkzeug, " mm neben der X-Schlittenmitte (in -X), Unterkante bei tiefstem Z: ",
         z_unten + z_min + saug_u, " mm (negativ = Feder federt auf dem Tisch ein)"));
if (z_unten + laenge_z - 14 - spindel_l < 0) echo("WARNUNG: Spindel ragt unter die Tischfläche, z_unten erhöhen oder Spindel kürzen");
