# Rührwerk für 8 mm Welle (TPU, Wasser bis 80 °C)

Schrägblattrührer mit 4 Flügeln (45° angestellt), Ø 60 mm, Nabe Ø 20 × 22 mm.

- `ruehrwerk.scad`: parametrisches OpenSCAD-Modell (Welle, Nabe, Flügel einstellbar)
- `ruehrwerk.stl`: fertig gerendert mit den Standardwerten

## Befestigung auf der Welle
- Bohrung 7,8 mm → Presssitz, TPU dehnt sich über die Welle
- D-Abflachung 0,5 mm (für D-Welle; bei runder Welle `d_flat = false`)
- M4-Madenschraube mit Mutternfalle (Mutter von oben einschieben). Das ist
  wichtig, weil der Presssitz bei 80 °C nachgibt.

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
