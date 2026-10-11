# Fertigung, Montage und Inbetriebnahme

## 1. Drucken (PETG, Düse 0,4)

Die STL liegen fertig ausgerichtet in [`stl/`](../stl). Liste mit Anzahl, Maßen und Gewicht: [`druckteile.csv`](druckteile.csv), insgesamt ≈ 2,4 kg PETG.

| Teilgruppe | Einstellungen |
|---|---|
| Haken (10×) | 5 Wände, 40 % Füllung, Tellerseite unten. Die Leistenaußenfläche ist die Rinnenflanke: nicht nacharbeiten |
| Nabe, Lagerbock, Keile | 6 Wände, 50–60 % Füllung |
| Randring 1…6 | 4 Wände, 20 % Füllung, Fuß unten |
| Übergabe | Rinnenlage (Kiel unten), Gleitflächen mit 0,15 mm Schicht. Unter dem Einlauftrichter ggf. Stützen |
| Auslauf, Rinne G1/G2, Rotor, Gehäuse | 4 Wände, 25 % Gyroid, 0,2 mm. **Nicht schrumpfen lassen:** Gehäuse kühl drucken, Brim 5 mm |
| Klemmpad | TPU 95A, 100 % |
| Sensorhalter | schwarzes PETG (kein Streulicht), 100 % |

Danach:
- **Gewindeeinsätze** M3 (Ø4,2 × 5,7) und M4 (Ø5,6 × 8,1) mit dem Lötkolben setzen (Liste in [`stueckliste.md`](stueckliste.md)).
- **Lagersitze:** 2 × 6001 in den Lagerbock (vorn und hinten bis zur Schulter), 688 in die Rotor-Lagerseite einpressen. Ist der Sitz zu eng, mit 28- bzw. 16-mm-Reibahle nacharbeiten.
- **Stift 8×16** in die Gehäuse-Lagerseite einpressen und mit Fügeklebstoff sichern.
- **Sperrstift:** M4 schneiden und auf die Kolbenstange von Zylinder A schrauben (mit Schraubensicherung).
- **Magnete 6×3** (10 Stück) in die Nabenrückseite kleben, alle mit **gleicher Polung** (Südpol zum Hallsensor).

## 2. Platten und Tellerplatte

DXF in [`dxf/`](../dxf):

| Datei | Material | Anzahl |
|---|---|---|
| `sheet_tellerplatte.dxf` | PE-HD 10 mm, eben | 1 |
| `sheet_rueckwand.dxf` | PETG/PC 4 mm | 1 |
| `sheet_haube.dxf` | PETG/PC 4 mm, klar | 1 |
| `sheet_bunker_boden.dxf` | PETG/PC 4 mm | 1 |
| `sheet_bunker_seite_unten.dxf` | PETG/PC 4 mm | 2 (eine spiegelbildlich) |
| `sheet_bunker_seite_oben.dxf` | PETG/PC 4 mm | 2 (eine spiegelbildlich) |

Bearbeitung:
- **Tellerplatte:**
  - Die Haken-Bohrungen (20 × Ø4,5) **von hinten** 90° senken.
  - Die Naben-Bohrungen (4 × Ø5,5) **von vorn** senken.
  - Die Senkköpfe dürfen nicht vorstehen.
- **Rückwand:** Alle M4-Bohrungen von hinten senken (Ring, Übergabe, Abstreifer).
- **Bunkerbleche:** Die Bohrungen der Kantenwinkel und Bodenauflagen von innen senken. Die Konturen sind die Innenflächen. Die Kanten an den Kehlen dürfen gerade (90°) geschnitten sein.

## 3. Profile zuschneiden

Zuschnittliste: [`stueckliste.md`](stueckliste.md), ≈ 17 m Profil 20×20 Nut 6 B-Typ.

- **Stützen** auf ± 0,5 mm genau. Sie bestimmen die Lage des Tellers zur Rinne.
- **M5-Gewinde in das Kernloch schneiden** bei: Stützen oben (4, für die Keile), Rotorsäule unten und Stellfüße.

## 4. Tellereinheit (liegend auf dem Tisch aufbauen, Rückwand unten)

