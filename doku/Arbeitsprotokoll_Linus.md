# Arbeitsprotokoll Linus (MATLAB-Kern und Validierung)

Laufende Mitschrift der Arbeitsschritte, Aufgabenpunkte 2 und 4.
Zweck: am Ende in die Protokollkapitel einpflegen, ohne etwas zu rekonstruieren.

Format je Eintrag: Datum, was gemacht wurde, Ergebnis in Stichpunkten, und in
welches Kapitel es gehoert. Entscheidungen wandern zusaetzlich in
`annahmen.md`, KI-Nutzung zusaetzlich in Kapitel 10.

---

## 16.08. Bestandsaufnahme MATLAB-Kern

**Gemacht:** Vollstaendige Durchsicht aller 18 Dateien in `matlab/` gegen die
sechs Modellgleichungen der Angabe.

- Kern ist code-vollstaendig: Gl. (1) in `pv_thermal_ode.m`, Gl. (2) inline,
  Gl. (3) in `calc_w_el.m`, Gl. (4) in `calc_h_conv.m`, Gl. (5) in
  `calc_q_rad.m`, Gl. (6) in `init_parameters.m`
- Coderegeln eingehalten: keine Zahlenwerte ausserhalb `init_parameters.m`,
  keine Fallunterscheidung in der rechten Seite, jede Datei unter 100 Zeilen
- `results/` leer: der Kern ist bis heute nie mit echten Daten gelaufen
- Einzige vorhandene Abbildung `figures/validierung_temperatur.pdf` stammt
  aus synthetischen Platzhalterdaten und ist nicht verwendbar

→ Kapitel 4.1 (Programmstruktur), Anhang A.1 (Dateiuebersicht)

## 16.08. Ueberschlagsrechnung als Erwartungswert vor dem ersten Lauf

**Gemacht:** Kennzahlen aus den Parametern von Hand ueberschlagen, damit der
erste Simulationslauf gegen eine Zahl geprueft werden kann und nicht gegen
das Bauchgefuehl.

- Flaechenbezogene Waermekapazitaet: 7,57 kJ/(m^2 K)
  (4800 + 1003 + 315 + 1003 + 450 aus dem Schichtstapel)
- Modulflaeche A = 1,650 x 0,990 = 1,634 m^2
- **C_m = 12,4 kJ/K**
- Waermeuebergang bei v = 2 m/s: h = 5,7 + 3,8 x 2 = 13,3 W/(m^2 K),
  mit A_konv = 3,27 m^2 also 43,5 W/K
- Strahlung linearisiert: h_rad ~ 4 sigma eps T^3 = 5,3 W/(m^2 K) bei
  T = 300 K, ueber Vorder- und Rueckseite 17,4 W/K
- Gesamtleitwert 60,9 W/K → **Zeitkonstante tau = 203 s**
- Stationaer bei G = 900 W/m^2: Q_solar = 1323 W, W_el = 153 W,
  → **Delta-T = 19 K** ueber Umgebungstemperatur

**Einordnung:** tau ~ 200 s deckt sich mit der von Herteleer et al. 2023
genannten Groessenordnung von einigen hundert Sekunden. Delta-T = 19 K passt
zur erwarteten Groessenordnung 20 bis 30 K bei voller Einstrahlung.

**Wichtig fuer die Sensitivitaetsanalyse:** tau = 203 s liegt deutlich unter
dem Datenraster von 600 s (10-Minuten-Werte). Damit laesst sich der offene
Streitpunkt zwischen Tuncel et al. (Stundenwerte, kein Kapazitaetseinfluss)
und Herteleer et al. (Sekunden bis Minuten noetig) mit einer eigenen Zahl
beantworten statt nur zitieren.

→ Kapitel 3.3 (Herleitung C_m), Kapitel 4.2 (Zeitkonstante, Solverwahl),
   Kapitel 7.3 (Einordnung)

## 16.08. Zwei Befunde im Code

**Gemacht:** Code auf Konsistenz mit den getroffenen Entscheidungen geprueft.

- `p.theta` (Neigung 32 Grad) wird in `init_parameters.m` definiert, aber
  nirgends im Code verwendet. Kein Fehler, sondern Folge der Entscheidung (b)
  aus der Startsitzung, die Globalstrahlung horizontal direkt zu verwenden.
  Muss aber als bewusst ungenutzt kommentiert werden, sonst ist es in der
  Pruefung eine offene Flanke.
