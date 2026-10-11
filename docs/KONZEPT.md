# Flaschen-Unscrambler für das KE-50 Band – Konzept

**Flasche:** Rebhan FPS K-3906.004, 50 ml HD-PE, Ø30 ± 0,3 × 102,5 ± 1 mm, Hals 24/410 (Ø23,8), 7 g
**Ziel:** Flaschen aus dem Karton (≈ 500 Stück, lose) **stehend, Boden unten** einzeln aufs KE-50 Band, 30–60 Fl./min
**Randbedingungen:** keine Vibrationstonne, Gestell aus 20×20 Nut 6 B-Typ, Funktionsteile aus dem 3D-Drucker (PETG, Bauraum 256 mm), Druckluft vorhanden, Steuerung ESP32 + Schrittmotoren

![Gesamtansicht Bandseite](img/gesamt_bandseite.png)

## 1. Funktionsprinzip

```
 Bunker ─► Stufenförderer ─► Trog ─► Rinne (28°) ─► Klemme B ─► Sperre A ─► Wendetrommel ─► Fallschacht ─► Band
 (≈530 Fl.)  7 Stufen, Hub 80   V-Rinne   Lichtschr.   (X3 halten)  (X2 halten)  Halsnut +        Boden voraus
             (Exzenter)                   "voll"                              2 Lichtschranken
```

1. **Bunker + Stufenförderer** (ohne Vibration): Das ganze Modul ist um **28° gekippt**. Die Flaschen liegen in den Stufen quer und rutschen deshalb von selbst an das tiefe Stufenende. Sieben bewegte Stufen (M1…M7) heben die Flaschen um je 63,7 mm über die festen Stufen (F0…F6). Der Antrieb ist eine Exzenter-Nocke mit Rolle; nach unten geht es per Schwerkraft. Jede Stufe ist 32 mm tief, also nur eine Flaschenbreite. Überzählige Flaschen fallen zurück, eine Schürze über F2 begrenzt den Schüttdruck.
2. **Trog → Rinne:** Die oberste Stufe kippt die Flaschen in einen 90°-V-Trog. Darin rutschen sie mit dem Hals oder dem Boden voraus in Längsrichtung in die Rinne. Ein **Abweiser** am Trogende rollt Flaschen aus einer zweiten Lage in den Förderer zurück.
3. **Vereinzelung:** Die Flaschen liegen Stoß an Stoß.
   - **Klemme B** (Ø10/10, 1–2 bar, TPU-Pad) hält die dritte Flasche (X3) fest.
   - **Sperre A** (Ø10/25, Stift von unten) gibt genau eine Flasche (X2) frei und schließt sofort dahinter.
   - Danach öffnet B, die Reihe rutscht um eine Flaschenlänge nach, und B klemmt wieder.
4. **Wendetrommel mit Halsnut (Kern der Orientierung):** Die Flasche rutscht in den Trommelschacht bis an den Gehäuseanschlag.
   - Dort ist eine **26,5 mm breite Umfangsnut** eingelassen.
   - Der **Hals (Ø23,8) taucht ≈ 17 mm** in die Nut ein. Der **Rumpf (Ø30)** passt nicht hinein und liegt an den Nutkanten an.
   - Dadurch liegt das Einlaufende der Flasche je nach Lage um **≈ 17 mm** verschieden. Eine Lichtschranke dort unterscheidet sicher, mit **± 8,7 mm Reserve**:

   | Lichtschranke „Orientierung“ | Lage | Drehung | Ergebnis |
   |---|---|---|---|
   | **belegt** | Boden am Anschlag | **−62°**: Anschlagende nach unten | Boden voraus in den Schacht |
   | **frei** | Hals in der Nut | **+58°** halten (Hals rutscht aus der Nut), dann **+118°**: Einlaufende nach unten | Boden voraus in den Schacht |

   Eine zweite Lichtschranke („Präsenz“) bestätigt, dass eine Flasche da ist. Ist das Ergebnis unklar, wackelt der Rotor kurz (−6°), damit sich die Flasche neu setzt, und misst dann erneut.
5. **Fallschacht → Band:** Die Flasche fällt ≈ 113 mm Boden voraus durch einen Trichter in den Schacht. Er ist 34 mm breit, an drei Seiten geführt und zum Band hin (+X) offen. Die Flasche steht auf dem Gurt und wird ausgetragen. Zwei Lichtschranken im Schacht melden „frei“, und der E18-Sensor über dem Band erkennt einen Stau.

| Boden am Anschlag | Hals in der Nut |
|---|---|
| ![](img/schnitt_boden.png) | ![](img/schnitt_hals.png) |
| Abwurf −62° | Abwurf +118° |
| ![](img/abwurf_boden.png) | ![](img/abwurf_hals.png) |

Rote Stäbe: Lichtschranken. Links ist „Orientierung“, rechts „Präsenz“.

## 2. Warum diese Lösung

