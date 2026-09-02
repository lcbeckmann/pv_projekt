# Simulink-Umsetzung: Arbeitsnotizen für Kapitel 8

Stand: 26.08.2026, Person D (Lars)

Das ist keine Protokollfassung, sondern die Materialsammlung dafür. Was hier
steht, ist belegt und mit Zahlen hinterlegt. Formuliert wird später in Overleaf.

---

## 1. Modellaufbau

### Struktur

Das Blockschaltbild bildet die Energiebilanz eins zu eins ab:

    C_m · dT_m/dt = Q_solar − W_el − Q_konv − Q_rad

Auf der obersten Ebene stehen vier Subsysteme (je ein Term), ein Summenblock
mit einem Plus und drei Minus, ein Gain `1/C_m` und ein Integrator. Wer die
Gleichung aus Kapitel 2 kennt, erkennt sie im Bild wieder.

**Warum diese Aufteilung und nicht ein einzelner Funktionsblock:** Die vier
Terme sind so getrennt geloggt verfügbar, was für den Vergleich mit
Tuncel et al. Abb. 2b nötig ist. Ein einzelner MATLAB-Function-Block hätte
dieselbe Zahl geliefert, aber weder die Abbildung noch die Termzerlegung.

### Signalführung

`G`, `T_amb`, `v` und `T_m` werden über Goto/From-Tags verteilt. Die vier
Bilanzterme laufen dagegen als sichtbare Leitungen zum Summenblock.

**Warum die Unterscheidung:** Die Bilanz ist die Kernaussage des Bildes und muss
sichtbar bleiben. Die Verteilung der Eingangsgrößen ist Verkabelung ohne
Aussagewert und würde das Bild mit Kreuzungen zustellen.

### Eingangsdaten

Ein `From Workspace`-Block liest die Matrix `w.matrix` mit den Spalten
`[Zeit, G, T_amb, v]`, ein Demux zerlegt sie in drei Signale.

**Wichtig für die Reproduzierbarkeit:** Die Matrix entsteht in
`build_weather_struct.m`, also derselben Funktion, die auch die Interpolanten
für den MATLAB-Kern baut. Beide Implementierungen werden damit aus identischen
Stützstellen gespeist. Beide interpolieren linear. Ohne diese gemeinsame Quelle
wäre der Vergleich in 8.3 nicht aussagekräftig, weil eine Abweichung auch von
unterschiedlich aufbereiteten Eingangsdaten kommen könnte.

---

## 2. Numerische Einstellungen

| Einstellung | Wert | Begründung |
|---|---|---|
| Solver | ode45, variable Schrittweite | wie im MATLAB-Kern |
| RelTol / AbsTol | 1e-6 (aus `p`) | identisch zu `odeset` im MATLAB-Kern |
| MaxStep | 300 s | halbe Auflösung der GeoSphere-Daten |
| Signal logging | Dataset, `logsout` | Zugriff über Signalnamen statt To-Workspace-Blöcke |

**Warum MaxStep:** Ohne diese Grenze nimmt ode45 in den ruhigen Nachtstunden
Schritte von über einer Stunde, überspringt Stützstellen der 10-Minuten-Daten
und schneidet die Morgenflanke ab. Die Grenze auf die halbe Datenauflösung
stellt sicher, dass jede Stützstelle mindestens einmal ausgewertet wird.

**Warum die Toleranzen aus `p` kommen und nicht als Zahl im Modell stehen:**
Sonst rechnet Simulink mit dem Standardwert 1e-3 und der MATLAB-Kern mit 1e-6.
Der Vergleich in 8.3 würde dann die Solvereinstellung messen statt der
Implementierung.

---

## 3. Verifikation

Drei Ebenen, von der einfachsten zur aufwendigsten.

### 3.1 Stationärer Referenzfall

Randbedingungen: G = 800 W/m², v = 1 m/s, T_amb = 293,15 K, t = 20000 s.
Das entspricht der NOCT-Prüfbedingung nach IEC 61215.

| Größe | Wert |
|---|---|
| T_m | 311,88 K (38,7 °C) |
| Q_solar | 1176,12 W |
| Q_konv | 581,17 W |
| Q_rad | 454,81 W |
| W_el | 140,14 W |
| Bilanzrest | 2,9e-12 W |

