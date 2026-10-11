// =====================================================================
//  Hakenteller-Zufuehrung: Tellerplatte, Haken, Nabe, Welle, Lagerbock,
//  Randring (Bunkerfuss), Abstreifer, Uebergabe (Pflug) + Auslauf,
//  Bunker-Facetten (Hilfsfunktionen), Kantenwinkel, Bodenauflage.
//  Rahmen: TD (Tellerteile), D (Bunker), G (Uebergabe/Auslauf).
// =====================================================================

// ---------------------------------------------------------------------
// Hilfen
// ---------------------------------------------------------------------
function unit(v) = v/norm(v);
function frame_m(a,b,c,o) = [[a[0],b[0],c[0],o[0]],[a[1],b[1],c[1],o[1]],[a[2],b[2],c[2],o[2]],[0,0,0,1]];
function frame_inv(a,b,c,o) = [[a[0],a[1],a[2],-(a*o)],[b[0],b[1],b[2],-(b*o)],[c[0],c[1],c[2],-(c*o)],[0,0,0,1]];
function det3(m) = m[0]*cross(m[1], m[2]);
// Schnittpunkt dreier Ebenen n_i.p = d_i (Cramer)
function plane3(n1,d1,n2,d2,n3,d3) = let(D = det3([n1,n2,n3]))
    (d1*cross(n2,n3) + d2*cross(n3,n1) + d3*cross(n1,n2))/D;
// Halbraum {p : n.p <= d}
module halfspace(n, d, L=3000) {
    nn = unit(n);
    translate(nn*d/norm(n)) rotate([0, acos(nn[2]), atan2(nn[1], nn[0])]) translate([-L/2,-L/2,-L]) cube(L);
}
// Ringsektor (z-Achse), Winkel in Grad
module sector3(r0, r1, a0, a1, z0, z1, fn=180) {
    n = max(2, ceil(abs(a1 - a0)/360*fn));
    translate([0,0,z0]) linear_extrude(z1 - z0) polygon(concat(
        [for (i=[0:n]) r1*[cos(a0 + i*(a1-a0)/n), sin(a0 + i*(a1-a0)/n)]],
        [for (i=[n:-1:0]) r0*[cos(a0 + i*(a1-a0)/n), sin(a0 + i*(a1-a0)/n)]]));
}
function dang(a) = a + TD_DROT;          // D-Winkel -> TD-Winkel

// Weltwaagerechte "Fuellebene" im D-Frame: FILL_N.p <= FILL_D
FILL_N = [Dv2w([1,0,0])[2], Dv2w([0,1,0])[2], Dv2w([0,0,1])[2]];
FILL_D = Z_RIM - D2w([0,0,0])[2];

// ---------------------------------------------------------------------
// Bunker-Facetten (D-Frame).  f = [D-Winkel, Kippung]
// Innenflaeche: n.p = d, Bunker innen n.p <= d, Blech aussen (0..SHEET_T)
// ---------------------------------------------------------------------
GROOVE = 8;                               // Blech steckt 8 mm in der Ringnut
function fac_n(f)  = [cos(f[1])*cos(f[0]), cos(f[1])*sin(f[0]), -sin(f[1])];
function fac_p0(f) = [HOP_RT*cos(f[0]), HOP_RT*sin(f[0]), RING_H];
function fac_d(f)  = fac_n(f)*fac_p0(f);
function fac_e1(f) = [-sin(f[0]), cos(f[0]), 0];
function fac_e2(f) = cross(fac_n(f), fac_e1(f));
module fac_to_D(f) multmatrix(frame_m(fac_e1(f), fac_e2(f), fac_n(f), fac_p0(f))) children();
module D_to_fac(f) multmatrix(frame_inv(fac_e1(f), fac_e2(f), fac_n(f), fac_p0(f))) children();
// Nachbarn (Kehlen): Paare von Indizes in HOP_FACETS
HOP_VALLEYS = [[0,1],[1,2],[0,3],[3,4]];
function valley_pt(i, j, plane_n, plane_d) =
    plane3(fac_n(HOP_FACETS[i]), fac_d(HOP_FACETS[i]), fac_n(HOP_FACETS[j]), fac_d(HOP_FACETS[j]), plane_n, plane_d);
function valley_lo(k) = valley_pt(HOP_VALLEYS[k][0], HOP_VALLEYS[k][1], [0,0,1], RING_H);
function valley_hi(k) = valley_pt(HOP_VALLEYS[k][0], HOP_VALLEYS[k][1], FILL_N, FILL_D);
// Kantenwinkel-Lagen entlang der Kehle (Anteil)
KW_POS = [0.28, 0.72];

