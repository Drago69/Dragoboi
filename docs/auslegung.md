# Auslegungsrechnung (automatisch aus der CAD-Konfiguration)

Erzeugt mit `python3 tools/calc.py --write`. Annahmen siehe Quelltext.

## Bunker
- Bunkerrand waagerecht bei Z = 1250 mm (Band OK 900 mm + 350)
- Nutzvolumen ca. 69.4 l  ->  ca. 527 Flaschen (Schuettdichte 0.55 bezogen auf Huellvolumen 72.5 cm3)

## Rinne (Neigung 28 Grad)
- mu=0.20: a=2.87 m/s2, Sperre->Anschlag 139 mm in 311 ms, Nachrutschen 102,5 mm in 267 ms
- mu=0.25: a=2.44 m/s2, Sperre->Anschlag 139 mm in 338 ms, Nachrutschen 102,5 mm in 290 ms
- mu=0.35: a=1.57 m/s2, Sperre->Anschlag 139 mm in 420 ms, Nachrutschen 102,5 mm in 361 ms
- Reibwinkel PETG/HDPE ca. 11-19 Grad -> Neigung 28 Grad hat Reserve

## Takt (Modell der Firmware-Ablaufsteuerung)
- Einrutschen Sperre->Anschlag 338 ms (mu 0,25), Nachrutschen Warteschlange 290 ms (Firmware: 380 ms)
- Boden am Anschlag: Rotor gibt Sperre frei nach 351 ms, Vereinzelung bereit nach 500 ms -> Takt 868 ms
- Hals am Anschlag : Rotor gibt Sperre frei nach 591 ms, Vereinzelung bereit nach 500 ms -> Takt 959 ms
- Mittel (50/50) 913 ms  ->  ca. 66 Flaschen/min Dauerleistung (Ziel 30-60)
- Begrenzend ist die Vereinzelung (Nachrutschen). Mehr Leistung: Rinne steiler (ALPHA) oder t_slide2 per Inbetriebnahme kuerzen.

## Fall in den Schacht
- Fallhoehe max. 113 mm, Auftreffgeschwindigkeit 1.49 m/s, Fallzeit 152 ms

## Hubantrieb (Exzenter, Rolle, Schwerkraftrueckstellung)
- 30 U/min: Hubfrequenz 0.50 Hz, Nockenwellenmoment max 2.33 Nm -> Motor (Getriebe i=13.73, eta 0,8) 0.21 Nm bei 412 U/min; Abheben der Rolle: nein (min. Beschl. -0.62 m/s2 vs. g*cos = 8.66)
- 45 U/min: Hubfrequenz 0.75 Hz, Nockenwellenmoment max 2.35 Nm -> Motor (Getriebe i=13.73, eta 0,8) 0.21 Nm bei 618 U/min; Abheben der Rolle: nein (min. Beschl. -1.40 m/s2 vs. g*cos = 8.66)
- 60 U/min: Hubfrequenz 1.00 Hz, Nockenwellenmoment max 2.39 Nm -> Motor (Getriebe i=13.73, eta 0,8) 0.22 Nm bei 824 U/min; Abheben der Rolle: nein (min. Beschl. -2.49 m/s2 vs. g*cos = 8.66)
- Hub 80.0 mm, max. Druckwinkel 38.8 Grad
- Stufenhoehe 63.7 mm x 7 Stufen = Foerderhoehe 446 mm (lokal)
- Foerdermenge: je Hub 0..2 Flaschen (Stufe 240 mm = 2,3 Flaschenlaengen). Bei 1,5 Fl./Hub: 60 Fl/min ab 40 Huebe/min = 40 U/min Nockenwelle
- Motor NEMA17 1,7 A an 24 V liefert bei 400-600 U/min ca. 0,30-0,38 Nm -> Reserve ca. 1,5

## Bunkergroesse (Varianten)
| Rand Z ueber Band | Rueckwand x | Bodengefaelle | Volumen | Flaschen |
|---|---|---|---|---|
| +300 | -650 | 15 Grad | 47.8 l | 363 |
| +300 | -650 | 10 Grad | 52.5 l | 398 |
| +300 | -750 | 15 Grad | 51.4 l | 390 |
| +300 | -750 | 10 Grad | 57.7 l | 438 |
| +350 | -650 | 15 Grad | 58.2 l | 442 |
| +350 | -650 | 10 Grad | 62.9 l | 477 |
| +350 | -750 | 15 Grad | 63.2 l | 480 |
| +350 | -750 | 10 Grad | 69.4 l | 527 |
| +400 | -650 | 15 Grad | 68.6 l | 521 |
| +400 | -650 | 10 Grad | 73.3 l | 556 |
| +400 | -750 | 15 Grad | 75.0 l | 569 |
| +400 | -750 | 10 Grad | 81.2 l | 616 |