Reproduzierbar über `run_simulink_referenz.m`.

**Einordnung:** Der Erwartungsbereich für NOCT bei c-Si liegt bei 43 bis 48 °C.
Das Modell liegt mit 38,7 °C darunter. Ein Teil davon ist erklärbar: NOCT ist im
Leerlauf definiert, unser Modell zieht W_el aus der Bilanz ab und muss deshalb
systematisch tiefer liegen. Der Rest geht auf die Wahl `A_conv = 2·A` zurück
(siehe Abschnitt 5).

**Warum stationär und nicht die Wochenkurve:** Bei einem einzelnen Betriebspunkt
ist eine Abweichung genau einem Term zuzuordnen. In einer Zeitreihe überlagern
sich Modellfehler, Solvereinfluss und Interpolation der Eingangsdaten.

### 3.2 Grenzfälle

| Fall | Ergebnis | Aussage |
|---|---|---|
| G = 0, v = 1 | 291 K, also 2 K unter T_amb | nächtliche Unterkühlung durch Abstrahlung gegen den Himmel |
| G = 800, v = 0 | deutlich über 314 K | Windabhängigkeit der Konvektion wirkt |

Der erste Fall ist inhaltlich interessant: ein rein stationäres Modell (z. B.
Ross) kann eine Modultemperatur unter Umgebungstemperatur nicht abbilden. Das
ist ein Argument für den dynamischen Ansatz und gehört in Kapitel 9.

### 3.3 Vergleich mit dem MATLAB-Kern (Kapitel 8.3)

Anwendungsfall GeoSphere 24.06. bis 01.07.2019, identische Eingangsdaten und
Toleranzen.

| Implementierung | Elektrischer Wochenertrag |
|---|---|
| MATLAB (`run_usecase.m`) | 9,732 kWh |
| Simulink (`run_simulink_usecase.m`) | 9,732 kWh |

Übereinstimmung auf drei Nachkommastellen über 1009 Stützstellen und sieben Tage.

**Was das zeigt und was nicht:** Es zeigt, dass beide Implementierungen dieselben
Gleichungen mit denselben Parametern rechnen. Es zeigt nicht, dass die
Gleichungen richtig sind. Das ist Verifikation, nicht Validierung. Ein
Parameterfehler wie eine falsch gewählte Konvektionsfläche steckt in beiden
Implementierungen gleichermaßen und wird durch diesen Vergleich nicht gefunden.

**Noch offen:** Differenzplot der Modultemperatur auf gemeinsamem Zeitraster,
mit maximaler Abweichung und RMS.

---

## 4. Ergebnisse Anwendungsfall

| Größe | Wert |
|---|---|
| T_m minimal | 11,6 °C |
| T_m maximal | 53,8 °C |
| G maximal | 944 W/m² |
| W_el maximal | 165,0 W |
| Elektrischer Ertrag Woche | 9,732 kWh |

Einordnung: Bei 55,5 kWh/m² Wocheneinstrahlung und 1,6335 m² Modulfläche
entspricht der Ertrag einem mittleren Systemwirkungsgrad von 10,7 %, bei einem
Nennwirkungsgrad von 12,7 %. Die Differenz ist der Temperaturverlust.

Das Minimum von 11,6 °C liegt 3,1 K unter der tiefsten gemessenen
Lufttemperatur (14,7 °C).

---

## 5. Offene Punkte und Annahmen

### A_conv = 2·A

Die Konvektion wird beidseitig mit derselben McAdams-Korrelation angesetzt.
Das unterstellt eine freistehende, hinterlüftete Aufständerung.

**Bekannte Inkonsistenz:** Bei der Abstrahlung wird zwischen den Seiten
unterschieden (Vorderseite gegen Himmelstemperatur nach Swinbank, Rückseite
gegen Umgebungstemperatur), bei der Konvektion nicht. Die Anströmung der
Rückseite ist bei einer Aufständerung schwächer als die der freien Vorderseite,
die Rückseitenkühlung wird also überschätzt.

**Wirkung, quantifiziert:** Im Referenzfall verschiebt der Wechsel von `2·A` auf
`A` die Modultemperatur um etwa 8 K (von 38,7 °C auf rund 47 °C). Damit ist
`A_conv` ein deutlich stärkerer Parameter als die Wärmekapazität `C_m`, für die
Tuncel et al. in Abb. 2a einen praktisch verschwindenden Einfluss auf RMSE und
MBE berichten. `A_conv` gehört in die Sensitivitätsanalyse.