- `plot_validation.m` setzt einen `title()` ueber die Residuenabbildung. Der
  in der zweiten Sitzung festgelegte Plotstandard verbietet Titel ueber dem
  Plot. Die Fehlermasse gehoeren in die Bildunterschrift.

→ Kapitel 2.7 (Annahmentabelle, Strahlungsebene), Kapitel 5.2 (Abbildungen)

## 16.08. Erster Lauf der Toolchain (versehentlich mit Platzhalterdaten)

**Gemacht:** `run_all` ausgefuehrt, ohne vorher die Flags umzustellen. Gelaufen
ist dadurch `run_validation` mit den synthetischen Platzhalterdaten aus
`load_weather_paper.m`, nicht der Anwendungsfall. Das Ergebnis ist inhaltlich
nicht verwertbar, aber als Funktionstest der Toolchain aufschlussreich.

- Toolchain laeuft vollstaendig durch: ODE-Loesung, Speichern nach
  `results/`, Plot, PDF-Export
- 4033 Zeitschritte fuer 5 simulierte Tage, T_m maximal 46,3 degC bei einer
  Umgebungstemperatur von maximal 30 degC
- Solververhalten unauffaellig, glatter Verlauf, keine numerischen Artefakte

**Physikalisch bestaetigt (der eigentliche Ertrag dieses Laufs):** In den
Nachtstunden liegt T_m sichtbar *unter* T_amb, um rund 2 bis 3 K. Das ist
kein Fehler, sondern die Strahlungskuehlung gegen den nach Swinbank deutlich
kaelteren Himmel, und es deckt sich mit dem vorab ueberschlagenen Wert. Damit
ist `calc_q_rad.m` als Term qualitativ bestaetigt.

**Methodischer Hinweis fuer die Auswertung:** Die Differenz der beiden
Maxima (46,3 - 30 = 16,3 K) ist *nicht* die Uebertemperatur, weil das
Einstrahlungsmaximum und das Maximum der Lufttemperatur im Tagesgang zeitlich
versetzt liegen. Auszuwerten ist immer punktweise, also `max(Tm - Tamb)`.

→ Kapitel 4.1 (Programmstruktur laeuft), Kapitel 6.2 (Strahlungskuehlung),
   Kapitel 9.1 (Gueltigkeitsbereich)

## 16.08. Abbildungsexport war unbrauchbar, `fig_style.m` korrigiert

**Gemacht:** Das erzeugte `figures/validierung_temperatur.pdf` geprueft.

- Befund: Plotflaeche schwarz, Achsenbeschriftung grau. Ursache ist der Dark
  Mode von MATLAB, der in die exportierte Vektorgrafik durchschlaegt.
  `fig_style.m` hat bisher nur die Figure-Farbe auf weiss gesetzt, nicht die
  Farben von Achsenflaeche, Achsen, Gitter, Text und Legende.
- Fuer ein gedrucktes Protokoll unbrauchbar, und es haette **jede** Abbildung
  des Projekts betroffen, nicht nur die eigenen.
- Behoben in `fig_style.m` durch explizites Setzen der acht betroffenen
  Default-Farben. Damit ist die Darstellung unabhaengig davon, ob jemand im
  Team MATLAB im Dark oder im Light Mode betreibt.

**Konsequenz fuer die Gruppe:** Alle bereits erzeugten Abbildungen muessen
einmal neu exportiert werden. Da Rechnen und Plotten getrennt sind, genuegt
dafuer der Aufruf der `plot_*`-Skripte, ohne erneute Simulation.

→ Kapitel 4.1 (Trennung Rechnen/Plotten zahlt sich hier konkret aus),
   Kapitel 10 (KI-Werkzeuge)

## 16.08. Zeitzonenbehandlung der GeoSphere-Daten repariert

**Gemacht:** Zweiter Startversuch von `run_usecase` bricht ab in
`load_weather_geosphere.m`, Zeile 32.

- Fehlermeldung: enthaelt das Eingabeformat ein Feld fuer den
  Zeitzonenoffset (`XXX`), verlangt `datetime` zwingend zusaetzlich den
  Parameter `TimeZone`. Der Aufruf hatte ihn nicht.
