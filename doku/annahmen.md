# Entscheidungslog

Eine Zeile pro Entscheidung. Keine Prosa. Aus dieser Datei wird spaeter die
Annahmentabelle in Kapitel 2.5 des Protokolls.

Format: Datum | Entscheidung | Begruendung | Wer

---

| Datum | Entscheidung | Begruendung | Wer |
|---|---|---|---|
| 10.08. | Basismodell statt Nusselt-Ansatz fuer die Konvektion | Windrichtung nicht nutzbar, Regime nicht validierbar | alle |
| 10.08. | Modul als ein Temperaturknoten (Lumped) | Laminatdicke ca. 3 mm, Biot-Zahl klein | alle |
| 10.08. | Bodentemperatur = Umgebungstemperatur | keine Messdaten verfuegbar | alle |
| 10.08. | Himmelstemperatur nach Swinbank | einfachste belegte Korrelation, nur T_amb noetig | alle |
| 10.08. | ode45 mit RelTol = AbsTol = 1e-6 | skalares System, nicht steif | Linus |
| 10.08. | lineare Interpolation der Wetterdaten | Spline kann bei Bewoelkungsspruengen ueberschwingen | Linus |
| 10.08. | Globalstrahlung horizontal, keine Umrechnung auf Modulebene | GeoSphere liefert horizontal; Transposition waere zusaetzliche Modellannahme ohne Validierungsmoeglichkeit. p.theta bleibt daher im Code ungenutzt und dient nur der Dokumentation | alle |
| 10.08. | GeoSphere-Station Wien Hohe Warte (Nr. 5904) | staedtischer Standort mit vollstaendiger Strahlungs-, Temperatur- und Windmessung im geforderten Zeitraum | Lars |
| 12.08. | Keine Datenluecken zu behandeln | Datensatz 24.06.-01.07.2019, 1009 Zeilen a 10 min; in cglo, tl und ff fehlt kein Wert. Der vorhandene Filter in load_weather_geosphere.m bleibt als Absicherung bestehen | Lars |
| 12.08. | Rechnen in UTC, Abbildungen in Ortszeit (Europe/Vienna) | Rohdaten sind UTC gestempelt; ohne Umrechnung laege der Mittag in den Abbildungen zwei Stunden zu frueh. Zeitzone wirkt nicht auf die Rechnung, da t aus Differenzen gebildet wird | Linus |
| 20.08. | A_conv = 2*A (Vorder- und Rueckseite konvektiv wirksam) | Annahme ueber die Einbausituation: freistehend aufgestaendertes, beidseitig umstroemtes Modul wie das Validierungsmodul bei Tuncel et al. 2020, Kap. 2.4. Nicht durch Literatur belegt, da die McAdams-Korrelation fuer eine Plattenseite gilt. Fall A_conv = A wird in der Sensitivitaetsanalyse mitgerechnet | Linus |
| 20.08. | Fehlermasse getrennt fuer Tag und Nacht ausweisen | Tuncel et al. geben MAE 0.90 degC gesamt, aber 2.61 degC tagsueber an. Ein Vergleich nur ueber den Gesamtzeitraum verduennt die Mittagsabweichung mit unauffaelligen Nachtwerten | Linus |
| 20.08. | Schwelle "tagsueber": G > 20 W/m^2 | Tuncel et al. definieren die Grenze nicht. Bewusst niedrig gewaehlt, damit Daemmerungsphasen zum Tag zaehlen und der Tagwert nicht kuenstlich guenstig ausfaellt | Linus |
| **offen** | Bestehkriterium der Validierung: **Vorschlag MAE (tagsueber) < 5 K** | Tuncel et al. erreichen mit dem volleren Nusselt-Ansatz tagsueber MAE 2.61 degC. Unser Basismodell mit linearer Konvektion kann das systematisch nicht unterbieten. Der Wert ist damit aus der Literatur begruendet und nicht nachtraeglich passend gewaehlt. **In der Gruppe zu bestaetigen** | Linus |
| **offen** | Umgebungstemperatur fuer die Validierung | Urspruenglicher Beschluss (10.08.): aus dem Graphen im Tuncel-Paper ableiten. **Hinfaellig**, siehe Abschnitt "Offene Punkte" unten: Abb. 1 enthaelt keine Eingangsgroessen | |
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

## Offene Punkte, in der Gruppe zu entscheiden

**1. Validierung gegen Tuncel Abb. 1 ist so nicht durchfuehrbar.**
Abb. 1(a) zeigt ausschliesslich die Modultemperatur, gemessen und
modelliert. Einstrahlung, Umgebungstemperatur und Windgeschwindigkeit sind
weder in der Abbildung noch sonst im Paper als Zahlenwerte veroeffentlicht
(Kap. 2.4 nennt nur, dass sie stuendlich gemessen wurden).
`load_weather_paper.m` braucht aber genau diese drei als Eingang. Aus der
Abbildung gewinnen wir nur die Zielgroesse, nicht das, womit man sie
berechnet. Der Beschluss vom 10.08., die Umgebungstemperatur aus dem
Graphen abzuleiten, loest das Problem nicht, weil G und v weiterhin fehlen.