// Bunkerinnenraum ueber dem Ring (fuer Pruefungen / Bleche)
module hopper_space(z0 = RING_H) {
    intersection() {
        intersection_for (f = HOP_FACETS) halfspace(fac_n(f), fac_d(f));
        halfspace(FILL_N, FILL_D);
        halfspace([0,0,-1], -z0);
    }
}
// Blech i (D-Frame): aussen an Facette i, begrenzt durch Nachbarn, Fuellebene, Nutgrund
module hopper_sheet(i) {
    f = HOP_FACETS[i];
    difference() {
        intersection() {
            halfspace(-fac_n(f), -fac_d(f));                   // aussen
            halfspace(fac_n(f), fac_d(f) + SHEET_T);           // Dicke
            intersection_for (j = [for (jj=[0:len(HOP_FACETS)-1]) if (jj != i) jj]) halfspace(fac_n(HOP_FACETS[j]), fac_d(HOP_FACETS[j]));
            halfspace(FILL_N, FILL_D);
            halfspace([0,0,-1], -(RING_H - GROOVE));
        }
        // Bohrungen Kantenwinkel (M4 Senkkopf von innen)
        for (k=[0:len(HOP_VALLEYS)-1], t=KW_POS) for (side=[0,1]) if (HOP_VALLEYS[k][side] == i)
            kw_place(k, t, side) translate([KW_S, 0, 0]) cylinder(d=M4_D, h=40, center=true, $fn=24);
        // Bohrungen Bodenauflage
        if (i == 0) for (x = BA_X) ba_place(x) cylinder(d=M4_D, h=40, center=true, $fn=24);
    }
}
// Blech flach (lokales 2D, Innenseite = z 0) fuer DXF
module hopper_sheet_2d(i) {
    projection(cut=true) translate([0,0,-SHEET_T/2]) D_to_fac(HOP_FACETS[i]) hopper_sheet(i);
}

// ---------------------------------------------------------------------
// Kantenwinkel (Kehle zwischen zwei Blechen), lokaler Rahmen:
//   y = Kehlenrichtung, Innenraum Richtung -z, Bleche symmetrisch.
// ---------------------------------------------------------------------
KW_S = 18;           // Schraube Abstand von der Kehle
KW_L = 30; KW_W = 28; KW_T = 5;
function kw_dihedral(k) = let(ni = fac_n(HOP_FACETS[HOP_VALLEYS[k][0]]), nj = fac_n(HOP_FACETS[HOP_VALLEYS[k][1]]))
    180 - acos(ni*nj);                    // Innenwinkel zwischen den Blechen
module kantenwinkel(delta) {
    ai = [ sin(delta/2), 0, -cos(delta/2)];  ni = [cos(delta/2), 0,  sin(delta/2)];
    aj = [-sin(delta/2), 0, -cos(delta/2)];  nj = [-cos(delta/2), 0, sin(delta/2)];
    module fl(a, n, s0, s1) multmatrix(frame_m(a, [0,1,0], n, [0,0,0])) translate([s0, -KW_W/2, SHEET_T]) cube([s1 - s0, KW_W, KW_T]);
    difference() {
        union() {
            fl(ai, ni, 0, KW_L); fl(aj, nj, 0, KW_L);
            hull() { fl(ai, ni, 0, 7); fl(aj, nj, 0, 7); }
        }
        for (p=[[ai,ni],[aj,nj]]) multmatrix(frame_m(p[0], [0,1,0], p[1], [0,0,0])) translate([KW_S, 0, 0]) {
            cylinder(d=M4_D, h=30, center=true, $fn=24);
        }
    }
}
// Platzierung: Kehle k, Anteil t, side 0/1 -> Rahmen des Blechs (x = a_i, y = Kehle, z = n_i, Ursprung auf der Kehle)
function kw_frame(k, t) = let(
    i = HOP_VALLEYS[k][0], j = HOP_VALLEYS[k][1],
    ni = fac_n(HOP_FACETS[i]), nj = fac_n(HOP_FACETS[j]),
    v = unit(valley_hi(k) - valley_lo(k)),
    ai0 = unit(cross(ni, v)), ai = (nj*ai0 < 0) ? ai0 : -ai0,
    aj0 = unit(cross(nj, v)), aj = (ni*aj0 < 0) ? aj0 : -aj0,
    P = valley_lo(k) + t*(valley_hi(k) - valley_lo(k)))
    [ai, aj, ni, nj, v, P];
