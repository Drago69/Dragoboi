# Einfaches 3-Achs-Gantry aus 3 × 40x20-Profil

Kartesische Maschine in Auslegerbauweise. Jede Achse besteht aus genau einem
V-Slot-Profil 2040, einem Schlitten auf vier V-Rädern und einem NEMA17-Motor.
Gedacht für leichte Arbeit wie Stiftplotter, Diodenlaser, Dosieren,
Pick & Place oder leichtes Gravieren. Zum Fräsen ist sie zu weich.

![Gesamtansicht](bilder/ansicht_1.png)
![Gesamtansicht von der Werkzeugseite](bilder/ansicht_2.png)

## Aufbau

| Achse | Profil | Lage | Antrieb |
|---|---|---|---|
| X | 2040 × 500 mm | liegt flach auf dem Tisch / Grundbrett | GT2-Riemen 6 mm, Motor am Profilanfang |
| Y | 2040 × 450 mm | Ausleger, quer auf den X-Schlitten geschraubt | GT2-Riemen 6 mm, Motor am Ausleger-Ende hinter dem X-Schlitten |
| Z | 2040 × 250 mm | senkrecht am Y-Schlitten (Z-Adapter) | T8-Trapezspindel, Motor oben |

- Alle drei Schlitten laufen auf je 4 V-Rädern, die auf den schmalen 20-mm-Seiten
  des Profils laufen (Lochabstand quer 59,7 mm, Standard für 2040).
- X und Y sind gleich gebaut: Motorkappe mit Zahnscheibe am einen Ende,
  Spannkappe mit Umlenkrolle und Spannschraube am anderen Ende. Der Riemen läuft
  flach über die Profiloberseite. Das ziehende Trum ist an beiden Schlittenenden
  geklemmt, das rücklaufende Trum läuft frei durch einen Kanal unter dem Schlitten.
- Z läuft mit Spindel, damit der Werkzeugschlitten stromlos nicht herunterfällt.

### Kennwerte (Standardmaße)

