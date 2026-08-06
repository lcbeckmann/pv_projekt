# KI-Kontext: PV-Modellierung

Dieses Dokument fasst den Stand des Projekts so zusammen, dass eine KI damit
sinnvoll weiterarbeiten kann, ohne dass jeder von uns bei null anfängt.

**So benutzt du es:** In Claude ein Projekt anlegen (linke Seitenleiste,
"Projekte", "Neues Projekt"). Diese Datei als Projektwissen hochladen,
zusammen mit der Angabe, den beiden Papers und `Projektvorgehen.pdf`. Danach
kennt Claude in jedem Chat dieses Projekts den Kontext.

**Wenn sich etwas Grundlegendes ändert**, aktualisiere dieses Dokument im Repo
und sag es in der Gruppe, damit alle die neue Version hochladen.

---

## 1. Aufgabe

Lehrveranstaltung: VU Kontinuierliche Simulation, 325.118, TU Wien.
Thema: Modellierung und Simulation eines Photovoltaikmoduls.
Gruppe: vier Personen. Abgabe: Protokoll (LaTeX) und Präsentation.

Acht Aufgabenpunkte laut Angabe:

1. Modellbildung
2. Implementierung der Systemgleichungen in MATLAB
3. Literaturrecherche der Modellparameter
4. Validierung des Modells
5. Anwendungsfall mit Messdaten
6. Sensitivitätsanalyse
7. Implementierung in Simulink (Batterieladung)
8. Protokoll und Präsentation

Entscheidend laut Angabe: **jeder Schritt muss begründbar und nachvollziehbar
sein.** Bewertet wird nicht primär, ob die Kurve stimmt, sondern ob wir sagen
können, warum wir sie so gerechnet haben.

Referenzarbeiten:
- Tuncel et al. 2020, *Dynamic thermal modelling of PV performance and effect
  of heat capacity on the module temperature*
- Herteleer et al. 2023, *Investigating methods to improve photovoltaic
  thermal models at second-to-minute timescales*

---

## 2. Das Modell

Bilanzraum ist das Modul ohne Rahmen, betrachtet als ein einziger
Temperaturknoten (Lumped). Aus dem ersten Hauptsatz:

    C_m * dT_m/dt = Q_solar - W_el - Q_konv - Q_rad          (2.1)

Genau ein unabhängiger Energiespeicher (die Wärmekapazität), also genau ein
Zustand. Die Ordnung folgt aus der Physik, nicht aus einer Wahl.

Einzelterme:

    Q_solar = alpha * G * A                                   (2.2)
    W_el    = G*A*(tau*alpha)*eta_ref*[1 - beta_ref*(T_m - T_ref)]   (2.3)
    h       = h_a + h_b * v                                   (2.4)
    Q_konv  = h * A_konv * (T_m - T_amb)                      (2.5)
    Q_rad   = sigma*A*[eps_f*(T_m^4 - T_sky^4) + eps_b*(T_m^4 - T_amb^4)]  (2.6)
    T_sky   = 0.0552 * T_amb^1.5   (Swinbank, T in K)
    C_m     = A * sum_n (d_n * rho_n * cp_n)                  (2.7)

Wichtig für das "Warum": W_el hängt von T_m ab. Diese Rückkopplung macht aus
der Bilanz erst eine Differentialgleichung.

---

## 3. Getroffene Entscheidungen

| Entscheidung | Begründung |
|---|---|
| **Basismodell** statt vollem Nusselt-Ansatz | Windrichtung aus den Messdaten nicht sinnvoll nutzbar, vier Strömungsregime mit unseren Daten nicht validierbar, Aufwand steht nicht im Verhältnis |
| Modul als ein Temperaturknoten | Laminatdicke rund 3 mm, Biot-Zahl klein |
| Wärmeleitung vernachlässigt | folgt aus der Lumped-Annahme |
| Bodentemperatur = Umgebungstemperatur | keine Messdaten verfügbar |
| Himmelstemperatur nach Swinbank | einfachste belegte Korrelation, braucht nur T_amb |
| ode45, RelTol = AbsTol = 1e-6 | skalares System, Steifheitsverhältnis nicht definiert, also nicht steif. Toleranzen bewusst gesetzt statt Defaults |
| lineare Interpolation der Wetterdaten | Spline kann bei Bewölkungssprüngen überschwingen und negative Einstrahlung erzeugen |
| Rechnen und Plotten getrennt | Abbildungen anpassen ohne Neuberechnung |

Der vollständige und laufend gepflegte Stand steht in `doku/annahmen.md`.
Diese Datei hier ist nur die Zusammenfassung.

---

## 4. Codestruktur

```
matlab/
  init_parameters.m        einzige Stelle mit Zahlenwerten, alles SI
  pv_thermal_ode.m         rechte Seite von (2.1)
  calc_w_el.m              (2.3)
  calc_h_conv.m            (2.4)  <- Erweiterungspunkt für Nusselt
  calc_q_rad.m             (2.6)
  calc_errors.m            MAE, RMSE, MBE
  build_weather_struct.m   griddedInterpolant für G, T_amb, v
  load_weather_paper.m     Validierungsdaten (aktuell Platzhalter!)
  load_weather_geosphere.m Messdaten Anwendungsfall
  run_validation.m         rechnet -> results/validation.mat
  run_usecase.m            rechnet -> results/usecase.mat
  run_sensitivity.m        rechnet -> results/sensitivity.mat
  plot_*.m                 laden nur, rechnen nicht
  fig_style.m              einheitliche Darstellung
  save_figure.m            Export als Vektor-PDF, 15 x 8 cm
  run_all.m                Steuerung über Flags
latex/
  main.tex, kapitel/01..10 + A_anhang, literatur.bib
```