module kw_place(k, t, side) {
    F = kw_frame(k, t);
    a = side == 0 ? F[0] : F[1]; n = side == 0 ? F[2] : F[3];
    multmatrix(frame_m(a, unit(cross(n, a)), n, F[5])) children();
}
// Kantenwinkel in Einbaulage (D-Frame)
module kantenwinkel_at(k, t) {
    F = kw_frame(k, t);
    x = unit(F[0] - F[1]); z = -unit(F[0] + F[1]); y = cross(z, x);
    multmatrix(frame_m(x, y, z, F[5])) kantenwinkel(kw_dihedral(k));
}

// ---------------------------------------------------------------------
// Tellerplatte (TD-Frame, z -TD_T..0).  Zukauf: PE-HD 10 mm, Zuschnitt nach DXF
// ---------------------------------------------------------------------
HUB_HOLES = [for (j=[0:3]) 18 + 90*j];
module tellerplatte_2d() {
    difference() {
        circle(r=TD_R, $fn=360);
        circle(d=HUB_SPIGOT + 0.3, $fn=64);
        for (a=HUB_HOLES) rotate(a) translate([HUB_PCD/2, 0]) circle(d=M5_D, $fn=24);
        for (k=[0:TD_N-1], p=HK_SCREW) rotate(k*TD_PITCH) translate(p) circle(d=M4_D, $fn=24);
    }
}
module tellerplatte() {
    difference() {
        translate([0,0,-TD_T]) linear_extrude(TD_T) tellerplatte_2d();
        // Senkungen 90 Grad: Nabe von vorn (M5), Haken von hinten (M4)
        for (a=HUB_HOLES) rotate(a) translate([HUB_PCD/2, 0, EPS_CUT]) mirror([0,0,1]) cylinder(d1=10.4, d2=0, h=5.2, $fn=32);
        for (k=[0:TD_N-1], p=HK_SCREW) rotate(k*TD_PITCH) translate([p[0], p[1], -TD_T - EPS_CUT]) cylinder(d1=9.0, d2=0, h=4.5, $fn=32);
    }
}

// ---------------------------------------------------------------------
// Haken (Tasche): Leiste innen + Mitnehmer hinten.  Haken-Frame = TD bei Taschenwinkel 0:
//   Flaschenmitte bei x = TD_RB, y = 0; Lauf in +y.
// ---------------------------------------------------------------------
module haken() {
    y0 = HK_YR - HK_PT;
    difference() {
        intersection() {
        cylinder(r=HK_PR, h=3*HK_H, center=true, $fn=720);      // Aussenkante Mitnehmer = Kreisbogen
        union() {
            // Leiste (Aussenflaeche x = TD_RL = -X-Flanke in T), vorn verjuengt
            hull() {
                translate([HK_RI, y0, 0]) cube([TD_RL - HK_RI - 1, HK_YF - 22 - y0, HK_H]);
                translate([HK_RI, y0, 0]) cube([TD_RL - HK_RI, HK_YF - 22 - y0, HK_H - 1]);
                translate([TD_RL - 7, HK_YF - 0.01, 0]) cube([7, 0.01, HK_H - 5]);
            }
            // Mitnehmer (Stirnflaeche y = HK_YR), Aussenkante gerundet
            hull() {
                translate([HK_RI, y0, 0]) cube([HK_PR - HK_RI + 8, HK_PT, HK_H]);
                translate([HK_RI, y0, 0]) cube([HK_PR - HK_RI + 10, HK_PT, HK_H - 2]);
            }
        }
        }
        // Gewindeeinsaetze M4 von unten
        for (p=HK_SCREW) translate([p[0], p[1], -EPS_CUT]) cylinder(d=M4_INS_D, h=M4_INS_L + 0.5, $fn=24);
        // Kennzeichnung Laufrichtung (Pfeil) oben
        translate([HK_RI + 8.5, -24, HK_H - 0.6]) linear_extrude(1) polygon([[-3,0],[3,0],[0,8]]);
    }
}
module haken_at(k, phi) rotate([0,0,phi + k*TD_PITCH]) haken();

