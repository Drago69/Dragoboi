// =====================================================================
//  Basisbibliothek: Profile, Zukaufteile (vereinfachte Huellen), Flasche
//  Benoetigt config.scad (vorher includen).
// =====================================================================

// ---------- BOM-Ausgabe ---------------------------------------------
// Jede Zeile: BOM;<Kategorie>;<Bezeichnung>;<Laenge/Groesse>;<Anzahl>
module bom(cat, name, size="", qty=1) {
    echo(str("BOM;", cat, ";", name, ";", size, ";", qty));
}

// ---------- 20x20 Nut 6 B-Typ -----------------------------------------
SIMPLE = false;   // true: Profile als Vollquadrat (schnelle Kollisionspruefung)
module prof2d() {
    if (SIMPLE) square(PROF, center=true); else
    difference() {
        offset(r=1) offset(delta=-1) square(PROF, center=true);
        circle(d=CORE_D, $fn=24);
        for (a=[0:90:270]) rotate(a) {
            // Nutoeffnung + Hinterschnitt (vereinfacht)
            translate([PROF/2-1.8, -SLOT_W/2]) square([2, SLOT_W]);
            translate([PROF/2-6.1, -5.5]) polygon([[0,1.5],[0,9.5],[4.3,11],[4.3,0]]);
        }
    }
}
// Profil entlang +Z, Querschnitt mittig
module prof(len, name="Profil 20x20 Nut 6 B-Typ", noBom=false) {
    if (!noBom) bom("Profil", name, str(round(len*10)/10, " mm"), 1);
    color(C_ALU) linear_extrude(len) prof2d();
}
// Profil zwischen zwei Punkten (Achse), rot = Drehung um eigene Achse
module prof_between(p0, p1, name="Profil 20x20 Nut 6 B-Typ") {
    v = p1 - p0; L = norm(v);
    b = acos(v[2]/L); c = atan2(v[1], v[0]);
    translate(p0) rotate([0, b, c]) prof(L, name);
}

// ---------- Schrauben-Platzhalter (nur Stueckliste) --------------------
module screw_bom(spec, qty=1) bom("Normteil", spec, "", qty);

// ---------- Flasche K-3906.004 -----------------------------------------
// Achse +Z, Boden bei z=0.  neckD/L ueberschreibbar fuer Toleranzstudien
module bottle_profile(L=B_L, D=B_D) {
    r = D/2; rn = B_NECK_D/2; rs = B_SHOULDER_R; rb = B_BOTTOM_R;
    zs = L - B_NECK_L;        // Schulter
    union() {
        // Rumpf
        hull() {
            translate([r-rb, rb]) circle(rb, $fn=24);
            translate([0, 0]) square([0.01, zs]);
            translate([r-rs, zs-rs]) circle(rs, $fn=24);
            translate([0, zs-0.01]) square([r-rs, 0.01]);
        }
        // Hals (Gewinde vereinfacht als Zylinder D23.8)
        square([rn, L]);
    }
}
module bottle(L=B_L, D=B_D) {
    color(C_BOTTLE) rotate_extrude($fn=48) bottle_profile(L, D);
}
// Flasche entlang +s liegend in Rinnenkoordinaten (Achse auf n=0)
// s0 = Lage des Bodens, dir = +1: Hals zeigt nach +s
module bottle_lying(s0, dir=1) {
    translate([0, s0, 0]) rotate([dir>0 ? -90 : 90, 0, 0]) bottle();
}

// ---------- NEMA17 ------------------------------------------------------
// Flanschflaeche bei z=0, Koerper in -z, Welle in +z
module nema17(len=40, shaft=24, shaft_d=5) {
    color(C_BLACK) translate([-21.15,-21.15,-len]) cube([42.3,42.3,len]);
    color(C_STEEL) {
        cylinder(d=22, h=2);
        cylinder(d=shaft_d, h=shaft);
    }
}
// NEMA17 mit Planetengetriebe 13,73:1 (z.B. 17HS19-1684S-PG14), Getriebe D36
// Getriebeflansch bei z=0, Abtrieb D8 x 20 in +z
module nema17_pg(len=48, gb_len=31) {
    color(C_BLACK) {
        translate([0,0,-gb_len]) cylinder(d=36, h=gb_len);
        translate([-21.15,-21.15,-gb_len-len]) cube([42.3,42.3,len]);
    }
    color(C_STEEL) { cylinder(d=22, h=2); cylinder(d=8, h=20); }
}

