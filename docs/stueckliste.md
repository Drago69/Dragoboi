# Stueckliste Flaschen-Unscrambler

Automatisch erzeugt aus `cad/assembly.scad` (`python3 tools/bom.py`). Profil- und Plattenmasse gelten fuer `BELT_Z = 900 mm` (Band-Oberkante). Bei anderer Bandhoehe in `cad/config.scad` aendern und neu erzeugen.

**Profile gesamt: 17.2 m 20x20 Nut 6 B-Typ** (entspricht ca. 10 Stangen a 2 m inkl. 5 % Verschnitt; besser: Zuschnitt beim Haendler bestellen, Toleranz +-0,2 mm, Beine besonders genau).

## Profil 20x20 Nut 6 B-Typ (Zuschnitt)

| Bezeichnung | Groesse / Verwendung | Anzahl |
|---|---|---|
| Bodenrahmen Rotor | 240.0 mm | 1 |
| Bodenrahmen Rotor | 129.3 mm | 1 |
| Bodenrahmen laengs | 721.4 mm | 1 |
| Bodenrahmen laengs | 451.7 mm | 1 |
| Bodenrahmen laengs | 269.7 mm | 1 |
| Bodenrahmen quer | 628.0 mm | 2 |
| Bodenrahmen quer | 554.0 mm | 1 |
| Bunker-Frontholm | 560.0 mm | 1 |
| Querholm Lagerung | 564.0 mm | 2 |
| Rotorarm | 185.0 mm | 1 |
| Rotorsaeule | 1112.0 mm | 1 |
| Sensorausleger | 312.5 mm | 1 |
| Strebe Rotorsaeule (Gehrung nach Bedarf) | 708.4 mm | 1 |
| Strebe Rotorsaeule (Gehrung nach Bedarf) | 643.0 mm | 1 |
| Stuetze Bunkerfront | 1134.4 mm | 2 |
| Stuetze Tellerrahmen | 1247.0 mm | 2 |
| Stuetze Tellerrahmen | 934.6 mm | 2 |
| Tellerrahmen Seite links oben | 166.0 mm | 1 |
| Tellerrahmen Seite links unten | 250.0 mm | 1 |
| Tellerrahmen Seite rechts | 524.0 mm | 1 |
| Tellerrahmen waagerecht | 668.0 mm | 2 |

## Platte

| Bezeichnung | Groesse / Verwendung | Anzahl |
|---|---|---|
| Rueckwand (sheet_rueckwand.dxf) 4 mm |  | 1 |
| Bunkerboden (sheet_bunker_boden.dxf) 4 mm |  | 1 |
| Bunkerseite unten (sheet_bunker_seite_unten.dxf) 4 mm, 1x gespiegelt |  | 2 |
| Bunkerseite oben (sheet_bunker_seite_oben.dxf) 4 mm, 1x gespiegelt |  | 2 |
| Haube transparent (sheet_haube.dxf) 4 mm PETG/PC |  | 1 |

## Druckteil

| Bezeichnung | Groesse / Verwendung | Anzahl |
|---|---|---|
| lagerbock_teller |  | 1 |
| haken |  | 10 |
| nabe |  | 1 |
| randring_1 |  | 1 |
| randring_2 |  | 1 |
| randring_3 |  | 1 |
| randring_4 |  | 1 |
| randring_5 |  | 1 |
| randring_6 |  | 1 |
| kantenwinkel_1 (Boden/Seite) |  | 4 |
| kantenwinkel_2 (Seite/Seite) |  | 4 |
| bodenauflage |  | 2 |
| uebergabe |  | 1 |
| auslauf |  | 1 |
| deckel_auslauf |  | 1 |
| abstreifer |  | 1 |
| haubenhalter |  | 4 |
| rinne_G1 |  | 1 |
| rinne_G2 |  | 1 |
| deckel_G1 |  | 1 |
| deckel_G2 |  | 1 |
| klemmbock |  | 1 |
| klemmstempel |  | 1 |
| sperrkonsole |  | 1 |
| sperrstift |  | 1 |
| klemmpad (TPU 95A) |  | 1 |
| gehaeuse_motorseite |  | 1 |
| gehaeuse_lagerseite |  | 1 |
| rotor_motorseite |  | 1 |
| rotor_lagerseite |  | 1 |
| motorstutzen |  | 1 |
| fallschacht |  | 1 |
| e18_halter |  | 1 |
| sensorhalter_laser |  | 5 |
| sensorhalter_pt |  | 5 |
| keil_teller |  | 4 |