- Zweiter, stiller Fehler in derselben Passage: die Folge
  `zeit.TimeZone = ''` und danach `zeit.TimeZone = 'UTC+2'` setzt nicht die
  Darstellung um, sondern verschiebt den physikalischen Zeitpunkt um zwei
  Stunden. Auf `t` wirkt sich das nicht aus, weil `t` aus Differenzen
  gebildet wird, wohl aber auf `w.startzeit` und damit auf jede spaetere
  Achsenbeschriftung mit absoluter Uhrzeit.
- Behoben: Einlesen explizit als UTC, danach Umstellung auf
  `Europe/Vienna`. Das aendert nur die Darstellung, nicht den Zeitpunkt, und
  behandelt die Sommerzeit korrekt (im Juni MESZ, also UTC+2). Der
  feste Offset `UTC+2` waere fuer Winterdaten falsch gewesen.
- Zusaetzlich ein `elseif` fuer den Fall, dass `readtable` die Spalte je nach
  MATLAB-Version bereits als zonenlose `datetime` liefert.

**Hinweis an die Gruppe:** Die Passage stammt aus dem Commit "Behebung
Zeitzonenkonflikt" und ist auf dieser MATLAB-Version nie gelaufen. Wer Code
committet, sollte ihn einmal ausgefuehrt haben.

**Noch offen:** Die Entscheidung "rechnen in UTC, darstellen in Ortszeit"
steht bisher nur in der Sitzungsagenda und muss als Zeile nach
`annahmen.md`.

→ Kapitel 4.3 (Behandlung der Wetterdaten), Kapitel 6.1 (Datengrundlage)

## 16.08. Abhaengigkeit vom Arbeitsverzeichnis beseitigt

**Gemacht:** Dritter Startversuch bricht ab beim Speichern von
`results/usecase.mat`, mit der Meldung, der Ordner `results` existiere nicht,
obwohl er im Repo liegt.

- Ursache: `exist('results','dir')` durchsucht **auch den MATLAB-Suchpfad**.
  Da `run_all` per `addpath(genpath(pwd))` alle Unterordner in den Pfad legt,
  meldet die Pruefung den Ordner als vorhanden, das `mkdir` unterbleibt.
  `save` schreibt dagegen relativ zum Arbeitsverzeichnis, in dem der Ordner
  nicht liegt. Die Pruefung und der Schreibzugriff beziehen sich also auf
  zwei verschiedene Orte.
- Behoben an zwei Stellen:
  1. `run_all.m` setzt das Arbeitsverzeichnis per
     `cd(fileparts(mfilename('fullpath')))` auf den eigenen Ordner. Damit ist
     es gleichgueltig, von wo aus gestartet wird.
  2. In `run_validation.m`, `run_usecase.m`, `run_sensitivity.m` und
     `save_figure.m` ersetzt `isfolder` das `exist(...,'dir')`. `isfolder`
     prueft ausschliesslich relativ zum Arbeitsverzeichnis und kann dadurch
     nicht faelschlich Erfolg melden.

**Einordnung:** Kein Modellfehler, sondern eine Schwaeche des Geruests. Sie
haette jeden im Team getroffen, der ein Skript einzeln statt ueber `run_all`
startet.

→ Kapitel 4.1 (Programmstruktur)

## 16.08. Erster Lauf mit echten Messdaten, Anwendungsfall gerechnet

**Gemacht:** `run_usecase` mit dem GeoSphere-Datensatz der Station Wien Hohe
Warte, 24.06. bis 01.07.2019, 10-Minuten-Werte, 168 Stunden Simulationszeit.
Damit ist Aufgabenpunkt 2 erstmals mit echten Zahlen belegt.

**Energieanteile ueber den gesamten Zeitraum:**

| Groesse | Energie [kWh] | Anteil |
|---|---|---|
| absorbierte Einstrahlung | 81,64 | 100 % |
| elektrisch abgefuehrt | 9,73 | 11,9 % |
| Konvektion | 40,19 | 49,2 % |
| Strahlung | 31,73 | 38,9 % |
| Summe der drei Abfluesse | 81,65 | 100,01 % |

