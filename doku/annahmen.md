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
| TT.MM. | Modulabmessungen L=1.650 m, B=0.990 m (Industriestandard 60-Zellen-Modul) | Tuncel et al. 2020 gibt keine Abmessungen an; Standardgroesse konsistent mit A~1.6 m^2 bei Herteleer et al. 2023, Tab. 1, und mit der Effizienzklasse (12.7 %) des Tuncel-Validierungsmoduls | Tom |
| TT.MM. | alpha_abs = tau_alpha = 0.90 | Standardannahme nach Duffie & Beckman 1991 (tau*alpha = 0.9), unabhaengig bestaetigt durch gemessene c-Si-Absorption ~90.5 % (AM1.5) | Tom |
| TT.MM. | eps_front = eps_back = 0.87 | Driesse, Stein & Theristis 2022: Literaturspanne Glas 0.84-0.91, Backsheet 0.85-0.89; Mittelwert je Bereich gewaehlt | Tom |
| TT.MM. | h_a = 5.7, h_b = 3.8 W/(m^2 K)/(m/s) | McAdams-Korrelation nach Duffie & Beckman 1991/2013, referenziert in Skoplaki & Palyvos 2009 | Tom |
| TT.MM. | Glasdichte im Schichtstapel: 3000 statt urspruenglich 2500 kg/m^3 | Herteleer et al. 2023, Tab. 1 gibt fuer gehaertetes Solarglas 3000 kg/m^3 an, nicht Standard-Floatglas 2500 kg/m^3 | Tom |
| TT.MM. | Rahmen und Luftfilme nicht in C_m (Schichtstapel nur Glas-EVA-Zelle-EVA-Backsheet) | Bilanzraum ist "Modul ohne Rahmen" (Kap. 2, KI_Kontext.md); Herteleer-Tabelle enthaelt Rahmen/Luftfilm-Zeilen zusaetzlich, die wir bewusst weglassen | Tom |
| TT.MM. | Wetter-Eingangsdaten (G, T_amb, Wind) fuer die Tuncel-Validierung als synthetische Annahme konstruiert (Option B) statt aus Abb. 1 digitalisiert | Tuncel et al. 2020 veroeffentlicht nur Tm/Welec-Kurven, keine Rohwetterdaten und keinen offenen Datensatz; G folgt Tagesbeschreibung aus Kap. 3 (2 Tage bewoelkt, 3 Tage klar), T_amb und Wind sind reine Annahmen (keine Angabe im Paper). Konsequenz: Fehlermetrik in run_validation.m spiegelt Modell- UND Wetterannahmefehler, nicht trennbar - im Protokoll explizit diskutieren | Tom |
| TT.MM. | Tm_mess in run_validation.m per Pixel-Digitalisierung aus Tuncel Abb. 1a (blaue Messkurve) gewonnen, stuendlich, Genauigkeit ca. +/-0.5-1 K | Seite als Bild gerendert, Achsen ueber Pixelposition der Achsenbox kalibriert, Kurve per Farbklassifizierung (blau vs. orange vs. graue Deviation-Balken) extrahiert; Ergebnis stimmt mit visuellem Eindruck der Tagesspitzen ueberein (Tag 1/2 niedriger = bewoelkt, Tag 3/5 hoeher = klar, konsistent mit Kap. 3) | Tom |
| | | | |

---

## Verworfene Ansaetze

Was wir ausprobiert und wieder weggeworfen haben, und warum. Gehoert in
Kapitel 9 des Protokolls und macht in der Praesentation Eindruck.

-
