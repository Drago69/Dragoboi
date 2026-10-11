// =====================================================================
//  Druckteile in Druckausrichtung (stuetzfrei, auf z=0, Bett 256x256)
//  openscad -D 'PART="rotor_motorseite"' -o rotor_motorseite.stl print.scad
//  Liste aller Teile: PARTS (wird von tools/build.sh verwendet)
// =====================================================================
include <config.scad>
include <lib/basics.scad>
include <parts/stair.scad>
include <parts/gutter.scad>
include <parts/rotor.scad>
include <parts/drive.scad>
include <parts/misc.scad>

PART = "stufe_M";

// [Name, Anzahl, Material, Hinweis]
PARTS = [
 ["stufe_M",            7, "PETG", "liegend auf Rueckseite; 4 Waende, 25% Gyroid"],
 ["stufe_F",            6, "PETG", "liegend auf Rueckseite"],
 ["stufe_F0",           1, "PETG", "liegend auf Vorderflaeche"],
 ["rinne_trog",         1, "PETG", "liegend auf Vorderflaeche, Gleitflaechen 0.15 mm Schicht"],
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
 ["nocke",              1, "PETG", "flach, 6 Waende, 50% Fuellung"],
 ["rollenhalter",       1, "PETG", "Platte unten"],
 ["lagerbock",          1, "PETG", "Lagerachse senkrecht"],
 ["motorbock",          1, "PETG", "Getriebeflansch unten"],
 ["schlitten_adapter",  2, "PETG", "flach"],
 ["hallhalter_hub",     1, "PETG", ""],
 ["keil28",             6, "PETG", "flach, 60% Fuellung"],
 ["keil15",             4, "PETG", "flach"],
 ["sensorhalter_laser", 5, "PETG schwarz", "Grundplatte unten"],
 ["sensorhalter_pt",    5, "PETG schwarz", "Grundplatte unten"],
 ["e18_halter",         1, "PETG", "auf Steg liegend"],
 ["schuerzenwinkel",    8, "PETG", ""],
];

// Nur Drehungen; tools/build_parts.py legt jedes Teil auf z=0 und zentriert es.
module print_part(name) {
    if (name == "stufe_M") rotate([0,-90,0]) stufe_M();               // Rueckseite unten
    if (name == "stufe_F") rotate([0,-90,0]) stufe_F();
    if (name == "stufe_F0") rotate([0, 90,0]) stufe_F0();             // Vorderflaeche unten
    if (name == "rinne_trog") rotate([0, 90,0]) rinne_trog();         // Vorderflaeche unten
    if (name == "rinne_G1") rinne_G1();                               // Kiel unten
    if (name == "rinne_G2") rinne_G2();
    if (name == "deckel_G1") deckel_G1();
    if (name == "deckel_G2") deckel_G2();
    if (name == "klemmbock") rotate([180,0,0]) klemmbock();
    if (name == "klemmstempel") klemmstempel();
    if (name == "klemmpad") klemmpad();
    if (name == "sperrkonsole") sperrkonsole();
    if (name == "sperrstift") sperrstift();
    if (name == "rotor_motorseite") rotate([180,0,0]) rotor_motorseite();   // Trennflaeche unten
    if (name == "rotor_lagerseite") rotor_lagerseite();
    if (name == "gehaeuse_motorseite") gehaeuse_motorseite();                // Aussenplatte unten
    if (name == "gehaeuse_lagerseite") rotate([180,0,0]) gehaeuse_lagerseite();
    if (name == "motorstutzen") motorstutzen();
    if (name == "fallschacht") rotate([180,0,0]) fallschacht();              // Flansch unten
    if (name == "nocke") nocke_local();
    if (name == "rollenhalter") rotate([180,0,0]) rollenhalter(0);
    if (name == "lagerbock") rotate([90,0,0]) lagerbock();                    // Lagerachse senkrecht
    if (name == "motorbock") rotate([90,0,0]) motorbock();                    // Getriebeflansch unten
    if (name == "schlitten_adapter") rotate([0,90,0]) schlitten_adapter(-1, 0);
    if (name == "hallhalter_hub") hallhalter_hub();
    if (name == "keil28") keil28();
    if (name == "keil15") keil15();
    if (name == "sensorhalter_laser") sensorhalter_laser();
    if (name == "sensorhalter_pt") sensorhalter_pt();
    if (name == "e18_halter") rotate([-90,0,0]) e18_halter();
    if (name == "schuerzenwinkel") schuerzenwinkel();
}

print_part(PART);