// ---------------------------------------------------------------------
// Nabe (TD-Frame): Flansch an Tellerrueckseite, Bund in Tellermitte,
// Bohrung D12 mit Abflachung (Madenschraube), Magnete je Tasche (Hallsensor).
// Zwischen Nabe und Innenring 6001: Distanzhuelse 12/18 x 6.
// ---------------------------------------------------------------------
HUB_Z1 = -TD_T;  HUB_Z0 = -TD_T - HUB_L;
HUB_GRUB_A = 63;               // Madenschraube M4 (zwischen den Nabenschrauben)
module nabe() {
    difference() {
        union() {
            translate([0,0,HUB_Z0]) cylinder(d=HUB_D, h=HUB_L, $fn=96);
            translate([0,0,HUB_Z1 - EPS_CUT]) cylinder(d=HUB_SPIGOT, h=6, $fn=64);
        }
        translate([0,0,HUB_Z0 - 1]) cylinder(d=SHAFT_D + 0.15, h=60, $fn=48);
        // Schrauben M5 (Senkkopf von vorn durch Teller) + Muttern hinten
        for (a=HUB_HOLES) rotate(a) translate([HUB_PCD/2, 0, HUB_Z0 - 1]) {
            cylinder(d=M5_D, h=HUB_L + 2, $fn=24);
            rotate(30) cylinder(d=9.3, h=1 + 5, $fn=6);
        }
        // Magnete 6x3 in Rueckseite (je Tasche), Hallsensor im Lagerbock
        for (k=[0:TD_N-1]) rotate(k*TD_PITCH) translate([MAG_R, 0, HUB_Z0 - EPS_CUT]) cylinder(d=6.2, h=3.2, $fn=32);
        // Madenschraube: M4 Mutter (von hinten eingelegt) + Schraube M4x16 von aussen
        rotate(HUB_GRUB_A) translate([0,0,(HUB_Z0 + HUB_Z1)/2]) {
            rotate([0,90,0]) cylinder(d=M4_D, h=HUB_D, $fn=24);
            translate([HUB_D/2 - 12, 0, 0]) rotate([0,90,0]) cylinder(d=8, h=20, $fn=32);
            translate([9.5, -3.6, -(HUB_Z1 - HUB_Z0)]) cube([3.4, 7.2, (HUB_Z1 - HUB_Z0)/2 + 3.6]);
        }
    }
}
module welle_teller() color(C_STEEL) translate([0,0,-6 - SHAFT_L]) difference() {
    cylinder(d=SHAFT_D, h=SHAFT_L, $fn=48);
    rotate(HUB_GRUB_A) translate([SHAFT_D/2 - 0.5, -10, SHAFT_L - 36]) cube([5, 20, 32]);       // Abflachung Nabe
}

// ---------------------------------------------------------------------
// Lagerbock mit Motorflansch (TD-Frame) an den Querholmen (Rueckseite z = LB_Z0)
//   2 x 6001-2RS (12x28x8), Klauenkupplung 8/12, NEMA17 + Planetengetriebe
// ---------------------------------------------------------------------
LB_FL_T = 8;
LB_HALL = [0, MAG_R];             // Hallsensor A3144 in der Stirnseite
GB_PCD  = 28;                     // Getriebeflansch 4 x M4 (am Motor pruefen)
module lagerbock_teller() {
    zf = LB_Z0;  zb = LB_B2;  zg = GB_Z;
    difference() {
        union() {
            translate([-(TC_X + PROF/2 + 2), -40, zf - LB_FL_T]) chamfer_box([2*(TC_X + PROF/2 + 2), 80, LB_FL_T], 4);
            translate([0,0,zb]) cylinder(d=46, h=zf - zb, $fn=96);
            // Kupplungsraum: 4 Saeulen + Getriebeplatte
            for (x=[-1,1], y=[-1,1]) translate([x*22 - 4, y*22 - 4, zg - 6]) cube([8, 8, zb - zg + 6 + 1]);
            translate([-26, -26, zg - 6]) chamfer_box([52, 52, 6], 4);
            translate([-26, -26, zb - 4]) chamfer_box([52, 52, 4.01], 4);
            // Rippen Flansch -> Lagerrohr
            for (a=[0, 180]) rotate(a) hull() {
                translate([22, -3, zf - LB_FL_T]) cube([TC_X - 22 + 10, 6, 0.01]);
                translate([22, -3, zf - LB_FL_T - 30]) cube([0.01, 6, 0.01]);
            }
        }
        // Lagersitze 6001 (28 x 8) von vorn bzw. hinten, Wellendurchgang
        translate([0,0,LB_B1 - 8]) cylinder(d=28.05, h=8 + (zf - LB_B1) + 1, $fn=96);
        translate([0,0,zb - 5]) cylinder(d=28.05, h=8 + 5, $fn=96);
        translate([0,0,zg - 10]) cylinder(d=20, h=zf - zg + 20, $fn=48);
        // Schrauben M5 in Querholmnut (Kopf hinten)
        for (x=[-TC_X, TC_X], y=[-28, 28]) translate([x, y, zf - LB_FL_T - 1]) cylinder(d=M5_D, h=LB_FL_T + 2, $fn=24);
        // Getriebe: Zentrierung D22 + 4 x M4
        translate([0,0,zg - 7]) {
            cylinder(d=22.4, h=8, $fn=64);
            for (a=[45:90:315]) rotate(a) translate([GB_PCD/2, 0, 0]) cylinder(d=M4_D, h=8, $fn=24);
        }
        // Hallsensor A3144 liegend (flache Seite zur Nabe), Beine nach hinten
        translate([LB_HALL[0], LB_HALL[1], zf]) {
            translate([-2.4, -2.1, -1.8]) cube([4.8, 4.2, 2]);
            translate([-1.8, -1, -LB_FL_T - 1]) cube([3.6, 2, LB_FL_T + 2]);
        }
    }
}
module kupplung_teller() color(C_STEEL) translate([0,0,GB_Z + 2.5]) difference() { cylinder(d=25, h=30, $fn=48); translate([0,0,-1]) cylinder(d=8.5, h=32, $fn=32); }
module distanzhuelse_teller() color(C_STEEL) translate([0,0,LB_B1]) difference() { cylinder(d=18, h=HUB_Z0 - LB_B1, $fn=48); translate([0,0,-1]) cylinder(d=12, h=10, $fn=32); }
module stellring_teller() color(C_STEEL) translate([0,0,LB_B2 - 10.5]) difference() { cylinder(d=22, h=10, $fn=48); translate([0,0,-1]) cylinder(d=12, h=12, $fn=32); }