Ausführlich in `doku/annahmen.md`, Eintrag A-xx.

### Windmesshöhe

GeoSphere misst nach WMO-Standard in 10 m Höhe, die Konvektionskorrelation
bezieht sich auf die Anströmung am Modul (etwa 2 m). Ohne Korrektur über ein
logarithmisches Windprofil ist die Windgeschwindigkeit um rund ein Viertel zu
hoch angesetzt und die Konvektion entsprechend zu stark. **Noch nicht
implementiert.**

### Q_solar: alpha_abs oder tau_alpha

Der MATLAB-Kern verwendet `p.alpha_abs`, das Simulink-Modell `p.tau_alpha`.
Beide stehen auf 0,9, deshalb fällt der Unterschied aktuell nicht auf. Sobald
einer der Werte geändert wird, laufen die Implementierungen auseinander.
**Zu klären, welcher der richtige ist.**

### Zeitzone

Die GeoSphere-Rohdaten liegen in UTC (`+00:00` im Zeitstempel). Für die
Rechnung ist die Zone ohne Bedeutung, weil die Zeitachse relativ zum Startpunkt
gebildet wird. Relevant wird sie nur für Achsenbeschriftungen und für Aussagen
über Sonnenstände. Plausibilitätsprüfung: das Einstrahlungsmaximum der Woche
liegt am 28.06. um 11:10 UTC, also 13:10 MESZ, was zum wahren Mittag in
Ostösterreich Ende Juni passt.

### Datengrundlage

Station 5904, 1009 Zeilen, 10-Minuten-Raster, keine fehlenden Werte in `cglo`,
`tl` und `ff`. Die Qualitätsflags stehen bei `cglo` in 129 Fällen auf 11 statt
12, ausschließlich zu Nachtzeiten bei Strahlungswerten von 0 oder 1. Kein
Datenproblem. **Stationsname, Seehöhe und Koordinaten noch nachzutragen.**

---

## 6. Fehler, die beim Bau aufgetreten sind

Für Kapitel 8 nur insoweit relevant, als sie das Vorgehen begründen. Fünf
Fehler, von denen drei plausible Ergebnisse geliefert haben:

1. Im Konstantenblock für `T_amb` stand der Anfangswert `p.Tm0` statt der
   Umgebungstemperatur.
2. Vier Goto/From-Tags waren nicht aufgelöst (`T_amb` statt `Tamb` getippt).
3. Im `W_el`-Subsystem stand derselbe Ausdruck in Gain und Bias.
4. Der Bias stand auf `-1` statt `1`.
5. Beim Temperaturkoeffizienten fehlte das Minuszeichen, der Wirkungsgrad
   stieg dadurch mit der Temperatur.

**Konsequenz für das Vorgehen:** Der Bilanzrest-Check (Summe der Terme gleich
null) hat keinen dieser Fehler gefunden, weil ein falscher Term konsistent in
die Summe eingeht. Gefunden wurden sie durch den Vergleich einzelner Terme mit
einer unabhängigen Handrechnung. Das ist das Argument dafür, warum mehr als
eine Prüfung nötig ist.

Fehler 5 lohnt eine Erwähnung: er verändert `W_el` um 6 % und die
Modultemperatur um weniger als 0,5 K. In einer Wochenkurve mit Tag-Nacht-Zyklus
wäre er nicht aufgefallen.

---

## 7. Einordnung Simulink gegenüber MATLAB

Für Kapitel 8 oder 9. Nicht als Lob, sondern als Abwägung.

**Wofür Simulink besser geeignet ist:**

- Die Struktur der Bilanz ist im Blockschaltbild unmittelbar lesbar. Aus einer
  `.m`-Datei ergibt sich das nicht.
- Zustandsereignisse (Ladeschlussbegrenzung der Batterie) werden über
  Zero-Crossing-Detection mit Nullstellensuche behandelt, nicht über eine
  `if`-Abfrage, die der Solver überfahren kann.

**Wofür der Textcode besser geeignet ist:**