**Energiebilanz als Qualitaetsnachweis:** Die Summe der drei Abfluesse
weicht um 0,01 kWh von der zugefuehrten Energie ab, das sind 0,01 Prozent
ueber 168 Stunden. Der Rest ist die Differenz des Speicherterms zwischen
Anfangs- und Endzustand. Damit ist numerisch belegt, dass der Solver ueber
den gesamten Zeitraum keine Energie verliert oder erzeugt. Das ist ein
schaerferer Nachweis der numerischen Qualitaet als eine reine
Toleranzbetrachtung.

**Dominanter Verlustterm (Frage aus Kapitel 6.3): die Konvektion mit
49 Prozent**, gefolgt von der Strahlung mit 39 Prozent. Elektrisch werden nur
knapp 12 Prozent der absorbierten Energie abgefuehrt.

**Plausibilitaet des elektrischen Ertrags:** Aus dem Verhaeltnis
9,73 / 81,64 = 11,9 Prozent folgt mit Gl. (3) eine mittlere, mit der
Einstrahlung gewichtete Modultemperatur von rund 39 degC. Das ist fuer eine
Juniwoche in Wien plausibel und bestaetigt die Temperaturrueckkopplung des
elektrischen Teilmodells.

**Achtung bei der Interpretation:** `energie.solar` ist die *absorbierte*
Strahlung, also alpha mal G mal A, nicht die einfallende. Die einfallende
Energie betraegt 81,64 / 0,90 = 90,7 kWh. Wer den Modulwirkungsgrad
angibt, muss auf die einfallende Groesse beziehen, sonst kommt ein zu
guenstiger Wert heraus. Bezogen auf die einfallende Strahlung liegt der
Ertrag bei 10,7 Prozent.

**Nebenbefund:** Die Korrektur an `fig_style.m` wirkt, die drei neuen
Abbildungen haben weissen Hintergrund und schwarze Beschriftung.

→ Kapitel 6.2 (Ergebnisse), Kapitel 6.3 (dominanter Verlustterm),
   Kapitel 4.2 (Energiebilanz als numerischer Nachweis)

## 16.08. Tuncel Abb. 1 geprueft: Validierung so nicht durchfuehrbar

**Gemacht:** Das Referenzpaper vollstaendig durchgesehen, um die
Digitalisierung vorzubereiten.

**Befund, der die geplante Validierung betrifft:** Abb. 1(a) enthaelt
ausschliesslich die Modultemperatur, gemessen und modelliert, sowie die
Abweichung zwischen beiden. Sie enthaelt **keine Eingangsgroessen**. Weder
Einstrahlung noch Umgebungstemperatur noch Windgeschwindigkeit sind in der
Abbildung oder sonst im Paper als Zahlenwerte veroeffentlicht. Kap. 2.4 nennt
nur, dass diese Groessen stuendlich an der Wetterstation der GUENAM-Anlage
gemessen wurden.

`load_weather_paper.m` braucht aber genau G, T_amb und v als Eingang. Aus
Abb. 1 laesst sich nur die Zielgroesse T_m gewinnen, nicht das, womit man sie
berechnet. Die Validierung "Paperdaten einlesen, rechnen, mit der Messkurve
vergleichen" ist mit dem vorliegenden Material nicht durchfuehrbar.

**Was das Paper stattdessen hergibt und was davon sofort verwertbar ist:**

| Groesse | Wert | Verwendung |
|---|---|---|
| MAE Modultemperatur gesamt | 0,90 degC | Benchmark |
| MAE tagsueber | 2,61 degC | Benchmark |
| MBE tagsueber | -1,64 degC | Modell unterschaetzt |
| MAE elektrische Leistung | 3,45 W/m^2 | Benchmark |
| C_m des Referenzmoduls | 5723 J/(m^2 K) | Vergleich zu unseren 7572 |
| Loesungsverfahren | implizites Euler, 1 h fest | Kontrast zu ode45 |
| Modul | poly-c-Si, 12,7 %, 0,45 %/K, 32 Grad | bestaetigt `init_parameters.m` |

**Bestehkriterium laesst sich damit begruenden statt raten:** Tuncel et al.
erreichen mit dem vollen Nusselt-Ansatz und vier Stroemungsregimen tagsueber
MAE 2,61 degC. Unser Basismodell mit linearer Konvektion kann das
systematisch nicht unterbieten. Ein Kriterium in der Groessenordnung MAE
kleiner 5 K ist damit aus der Literatur begruendet und nicht nachtraeglich
passend gewaehlt.

