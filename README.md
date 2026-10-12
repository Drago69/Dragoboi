# Rührwerk für 8 mm Welle (TPU, Wasser bis 80 °C)

Schrägblattrührer mit 4 Flügeln (45° angestellt), Ø 60 mm, Nabe Ø 20 × 22 mm.

- `ruehrwerk.scad`: parametrisches OpenSCAD-Modell (Welle, Nabe, Flügel einstellbar)
- `ruehrwerk.stl`: fertig gerendert mit den Standardwerten

## Befestigung auf der Welle: geklebt
- Bohrung rund, exakt 8,0 mm. Für mehr Klebespalt `bohrung_spiel = 0.2`
  setzen (0,1 mm je Seite).
- Glatte Bohrung ohne Nuten. Mit `kleberillen = 3` lassen sich Ringnuten als
  Kleberreservoir zuschalten.
- Keine D-Abflachung. Für eine D-Welle `d_flat = true` setzen; dann wird
  das Drehmoment formschlüssig übertragen.
- Die M4-Madenschraube ist abgeschaltet. Mit `madenschraube = true` gibt es
  sie als zusätzliche Sicherung.

### Kleber (TPU, 80 °C Wasser)
- **Empfohlen: 2K-Polyurethan-Kleber** (z. B. 2K-PU-Strukturkleber). Er haftet
  gut auf TPU, bleibt elastisch und ist heißwasserbeständig.
- **Alternative: MS-Polymer / Hybridkleber** (z. B. Sikaflex/Hybrid-Kleber),
  wärmebeständig bis ca. 90 °C. Braucht 24–48 h zum Aushärten.
- **Ungeeignet:** Sekundenkleber, denn er wird in heißem Wasser spröde und
  löst sich. Standard-Epoxid haftet auf TPU schlecht.
- Vorbereitung: Welle anrauen (Schleifpapier 120) und mit Isopropanol
  entfetten. Bohrung ebenfalls entfetten.
- Kleber in die Bohrung und auf die Welle geben und das Rührwerk mit leichter
  Drehung aufschieben, damit sich der Kleber gleichmäßig verteilt. Ausgetretenen Kleber abwischen und voll aushärten
  lassen, bevor es in heißes Wasser geht.

## Druckempfehlung (TPU 95A)
- Liegend drucken, Nabe unten (keine Stützen nötig)
- 3–4 Wände, 40–100 % Infill (Gyroid) → steifere Flügel, kein Wasser im Inneren
- Langsam drucken (20–30 mm/s), Retract klein halten

## Wichtig: TPU bei 80 °C
- **Polyether-TPU verwenden** (z. B. als „hydrolysebeständig“ gekennzeichnet).
  Polyester-TPU (die meisten Standard-Filamente) wird in heißem Wasser durch
  Hydrolyse mit der Zeit spröde.
- TPU wird bei 80 °C deutlich weicher. Deshalb sind die Flügel 3,5 mm dick.
  Bei hoher Drehzahl oder zähem Medium `fluegel_dicke` auf 4–5 mm erhöhen oder
  `anstellwinkel` verringern.
- Steifere Alternative für heißes Wasser: **PP** (Polypropylen). PETG und PLA
  sind ungeeignet, denn sie erweichen bei 60–80 °C.
