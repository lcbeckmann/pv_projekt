# 2. Treffen PV-Modellierung

**Datum:** ______  **Ort:** ______  **Dauer:** 90 Minuten
**Protokoll tippt:** ______ (Ergänzungen direkt in `annahmen.md`)

**Ziel der Sitzung:** Am Ende rechnet der MATLAB-Kern mit den echten
GeoSphere-Daten, die Parametertabelle hat keine offene Quelle mehr, und die
Fehlermaße für die Validierung stehen fest.

**Mitbringen:** gepushter Stand im Repo. Was lokal auf einem Laptop liegt,
existiert für diese Sitzung nicht.

---

## 0. Statusrunde (10 min)

Jeder zwei Minuten: was ist gepusht, was fehlt, wo hängt es. Kein Ausblick,
keine Absichtserklärung. Wenn etwas nicht fertig ist, ist das in Ordnung, aber
es braucht ein neues Datum, bevor wir weitergehen.

---

## 1. Abnahme der vier Entscheidungen aus der Startsitzung (5 min)

a) Modul, b) Strahlungsebene, c) Umgebungstemperatur Validierung,
d) GeoSphere-Station.

Nur eine Frage: steht jede der vier mit Begründung in `annahmen.md`? Wenn
nein, wird sie jetzt in zwei Sätzen nachgetragen. Nicht neu aufmachen.

---

## 2. Datensatz abnehmen (15 min)

Die Datei `Stationsda1T0000.csv` liegt vor: Station 5904, 24.06.2019 00:00
bis 01.07.2019 00:00, 10-Minuten-Werte, 1009 Zeilen. In `cglo`, `tl`, `ff`
fehlt kein einziger Wert.

Offen und heute zu klären:

- **Zeitzone.** Die Zeitstempel sind UTC. Das Strahlungsmaximum liegt um etwa
  11:10 UTC, also 13:10 Ortszeit (MESZ). Wenn wir ohne Umrechnung plotten,
  sitzt der Mittag zwei Stunden zu früh. Entscheidung: rechnen in UTC, für
  Abbildungen auf MESZ. Wer setzt das um?
- **Einheiten.** `cglo` erreicht 944, das passt zu W/m². Trotzdem aus der
  Spaltenbeschreibung von GeoSphere belegen und in die Parametertabelle
  schreiben, nicht aus der Größenordnung schließen.
- **Flags.** In `cglo_flag` stehen 11 und 12, in `tl_flag` nur 12. Was
  bedeuten die beiden Werte? Wenn 11 "ungeprüft" heißt, betrifft das 129 von
  1009 Zeitschritten und gehört ins Protokoll.
- **Windgeschwindigkeit.** `ff` (0,1 bis 6,7) und `ffam` liegen beide vor.
  Welche Spalte nehmen wir, und in welcher Höhe misst die Station? Unser
  h = h_a + h_b·v meint die Anströmung am Modul, nicht den Wert am Mast. Das
  ist eine Annahme und muss als solche in die Tabelle.
- **Bonus:** Die Station liefert `ts` und `tb10`. Damit können wir die Annahme
  "Bodentemperatur gleich Umgebungstemperatur" gegen echte Werte halten,
  statt sie nur zu behaupten. Ein Satz im Protokoll, mehr braucht es nicht.

---

## 3. Parametertabelle durchgehen (15 min)

Tabelle auf den Beamer, Zeile für Zeile. Jede Zeile hat Symbol, Wert,
Einheit, Quelle. Wie viele `TODO Quelle` sind noch offen, und wer schließt
welche bis wann?

Besonders anschauen:

- Schichtaufbau für C_m. Dicken, Dichten, spezifische Wärmekapazitäten,
  jeweils mit Quelle. Das ist der Parameter mit den meisten Einzelwerten und
  der größte Kandidat für einen Einheitenfehler.
- h_a und h_b: aus welcher Arbeit, für welche Einbausituation gemessen?
- ε_f und ε_b: getrennte Werte oder derselbe Wert für beide Seiten?

---

## 4. Erster Lauf und Plausibilitätscheck (15 min)

Der MATLAB-Kern rechnet einmal live vor der Gruppe. Die Kurve muss nicht schön
sein, sie muss laufen. Wir prüfen gemeinsam:

- Nachts nähert sich T_m an T_amb an. Wenn nicht, stimmt die Bilanz nicht.
- Mittags liegt T_m deutlich über T_amb, Größenordnung 20 bis 30 K bei voller
  Einstrahlung.