**Diskussionspunkt fuer Kapitel 7:** Das Paper variiert C_m ueber zwei
Groessenordnungen (10^2 bis 10^4) und findet praktisch keine Aenderung von
RMSE und MBE. Schlussfolgerung der Autoren: bei Stundenwerten genuegt eine
stationaere Rechnung. Unser C_m liegt mit 7572 J/(m^2 K) rund 32 Prozent
ueber dem Wert des Papers, liegt damit aber immer noch klar innerhalb des
dort untersuchten Bereichs.

**Ebenfalls bemerkenswert:** In Abb. 2(b) liegt der Speicherterm
C_m dT/dt sichtbar am kleinsten von allen Bilanztermen. Das deckt sich mit
unserem eigenen Lauf, in dem der Speicherterm ueber 168 Stunden nur
0,01 kWh netto ausmacht.

→ Kapitel 5.1 (Bestehkriterium), Kapitel 5.3 (Abweichungen),
   Kapitel 7.3 (Einordnung), Kapitel 9.2 (Grenzen)

## 16.08. Herkunft aller Annahmen durchgegangen, eine Luecke gefunden

**Gemacht:** Jede Zahl in `init_parameters.m` auf ihre Quelle zurueckverfolgt,
um sie in der Praesentation verteidigen zu koennen.

**Ergebnis:** Alle Parameter sind belegt, mit **einer** Ausnahme:

    p.A_conv = 2 * p.A    % konvektiv wirksame Flaeche (Vorder- + Rueckseite)

Das ist die einzige nicht abgeleitete Zahl ohne Quellenangabe, und sie ist
alles andere als harmlos. Die McAdams-Korrelation h = 5,7 + 3,8 v ist fuer
**eine** ueberstroemte Plattenseite aufgestellt. Indem wir sie auf die
doppelte Flaeche anwenden, verdoppeln wir den konvektiven Waermeuebergang.
Genau dieser Term ist im Anwendungsfall mit 49 Prozent der dominante
Verlustpfad. Die Annahme entscheidet damit spuerbar ueber das Ergebnis.

**Physikalisch vertretbar** ist sie fuer ein freistehend aufgestaendertes
Modul, das beidseitig umstroemt wird. Fuer ein dach- oder fassadenintegriertes
Modul waere sie falsch, dort waere A_conv = A anzusetzen. Es handelt sich
also um eine Annahme ueber die **Einbausituation**, die bisher nirgends
ausgesprochen ist.

**Zu tun:** Zeile in `annahmen.md` ergaenzen, Kommentar in
`init_parameters.m` mit Begruendung versehen, und den Fall A_conv = A in die
Sensitivitaetsanalyse aufnehmen. Letzteres ist billig, weil dort ohnehin
schon h_b variiert wird, und es beantwortet die Frage quantitativ statt
argumentativ.

→ Kapitel 2.4 (Konvektion), Kapitel 2.7 (Annahmentabelle),
   Kapitel 7.2 (Sensitivitaet), Kapitel 9.1 (Gueltigkeitsbereich)

## 16.08. Fehlerdefinition von Tuncel geprueft, Tag-Nacht-Trennung noetig

**Gemacht:** Nachgesehen, wie das Referenzpaper seine Fehlermasse bildet,
damit unsere Zahlen mit seinen vergleichbar sind.

**Formeln.** Das Paper nennt MAE, RMSE und MBE nur beim Namen und gibt keine
Gleichungen an. Es sind die Standarddefinitionen, und `calc_errors.m`
implementiert sie bereits richtig:

    r    = T_sim - T_mess
    MAE  = mean(|r|)        mittlerer Betrag der Abweichung
    RMSE = sqrt(mean(r^2))  bestraft grosse Ausreisser staerker
    MBE  = mean(r)          Vorzeichen zeigt die Richtung

**Vorzeichenkonvention stimmt ueberein.** Tuncel schreibt, das Modell
unterschaetze die Modultemperatur, und gibt MBE mit -1,64 degC an. Negativ
bedeutet dort also Unterschaetzung, das entspricht r = sim - mess, genau wie
in `calc_errors.m`. Damit sind die Vorzeichen direkt vergleichbar.

**Die eigentliche Falle: das Paper gibt zwei verschiedene MAE an.**

| Bezug | MAE |
|---|---|
| gesamter Zeitraum | 0,90 degC |
| nur tagsueber | 2,61 degC |