- **Kein Vibrationsförderer:** Der Stufenförderer ist leise, schont die Flaschen und lässt sich gut drucken. Er bewegt die leichten 7-g-Flaschen sicher, ohne sie zu verkanten.
- **Orientierung über Geometrie, nicht über Gewicht:** Boden und Hals wiegen bei der leeren Flasche praktisch gleich viel. Fallrichtungs-Tricks sind deshalb unzuverlässig. Die Halsnut macht aus 3 mm Durchmesserunterschied **17 mm Lageunterschied**. Damit reichen einfache Lichtschranken, und auch die Toleranzen L ±1 und D ±0,3 sind geprüft (siehe 5.).
- **Ein Motor für alle Lagen:** Beide Lagen werden durch die Drehrichtung gelöst. Es gibt keinen Ausschuss und keine Rückführung, also 100 % Ausbeute.
- **Fail-safe:** Stromlos ist die Sperre zu und die Klemme offen. Der Rotor steht dann, und es kann nichts nachlaufen.

## 3. Hauptmaße (Band-OK = 900 mm, Parameter `BELT_Z`)

| Größe | Wert |
|---|---|
| Rotorachse über Boden | 1072 mm (Band + 172) |
| Bunker-Einfüllhöhe | 1250 mm (Band + 350), waagerechter Rand |
| Bunkerinhalt | ≈ 69 l ≈ **530 Flaschen** |
| Neigung Stufenförderer / Rinne | 28° (Reibwinkel PETG/HDPE ≈ 11–19°) |
| Stufen | 7 × 63,7 mm, Hub 80 mm, Stufenlänge 240 mm (≈ 2 Flaschen je Hub) |
| Rinnenquerschnitt | 90°-V, lichte Breite 33, Decke +18,5 über Flaschenachse |
| Wendetrommel | Ø116 × 45, Gehäuse Ø118 innen, Halsnut 26,5 breit / 22 tief |
| Fallhöhe | max. 113 mm (1,5 m/s) |
| Platzbedarf | ca. 1,4 m (X, entlang Band) × 1,0 m (Y) neben dem Band; Arm reicht 45 mm über die Bandmitte, Stau-Sensor 260 mm bandabwärts |

Alle Maße sind parametrisch in [`cad/config.scad`](../cad/config.scad). Die **Bandhöhe** bitte vor Ort messen und `BELT_Z` anpassen. Danach `tools/build_all.sh` ausführen; Profillängen, Platten und STL passen sich an.

![Seitenansicht](img/seitenansicht.png)

## 4. Leistung (aus [`auslegung.md`](auslegung.md))

- Takt Wendetrommel + Vereinzelung: **≈ 0,87 s** (Boden am Anschlag) bzw. **≈ 0,96 s** (Hals am Anschlag), im Mittel **≈ 66 Fl./min**. Begrenzend ist das Nachrutschen der Warteschlange.
- Stufenförderer: ≈ 1,5 Fl./Hub. Bei 40 Hüben/min wird die Rinne also schneller gefüllt als geleert. Die Lichtschranke „voll“ schaltet den Förderer aus, er hält in der unteren Stellung.
- Hubantrieb: max. 2,4 Nm an der Nockenwelle. Ein NEMA17 mit Planetengetriebe 13,73:1 braucht dafür 0,22 Nm, das ist ≈ 1,5-fache Reserve. Die Rolle hebt bis 60 U/min nicht ab.

## 5. Prüfungen am CAD-Modell (automatisch, `tools/`)

| Prüfung | Ergebnis |
|---|---|
| Kollision: 135 Paarungen über 8 Nockenstellungen und 10 Rotorwinkel | **0 Kollisionen** |
| Lichtschranken bei L 101,5/102,5/103,5 und D 29,7/30/30,3 (je beide Lagen) | **alle eindeutig** |
| Abwurf −62°: Flasche läuft ohne Verschieben durch Nut/Rampe | ok (0,0 mm) |
| Abwurf +118°: Hals in der Nut frei bis 78°; Firmware hält bei 58° | ok |
| Freier Fall Rotor → Trichter → Schacht (alle zulässigen Lagen, D 29,7/30,3) | ok |
| Auslauf unter dem Gehäuse (Flasche 103,5 hoch) | ok, 5 mm Luft |
| Durchlauf Trog → G1 → G2 → Rotor (Sperre und Klemme offen) | ok |
| Druckteile: dicht, ein Körper, passt in 256 mm, stützfrei ausgerichtet | 31/31 ok |

## 6. Offene Punkte vor Ort

1. **Bandhöhe KE-50 messen** → `BELT_Z`. Prüfen, ob die Bandbeine im Bereich Y = −120…−420 mm (Bodenrahmen Rotor) frei sind.
2. **Seitenführung des KE-50** auf X = −30…+50 mm um die Abwurfstelle aussparen. Die Seitenwände des Fallschachts übernehmen dort die Führung und laufen bei X = +50 aus. Die Führungen auf **34 mm** Abstand einstellen. Bandgeschwindigkeit ≥ 0,15 m/s, damit der Schacht schnell frei wird.
3. **Getriebeflansch** des Hubmotors prüfen. Angenommen sind 4 × M4 auf Ø28 mit Zentrierung Ø22 (`GB_PCD` in `cad/parts/drive.scad`).
4. **Schulterform der Flasche:** Angenommen ist eine Schulter bei 17 mm mit R2,5. Bei abweichender Form ändert sich nur die Eintauchtiefe in die Nut; die Lichtschranke hat ± 8,7 mm Reserve.
5. **Naturfarbene, durchscheinende Flaschen:** Die Lichtschranken arbeiten analog mit einstellbarer Schwelle. Der Befehl `cal` misst den freien Pegel. Bei sehr klaren Flaschen kann ein Polarisationsfilter oder ein IR-Laser nötig sein.
