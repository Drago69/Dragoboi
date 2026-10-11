# Auslegungsrechnung (automatisch aus der CAD-Konfiguration)

Erzeugt mit `python3 tools/calc.py --write`. Annahmen siehe Quelltext.

## Bunker
- Trichter aus 5 Blechen auf dem Randring, Rand waagerecht bei Z = 1240 mm (Band + 340)
- Fuellraum bis zum Rand 34.1 l  ->  ca. **259 Flaschen** (Schuettdichte 0.55 bezogen auf das Huellvolumen 72.5 cm3), Masse ca. 1.8 kg
- Hoeher geht nicht: der Auslauf (Kanal vom Teller zur Rinne) laeuft links ueber den Bunker; Abstand Fuellraum -> Auslauf ca. 8 mm (Pruefung 8)
- Bei 60 Fl./min reicht eine Fuellung ca. 4.3 min; ein Karton (500 Stueck) wird in zwei Portionen nachgefuellt

## Rinne (90-Grad-V, Neigung 28 Grad)
- Im 90-Grad-V wirkt die Reibung beider Flanken: a = g (sin a - sqrt(2) mu cos a). Rutschen bis mu < 0.376 (Reibwinkel 20.6 Grad). PE-HD auf PETG trocken: mu ca. 0,15-0,30
- mu=0.15: a=2.77 m/s2, Sperre->Anschlag 139 mm in 317 ms, Nachrutschen 102,5 mm in 272 ms
- mu=0.20: a=2.16 m/s2, Sperre->Anschlag 139 mm in 359 ms, Nachrutschen 102,5 mm in 308 ms
- mu=0.25: a=1.54 m/s2, Sperre->Anschlag 139 mm in 425 ms, Nachrutschen 102,5 mm in 364 ms
- mu=0.30: a=0.93 m/s2, Sperre->Anschlag 139 mm in 547 ms, Nachrutschen 102,5 mm in 469 ms

## Takt (Modell der Firmware-Ablaufsteuerung, mu = 0.20)
- Einrutschen Sperre->Anschlag 359 ms, Nachrutschen Warteschlange 308 ms (Firmware t_slide2 = 380 ms)
- Boden am Anschlag: Rotor gibt Sperre frei nach 351 ms, Vereinzelung bereit nach 500 ms -> Takt 889 ms
- Hals am Anschlag : Rotor gibt Sperre frei nach 591 ms, Vereinzelung bereit nach 500 ms -> Takt 980 ms
- Mittel (50/50) 935 ms  ->  ca. **64 Flaschen/min** Dauerleistung (Ziel 30-60)
- Begrenzend ist die Vereinzelung (Nachrutschen); t_slide2 bei der Inbetriebnahme so kurz wie sicher einstellen.

## Fall in den Schacht
- Fallhoehe max. 113 mm, Auftreffgeschwindigkeit 1.49 m/s, Fallzeit 152 ms

## Hakenteller
- Teller D500, Neigung 51.4 Grad, 10 Haken, 15 U/min -> Taschengeschwindigkeit 0.36 m/s, 150 Taschen/min. Fuer 64 Fl./min muessen nur 43 % der Taschen gefuellt sein
- Uebergabe T liegt 36.9 Grad hinter dem hoechsten Punkt; dort zeigt die Flaschenachse genau in Rinnenrichtung (28 Grad Gefaelle)
- Die Flasche beginnt in der Tasche vor T nach vorn zu rutschen (Leiste + Tellerflaeche reiben):
  - mu=0.15: ab -22 Grad vor T
  - mu=0.20: ab -17 Grad vor T
  - mu=0.25: ab -12 Grad vor T
  - mu=0.30: ab -7 Grad vor T
  Der Einlauf ist dafuer aufgeweitet (Pruefung 7: Vorrutschen bis 32 mm frei). Den Weg nach vorn begrenzt der vorauslaufende Mitnehmer.
- Mitnehmer (Aussenkante r = 232.2) streicht bis s = -499 durch die Rinne; die hinterste ruhende Flasche X5 endet bei s = -490.5 (mit +1 mm je Flasche -494.5) -> frei
- Abschalten bei 'Rinne voll' (X4 liegt an der Lichtschranke): die naechste Tasche darf nicht mehr uebergeben.
  - mu=0.15: X4 braucht 317 ms von T; X6 kaeme 800 ms nach X4 -> Teller muss 483 ms nach 'voll' stehen
  - mu=0.20: X4 braucht 346 ms von T; X6 kaeme 800 ms nach X4 -> Teller muss 454 ms nach 'voll' stehen
  - mu=0.25: X4 braucht 386 ms von T; X6 kaeme 800 ms nach X4 -> Teller muss 414 ms nach 'voll' stehen
  Firmware: t_full_on = 120 ms (Entprellung, eine vorbeirutschende Flasche verdeckt die Schranke ca. 80 ms), Bremsrampe < 60 ms.
  Kommt doch eine Flasche zu viel, laeuft der Mitnehmer gegen sie: Motor blockiert (max. ca. 13 N an der Flasche), die Firmware erkennt das am fehlenden Hall-Takt, haelt an und faehrt erst bei freier Rinne wieder an.
- Moment (Abschaetzung): Heben 3 Flaschen 0.04 Nm + Reibung Schuettgut (0.9 kg auf dem Teller, mu 0,3) 0.28 Nm + Haken im Schuettgut (3 x 2 N) 1.26 Nm + Ring/Abstreifer 0,2 Nm = **1.8 Nm**
- Antrieb NEMA17 + Planetengetriebe 13,73:1: 206 U/min am Motor, ca. 0,35 Nm x 13,73 x 0,8 = 3,8 Nm, Getriebe zul. ca. 3 Nm -> Reserve 1.7
