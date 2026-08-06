# Entscheidungslog

Eine Zeile pro Entscheidung. Keine Prosa. Aus dieser Datei wird spaeter die
Annahmentabelle in Kapitel 2.5 des Protokolls.

Format: Datum | Entscheidung | Begruendung | Wer

---

| Datum | Entscheidung | Begruendung | Wer |
|---|---|---|---|
| TT.MM. | Basismodell statt Nusselt-Ansatz fuer die Konvektion | Windrichtung nicht nutzbar, Regime nicht validierbar | alle |
| TT.MM. | Modul als ein Temperaturknoten (Lumped) | Laminatdicke ca. 3 mm, Biot-Zahl klein | alle |
| TT.MM. | Bodentemperatur = Umgebungstemperatur | keine Messdaten verfuegbar | alle |
| TT.MM. | Himmelstemperatur nach Swinbank | einfachste belegte Korrelation, nur T_amb noetig | |
| TT.MM. | ode45 mit RelTol = AbsTol = 1e-6 | skalares System, nicht steif | |
| TT.MM. | lineare Interpolation der Wetterdaten | Spline kann bei Bewoelkungsspruengen ueberschwingen | |
| TT.MM. | Umgebungstemperatur fuer die Validierung: ... degC | Paper macht keine Angabe | |
| TT.MM. | GeoSphere-Station: ... | | |
| TT.MM. | Umgang mit Datenluecken: ... | | |
| | | | |

---

## Verworfene Ansaetze

Was wir ausprobiert und wieder weggeworfen haben, und warum. Gehoert in
Kapitel 9 des Protokolls und macht in der Praesentation Eindruck.

-