Der Unterschied betraegt fast den Faktor drei und ist kein Widerspruch:
nachts liegt das Modul nahe an der Umgebungstemperatur, dort ist wenig
Dynamik und der Fehler klein. Mittelt man ueber 24 Stunden, verduennen die
vielen unauffaelligen Nachtwerte die Abweichung der Mittagsstunden.

**Konsequenz fuer unsere Validierung:** Wer den MAE ueber den gesamten
Zeitraum bildet und ihn mit Tuncels 2,61 degC vergleicht, vergleicht zwei
verschiedene Dinge und sieht besser aus, als er ist. Wir muessen beide Werte
getrennt ausweisen, so wie das Paper es tut. `calc_errors.m` kennt bisher
keine Tag-Nacht-Trennung.

**Zusaetzlich festzulegen:** Das Paper definiert nicht, wo "daytime"
beginnt. Wir brauchen eine eigene, dokumentierte Schwelle, zum Beispiel
G groesser 20 W/m^2. Diese Definition gehoert nach `annahmen.md`, weil sie
die Fehlerzahl spuerbar verschiebt.

→ Kapitel 5.1 (Fehlermasse), Kapitel 5.2 (Ergebnisse)

## 20.08. Fahrplan abgearbeitet: offene Punkte in Code und Protokoll geschlossen

**Gemacht:** Die bis dahin gesammelten offenen Punkte in einem Zug
abgearbeitet. Betroffen sind acht Dateien.

**Eigener Bereich (MATLAB-Kern und Validierung):**

- `calc_errors.m` um eine Tag-Nacht-Trennung erweitert. Optionales drittes
  Argument `ist_tag`, zusaetzliche Felder `e.tag` und `e.nacht`. Die
  Begruendung (Tuncel gibt 0,90 gegen 2,61 degC an) steht im Dateikopf, weil
  sie sonst in einem halben Jahr niemand mehr rekonstruiert.
- `run_validation.m`: Fehlermasse werden jetzt getrennt berechnet und
  ausgegeben. Ausserdem ist der Einbau der Messwerte vorbereitet: liegen in
  der Wetterstruct die Felder `t_mess` und `Tm_mess`, werden sie auf das
  Zeitgitter des Loesers interpoliert. Bis dahin bleibt der bisherige
  Platzhalter aktiv, ohne dass etwas abstuerzt.
- `plot_validation.m`: `title()` entfernt. Der Plotstandard der LVA verlangt
  die Kernaussage in der Bildunterschrift und keine Wiederholung zwischen
  Titel, Achse und Caption. Die Fehlermasse werden stattdessen fertig
  formatiert auf die Konsole ausgegeben und von dort in die Caption
  uebernommen.
- Kapitel 4 (Numerik) als Rohfassung geschrieben. Enthaelt die Begruendung
  der Solverwahl ueber das nicht definierte Steifheitsverhaeltnis eines
  skalaren Systems, die Energiebilanz als unabhaengige Kontrolle und die
  Zeitkonstante. Offen bleibt eine einzige Zahl, die maximale Abweichung aus
  dem Toleranzvergleich.
- Kapitel 5.1 (Vorgehen und Fehlermasse) geschrieben, einschliesslich der
  drei Validierungskriterien der Vorlesung und der Herleitung des
  Bestehkriteriums aus der Literatur. Abschnitt 5.2 als Datengrundlage
  angelegt, in dem der Befund zu Abb. 1 festgehalten ist.

**Ausserhalb des eigenen Bereichs, mit dem Team abzustimmen:**

- `init_parameters.m` (Toms Datei): `A_conv` und `theta` mit Begruendung
  kommentiert, `p.G_tag_min = 20` ergaenzt. Die Zahl musste dorthin, weil
  die Coderegel keine Zahlenwerte ausserhalb dieser Datei erlaubt.
