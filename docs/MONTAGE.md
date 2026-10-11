# Fertigung, Montage und Inbetriebnahme

## 1. Drucken (PETG, Düse 0,4)

Die STL liegen fertig ausgerichtet und stützfrei in [`stl/`](../stl). Liste mit Anzahl, Maßen und Gewicht: [`druckteile.csv`](druckteile.csv), insgesamt ≈ 5,5 kg PETG.

| Teilgruppe | Einstellungen |
|---|---|
| Stufen M/F/F0, Trog | 4 Wände, 5 Decklagen, 12–15 % Gyroid. Gleitflächen (Stufen-Oberseite, V-Rinne) mit 0,15 mm Schichthöhe |
| Rotor, Gehäuse, Rinne G1/G2 | 4 Wände, 25 % Gyroid, 0,2 mm. **Nicht schrumpfen lassen:** Gehäuse kühl drucken, Brim 5 mm |
| Nocke, Keile, Motorbock, Lagerbock | 6 Wände, 50 % Füllung |
| Klemmpad | TPU 95A, 100 % |
| Sensorhalter | schwarzes PETG (kein Streulicht), 100 % |

Danach:
- **Gewindeeinsätze M3** (Ø4,2 × 5,7) mit dem Lötkolben setzen (Liste in [`stueckliste.md`](stueckliste.md)).
- **Lagersitze:** 608 im Lager- und Motorbock, 688 in der Rotor-Lagerseite einpressen. Ist der Sitz zu eng, mit 22-mm- bzw. 16-mm-Reibahle nacharbeiten.
- **Stift 8×16** in die Gehäuse-Lagerseite einpressen und mit Fügeklebstoff sichern.
- **Sperrstift:** M4 schneiden und auf die Kolbenstange von Zylinder A schrauben (mit Schraubensicherung).

## 2. Profile zuschneiden

Zuschnittliste: [`stueckliste.md`](stueckliste.md), 37,2 m Profil 20×20 Nut 6 B-Typ.

- **Beine M1…M7, F0…F6, Trog auf ± 0,2 mm genau.** Sie bestimmen die Stufenhöhen; die Kappe sitzt direkt auf dem Bein.
- **M5-Gewinde in das Kernloch schneiden** bei: Modulstützen oben (6), Bodenstützen oben (4), Rotorsäule unten und Stellfüße.

## 3. Montage Stufenförderer (Modul liegt dabei flach auf dem Tisch)

1. Stationsquerholme (6) mit den Grundträgern (y = ±100) zum Rahmen verschrauben. Die MGN-Säulen auf die Querholme bei Station 3 und 6 setzen und die MGN12-Schienen montieren (M3 + Hammermutter M3).
2. Schlitten aufbauen: Querholme, Längsträger, Mittelholm, Schlittenadapter an die MGN-Wagen. Die Beine M1…M7 mit Winkeln auf die Längsträger setzen (y = ±60).
3. Beine F0…F6 und Trog auf die Grundträger setzen (y = ±100).
4. **Kappen aufsetzen:** M und F nach Beschriftung auf der Unterseite. Kappen M mit M5×50 von der Stirnseite in eine Hammermutter im Bein verschrauben, Kappen F mit M5×10, den Trog von vorn mit M5×20.
5. Hubantrieb montieren:
   - Lagerbock (+y) und Motorbock (−y) auf die Grundträger setzen.
   - Welle D8 mit Nocke (Flanschkupplung), Stellringe und Klauenkupplung montieren, dann den Motor mit 13,73:1-Getriebe anbauen.
   - Rollenhalter mit 608-Rolle unter den Mittelholm schrauben.
   - **Kontrolle:** Den Schlitten von Hand über die Nocke drehen. Er muss frei laufen, und die Rolle bleibt auf der Nocke.
6. **Stufen einstellen**, mit einer Messuhr oder einem Lineal über zwei Stufen:
   - Hub oben (Nocke 0°): Vorderkante M_i liegt **2,5 mm über** der Hinterkante F_i.
   - Hub unten (180°): Hinterkante M_i liegt **2,5 mm unter** der Vorderkante F_{i−1}.
   - Bei Abweichung das Bein kürzen oder unterlegen.
7. Hallhalter „Hub unten“ an Säule 1, Magnet 6×3 in den Schlittenadapter kleben (Schlitten in unterer Stellung).
8. Platten montieren: Bodenträger (10°) mit Stützen und Keilen 15°, Bodenplatte (Senkkopf M5), Seitenwände, Rückwand, Schürze mit Winkeln. **Spalt Kappe ↔ Seitenwand 0,75 mm** prüfen.

## 4. Gestell und Aufstellung

1. Bodenrahmen nach Zeichnung aufbauen, Stellfüße eindrehen. Die Modulstützen aufstellen und die Keile 28° oben aufschrauben (M5 in das Kernloch).
2. Das Modul auf die Keile setzen. Die Querholme der Stationen 1, 3 und 6 liegen auf; mit M5 von unten in die Nut verschrauben.
3. Rotorsäule mit zwei Streben (Gelenkverbinder) und Rotorarm aufbauen, dann den Sensorausleger auf den Arm setzen.
4. Den Bodenrahmen so neben das KE-50 stellen, dass die **Rotormitte über der Bandmitte** liegt (Y = 0). Mit den Stellfüßen die Bandhöhe ausgleichen: Unterkante Fallschacht **1,5 mm über dem Gurt**.