| | Wert |
|---|---|
| Verfahrweg X | 400 mm |
| Verfahrweg Y | ca. 277 mm (siehe [Grenzen](#grenzen-und-softlimits)) |
| Verfahrweg Z | 160 mm |
| Werkzeugplatte | 93,5 mm neben der X-Schlittenmitte (in −X), 6 × M4-Gewindeeinsatz im 20-mm-Raster |
| Höhe Z-Profil-Unterkante | 16 mm über dem Tisch |

OpenSCAD gibt diese Werte beim Rendern als `ECHO` aus. Sie passen sich an,
wenn Profillängen oder Schlittenmaße geändert werden.

## Dateien

- `gantry.scad`: parametrisches OpenSCAD-Modell. Mit `teil = "baugruppe"` zeigt es
  die ganze Maschine (F5). `pos_x`, `pos_y` und `pos_z` verfahren die Schlitten.
  Jedes andere `teil` rendert ein einzelnes Druckteil, schon in Druckrichtung auf z = 0.
- `stl/`: alle Druckteile mit den Standardwerten gerendert
- `bilder/`: Ansichten

## Druckteile

![Druckteile](bilder/druckteile.png)

| Teil | Anzahl | Funktion |
|---|---|---|
| `schlitten_x` | 1 | X-Schlitten, trägt den Y-Ausleger (8 × M5 von unten in Hammermuttern) |
| `schlitten_y` | 1 | Y-Schlitten, 4 Mutternfallen unten für den Z-Adapter |
| `motorkappe` | 2 | X und Y, Motor senkrecht, Zahnscheibe unter der Motorplatte |
| `spannkappe` | 2 | X und Y, Tunnel für den Spannschlitten |
| `spannschlitten` | 2 | trägt die Umlenkrolle, wird mit M3 nach außen gezogen |
| `z_adapter` | 1 | Winkel auf dem Y-Schlitten, hält das Z-Profil an der Rückseite |
| `z_schlitten` | 1 | Werkzeugschlitten mit Lasche für die T8-Mutter |
| `z_kopf` | 1 | oberer Z-Deckel mit Motorplatte |
| `z_fuss` | 1 | unterer Z-Deckel und Anschlag |

Druckempfehlung: PETG oder ASA, 0,2 mm Schicht, 4 Wände, 40 % Infill (Gyroid),
Schlitten mit 60 % Infill. Die STLs liegen schon richtig herum, Stützen sind
nicht nötig. Die Motorkappe wird kopfüber gedruckt (Motorplatte unten), damit
die Motorfläche plan wird.

Die Riemenklemmen sind 1,5 mm breite Schlitze mit kleinen Rippen, die in die
Riemenzähne greifen. Druck sie mit 0,4-mm-Düse und prüf zuerst mit einem
Riemenstück, ob der Riemen sich von oben hineindrücken lässt.

## Stückliste (Zukaufteile)

**Mechanik**
- V-Slot 2040: 500 mm, 450 mm, 250 mm, an allen 6 Enden M5-Gewinde in die
  Kernlöcher geschnitten (viele Händler liefern das auf Wunsch)
- 12 × V-Rad (Solid V-Wheel, Delrin) mit 2 × 625ZZ
- 6 × Distanzhülse 6,35 mm (M5), 6 × Exzenterbuchse 6,35 mm
- 3 × NEMA17 (z. B. 17HS4401, 1,5–2 A, Welle 5 mm, mind. 20 mm lang)
- 2 × GT2-Zahnscheibe 20 Zähne, Bohrung 5 mm, für 6-mm-Riemen
- 2 × GT2-Umlenkrolle 20 Zähne verzahnt, Bohrung 5 mm (Ø 18 mm, ca. 8,5 mm breit)
- GT2-Riemen 6 mm, 2,5 m (X ≈ 1060 mm, Y ≈ 960 mm)
- T8-Trapezgewindespindel 250 mm mit Flanschmutter. Steigung 2 mm ist
  selbsthemmend, Steigung 8 mm ist schneller.
- Wellenkupplung 5 → 8 mm (Ø 20 × 25 mm)

**Schrauben**
- Räder: 12 × M5×30 Linsenkopf (ISO 7380), 12 × M5-Stoppmutter, 12 × Scheibe M5
- Profilenden: 10 × M5×16 Zylinderkopf, 2 × M5×12 (Z-Fuß)
- Y-Ausleger auf X-Schlitten: 8 × M5×12 + 8 × Hammermutter M5 (V-Slot/Nut 6)
- Z-Adapter: 4 × M5×20 + 4 × Mutter M5 (Grundplatte), 6 × M5×16 + 6 × Hammermutter (Wand)
- Z-Kopf-Schürze: 2 × M5×10 + 2 × Hammermutter
- Motoren: 12 × M3×10
- Spannschlitten: 2 × M5×20 + 2 × Mutter M5 + 4 × Scheibe M5 (Rollenachse),
  2 × M3×25 + 2 × Mutter M3 (Spannschraube)
- T8-Mutter: 4 × M3×16 + 4 × Mutter M3
- Werkzeugplatte: 6 × Gewindeeinsatz M4 (Bohrung 5,6 mm, 8 mm tief), optional

**Elektronik (Vorschlag)**
- Arduino Uno + CNC-Shield mit GRBL oder ein 32-bit-Board mit FluidNC
- 3 × Treiber TMC2209 oder A4988, Netzteil 24 V / 5 A
- 3 × Endschalter
- Schritte/mm bei 1/16-Mikroschritt: X und Y = 80, Z = 400 (T8×8) bzw. 1600 (T8×2)

## Montage

1. **Räder.** Linsenkopfschraube von der Radseite durch Rad, Hülse und Platte
   stecken, oben Scheibe und Stoppmutter in die Senkung. Auf der einen Seite
   (Bohrung 5,4 mm) kommt die normale Hülse, auf der anderen Seite
   (Bohrung 7,2 mm) die Exzenterbuchse. Die Schraubenenden stehen oben ca. 1,5 mm vor.
2. **Y-Schlitten vorbereiten.** Vier M5-Muttern von unten in die Fallen drücken
   (mit etwas Klebeband halten).
3. **Y-Ausleger auf den X-Schlitten.** Je 4 Hammermuttern in die beiden unteren
   Nuten des Y-Profils schieben. Das Profilende bündig mit der Schlittenkante
   ausrichten und mit 8 × M5×12 von unten verschrauben. Das geht nur, solange der
   X-Schlitten noch nicht auf dem X-Profil sitzt.
4. **Schlitten aufschieben.** X- und Y-Schlitten von den Profilenden her
   aufschieben. Die Exzenter so drehen, dass kein Spiel bleibt und der Schlitten
   noch leicht läuft. Ein Rad, das du mit zwei Fingern nicht mehr drehen kannst,
   ist zu fest.
5. **Endkappen.** Motor mit Zahnscheibe von oben in die Motorkappe setzen und
   mit 4 × M3×10 von unten festschrauben, bevor die Kappe ans Profil kommt. Die
   Unterkante der Zahnscheibe liegt 23 mm unter der Motorflanschfläche, so läuft
   der Riemen auf Höhe der Klemmen. Die Kappen mit 2 × M5×16 in die Profilenden
   schrauben (Schlüssel von der offenen Stirnseite bzw. durch die Löcher in der
   Endwand). Auf der Spannkappe den Spannschlitten mit Umlenkrolle von oben
   einlegen, die M3-Mutter von oben in den Schlitz drücken und die M3×25 von
   außen durch die Endwand eindrehen.
6. **Riemen.** Ein Ende von oben in die Klemme an einem Schlittenende drücken,
   Zähne nach innen. Dann den Riemen über Zahnscheibe bzw. Rolle zurückführen,
   unter dem Schlitten durch den Kanal führen, um die andere Scheibe legen und
   in die zweite Klemme drücken. Mit der M3-Schraube spannen (bis 10 mm Weg).
7. **Z-Achse.** Drei Hammermuttern in jede Nut der Z-Profil-Rückseite schieben,
   außerdem eine pro Nut oben für die Schürze des Z-Kopfs. Den Z-Schlitten
   aufschieben und einstellen, dann den Z-Fuß anschrauben. Z-Kopf mit Motor,
   Kupplung und Spindel montieren, die T8-Mutter mit 4 × M3 auf die Lasche
   schrauben. Das Z-Profil mit 6 × M5×16 an den Z-Adapter schrauben und den Adapter
   mit 4 × M5×20 auf den Y-Schlitten setzen.
8. **Grundbrett.** Das X-Profil liegt flach auf. Mit 2–4 Hammermuttern in den
   unteren Nuten und M5-Senkschrauben von unten durch das Brett festschrauben.
   Die Endkappen schließen bündig mit der Profilunterseite ab.

## Grenzen und Softlimits

- **Y nicht bis zum Ausleger-Ende fahren.** Die Z-Säule reicht bis 16 mm über den
  Tisch. Steht der Y-Schlitten näher als **123 mm** (Schlittenmitte, gemessen
  vom Y-Profilanfang) am X-Profil, stößt die Säule gegen X-Profil oder X-Motorkappe.
  In der Firmware den Y-Bereich daher auf 123…400 mm begrenzen und Y zur
  Spannkappe hin referenzieren. Innerhalb dieses Bereichs ist die Baugruppe in
  allen Endlagen von X, Y und Z auf Überschneidungen geprüft.
- **Ausleger.** Der Y-Ausleger hängt einseitig am X-Schlitten, das Profil liegt
  flach. Mit Z-Säule und 1 kg Werkzeug biegt er sich am äußeren Ende grob um
  0,2 mm durch. Das ist statisch und je nach Y-Stellung gleich, stört also beim
  Plotten oder Lasern kaum. Spiel kommt eher von den Rädern: Exzenter sauber
  einstellen und die Schlitten aus PETG/ASA mit viel Infill drucken.
- **Profilsorte.** Die Räder brauchen **V-Slot**-Profil. Normales B-Typ-Profil
  (Nut 6, gerade Flanken) geht mit V-Rädern nicht. Dafür müssten die Schlitten
  auf MGN12-Schienen umgebaut werden.
- **Spindel.** Sie hängt frei am Motor (kein unteres Lager). Bei 250 mm ist das
  unkritisch. Für längere Z-Achsen gehört ein 608-Lager in den Z-Fuß.