1. **Rahmen:** Waagerechte Holme oben und unten, Seitenholm rechts, Seitenholm links in zwei Stücken (dazwischen läuft der Auslauf). Hinten die zwei Querholme der Lagerung (x = ±50) aufsetzen.
2. **Rückwand** auf den Rahmen schrauben (M5 + Hammermutter).
3. **Lagerbock:**
   - Die 6001-Lager einpressen und den Hallsensor A3144 liegend in die Tasche der Stirnseite kleben (flache Seite nach vorn, Beine nach hinten).
   - Den Lagerbock mit 4 × M5 an die Querholme schrauben.
   - Den Motor mit Planetengetriebe an die Getriebeplatte schrauben (4 × M4, Zentrierung Ø22).
4. **Welle und Teller:**
   - Welle Ø12 von vorn durch die Lager stecken und die Distanzhülse 12/18×6 aufsetzen.
   - Die Nabe (mit Magneten) aufschieben und auf die Abflachung klemmen (M4×16 durch die Mutter).
   - Hinten den Stellring setzen, dann die Klauenkupplung.
   - Die Tellerplatte mit 4 × Senkschraube M5 an die Nabe schrauben.
   - **Teller-Vorderseite bündig mit der Rückwand-Vorderseite** (± 0,3 mm, Lineal über beide). Mit der Lage der Nabe auf der Welle einstellen.
5. **Haken** von hinten mit je 2 × M4×16 Senkkopf anschrauben. Der Pfeil auf dem Haken zeigt in Drehrichtung (von vorn gesehen gegen den Uhrzeigersinn).
6. **Randring 1…6** von hinten durch die Rückwand anschrauben (Nummern = Reihenfolge links oben → unten → rechts). Spalt Teller ↔ Ring ≈ 1,5 mm prüfen.
7. **Abstreifer** (rechts oben) und **Übergabe** (links oben) von hinten anschrauben:
   - Teller langsam von Hand drehen.
   - Jeder Haken muss **unter dem Pflug** (≥ 0,5 mm) und neben der Seitenwand der Übergabe frei durchlaufen.
8. **Bunkerbleche** in die Nuten des Randrings stellen: zuerst Boden, dann die Seiten. Kantenwinkel außen anschrauben (Senkkopf M4 von innen).
9. **Haube** mit Distanzrohren und M4×90 aufsetzen.

## 5. Gestell und Aufstellung

1. **Bodenrahmen** nach Zeichnung aufbauen. Er liegt schräg zum Band (parallel zur Tellerebene) und hat einen Ausleger zur Rotorsäule. Stellfüße eindrehen.
2. Die **vier Stützen** aufstellen und die Keile (51,4°) oben aufschrauben (M5 in das Kernloch).
3. Die **Tellereinheit** mit den Seitenholmen auf die Keile setzen und mit M5 in die Holmnut verschrauben.
4. **Bunker-Frontholm** auf die zwei vorderen Stützen setzen. Die Bodenauflagen aufschrauben und den Bunkerboden darauf befestigen.
5. **Rotorsäule** mit zwei Streben (Gelenkverbinder) und Rotorarm aufbauen, dann den Sensorausleger auf den Arm setzen.
6. Das Gestell so neben das KE-50 stellen, dass die **Rotormitte über der Bandmitte** liegt (Y = 0). Mit den Stellfüßen die Bandhöhe ausgleichen: Unterkante Fallschacht **1,5 mm über dem Gurt**.

## 6. Wendetrommel, Rinne, Schacht

1. **Gehäuse Motorseite:** Motorstutzen und NEMA17 mit 4 × M3×20 von innen verschrauben (Köpfe versenkt).
2. **Rotor:**
   - Die Hälften mit 4 × M3×40 verschrauben, das 688-Lager in die Lagerseite drücken und Magnet 6×3 in die +X-Fläche kleben.
   - Den Rotor auf die Motorwelle schieben (Flat zur Madenschraube) und die Madenschraube durch das Fenster im Stutzen anziehen.
3. **Gehäuse Lagerseite** aufsetzen (Stift in Lager) und mit 5 × M3×35 verschrauben. Den Rotor von Hand drehen; er muss frei laufen, 1 mm Spalt.
4. Den Fallschacht unten anschrauben (4 × M3×10). Lichtschrankenhalter montieren: Laser auf der −X- bzw. −Y-Seite, Fototransistoren gegenüber.
5. Das Gehäuse mit der Lasche an den Rotorarm schrauben (2 × M5, Höhe einstellbar).
6. **Rinne:**
   - Auslauf an die Übergabe (3 × M3 + 2 Stifte), G1 an den Auslauf, G2 an G1, G2 an das Gehäuse, jeweils mit 2 Zylinderstiften Ø4 + 4 × M3. Die Stifte bestimmen die Flucht.
   - **Rotorsäule und Arm so verschieben, dass sich alle Flansche spannungsfrei verschrauben lassen.**
   - Dann Deckel, Klemmbock mit Zylinder B, Sperrkonsole mit Zylinder A montieren.
   - **Kontrolle:** Eine Flasche von Hand in die Übergabe legen. Sie muss bis zum Anschlag ohne Hängen laufen. Kanten an den Stößen gegebenenfalls leicht entgraten.