// ---------------------------------------------------------------------
// Randring (D-Frame): Innen RING_RI (schwebt 1.5 ueber dem Teller),
// Fuss auf der Rueckwand (r >= TD_HOLE + 0.5), Nuten fuer die Bunkerbleche,
// Zwickel in den Ecken der Facetten, beschnitten am Auslauf.
// ---------------------------------------------------------------------
RING_OUT = 18;                 // Ringaussenkontur = Facettenlinie + RING_OUT
RING_RO  = 290;
// Facettenecken (Ringoberseite)
function ring_corner(k) = valley_lo(k);
module ring_outline2d() {
    intersection() {
        circle(r=RING_RO, $fn=360);
        // Polygon aus Facettenlinien + RING_OUT
        intersection_for (f = HOP_FACETS)
            rotate(f[0]) translate([HOP_RT + RING_OUT - 2000, -1000]) square(2000);
    }
}
module ring_body() {
    difference() {
        intersection() {
            linear_extrude(RING_H) ring_outline2d();
            sector3(RING_RI, RING_RO + 5, RING_A0, RING_A1, -1, RING_H + 1, fn=720);
        }
        // Nuten fuer die Bleche
        for (i=[0:len(HOP_FACETS)-1]) ring_groove(i);
        // Freiraum Uebergabe/Auslauf
        G_to_D() auslauf_huelle(3);
        // Innenkante oben fasen
        translate([0,0,RING_H - 2]) cylinder(r1=RING_RI, r2=RING_RI + 2.01, h=2.01, $fn=360);
    }
}
module ring_groove(i) {
    f = HOP_FACETS[i];
    intersection() {
        halfspace(-fac_n(f), -(fac_d(f) - 0.3));
        halfspace(fac_n(f), fac_d(f) + SHEET_T + 0.3);
        halfspace([0,0,-1], -(RING_H - GROOVE));
        intersection_for (j = [for (jj=[0:len(HOP_FACETS)-1]) if (jj != i) jj]) halfspace(fac_n(HOP_FACETS[j]), fac_d(HOP_FACETS[j]) + SHEET_T + 0.3);
    }
}
// Zwickel in den Facettenecken (Innenseite, auf dem Ring)
module ring_zwickel(k) {
    i = HOP_VALLEYS[k][0]; j = HOP_VALLEYS[k][1];
    C0 = valley_lo(k); v = unit(valley_hi(k) - valley_lo(k));
    ac = atan2(C0[1], C0[0]);
    intersection() {
        hull() {
            translate(C0) cube(0.01, center=true);
            translate(C0 + 16*v) cube(0.01, center=true);
            for (da=[-13, 13]) translate([(RING_RI + 1)*cos(ac + da), (RING_RI + 1)*sin(ac + da), RING_H - 0.01]) cube(0.01);
        }
        hopper_space(RING_H - 1);
    }
}
RING_SCREW_R = (RING_RI + HOP_RT + RING_OUT)/2 + 1;
function ring_screws() = [for (s=[0:len(RING_SEG)-2]) let(a0 = RING_SEG[s], a1 = RING_SEG[s+1])
                          for (t=[0.22, 0.78]) a0 + t*(a1 - a0)];
