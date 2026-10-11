# Flaschen-Unscrambler für KE-50 Band

Ordnet lose 50-ml-HD-PE-Flaschen (Rebhan **K-3906.004**, Ø30 × 102,5, Hals 24/410) aus dem Bunker und stellt sie **stehend, Boden unten** einzeln auf das KE-50 Band.

- Ohne Vibrationstonne
- Gestell aus 20×20-Profil (Nut 6), Funktionsteile aus dem 3D-Drucker (PETG)
- Steuerung: ESP32 mit zwei Schrittmotoren und zwei kleinen Pneumatikzylindern
- Bunker ≈ 530 Flaschen, Leistung ≈ 60–66 Flaschen/min

![Gesamtansicht](docs/img/gesamt_bandseite.png)

**Prinzip:** gekippter Stufenförderer → V-Rinne → Vereinzelung (Klemme + Sperrstift) → **Wendetrommel mit Halsnut**. Der Hals taucht in die Nut ein, der Rumpf nicht; eine Lichtschranke erkennt die Lage. Die Trommel dreht −62° oder +118°, damit die Flasche immer Boden voraus in den Fallschacht fällt. Details: **[docs/KONZEPT.md](docs/KONZEPT.md)**

## Inhalt

| Ordner / Datei | Inhalt |
|---|---|
| [`cad/config.scad`](cad/config.scad) | **alle Parameter** (Bandhöhe `BELT_Z`, Flaschenmaße, Neigung, Stufen, Rotor …) |
| [`cad/assembly.scad`](cad/assembly.scad) | Gesamtbaugruppe. Bewegungszustände über `CAM_PHI`, `ROT_ANG`, `GATE_EXT` |
| `cad/parts/*.scad` | Druckteile (Stufen, Rinne, Rotor/Gehäuse, Antrieb, Halter) |
| [`cad/print.scad`](cad/print.scad) | Druckteile in Druckausrichtung, mit Teileliste |
| [`stl/`](stl) | **31 Druckteile als STL**, geprüft und druckfertig |
| [`dxf/`](dxf) | 5 Platten (4 mm PETG/PC) als DXF |
| [`docs/stueckliste.md`](docs/stueckliste.md) | Stückliste: Profilzuschnitt, Zukauf, Normteile, Elektrik (auch als CSV) |
| [`docs/MONTAGE.md`](docs/MONTAGE.md) | Druck, Montage, Inbetriebnahme, Störmeldungen |
| [`docs/ELEKTRIK.md`](docs/ELEKTRIK.md) | Pinbelegung, Verdrahtung, Not-Halt, Pneumatik |
| [`docs/auslegung.md`](docs/auslegung.md) | Rechnung: Bunkervolumen, Takt, Momente, Fall |
| [`firmware/`](firmware) | ESP32-Firmware (Arduino IDE oder PlatformIO), Zustandsautomat + serielle Konsole |
| [`tools/`](tools) | Export, Stückliste, Kollisions- und Funktionsprüfung |

## Anpassen und neu erzeugen

```bash
# z.B. Bandhöhe ändern:  cad/config.scad -> BELT_Z = 850;
tools/build_all.sh          # STL, DXF, Stückliste, Rechnung, Bilder, Prüfungen
```

Benötigt werden OpenSCAD ≥ 2021.01, `xvfb-run` (nur für Bilder) und Python 3 mit `trimesh`, `manifold3d` und `numpy`.

## Geprüft

- 0 Kollisionen in 135 Bauteilpaarungen über alle Hub- und Rotorstellungen
- Lageerkennung eindeutig für alle Toleranzkombinationen (L ± 1, D ± 0,3)
- Freier Fall, Auslauf auf dem Band und Rinnendurchlauf geometrisch frei
- Alle Druckteile wasserdicht, je ein Körper, passend für einen Bauraum von 256 mm
- Firmware kompiliert mit ESP32-Arduino-Core 2.0.17 und FastAccelStepper 0.31.3 (24 % Flash)

**Vor dem Bau messen:** die Bandhöhe des KE-50 (`BELT_Z`) und den Lochkreis des Getriebeflanschs. Außerdem die Seitenführung im Bereich der Abwurfstelle aussparen; siehe Abschnitt 6 in [KONZEPT.md](docs/KONZEPT.md).
