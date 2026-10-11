# Elektrik und Pneumatik

Steuerung: **ESP32 DevKitC**, Firmware in [`firmware/unscrambler`](../firmware/unscrambler). Netzteil 24 V / 150 W.

## Spannungsversorgung und Not-Halt

```
230 V ─► Netzteil 24 V ──┬─► DC/DC 5 V ─► ESP32 (5V-Pin), Laser (über MOSFET), E18, Hallsensoren
                         │
                         └─► NOT-HALT (Öffner) ─► Schütz/Relais K1 (Spule 24 V)
                                                   K1 Schließer ─► 24 V geschaltet: VM beider TMC2209, Ventile, Störleuchte
                                                   K1 Hilfskontakt (Schließer) ─► GPIO5 nach GND (LOW = Leistungskreis ein)
```

Nach dem Entriegeln des Not-Halts schaltet K1 wieder ein (Selbsthaltung über einen Taster nach Bedarf). Die Firmware meldet dann eine Störung. Mit **Start** wird neu referenziert.

## Pinbelegung ESP32

| GPIO | Funktion | Anschluss |
|---|---|---|
| 25 / 26 / 27 | Rotor STEP / DIR / EN | TMC2209 #1 (MS1 = MS2 = VIO → 1/16 Schritt) |
| 18 / 19 / 21 | Teller STEP / DIR / EN | TMC2209 #2 (1/16) |
| 16 | Ventil Sperre A | MOSFET → Spule 24 V, Freilaufdiode. **HIGH = Stift eingefahren (offen)** |
| 17 | Ventil Klemme B | MOSFET → Spule 24 V. **HIGH = Klemme zu** |
| 15 | Laser-Versorgung 5 V | MOSFET (alle 5 Laser parallel, je ≈ 20 mA) |
| 33 | Störleuchte gelb | MOSFET → 24 V |
| 2 | Betriebs-LED (onboard) | blinkt langsam = Betrieb, schnell = Stillstand |
| 36 (VP) | Lichtschranke Präsenz (Rotor) | Fototransistor: Kollektor → GPIO + 10 kΩ nach 3,3 V, Emitter → GND |
| 39 (VN) | Lichtschranke Orientierung (Rotor) | dto. |
| 34 | Lichtschranke Rinne voll (G1) | dto. |
| 35 | Lichtschranke Schacht A (X = +3) | dto. |
| 32 | Lichtschranke Schacht B (X = +22) | dto. |
| 13 | Hall A3144 Rotor-Referenz | OUT → GPIO + 4,7 kΩ nach 3,3 V; VCC 5 V |
| 14 | Hall A3144 Teller (im Lagerbock, 10 Magnete in der Nabe = 1 Impuls je Haken) | dto. |
| 4 | E18-D80NK Band-Stau | schwarz → GPIO + 4,7 kΩ nach 3,3 V; braun 5 V, blau GND |
| 22 | Taster Start (Schließer) | nach GND |
| 23 | Taster Stop (**Öffner**) | nach GND, offen bzw. Drahtbruch = Stop |
| 5 | Rückmeldung K1 | Hilfskontakt nach GND |

Zum Test am Tisch: GPIO 23 und GPIO 5 mit Drahtbrücken auf GND legen.

**Motorströme** (Vref-Poti am TMC2209, nach Datenblatt des Moduls): Rotor-NEMA17 **1,0 A RMS**, Tellermotor 17HS19-1684S-PG14 **1,4 A RMS**. Die TMC2209 brauchen Kühlkörper.

**Lichtschranken:** 650-nm-Laser Ø6 (≤ 1 mW, Klasse 2) im Halter `sensorhalter_laser` mit Blende 2,5 mm. Gegenüber sitzt ein Fototransistor 5 mm im `sensorhalter_pt` mit Blende 1,5 mm. Alle Strahlen laufen durch Ø4-Bohrungen und sind abgedeckt. Kabel in den Halter-Schlitz legen und mit einer M3-Madenschraube klemmen.

## Pneumatik

```
Druckluft 4–6 bar ─► Wartungseinheit (Filter/Regler 4 bar) ─┬─► Ventil A (5/2, monostabil) ─► Zylinder A  Ø10/25 (Sperrstift)
                                                            └─► Druckregler 1–2 bar ─► Ventil B (5/2) ─► Zylinder B  Ø10/10 (Klemme)
```

- **Ventil A stromlos → Zylinder A AUSGEFAHREN** (Stift oben = Sperre zu). Den in Ruhe belüfteten Ventilausgang auf den **hinteren** Zylinderanschluss legen.
- **Ventil B stromlos → Zylinder B EINGEFAHREN** (Klemme offen).
- An beiden Zylindern Drosselrückschlagventile als Abluftdrosselung einbauen. A schnell (< 40 ms), B weich einstellen. Die Klemmkraft über den Druckregler B einstellen: Die Flasche muss sicher halten, darf aber nicht eindellen (≈ 1,5 bar).
- Luftverbrauch: < 2 Nl/min bei 60 Takten/min.