module randring_full() {
    difference() {
        union() {
            ring_body();
            for (k=[0:len(HOP_VALLEYS)-1]) ring_zwickel(k);
        }
        // Gewindeeinsaetze M4 von unten (Schrauben durch die Rueckwand)
        for (a=ring_screws()) translate([RING_SCREW_R*cos(a), RING_SCREW_R*sin(a), -EPS_CUT])
            cylinder(d=M4_INS_D, h=M4_INS_L + 0.5, $fn=24);
    }
}
module randring(s) intersection() {
    randring_full();
    sector3(0, RING_RO + 10, RING_SEG[s], RING_SEG[s+1], -2, RING_H + 60, fn=720);
}

// ---------------------------------------------------------------------
// Abstreifer (zweite Lage) bei D-Winkel STRIP_A, D-Frame
// ---------------------------------------------------------------------
STRIP_Z0 = 2*B_D + 3 - B_D;   // 33: ueber der Taschenflasche (30)
STRIP_Z1 = 58;
STRIP_SKEW = 25;              // Aussenende laeuft nach (Ablenkung nach innen)
module abstreifer() {
    rotate(STRIP_A) difference() {
        union() {
            // Fuss auf der Rueckwand
            translate([TD_HOLE + 3, -16, 0]) cube([RING_RO - TD_HOLE - 3, 32, 8]);
            // Steg
            translate([TD_HOLE + 6, -8, 0]) cube([RING_RO - TD_HOLE - 6, 16, STRIP_Z1]);
            // Arm schraeg nach innen
            hull() {
                translate([TD_HOLE + 6, -8, STRIP_Z0]) cube([RING_RO - TD_HOLE - 6, 16, STRIP_Z1 - STRIP_Z0]);
                translate([HK_RI - 8, -6 + (TD_HOLE - HK_RI)*tan(STRIP_SKEW), STRIP_Z0]) cube([6, 12, STRIP_Z1 - STRIP_Z0]);
            }
        }
        for (x=[TD_HOLE + 12, RING_RO - 9]) for (y=[-11, 11]) translate([x, y, -EPS_CUT]) cylinder(d=M4_INS_D, h=M4_INS_L + 0.5, $fn=24);
    }
}