## Zukauf

| Bezeichnung | Groesse / Verwendung | Anzahl |
|---|---|---|
| Schrittmotor NEMA17 1,7 A mit Planetengetriebe 13,73:1 (z.B. 17HS19-1684S-PG14), Abtrieb D8 |  | 1 |
| Rillenkugellager 6001-2RS (12x28x8) |  | 2 |
| Hallsensor A3144 (TO-92) fuer Tellerdrehung |  | 1 |
| Tellerplatte PE-HD 10 mm, D500 nach DXF (sheet_tellerplatte.dxf) |  | 1 |
| Welle D12 h6, Silberstahl, 2 Abflachungen | 118 mm | 1 |
| Klauenkupplung D25 L30, 8-12 mm |  | 1 |
| Stellring D12 (DIN 705) |  | 1 |
| Distanzhuelse 12/18 x 6 (Stahl oder Messing), zwischen Nabe und Lager |  | 1 |
| Neodym-Magnet 6x3 (Nabe, je Tasche) |  | 10 |
| Pneumatikzylinder ISO 6432 D10 Hub 25, doppeltwirkend (Sperre A) |  | 1 |
| Pneumatikzylinder ISO 6432 D10 Hub 10, doppeltwirkend (Klemme B) |  | 1 |
| Zylinderstift D4x12 ISO 8734 (Kanalstoesse) |  | 8 |
| Schrittmotor NEMA17 42x40, Welle D5x24 mit Abflachung (Rotor) |  | 1 |
| Rillenkugellager 688-2RS (8x16x5) |  | 1 |
| Zylinderstift D8x20 ISO 8734 (Rotorachse Lagerseite) |  | 1 |
| Laserdiodenmodul 650 nm, <1 mW (Klasse 2), D6 mm, 5 V |  | 5 |
| Fototransistor 5 mm (z.B. SFH 300 / LPT80A) |  | 5 |
| Naeherungssensor E18-D80NK (M18, NPN, 3-80 cm) |  | 1 |
| Hallsensor A3144 (TO-92) + Neodym-Magnet 6x3 (Rotor) |  | 1 |
| Stellfuss M8 (oder M5 je nach Profil) D30 |  | 7 |
| Gelenkverbinder 20x20 Nut 6 |  | 4 |

## Normteil