## 5. Wendetrommel, Rinne, Schacht

1. **Gehäuse Motorseite:** Motorstutzen und NEMA17 mit 4 × M3×20 von innen verschrauben (Köpfe versenkt).
2. **Rotor:** Die Hälften mit 4 × M3×40 verschrauben, das 688-Lager in die Lagerseite drücken und Magnet 6×3 in die +X-Fläche kleben. Den Rotor auf die Motorwelle schieben (Flat zur Madenschraube) und die Madenschraube durch das Fenster im Stutzen anziehen.
3. **Gehäuse Lagerseite** aufsetzen (Stift in Lager) und mit 5 × M3×35 verschrauben. Den Rotor von Hand drehen; er muss frei laufen, 1 mm Spalt.
4. Den Fallschacht unten anschrauben (4 × M3×10). Lichtschrankenhalter montieren: Laser auf der −X- bzw. −Y-Seite, Fototransistoren gegenüber.
5. Das Gehäuse mit der Lasche an den Rotorarm schrauben (2 × M5, Höhe einstellbar).
6. **Rinne:**
   - G1 an den Trog, G2 an G1 und G2 an das Gehäuse, jeweils mit 2 Zylinderstiften Ø4 + 4 × M3. Die Stifte bestimmen die Flucht. **Säule und Arm so verschieben, dass sich alle Flansche spannungsfrei verschrauben lassen.**
   - Dann Deckel, Klemmbock mit Zylinder B, Sperrkonsole mit Zylinder A montieren.
   - **Kontrolle:** Eine Flasche von Hand durchrutschen lassen. Sie muss vom Trog bis zum Anschlag ohne Hängen laufen. Kanten an den Stößen gegebenenfalls leicht entgraten.

## 6. Inbetriebnahme (serielle Konsole 115200 Baud, Befehl `help`)

1. **Ohne Druckluft und Flaschen.** Laser ausrichten:
   - Mit `sens` die Rohwerte ablesen. Frei sollte der Wert < 800 sein, mit Papier im Strahl > 3000.
   - Dann `cal` ausführen, damit werden die Schwellen gesetzt. Mit `save` speichern.
2. **Drehsinn prüfen:**
   - `rot 30` muss den Anschlag nach **oben** drehen (Rotor dreht von +Y nach +Z, Blick von +X).
   - Sonst `set rot_dir -1`.
   - Dann `home` ausführen: Der Rotor sucht den Hallsensor und fährt in die Ladestellung.
   - Steht der Schacht nicht genau in Flucht mit G2, mit `set rot_home_ofs <Grad>` korrigieren. Dabei mit einer Flasche prüfen, ob sie ohne Kante einrutscht.
3. **Pneumatik:**
   - `gate 1` / `gate 0` sowie `clamp 1` / `clamp 0` schalten.
   - Den Sperrstift ausgefahren auf ≈ 15 mm über der V-Spitze einstellen (Kolbenstange in der Kappe drehen).
   - Den Klemmstempel so einstellen, dass er mit 3–4 mm Vorlauf auf die Flasche drückt.
4. **Einzelflaschen** in den Trog legen, je 10 × Boden voraus und 10 × Hals voraus. Dann `start`:
   - `status` zeigt den Zähler „Hals am Anschlag“.
   - Jede Flasche muss **stehend** auf dem Band ankommen.
5. **Hubantrieb:**
   - Mit `feed 30` testen. Das Abheben der Rolle ist rechnerisch erst über 60 U/min möglich.
   - Die Betriebsdrehzahl mit `set feed_rpm 40` festlegen und mit `save` speichern.
6. **Leistung optimieren**, dabei mit `status` die Rate beobachten:
   - `t_slide2`: Nachrutschzeit, so kurz wie sicher möglich.
   - `t_settle`, `t_drop`.
   - `t_hold`: Ist der Hals beim Haltepunkt noch nicht aus der Nut, den Wert erhöhen.

### Störmeldungen

| Meldung | Ursache / Abhilfe |
|---|---|
| Orientierung nicht eindeutig | Laser verstellt, Schwelle prüfen (`sens`), Flasche verformt |
| Flasche hängt im Rotor | Rotor von Hand leeren, Spiel im Schacht und Rotorschacht prüfen |
| Rotor belegt in Ladestellung | dto. |
| Hubantrieb blockiert | Flasche zwischen Stufen und Seitenwand? Spalt 0,75 mm prüfen |
| Warnung: Flasche im Schacht nicht erkannt | Schachtschranke A ausrichten; Flasche eventuell im Rotor hängen geblieben |
| NOT-HALT / Leistungskreis aus | K1 prüfen. Nach dem Entriegeln **Start** drücken, dann wird neu referenziert |