// ---------------------------------------------------------------------
// Uebergabe (Pflug, Dach, +X-Wand) und Auslauf (Kanal C), Rinnen-Frame G
// ---------------------------------------------------------------------
S_AB   = S_T + 150;          // Stoss Uebergabe -> Auslauf
UE_S0  = S_T - 60;           // Beginn Uebergabe (Einlauftrichter)
UE_FLARE = 14;               // Aufweitung +X-Wand / Dach am Einlauf
module in_td() translate(TD_C) rotate([0,-45,0]) children();             // TD -> G
module G_to_TD() rotate([0,45,0]) translate(-TD_C) children();             // G -> TD
module G_to_D()  rotate([0,0,-TD_DROT]) G_to_TD() children();             // G -> D
// Huellkoerper Uebergabe + Auslauf + Flansch G1 (fuer Freischnitte), G-Frame
module auslauf_huelle(g=0) {
    translate([0,0,0]) along_s(UE_S0 - g, S_EXIT + CH_FL_T + g)
        offset(delta=g) polygon([[-CH_FLANGE_X, CH_KEEL], [CH_FLANGE_X, CH_KEEL], [CH_FLANGE_X, CH_ROOF + CH_COVER_T + 4],
                                [-CH_FLANGE_X, CH_ROOF + CH_COVER_T + 4]]);
    in_td() translate([HK_RI - 12 - g, -g, PLOW_Z0 - g]) cube([TD_RL + 1 - (HK_RI - 12) + 2*g, S_AB - S_T + 2*g, 46 - PLOW_Z0 + 2*g]);
    uebergabe_fuss_huelle(g);
}
// Flaschenraum einer Taschenflasche (TD) bei Taschenwinkel phi, Vorrutschen s
module pocket_bottle_env(phi, slide=0, grow=1.5) {
    rotate(phi) translate([TD_RB, -B_L/2, B_D/2]) rotate([-90,0,0]) cylinder(r=B_D/2 + grow, h=B_L + slide, $fn=32);
}
// Kanal-Innenraum (geschlossenes Dach), G-Frame
module ch_inner_closed2d(grow=0) offset(delta=grow) polygon([[0,-CH_APEX],[CH_W/2,CH_VTOP],[CH_W/2,CH_ROOF],[-CH_W/2,CH_ROOF],[-CH_W/2,CH_VTOP]]);
UE_FLARE_S1 = S_T + 110;     // ab hier normaler Kanal
module ue_inner() {
    along_s(UE_FLARE_S1, S_AB + 1) ch_inner_closed2d();
    hull() {
        translate([0, UE_FLARE_S1 + 0.01, 0]) rotate([90,0,0]) linear_extrude(0.01) ch_inner_closed2d();
        translate([0, UE_S0 - 1, 0]) rotate([90,0,0]) linear_extrude(0.01)
            polygon([[0,-CH_APEX],[CH_W/2 + UE_FLARE,CH_VTOP],[CH_W/2 + UE_FLARE,CH_ROOF + UE_FLARE],[-CH_W/2,CH_ROOF + UE_FLARE],[-CH_W/2,CH_VTOP]]);
    }
}
// Fuss der Uebergabe auf der Rueckwand (TD), Schrauben M4
UE_FOOT_A = [-14, 34];       // TD-Winkelbereich
UE_SCREWS = [[266, -8], [266, 12], [266, 30]];   // [r, TD-Winkel]
module uebergabe_fuss_huelle(g=0) in_td() intersection() {
    sector3(TD_HOLE + 0.5 - g, 284 + g, UE_FOOT_A[0] - g/3, UE_FOOT_A[1] + g/3, -g, 10 + g);
    translate([0, UE_S0 - S_T - g, -50]) cube([500, S_AB - UE_S0 - 2 + 2*g, 100]);
}
module uebergabe() {
    wall = 3;
    difference() {
        union() {
            // Kanalschale (Kiel bis Dach), wie Rinne, mit geschlossenem Dach
            along_s(UE_S0, S_AB) polygon([[-CH_W/2 - wall, CH_KEEL], [CH_W/2 + wall, CH_KEEL],
                                          [CH_W/2 + wall, CH_ROOF + wall], [-CH_W/2 - wall, CH_ROOF + wall]]);
            // Einlauftrichter aussen
            hull() {
                translate([0, UE_FLARE_S1, 0]) rotate([90,0,0]) linear_extrude(0.01)
                    polygon([[-CH_W/2 - wall, CH_KEEL], [CH_W/2 + wall, CH_KEEL], [CH_W/2 + wall, CH_ROOF + wall], [-CH_W/2 - wall, CH_ROOF + wall]]);
                translate([0, UE_S0 + 0.01, 0]) rotate([90,0,0]) linear_extrude(0.01)
                    polygon([[-CH_W/2 - wall, CH_KEEL], [CH_W/2 + wall + UE_FLARE, CH_KEEL], [CH_W/2 + wall + UE_FLARE, CH_ROOF + wall + UE_FLARE], [-CH_W/2 - wall, CH_ROOF + wall + UE_FLARE]]);
            }
            // Pflug (TD): Block innen an der -X-Flanke, ueber den Haken
            in_td() intersection() {
                translate([HK_RI - 12, 0, PLOW_Z0]) cube([TD_RL + 1 - (HK_RI - 12), S_AB - S_T, 46 - PLOW_Z0]);
                halfspace([-1, 0, -1], -(TD_RL - 0.5 + PLOW_Z0));        // Unterseite innen 45 Grad
            }
            // Fuss auf der Rueckwand (+X-Seite)
            uebergabe_fuss_huelle(0);
            ch_flange(S_AB, -1);
        }
        ue_inner();
        // Teller + Haken + Taschenflaschen freistellen (TD)
        in_td() {
            translate([0,0,-50]) cylinder(r=TD_HOLE + 0.5, h=50 + 1.5, $fn=360);       // Teller (schwebt 1.5)
            translate([0,0,-100]) cylinder(r=400, h=100.02, $fn=180);                      // hinter der Rueckwandebene
            translate([0,0,-1]) difference() { cylinder(r=HK_PR + 2.5, h=PLOW_Z0 + 1, $fn=360); cylinder(r=HK_RI - 2.5, h=40, $fn=360); }
            // vor T: -X-Seite offen (Taschenflasche ist noch um phi gedreht)
            intersection() { halfspace([1, 0, -1], 195); translate([-500, -500, -50]) cube([1000, 500, 200]); }
            intersection() {
                union() for (a=[-72:4:-4]) hull() { pocket_bottle_env(a, a > -24 ? 32 : 0); pocket_bottle_env(a + 4, a + 4 > -24 ? 32 : 0); }
                translate([-500, -500, -50]) cube([1000, 500, 200]);                       // nur vor T (y < 0)
            }
        }
        ch_flange_holes(S_AB, -1, "clear");
        // Schrauben Fuss
        for (p=UE_SCREWS) in_td() rotate(p[1]) translate([p[0], 0, -EPS_CUT]) cylinder(d=M4_INS_D, h=M4_INS_L + 0.5, $fn=24);
    }
}
// Auslauf (Kanal C, offen oben mit Deckel) S_AB .. S_EXIT, Rinnen-Frame
AUS_COVER_S = [S_AB + 14, S_EXIT - 16];
module auslauf() {
    difference() {
        union() {
            along_s(S_AB, S_EXIT) ch_outer2d();
            ch_flange(S_AB, +1);
            ch_flange(S_EXIT, -1);
        }
        along_s(S_AB - 1, S_EXIT + 1) ch_inner2d();
        ch_flange_holes(S_AB, +1, "insert");
        ch_flange_holes(S_EXIT, -1, "insert");
        cover_inserts(AUS_COVER_S);
        // Teller + Haken freistellen
        in_td() {
            translate([0,0,-50]) cylinder(r=TD_HOLE + 0.5, h=50 + 1.5, $fn=360);
            translate([0,0,-1]) difference() { cylinder(r=HK_PR + 2.5, h=PLOW_Z0 + 1, $fn=360); cylinder(r=HK_RI - 2.5, h=40, $fn=360); }
        }
    }
}
module deckel_auslauf() deckel(S_AB, S_EXIT, AUS_COVER_S);