| Bezeichnung | Groesse / Verwendung | Anzahl |
|---|---|---|
| Senkschraube M4x16 ISO 10642 | Haken: von hinten durch die Tellerplatte in den Einsatz | 20 |
| Senkschraube M5x40 ISO 10642 + Mutter M5 | Nabe: von vorn durch Teller + Nabe, Mutter in der Nabe | 4 |
| Schraube M4x16 ISO 4762 + Mutter M4 | Nabe: Klemmung auf der Wellenabflachung (Kopf frei im Senkloch) | 1 |
| Gewindeeinsatz M4 (z.B. Ruthex RX-M4x8,1) | Haken 20, Randring 12, Uebergabe 3, Abstreifer 4, Bodenauflage 2, Reserve 4 | 45 |
| Schraube M5x12 ISO 4762 + Hammermutter M5 Nut 6 | Lagerbock an die Querholme | 4 |
| Schraube M4x10 ISO 4762 | Getriebeflansch an Lagerbock (Laenge am Motor pruefen) | 4 |
| Schraube M5x10 ISO 4762 + Scheibe + Hammermutter M5 | Rueckwand an Tellerrahmen | 17 |
| Senkschraube M4x10 ISO 10642 | von hinten durch die Rueckwand: Randring 12, Uebergabe 3, Abstreifer 4 | 19 |
| Schraube M4x90 ISO 4762 + Mutter + 2 Scheiben | Haube mit Distanzrohr an Rueckwand | 4 |
| Senkschraube M4x16 ISO 10642 + Mutter M4 | Kantenwinkel (8 Stueck) an den Bunkerblechen | 16 |
| Senkschraube M4x12 ISO 10642 | Bunkerboden auf Bodenauflage | 2 |
| Schraube M5x12 ISO 4762 + Hammermutter M5 | Bodenauflage auf Bunker-Frontholm | 4 |
| Schraube M5x20 ISO 4762 (in Profilkernloch, M5 schneiden) | Keile auf Stuetzen | 4 |
| Schraube M5x12 ISO 4762 + Hammermutter M5 | Keile an Tellerrahmen (2 je Keil) | 8 |
| Winkel 20x20 Nut 6 (Druckguss) inkl. 2x M5x10 + 2x Hammermutter | Tellerrahmen 8, Querholme 4, Bodenrahmen 16, Stuetzen 12, Frontholm 2, Rotorsaeule/Arm/Ausleger 6, Reserve 4 | 52 |
| Gelenkverbinder 20x20 Nut 6 | Diagonalstreben Rotorsaeule | 4 |
| Gewindeeinsatz M3 (z.B. Ruthex RX-M3x5,7) | Auslauf 8 (Flansche) + 4 (Deckel), G2 8 (Flansch 4 + Konsole 4), Deckel G1/G2 16, Gehaeuse 4 (Flansch) + 4 (Schacht) + 5 (Haelften) + 8 (Sensoren), Rinne G1 4 (Sensor), Schacht 8 (Sensoren), Reserve 3 | 76 |
| M3x16 ISO 4762 | Kanalstoesse Uebergabe-Auslauf (3), Auslauf-G1, G1-G2, G2-Gehaeuse (je 4) | 15 |
| M3x8 ISO 4762 | Deckel (16), Sensorhalter (20) | 36 |
| M3x20 ISO 4762 | Klemmbock (4), Motor Rotor (4) | 8 |
| M3x10 ISO 4762 | Sperrkonsole (4), Fallschacht (4) | 8 |
| M3x35 ISO 4762 | Gehaeusehaelften | 5 |
| M3x40 ISO 4762 + Mutter M3 | Rotorhaelften | 4 |
| Madenschraube M3x6 ISO 4026 + Mutter M3 | Rotornabe auf Motorwelle (Flat) | 1 |
| Madenschraube M3x4 | Sensorhalter Klemmung | 10 |
| M5x12 ISO 4762 + Hammermutter M5 | Gehaeuselasche an Rotorarm | 2 |
| Mutter M4 (Stempel) | Klemmstempel auf Kolbenstange | 1 |

## Elektrik/Pneumatik

| Bezeichnung | Groesse / Verwendung | Anzahl |
|---|---|---|
| ESP32 DevKitC V4 (38 Pin) | Steuerung | 1 |
| Schrittmotortreiber TMC2209 (Modul, z.B. BTT V1.3) | Rotor + Tellerantrieb | 2 |
| Netzteil 24 V / 6,5 A (150 W, z.B. Mean Well LRS-150-24) |  | 1 |
| DC/DC-Wandler 24 V -> 5 V / 3 A | ESP32, Laser, Sensoren | 1 |
| MOSFET-Modul 4-fach (z.B. IRLZ44N/AOD4184, Logic-Level) + Freilaufdioden | 2 Ventile + Laser + Leuchte | 1 |
| Magnetventil 5/2 monostabil 24 VDC, M5 (z.B. Airtac 4V110-M5) | Sperre A, Klemme B | 2 |
| Druckregler mit Manometer 0-4 bar, Wartungseinheit | Klemme B mit 1-2 bar | 1 |
| Steckverschraubung M5 auf 4 mm + Drosselrueckschlag M5 | Zylinderanschluesse | 4 |
| PU-Schlauch 4 mm | m | 3 |
| Not-Halt-Taster 1 Oeffner + Schuetz/Relais 24 V fuer Motor-/Ventilspannung |  | 1 |
| Taster Start (gruen) / Stop (rot), Leuchtmelder Stoerung (gelb) | Satz | 1 |
| Kabel LiYY 4x0,25 (Sensoren), LiYY 4x0,5 (Motoren) | Satz | 1 |
| Gehaeuse ABS ca. 200x150x75, Kabelverschraubungen M16 |  | 1 |