## 7. Inbetriebnahme (serielle Konsole 115200 Baud, Befehl `help`)

1. **Ohne Druckluft und Flaschen.** Laser ausrichten:
   - Mit `sens` die Rohwerte ablesen. Frei sollte der Wert < 800 sein, mit Papier im Strahl > 3000.
   - Dann `cal` ausführen, damit werden die Schwellen gesetzt. Mit `save` speichern.
2. **Drehsinn Rotor:**
   - `rot 30` muss den Anschlag nach **oben** drehen (Rotor dreht von +Y nach +Z, Blick von +X). Sonst `set rot_dir -1`.
   - Dann `home` ausführen: Der Rotor sucht den Hallsensor und fährt in die Ladestellung.
   - Steht der Schacht nicht genau in Flucht mit G2, mit `set rot_home_ofs <Grad>` korrigieren. Dabei mit einer Flasche prüfen, ob sie ohne Kante einrutscht.
3. **Teller:**
   - `feed 5` (langsam). Von vorn gesehen muss der Teller **gegen den Uhrzeigersinn** drehen: rechts hoch, links runter. Sonst den Motorstecker drehen (eine Spule tauschen).
   - Bei langsamer Drehung mit `sens` prüfen, dass „Hall Teller“ bei jedem Haken kurz auf 1 geht (10 Magnete).
   - `feed 0`.
4. **Pneumatik:**
   - `gate 1` / `gate 0` sowie `clamp 1` / `clamp 0` schalten.
   - Den Sperrstift ausgefahren auf ≈ 15 mm über der V-Spitze einstellen (Kolbenstange in der Kappe drehen).
   - Den Klemmstempel so einstellen, dass er mit 3–4 mm Vorlauf auf die Flasche drückt.
5. **Einzelflaschen** von Hand in die Übergabe legen, je 10 × Boden voraus und 10 × Hals voraus. Dann `start`:
   - `status` zeigt den Zähler „Hals am Anschlag“.
   - Jede Flasche muss **stehend** auf dem Band ankommen.
6. **Bunker füllen** (bis zum Rand, ≈ 260 Flaschen), `start`. Beobachten:
   - Die Taschen füllen sich unten, die zweite Lage fällt am Abstreifer zurück.
   - Bei „Rinne voll“ steht der Teller, bevor eine weitere Flasche übergeben wird.
   - Die Tellerdrehzahl mit `set feed_rpm 12…18` anpassen, mit `save` speichern.
7. **Leistung optimieren**, dabei mit `status` die Rate beobachten:
   - `t_slide2`: Nachrutschzeit, so kurz wie sicher möglich.
   - `t_settle`, `t_drop`.
   - `t_hold`: Ist der Hals beim Haltepunkt noch nicht aus der Nut, den Wert erhöhen.

### Störmeldungen

| Meldung | Ursache / Abhilfe |
|---|---|
| Orientierung nicht eindeutig | Laser verstellt, Schwelle prüfen (`sens`), Flasche verformt |
| Flasche hängt im Rotor | Rotor von Hand leeren, Spiel im Schacht und Rotorschacht prüfen |
| Rotor belegt in Ladestellung | dto. |
| Teller blockiert -> Pause | Mitnehmer läuft gegen eine Flasche, meist bei voller Rinne. Der Teller läuft nach 1,5 s selbst wieder an |
| Teller blockiert (kein Hall-Impuls) | 3 Blockaden in 30 s: Flasche zwischen Haken und Pflug/Ring? Magnete, Hallsensor, Kupplung prüfen |
| Warnung: Flasche im Schacht nicht erkannt | Schachtschranke A ausrichten; Flasche eventuell im Rotor hängen geblieben |
| NOT-HALT / Leistungskreis aus | K1 prüfen. Nach dem Entriegeln **Start** drücken, dann wird neu referenziert |
