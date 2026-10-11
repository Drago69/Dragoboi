// =====================================================================
//  Druckteile in Druckausrichtung (stuetzfrei, auf z=0, Bett 256x256)
//  openscad -D 'PART="haken"' -o haken.stl print.scad
//  Liste aller Teile: PARTS (wird von tools/build_parts.py verwendet)
// =====================================================================
include <config.scad>
include <lib/basics.scad>
include <parts/gutter.scad>
include <parts/teller.scad>
include <parts/rotor.scad>
include <parts/misc.scad>

PART = "haken";

// [Name, Anzahl, Material, Hinweis]
PARTS = [
 ["haken",             10, "PETG", "flach, 5 Waende, 40% Fuellung (Mitnehmer)"],
 ["nabe",               1, "PETG", "Rueckseite unten, 6 Waende, 60% Fuellung"],
 ["lagerbock_teller",   1, "PETG", "Flansch unten, 5 Waende, 40% Fuellung"],
 ["randring_1",         1, "PETG", "Fuss unten"],
 ["randring_2",         1, "PETG", "Fuss unten"],
 ["randring_3",         1, "PETG", "Fuss unten"],
 ["randring_4",         1, "PETG", "Fuss unten"],
 ["randring_5",         1, "PETG", "Fuss unten"],
 ["randring_6",         1, "PETG", "Fuss unten"],
 ["kantenwinkel_1",     4, "PETG", "Kante unten"],
 ["kantenwinkel_2",     4, "PETG", "Kante unten"],
 ["bodenauflage",       2, "PETG", "Holmseite unten"],
 ["abstreifer",         1, "PETG", "Aussenende unten"],
 ["uebergabe",          1, "PETG", "Rinnenlage (Kiel unten), Gleitflaechen 0.15 mm Schicht"],
 ["auslauf",            1, "PETG", "Kiel unten"],
 ["deckel_auslauf",     1, "PETG", "flach (transparentes PETG empfohlen)"],
 ["haubenhalter",       4, "PETG", "stehend"],
 ["keil_teller",        4, "PETG", "flach, 60% Fuellung"],
 ["rinne_G1",           1, "PETG", "auf Kiel"],
 ["rinne_G2",           1, "PETG", "auf Kiel"],
 ["deckel_G1",          1, "PETG", "flach (transparentes PETG empfohlen)"],
 ["deckel_G2",          1, "PETG", "flach"],
 ["klemmbock",          1, "PETG", "Platte unten"],
 ["klemmstempel",       1, "PETG", ""],
 ["klemmpad",           1, "TPU 95A", "unter Stempel kleben"],
 ["sperrkonsole",       1, "PETG", "Zylinderplatte unten"],
 ["sperrstift",         1, "PETG", "stehend, M4 schneiden"],
 ["rotor_motorseite",   1, "PETG", "Trennflaeche unten, 100% Waende um Nabe"],
 ["rotor_lagerseite",   1, "PETG", "Trennflaeche unten"],
 ["gehaeuse_motorseite",1, "PETG", "Aussenplatte unten"],
 ["gehaeuse_lagerseite",1, "PETG", "Aussenplatte unten"],
 ["motorstutzen",       1, "PETG", "Motorseite unten"],
 ["fallschacht",        1, "PETG", "Flansch unten"],
 ["sensorhalter_laser", 5, "PETG schwarz", "Grundplatte unten"],
 ["sensorhalter_pt",    5, "PETG schwarz", "Grundplatte unten"],
 ["e18_halter",         1, "PETG", "auf Steg liegend"],
];

// Nur Drehungen; tools/build_parts.py legt jedes Teil auf z=0 und zentriert es.
module D_world_rot() multmatrix([[F_U[0], Dv2w([0,1,0])[0], Dv2w([0,0,1])[0], 0],
                                 [F_U[1], Dv2w([0,1,0])[1], Dv2w([0,0,1])[1], 0],
                                 [F_U[2], Dv2w([0,1,0])[2], Dv2w([0,0,1])[2], 0], [0,0,0,1]]) children();
module print_part(name) {
    if (name == "haken") haken();                                         // Tellerseite unten
    if (name == "nabe") nabe();                                           // Rueckseite (Muttern, Magnete) unten
    if (name == "lagerbock_teller") rotate([180,0,0]) lagerbock_teller(); // Flansch unten
    for (s=[0:5]) if (name == str("randring_", s + 1)) randring(s);       // Fuss unten
    if (name == "kantenwinkel_1") rotate([0,180,0]) kantenwinkel(kw_dihedral(0));
    if (name == "kantenwinkel_2") rotate([0,180,0]) kantenwinkel(kw_dihedral(1));
    if (name == "bodenauflage") D_world_rot() bodenauflage_at(BA_X[1]);  // Weltlage: Holmseite waagerecht unten
    if (name == "abstreifer") rotate([0,90,0]) rotate([0,0,-STRIP_A]) abstreifer();   // Aussenende unten
    if (name == "uebergabe") uebergabe();                                 // Rinnenlage
    if (name == "auslauf") auslauf();
    if (name == "deckel_auslauf") deckel_auslauf();
    if (name == "haubenhalter") haubenhalter();
    if (name == "keil_teller") keil(TD_INCL);
    if (name == "rinne_G1") rinne_G1();
    if (name == "rinne_G2") rinne_G2();
    if (name == "deckel_G1") deckel_G1();
    if (name == "deckel_G2") deckel_G2();
    if (name == "klemmbock") rotate([180,0,0]) klemmbock();
    if (name == "klemmstempel") klemmstempel();
    if (name == "klemmpad") klemmpad();
    if (name == "sperrkonsole") sperrkonsole();
    if (name == "sperrstift") sperrstift();
    if (name == "rotor_motorseite") rotate([180,0,0]) rotor_motorseite();
    if (name == "rotor_lagerseite") rotor_lagerseite();
    if (name == "gehaeuse_motorseite") gehaeuse_motorseite();
    if (name == "gehaeuse_lagerseite") rotate([180,0,0]) gehaeuse_lagerseite();
    if (name == "motorstutzen") motorstutzen();
    if (name == "fallschacht") rotate([180,0,0]) fallschacht();
    if (name == "sensorhalter_laser") sensorhalter_laser();
    if (name == "sensorhalter_pt") sensorhalter_pt();
    if (name == "e18_halter") rotate([-90,0,0]) e18_halter();
}

print_part(PART);