- Die Kopplung an die Eingangsdaten läuft über Spaltenpositionen der Matrix,
  nicht über Namen. Eine Vertauschung von `G` und `T_amb` läuft stillschweigend
  durch. Im MATLAB-Kern ist `w.G` eindeutig. (Ist beim Bau tatsächlich
  passiert.)
- `.slx` ist ein Binärformat. `git diff` zeigt nur "binary file differs",
  paralleles Arbeiten am Modell ist nicht mergebar. Am Modell arbeitet deshalb
  nur eine Person.
- Für Parameterstudien wie die Sensitivitätsanalyse ist eine Schleife über
  Parameterwerte im Textcode einfacher als jeder Simulink-Ansatz.

---

## 8. Batteriemodell (Aufgabenpunkt 7)

**Vorbemerkung fürs Protokoll:** Laut Angabe wird ein passendes Batteriemodell
zur Verfügung gestellt. Das Modell wurde bis zum Bearbeitungszeitpunkt nicht
bereitgestellt; auf Anfrage kam keine Rückmeldung. Es wurde deshalb ein eigenes,
bewusst einfaches Modell aufgesetzt. (Datum und Anfrage in `annahmen.md`
festhalten.)

**Gewähltes Modell:** reine Energiebilanz mit einem Zustand.

    E_nenn · dSoC/dt = eta_lade · W_el

mit SoC begrenzt auf [0, 1].

**Begründung der Ordnung:** Ein unabhängiger Energiespeicher, also ein Zustand.
Dieselbe Argumentation wie beim Modul.

**Parameter:** E_nenn = 1,2 kWh, eta_lade = 0,90, SoC0 = 0,20.

**Begründung der Dimensionierung:** Das Modul liefert 1,39 kWh pro Tag. Bei
1,2 kWh Kapazität und Start bei 20 % treten im Simulationszeitraum beide
Betriebszustände auf, Ladung und Ladeschlussbegrenzung. Bei deutlich größerer
Kapazität wäre nur eine Rampe zu sehen, bei deutlich kleinerer nur die
Begrenzung. Das ist die Begründung eines Demonstrationsfalls, keine Auslegung
für eine reale Anwendung.

**Umsetzung:** Integrator mit aktivierter Ausgangsbegrenzung (0 bis 1). Simulink
behandelt das Erreichen der Sättigung als Zustandsereignis mit Nullstellensuche,
nicht als Abschneiden nach dem Schritt. Das ist der hybride Anteil des Modells
(Bezug: VO 4, hybride Simulation).

**Grenzen (Kapitel 9.2):** Klemmenspannung, Innenwiderstand und
Temperaturabhängigkeit sind nicht abgebildet. Das Modell beantwortet, wie
schnell die Batterie voll wird, nicht, welche Spannung anliegt. Keine Last
modelliert, die Angabe fordert nur das Laden.

---

## 9. Noch zu erledigen

- [ ] Batterie-Subsystem bauen, `SoC` loggen
- [ ] Wochenlauf mit Batterie, Zeitpunkt des Erreichens von SoC = 1 festhalten
- [ ] Differenzplot T_m Simulink gegen MATLAB, max und RMS
- [ ] Lauf mit `A_conv = A` für die Tabelle in `annahmen.md`
- [ ] Windhöhenkorrektur implementieren oder als offene Annahme dokumentieren
- [ ] `alpha_abs` gegen `tau_alpha` klären
- [ ] Stationsmetadaten nachtragen
- [ ] Termvergleich mit Tuncel Abb. 2b (setzt digitalisierte Kurven voraus)
- [ ] Blockschaltbild als Vektorgrafik exportieren (`print -dpdf`, kein
      Screenshot)

---

## 10. Dateien

| Datei | Aufgabe |
|---|---|
| `matlab/simulink/pv_simulink.slx` | Blockschaltbild |
| `matlab/run_simulink_referenz.m` | stationärer Referenzfall, Regressionstest |
| `matlab/run_simulink_usecase.m` | Anwendungsfall, rechnet und speichert |
| `matlab/results/simulink_usecase.mat` | Ergebnisse des Anwendungsfalls |

Arbeitsverzeichnis ist `matlab/`. Von `pv_projekt/` aus schlagen die relativen
Pfade zu den Wetterdaten fehl. Gehört in die README.
