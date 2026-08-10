# Startsitzung PV-Modellierung

**Datum:** ______  **Ort:** ______  **Dauer:** 90 Minuten
**Protokoll tippt:** ______ (schreibt live in `doku/annahmen.md` mit)

**Ziel der Sitzung:** Am Ende steht eine ausgefüllte Annahmentabelle und jeder
weiß, was er bis wann macht. Alles andere ist Beiwerk.

**Mitbringen:** Angabe, `Projektvorgehen.pdf`, Laptop mit MATLAB und Zugang zum
Repo. Wer beim Klonen noch Probleme hat, meldet sich bitte vorher, nicht in der
Sitzung.

---

## 1. Rollen bestätigen (10 min)

Nur zuordnen, nicht diskutieren. Widerspruch klärt sich in zwei Minuten.

| Rolle | Wer |
|---|---|
| Parameterrecherche und Parametertabelle |Tom |
| MATLAB-Kern und Validierung | |
| GeoSphere-Daten, Anwendungsfall, Sensitivität | |
| Simulink und Batteriemodell | |
| Schlusswort über die Protokollstruktur | |

Der MATLAB-Kern wird von einer Person geschrieben. Wer etwas daran braucht,
sagt es dieser Person.

---

## 2. Modellgleichung gemeinsam durchgehen (30 min)

Einer erklärt, alle stellen Fragen. Am Ende muss jeder die Gleichung an der
Tafel herleiten können, auch wer sie nicht implementiert.

    C_m * dT_m/dt = Q_solar - W_el - Q_konv - Q_rad

Punkte, die jeder verstanden haben muss:

- Warum genau **ein** Zustand? Ein unabhängiger Energiespeicher, die
  Wärmekapazität. Die Ordnung folgt aus der Physik, nicht aus einer Wahl.
- Warum ist das überhaupt eine DGL? Weil W_el von T_m abhängt. Ohne diese
  Rückkopplung wäre T_m eine explizite Formel.
- Was ist der Bilanzraum? Das Modul ohne Rahmen.
- Welche Terme fehlen, und warum ist das vertretbar?

**Zu klären:** Passt die Systemgrenze so, oder will jemand etwas anders
schneiden?

---

## 3. Annahmen festlegen (25 min)

Der eigentliche Kern der Sitzung. Jede Entscheidung geht sofort in
`annahmen.md`, mit Begründung und erwarteter Auswirkung.

### Die vier Entscheidungen, die heute fallen müssen

**a) Welches Modul nehmen wir an?**
Fläche, Wirkungsgrad, Temperaturkoeffizient. Entweder die Werte aus dem
Tuncel-Paper oder ein reales Datenblatt.
Empfehlung: Paper, weil wir dann validieren können.
→ Entscheidung: ______

**b) Neigung, Ausrichtung, Strahlungsebene.**
Nehmen wir die Globalstrahlung horizontal, wie GeoSphere sie liefert, oder
rechnen wir auf Modulebene um? Direkt zu verwenden ist zulässig, ist aber eine
Annahme und gehört in die Tabelle.
→ Entscheidung: ______

**c) Welche Umgebungstemperatur für die Validierung?**
Das Tuncel-Paper macht dazu keine Angabe. Wir brauchen einen Wert und eine
Begründung.
→ Entscheidung: ______

**d) Welche GeoSphere-Station?**
Mit Begründung, die später ins Protokoll kann.
→ Entscheidung: ______

### Bereits vorgeschlagen, bitte bestätigen oder widersprechen

- Basismodell (lineare Konvektion) statt Nusselt-Ansatz
- Modul als ein Temperaturknoten, Wärmeleitung vernachlässigt
- Bodentemperatur gleich Umgebungstemperatur
- Himmelstemperatur nach Swinbank
- ode45 mit RelTol = AbsTol = 1e-6

**Nicht diskutieren:** ob wir doch den Nusselt-Ansatz nehmen. Die Erweiterung
ist genau eine Datei (`calc_h_conv.m`). Wenn am Ende Zeit übrig ist, machen wir
es dann.

---

## 4. Offene Punkte verteilen (15 min)

Jeder Punkt bekommt einen Namen und ein Datum. Ohne Datum passiert nichts.

| Was | Wer | Bis wann |
|---|---|---|
| GeoSphere-Daten herunterladen (24.06.–01.07.2019, 10-min-Werte) | | |
| Zeitzone und Datenlücken klären | | |
| Paperdaten aus Tuncel Abb. 1 digitalisieren | | |
| Alle `TODO Quelle` in `init_parameters.m` belegen | | |
| Schichtaufbau für C_m mit Quellen hinterlegen | | |
| Batteriemodell von der LVA besorgen | | |
| Simulink Onramp durcharbeiten | | |
| Ablage für Papers und Folien anlegen | | |

---

## 5. Zwischentermine setzen (10 min)

Ein Abgabedatum allein reicht nicht.

| Meilenstein | Datum |
|---|---|
| Daten da, Parameter belegt, MATLAB rechnet mit echten Zahlen | |
| Validierung fertig inklusive Fehlermaßen | |
| Anwendungsfall gerechnet, Simulink läuft | |
| Sensitivitätsanalyse fertig, alle Abbildungen final | |
| Protokoll komplett, Gegenlesen abgeschlossen | |
| Präsentation fertig | |
| **Abgabe** | |

Nächstes Treffen: ______

---

## Arbeitsregeln kurz ansprechen (5 min, falls Zeit)

Steht alles im `Projektvorgehen.pdf`, hier nur die drei, die man täglich
braucht:

1. Vor dem Arbeiten in GitHub Desktop **Pull**, danach **Commit** und **Push**.
   Am selben Tag, nicht am Wochenende.
2. Keine Zahlen außerhalb von `init_parameters.m`. Rechnen und Plotten bleiben
   getrennt.
3. Neue Annahme im Code heißt neue Zeile in `annahmen.md`. Sofort, nicht am
   Schluss. Am Ende kann niemand mehr rekonstruieren, warum wir in Woche eins
   die Bodentemperatur gleich der Lufttemperatur gesetzt haben.

Das Protokoll wird nicht danach bewertet, ob die Kurve stimmt, sondern ob wir
begründen können, warum wir sie so gerechnet haben.

---

## Ergebnis der Sitzung

- [ ] Rollen zugeordnet
- [ ] Annahmentabelle in `annahmen.md` ausgefüllt und gepusht
- [ ] Vier offene Entscheidungen (a bis d) getroffen
- [ ] Aufgaben mit Namen und Datum verteilt
- [ ] Zwischentermine im Kalender