Drei Wege stehen zur Wahl:

  a) *Eingangsdaten rekonstruieren.* T_amb aus den Nachtminima von Abb. 1(a)
     ableiten, G als Klarhimmelmodell fuer Ankara rechnen (das Paper nennt
     drei der fuenf Tage als klar), v als Konstante annehmen. Liefert eine
     echte Kurve, beruht aber auf mehreren ungepruefbaren Annahmen.
  b) *Gegen Abb. 2(b) validieren.* Dort sind fuer den 19. Juni alle
     Bilanzterme in W/m^2 aufgetragen. Die Verhaeltnisse der Terme lassen
     sich mit unserem Anwendungsfall vergleichen, ohne Eingangsdaten zu
     erfinden.
  c) *Validierungsanspruch zurueckziehen.* Plausibilitaetspruefung plus
     Benchmark-Vergleich der Fehlermasse, im Protokoll offen begruendet.

Empfehlung Linus: b) und c) kombinieren.

**2. Bestehkriterium** (Zeile oben) muss bestaetigt werden, bevor die
Ergebnisse vorliegen. Wer die Schwelle nach dem Ergebnis waehlt, sucht sich
die passende aus.

**3. Bodentemperatur = Umgebungstemperatur** ist mit "keine Messdaten
verfuegbar" begruendet. Das trifft nicht mehr zu: der GeoSphere-Datensatz
enthaelt `ts` (Erdbodentemperatur) und `tb10`. Die Annahme laesst sich also
gegen echte Werte pruefen, statt sie nur zu behaupten. Ein Satz im
Protokoll genuegt.

**4. Anfangstemperatur.** Die MATLAB-Skripte starten mit
`T0 = w.Tamb(0)`, das Simulink-Modell mit `p.Tm0 = 298.15 K`. Fuer den
Vergleich in Kapitel 8.3 sollten beide gleich gesetzt oder die Abweichung
erwaehnt werden. Bei einer Zeitkonstante von rund 200 s ist der Einfluss
nach etwa einer halben Stunde abgeklungen.

**5. Zeitbezug der Messkurve.** Die Abbildung `validierung_temperatur.pdf`
zeigt einen durchgaengigen Versatz von drei bis vier Stunden zwischen
Modell und digitalisierter Messung. Die x-Achse in Tuncel Abb. 1 ist mit
"Hours" von 0 bis 120 beschriftet, ohne Angabe, welcher Tageszeit die Null
entspricht. Zu klaeren, bevor die Fehlermasse ins Protokoll gehen: Ist der
Versatz eine Folge der Achsenzuordnung, der Digitalisierung oder des in
`load_weather_paper.m` angenommenen Sonnenverlaufs?

**6. Letzte sieben Stunden der Messkurve.** Ab etwa 113 h ist
`Tm_mess` konstant 293,74 K. Das ist ein Digitalisierungsartefakt und kein
Messwert, geht aber derzeit in die Fehlermasse ein. Ausschliessen?

**7. Bestehkriterium bei konstruierten Eingangsdaten.** Die Grenze von 5 K
wurde fuer eine Validierung gegen gemessene Eingangsgroessen formuliert. Bei
angenommenem Wetter misst sie Modell- und Annahmefehler gemeinsam. Entweder
neu formulieren oder ausdruecklich als nicht anwendbar kennzeichnen.

---

## Nachzurecherchieren

**a) Wie war das Validierungsmodul bei Tuncel montiert?**
Entscheidend fuer A_conv. Kap. 2.4 nennt nur "GUENAM's Outdoor Testing
Facility", Kap. 2.1.3 spricht dagegen von "PV modules mounted on a roof"
und fuehrt das Dach als dritten Strahlungspartner neben Himmel und Erde.
Bei Dachmontage waere A_conv = 2*A nicht haltbar. Moegliche Quellen:
Referenz [10] und [19] des Papers (Tuncel/Ozden/Balog, PVCon 2018 bzw.
Ozden et al.), Webseite der GUENAM-Anlage.

**b) Zeitabhaengiges (tau*alpha).** Das Paper schreibt zu Gl. (10), das
Transmissions-Absorptions-Produkt sei "dependent on time and date", also
einfallswinkelabhaengig. Wir setzen konstant 0,90. Welchen Ansatz nutzt
das Paper, und wie gross waere der Effekt in den Randstunden?

**c) Sonnenauf- und -untergang Ankara im Juni.** In
`load_weather_paper.m` mit 5:00 und 20:00 grob angesetzt. Belegbare Werte
wuerden den Zeitversatz aus Punkt 5 eingrenzen helfen.

**d) Bodentemperatur.** Der GeoSphere-Datensatz enthaelt `ts` und `tb10`.
Damit laesst sich die Annahme "Bodentemperatur gleich Lufttemperatur"
gegen Messwerte halten, statt sie zu behaupten.

**e) `doku/Schichtaufbau_Cm_Dokumentation.md`** wird in
`init_parameters.m` referenziert, existiert aber nicht im Repo.

---

## Verworfene Ansaetze

Was wir ausprobiert und wieder weggeworfen haben, und warum. Gehoert in
Kapitel 9 des Protokolls und macht in der Praesentation Eindruck.

- **Validierung durch Digitalisieren von Tuncel Abb. 1** (verworfen 16.08.):
  Die Abbildung enthaelt keine Eingangsgroessen, siehe offener Punkt 1.
  Der Aufwand haette nur die Zielgroesse geliefert.
- **`zeit.TimeZone = 'UTC+2'`** (verworfen 16.08.): verschiebt den
  physikalischen Zeitpunkt statt der Darstellung und waere fuer Winterdaten
  zusaetzlich falsch. Ersetzt durch Einlesen als UTC mit Darstellung in
  `Europe/Vienna`.
