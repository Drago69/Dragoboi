// Rührwerk (Schrägblattrührer) für 8 mm Welle – ausgelegt für TPU-Druck
// Einsatz: Wasser bis ca. 80 °C
//
// Alle Maße in mm. Parameter anpassen und in OpenSCAD neu rendern (F6 -> STL).

/* [Welle] */
welle_d        = 8;     // Wellendurchmesser
bohrung_spiel  = -0.2;  // negativ = Presssitz (TPU dehnt sich), 0 = Nennmaß
d_flat         = true;  // Abflachung in der Bohrung (für Welle mit D-Profil)
d_flat_tiefe   = 0.5;   // Tiefe der Abflachung (Standard D-Welle 8 mm: 0.5)
madenschraube  = true;  // Querbohrung + Mutternfalle für M4 Madenschraube

/* [Nabe] */
nabe_d         = 20;    // Außendurchmesser Nabe
nabe_h         = 22;    // Höhe Nabe

/* [Rührflügel] */
fluegel_anzahl = 4;
ruehrer_d      = 60;    // Gesamtdurchmesser über die Flügel
fluegel_h      = 16;    // Flügelbreite (in Achsrichtung, vor dem Anstellen)
fluegel_dicke  = 3.5;   // dick wählen: TPU wird bei 80 °C weicher
anstellwinkel  = 45;    // 45° = axial + radial fördernd, 0° = rein radial
fluegel_z      = 4;     // Höhe der Flügelmitte über Nabenunterkante + h/2
kanten_r       = 1;     // Abrundung der Flügelkanten

$fn = 64;

bohrung_d = welle_d + bohrung_spiel;

module fluegel() {
    l = ruehrer_d / 2 - nabe_d / 2 + 2;   // ragt 2 mm in die Nabe
    translate([nabe_d / 2 - 2, 0, 0])
        rotate([anstellwinkel, 0, 0])
            // abgerundete Platte, radial entlang X
            hull()
                for (y = [-fluegel_dicke / 2 + kanten_r, fluegel_dicke / 2 - kanten_r])
                for (z = [-fluegel_h / 2 + kanten_r, fluegel_h / 2 - kanten_r])
                    translate([0, y, z])
                        rotate([0, 90, 0])
                            cylinder(r = kanten_r, h = l, $fn = 24);
}

module bohrung() {
    difference() {
        translate([0, 0, -1]) cylinder(d = bohrung_d, h = nabe_h + 2);
        if (d_flat)
            translate([bohrung_d / 2 - d_flat_tiefe, -bohrung_d, -2])
                cube([bohrung_d, 2 * bohrung_d, nabe_h + 4]);
    }
    // Einführfase unten
    translate([0, 0, -0.01]) cylinder(d1 = bohrung_d + 1.2, d2 = bohrung_d, h = 0.6);
}

module madenschraube_m4() {
    z = nabe_h - 6;
    // Gewinde-/Schraubenbohrung durch die Abflachungsseite
    translate([0, 0, z]) rotate([0, 90, 0]) cylinder(d = 4.3, h = nabe_d);
    // Mutternfalle M4 (SW 7), von oben eingeschoben
    translate([bohrung_d / 2 + 1.5, 0, z])
        rotate([0, 90, 0]) rotate([0, 0, 30])
            hull() {
                cylinder(d = 8.1, h = 3.4, $fn = 6);
                translate([-nabe_h, 0, 0]) cylinder(d = 8.1, h = 3.4, $fn = 6);
            }
}

difference() {
    union() {
        cylinder(d = nabe_d, h = nabe_h);
        for (i = [0 : fluegel_anzahl - 1])
            rotate([0, 0, i * 360 / fluegel_anzahl + 45])   // Flügel nicht über der Schraube
                translate([0, 0, nabe_h / 2 - fluegel_z])
                    fluegel();
    }
    bohrung();
    if (madenschraube) madenschraube_m4();
    // Flügel unten/oben bündig mit der Nabe abschneiden
    translate([-ruehrer_d, -ruehrer_d, -50]) cube([2 * ruehrer_d, 2 * ruehrer_d, 50]);
    translate([-ruehrer_d, -ruehrer_d, nabe_h]) cube([2 * ruehrer_d, 2 * ruehrer_d, 50]);
}