- `run_sensitivity.m` (Matyas' Datei): Studie ueber `A_conv` von 1*A bis
  2*A aufgenommen. Damit wird die einzige nicht durch Literatur belegte
  Annahme quantitativ statt argumentativ behandelt.
- `annahmen.md` (gemeinsam): alle Platzhalterdaten gefuellt, Station und
  Datenluecken eingetragen, vier neue Zeilen ergaenzt, ein Abschnitt
  "Offene Punkte" mit den vier Gruppenentscheidungen angelegt und zwei
  verworfene Ansaetze dokumentiert.

**Dabei einen Fehler in der Auswertung der Sensitivitaetsanalyse gefunden.**
`plot_sensitivity.m` bestimmte den Bezugswert der relativen Darstellung als
*mittleren* Wert der jeweiligen Reihe. Das trifft nur zu, wenn der
Nominalwert zufaellig in der Mitte liegt. Bei `eps_front` war das schon
vorher nicht der Fall (Mitte 0,85, tatsaechlicher Nominalwert 0,87), und die
neue A_conv-Studie hat ihren Nominalfall am oberen Rand. Die Abbildungen
haetten die Kurven gegen einen falschen Bezugspunkt normiert. Behoben, indem
`run_sensitivity.m` den Nominalwert je Studie mitschreibt und
`plot_sensitivity.m` ihn von dort nimmt.

**Nicht erledigt, weil ohne MATLAB nicht moeglich:** Toleranzvergleich und
die Pruefbefehle. Beides bleibt in der Liste unten.

→ Kapitel 4 und 5 liegen als Rohfassung vor, Kapitel 7.2 bekommt eine
   zusaetzliche Studie

---

## Offen, noch nicht protokolliert

Diese Schritte stehen noch aus. Beim Abarbeiten hier fortschreiben.

- [x] Erster Lauf `run_usecase` mit echten GeoSphere-Daten → erledigt 16.08.
- [ ] Abgleich gegen die drei Erwartungswerte (C_m, tau, Uebertemperatur),
      Pruefbefehle stehen aus → Kapitel 4.2 und 6.2
- [ ] Nachweis der Loesungsunabhaengigkeit: Wiederholung mit RelTol = AbsTol =
      1e-8, maximale Abweichung in T_m notieren → Kapitel 4.2, dort ist die
      Zahl das einzige verbliebene TODO
- [ ] `run_sensitivity` einmal laufen lassen, jetzt mit der A_conv-Studie
      → Kapitel 7.2
- [x] Bestehkriterium formuliert und begruendet (MAE tagsueber unter 5 K)
      → steht in `annahmen.md`, **muss in der Gruppe bestaetigt werden**
- [ ] Datengrundlage der Validierung: Gruppenentscheidung zwischen den drei
      Wegen in `annahmen.md`, offener Punkt 1 → Kapitel 5.2
- [ ] Bodentemperatur gegen `ts` und `tb10` aus dem GeoSphere-Datensatz
      pruefen, statt die Annahme nur zu behaupten → Kapitel 9.1
- [ ] Anfangstemperatur zwischen MATLAB (`T0 = Tamb(0)`) und Simulink
      (`p.Tm0 = 298.15`) angleichen oder Abweichung begruenden → Kapitel 8.3

---

## Verwendung von KI-Werkzeugen (fuer Kapitel 10)

| Wofuer | Werkzeug | Wie geprueft |
|---|---|---|
| Durchsicht des MATLAB-Kerns gegen die Modellgleichungen, Aufspueren des ungenutzten Parameters `theta` und des Plotstandard-Verstosses | Claude (Claude Code) | Beide Befunde im Quelltext an der genannten Stelle nachgesehen und bestaetigt |
| Ueberschlagsrechnung C_m, tau, stationaeres Delta-T als Erwartungswert vor dem ersten Lauf | Claude (Claude Code) | Von Hand nachgerechnet; Gegenprobe gegen die Simulation steht noch aus |
| Pruefung des exportierten Abbildungs-PDF, Diagnose des Dark-Mode-Problems und Korrektur von `fig_style.m` | Claude (Claude Code) | PDF vor und nach der Korrektur angesehen, Farbwechsel bestaetigt |
| Durchsicht von Tuncel et al. 2020 auf Fehlerdefinition und Datengrundlage der Abb. 1 | Claude (Claude Code) | Abbildung und Kap. 2.4/3 des Papers selbst gelesen; die Aussage, dass keine Eingangsgroessen veroeffentlicht sind, am Original geprueft |
| Erweiterung von `calc_errors.m`, Rohfassung der Kapitel 4 und 5.1 | Claude (Claude Code) | Formeln gegen die Standarddefinitionen und die Vorzeichenkonvention des Papers geprueft; Text vor Uebernahme durchgearbeitet |