**Coderegeln, die eingehalten werden müssen:**

1. Keine Zahlenwerte außerhalb von `init_parameters.m`.
2. Rechnen und Plotten getrennt, Austausch über `.mat` in `results/`.
3. Alles SI, Temperaturen intern in Kelvin, Umrechnung erst beim Plotten.
4. Jede Gleichung im Code trägt die Nummer aus dem Protokoll (`% Gl. (2.3)`).
5. Sprechende Variablennamen.
6. Eine Datei, ein Zweck. Über etwa 100 Zeilen steckt eine Funktion zu viel drin.
7. Keine anonymen Funktionen mit Logik darin.
8. Vektorisierung nur wo sie spürbar hilft. Lesbarkeit schlägt Eleganz.
9. Kein `clear` in den `run_*` und `plot_*` Skripten, sonst löscht es die
   Flags von `run_all` aus dem Workspace.

**Regel 8 ist wichtig für die KI-Nutzung.** Wir hatten in einem früheren
Projekt das Problem, dass zu clever gearbeitet wurde und der Code hinterher
nicht mehr nachvollziehbar war. Wenn du eine KI um Code bittest, sag ihr
ausdrücklich: einfache, explizite Lösung, keine cleveren Konstruktionen,
Kommentare auf Deutsch, Gleichungsnummern mitführen.

---

## 5. Protokollstruktur

1. Einleitung und Aufgabenstellung
2. Modellbildung (Systemabgrenzung, Bilanz, Zustandswahl, Teilmodelle,
   **Annahmentabelle**)
3. Modellparameter (Recherche, Parametertabelle mit Quellen)
4. Numerische Umsetzung (Programmstruktur, Solverwahl, Interpolation)
5. Validierung (Fehlermaße, Ergebnisse, Diskussion der Abweichungen)
6. Anwendungsfall (Datengrundlage, Ergebnisse, dominanter Verlustterm)
7. Sensitivitätsanalyse
8. Simulink und Batterieladung
9. Diskussion und Grenzen des Modells
10. Verwendung von KI-Werkzeugen

Jedes Kapitel eine eigene Datei unter `kapitel/`, damit vier Leute
gleichzeitig in Overleaf arbeiten können.

**Vorgaben für Abbildungen** (aus den Protokolltipps der LVA):
Achsenbeschriftung mit Einheiten, Legenden sauber beschriftet,
unterschiedliche Linienarten statt nur Farben, Schriftgröße passend zur
Plotgröße, Vektorgrafik, keine Simulink-Scopes, keine Redundanz zwischen
Titel, Achsenbeschriftung und Bildunterschrift. Die Bildunterschrift muss die
Abbildung allein verständlich machen und die Kernaussage benennen.

**KI-Nutzung ist ausdrücklich erlaubt** und muss nicht verschleiert werden.
Kapitel 10 dokumentiert, welche Werkzeuge wofür eingesetzt wurden und vor
allem **wie die Ergebnisse geprüft wurden**. Jede übernommene Formel wird
gegen die Primärquelle geprüft, jeder Parameter gegen die zitierte Arbeit.

---

## 6. Aktueller Stand

**Fertig:** Gerüst steht, MATLAB läuft durch, LaTeX kompiliert, Repo und
Overleaf sind aufgesetzt.

**Offen:**

- `load_weather_paper.m` liefert noch synthetische Platzhalterdaten (mit
  Warnung). Muss durch die digitalisierten Werte aus Tuncel Abb. 1 ersetzt
  werden.
- GeoSphere-Daten (24.06. bis 01.07.2019, 10-Minuten-Werte) beschaffen und
  in `load_weather_geosphere.m` die Spaltennamen anpassen.
- Alle mit `TODO Quelle` markierten Parameter belegen (Aufgabenpunkt 3).
- Umgebungstemperatur für die Validierung festlegen, das Paper macht dazu
  keine Angabe.
- Schichtaufbau für C_m mit Quellen hinterlegen.
- Simulink-Modell und Batteriekopplung.
- Alle Kapitel des Protokolls sind Gerüste mit Kommentaren, noch kein Text.

**Offener Diskussionspunkt für Kapitel 7:** Tuncel et al. finden bei
Stundenwerten praktisch keinen Einfluss der Wärmekapazität und schließen
daraus, dass stationäre Rechnung genügen würde. Herteleer et al. argumentieren
für Sekunden- bis Minutenauflösung über die Zeitkonstante tau = R_eq * C_eq
von einigen hundert Sekunden. Mit 10-Minuten-Daten liegen wir dazwischen. Wo
unser Ergebnis landet, ist ein gutes Resultat für die Sensitivitätsanalyse.

---

## 7. Wie du mit einer KI arbeitest

Was gut funktioniert: Formulierungsvorschläge für Protokollkapitel,
Literaturhinweise nachschlagen, Fehlersuche im Code, Erklärungen zu
Vorlesungsinhalten, Gegenlesen auf Verständlichkeit.

Was du kontrollieren musst: **jede Zahl, jede Formel, jede Quellenangabe.**
Erfundene Literaturstellen sind ein bekanntes Problem. Wenn die KI eine Quelle
nennt, such sie selbst und schau hinein, bevor sie in `literatur.bib` landet.

Was nicht passieren darf: Code oder Text übernehmen, den du nicht erklären
kannst. Am Ende präsentieren wir zu viert, und jeder muss jeden Teil
verteidigen können. Wenn du eine Antwort nicht verstehst, frag nach, bis du
sie verstehst, statt sie einzubauen.

Nützlicher Zusatz beim Prompten: "Schreib eine einfache, explizite Lösung.
Keine cleveren Konstruktionen. Kommentare auf Deutsch. Halte dich an die
Coderegeln aus dem Kontextdokument."