- W_el sinkt bei steigender Temperatur, nicht umgekehrt. Vorzeichen von β_ref.
- Das Modell reagiert träge, nicht sprunghaft. Zeitkonstante grob abschätzen
  und mit der Simulation vergleichen.

**Plotstandard festlegen (5 min davon).** Laut Protokolltipps: Schriftgröße
groß genug zum Lesen im ausgedruckten Protokoll, kein Titel über dem Plot,
Achsen mit Größe und Einheit, keine redundante Legende. Wir legen das einmal
in einer gemeinsamen Hilfsfunktion fest, sonst müssen am Ende alle Abbildungen
noch einmal gebaut werden.

Dazu die Regel, die schon steht: `run_*.m` rechnet und speichert das Ergebnis
als `.mat`, `plot_*.m` lädt nur und zeichnet. Kein Testlauf soll alle
Abbildungen neu erzeugen.

---

## 5. Validierung vorbereiten (10 min)

- Sind die Punkte aus Tuncel Abb. 1 digitalisiert? Welche Kurve, welcher Tag,
  wie viele Punkte?
- **Fehlermaße jetzt festlegen, vor den Ergebnissen.** Vorschlag: RMSE, MAE,
  maximale Abweichung, jeweils in K. Wer die Metrik erst nach dem Ergebnis
  wählt, sucht sich die aus, die am besten aussieht. Das fällt in der
  Prüfungsfrage auf.
- Woran erkennen wir, dass die Validierung bestanden ist? Eine Zahl nennen,
  auch wenn sie grob ist.
- Sammeln, welche Abweichungsgründe wir erwarten: fehlende Angabe zur
  Umgebungstemperatur, Windgeschwindigkeit unbekannt, Ableseungenauigkeit beim
  Digitalisieren, ein Knoten statt Schichtmodell. Das ist später Kapitel 5.3
  und lässt sich heute in zehn Minuten stichwortartig festhalten.

---

## 6. Schnittstelle zu Simulink und Batterie (10 min)

- Liegt das Batteriemodell der LVA vor? Wenn nein, wer holt es bis wann?
- Was übergibt das PV-Modell an die Batterie: W_el über der Zeit. In welcher
  Einheit, mit welchem Zeitraster?
- Wer den Simulink-Teil baut, braucht nichts vom MATLAB-Kern außer den
  Gleichungen. Doppelte Implementierung ist hier gewollt, denn der Vergleich
  der beiden ist ein eigener Abschnitt im Protokoll.

---

## 7. Schreiben verteilen (10 min)

Das Protokollgerüst steht in Overleaf. Jetzt bekommt jedes Kapitel einen
Namen. Wer rechnet, schreibt auch das zugehörige Kapitel, sonst geht die
Begründung verloren.

| Kapitel | Wer | Rohfassung bis |
|---|---|---|
| 2 Modellbildung, 3 Parameter | | |
| 4 Numerik, 5 Validierung | | |
| 6 Anwendungsfall, 7 Sensitivität | | |
| 8 Simulink, 9 Diskussion | | |
| 10 KI-Verwendung, Anhang | | |

Kapitel 10 füllt sich am besten laufend: wer ein Werkzeug für einen Abschnitt
benutzt hat, schreibt sofort eine Zeile dazu. Am Ende weiß es keiner mehr.

Rohfassung heißt: Text steht, Zahlen dürfen Platzhalter sein. Nicht schön,
aber vollständig.

---

## 8. Termine (5 min)

Meilensteine aus der Startsitzung prüfen. Was hat sich verschoben, und was
verschiebt sich dadurch mit?

Nächstes Treffen: ______

---

## Nicht Thema dieser Sitzung

- Nusselt-Ansatz statt linearer Konvektion
- Mehrknotenmodell
- Umrechnung auf geneigte Modulebene, falls in der Startsitzung dagegen
  entschieden wurde
- Formatierung des Protokolls

Wenn dazu etwas kommt: auf eine Liste "später, falls Zeit" und weiter.

---

## Ergebnis der Sitzung

- [ ] Alle vier Startentscheidungen stehen schriftlich in `annahmen.md`
- [ ] Zeitzone, Einheiten, Flags und Windspalte geklärt und dokumentiert
- [ ] Parametertabelle ohne offenes `TODO Quelle`, oder mit Name und Datum
- [ ] MATLAB-Kern ist einmal vor der Gruppe gelaufen
- [ ] Fehlermaße für die Validierung festgelegt
- [ ] Plotstandard in einer Hilfsfunktion festgelegt
- [ ] Jedes Protokollkapitel hat einen Namen und ein Datum
- [ ] Nächster Termin steht