// ---------- MGN12 -------------------------------------------------------
// Schiene entlang +Z ab z=0, Montageflaeche (Unterseite) bei x=0, Schiene in +x
module mgn12_rail(len) {
    color(C_STEEL) translate([0, -MGN_RAIL_W/2, 0]) cube([MGN_RAIL_H, MGN_RAIL_W, len]);
}
// Wagen: Mitte bei z=zc, Oberseite bei x = MGN_H
module mgn12h_block(zc) {
    color([0.3,0.3,0.35]) difference() {
        translate([3, -MGN_BLK_W/2, zc-MGN_BLK_L/2]) cube([MGN_H-3, MGN_BLK_W, MGN_BLK_L]);
        translate([0, -MGN_RAIL_W/2 - 0.25, zc-MGN_BLK_L/2 - 1]) cube([MGN_RAIL_H + 0.5, MGN_RAIL_W + 0.5, MGN_BLK_L + 2]);
    }
}

// ---------- Pneumatikzylinder ISO 6432 ----------------------------------
// Nasenflaeche (Gewindeende) bei z=0, Zylinder in -z, Stange in +z
// ext = aktuelle Ausfahrlaenge Stange ueber Nase
module iso6432(d=10, stroke=25, ext=16, body=70) {
    color(C_STEEL) {
        translate([0,0,0]) cylinder(d=4, h=ext);              // Stange
        translate([0,0,-16]) cylinder(d=12, h=16);             // Gewinde M12x1.25
        translate([0,0,-16-body-stroke]) cylinder(d=d+5, h=body+stroke);
        translate([0,0,-16-body-stroke-8]) cylinder(d=8, h=8); // Deckel/Anschluss
    }
}

// ---------- Lager / Kleinteile ------------------------------------------
module bearing(d_in, d_out, w) {
    color(C_STEEL) difference() { cylinder(d=d_out, h=w); translate([0,0,-1]) cylinder(d=d_in, h=w+2); }
}
module laser_module() { color([0.8,0.65,0.2]) cylinder(d=6, h=13); }
module phototransistor() { color([0.2,0.2,0.25]) { cylinder(d=5, h=7); translate([0,0,7]) sphere(d=5); } }
module e18_sensor() {           // E18-D80NK, M18 x 45, Linse bei z=0, Koerper +z
    color(C_BLACK) cylinder(d=18, h=45);
    color([0.4,0.4,0.4]) translate([0,0,45]) cylinder(d=6, h=20);
}
module magnet6x3() { color([0.6,0.6,0.7]) cylinder(d=6, h=3); }

// ---------- Hilfsformen -------------------------------------------------
module chamfer_box(size, c=1) {
    hull() {
        translate([c,0,0]) cube([size[0]-2*c, size[1], size[2]]);
        translate([0,c,0]) cube([size[0], size[1]-2*c, size[2]]);
    }
}
// Bohrung mit Senkung fuer Zylinderkopf, Achse +Z, Kopf oben bei z=top
module cb_hole(d, head_d, head_h, len, top) {
    translate([0,0,top-len]) cylinder(d=d, h=len+EPS_CUT, $fn=24);
    translate([0,0,top-head_h]) cylinder(d=head_d, h=head_h+5, $fn=24);
}
// Tropfenform-Bohrung (liegend druckbar), Achse +Z
module teardrop_hole(d, h) {
    linear_extrude(h) hull() { circle(d=d, $fn=24); translate([0, d/2*sqrt(2)/1.0]) square(0.01, center=true); }
}