// ---------------------------------------------------------------------
// Haubenhalter (Distanzrohr) und Bodenauflage (Saettel unter Bunkerboden)
// ---------------------------------------------------------------------
HOOD_PTS = [[300, 15], [292, 248], [-250, 248], [-300, -18]];   // D-Frame
module haubenhalter() difference() {
    cylinder(d=14, h=HOOD_Z, $fn=48);
    translate([0,0,-1]) cylinder(d=M4_D, h=HOOD_Z + 2, $fn=24);
}
// Bodenauflage: auf Frontholm (waagerecht, entlang x_D), Oberseite parallel Bunkerboden
BA_X = [-160, 160];
BA_BACK = 42;                 // Abstand Auflage hinter Bodenvorderkante (entlang Boden)
function floor_front_mid() = plane3(fac_n(HOP_FACETS[0]), fac_d(HOP_FACETS[0]), FILL_N, FILL_D, [1,0,0], 0);
function floor_dir() = unit(cross([1,0,0], fac_n(HOP_FACETS[0])));      // im Boden, senkrecht zu x_D
function floor_up() = floor_dir()[2] > 0 ? floor_dir() : -floor_dir();
// Rahmen auf der Bodenaussenseite: x = x_D, y = bergauf im Boden, z = Normale aussen
module ba_place(x) let(n = fac_n(HOP_FACETS[0]), u = floor_up(), P = floor_front_mid() - BA_BACK*u + [x, 0, 0])
    multmatrix(frame_m([1,0,0], u, n, P)) children();
// Sattelpunkte (D-Frame): Kontaktmitte auf der Bodenaussenseite
function ba_pt(x) = floor_front_mid() - BA_BACK*floor_up() + [x, 0, 0] + SHEET_T*fac_n(HOP_FACETS[0]);
BA_HU = 20;  BA_HX = 15;  BA_MIN = 8;
function zw_D(p) = D2w(p)[2];
// Oberkante Frontholm (Welt Z)
FB_ZTOP = zw_D(ba_pt(0) - BA_HU*floor_up()) - BA_MIN;
// Bodenauflage (D-Frame, Einbaulage) zwischen Bunkerboden und Frontholm
module bodenauflage_at(x) {
    u = floor_up(); n = fac_n(HOP_FACETS[0]); c = ba_pt(x);
    corners = [for (sx=[-1,1], su=[-1,1]) c + sx*BA_HX*[1,0,0] + su*BA_HU*u];
    function down(p) = p - (zw_D(p) - FB_ZTOP)*FILL_N;
    difference() {
        hull() for (p=corners) { translate(p) cube(0.01, center=true); translate(down(p)) cube(0.01, center=true); }
        // M4 Einsatz von der Blechseite
        multmatrix(frame_m([1,0,0], u, n, c)) translate([0,0,-0.1]) cylinder(d=M4_INS_D, h=M4_INS_L + 0.6, $fn=24);
        // 2 x M5 senkrecht in die Holmnut, Kopf von oben versenkt
        for (sx=[-1,1]) let(q = down(c + sx*9*[1,0,0])) multmatrix(frame_m([1,0,0], cross(FILL_N, [1,0,0]), FILL_N, q)) {
            translate([0,0,-1]) cylinder(d=M5_D, h=60, $fn=24);
            translate([0,0,7]) cylinder(d=M5_HEAD_D + 0.8, h=60, $fn=32);
        }
    }
}
