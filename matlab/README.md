# MATLAB-Teil, PV-Modellierung

## Grundregeln

1. Keine Zahlenwerte ausserhalb von `init_parameters.m`.
2. Rechnen und Plotten sind getrennt. `run_*.m` speichert nach `results/`,
   `plot_*.m` laedt von dort. Wer nur die Optik aendert, startet keine Simulation neu.
3. Alles in SI, Temperaturen intern in Kelvin. Umrechnung erst beim Plotten.
4. Jede Gleichung im Code traegt die Nummer aus dem Protokoll, z.B. `% Gl. (2.3)`.
5. Eine Datei, ein Zweck. Ueber etwa 100 Zeilen ist meist eine Funktion zu viel drin.

## Reihenfolge

```matlab
run_all          % Flags im Kopf der Datei setzen
```

oder einzeln:

```matlab
run_validation   % -> results/validation.mat
plot_validation  % -> figures/*.pdf
```

## Was noch fehlt

- `load_weather_paper.m`: synthetische Platzhalterdaten, muessen durch die
  digitalisierten Werte aus Tuncel et al. Abb. 1 ersetzt werden.
- `load_weather_geosphere.m`: Spaltennamen an den tatsaechlichen CSV-Export anpassen,
  Datei nach `data/geosphere_2019.csv` legen.
- Alle mit `TODO Quelle` markierten Parameter belegen (Aufgabenpunkt 3).
- Simulink-Modell in `simulink/`.

## Erweiterungspunkt

Wer statt des linearen Konvektionsansatzes den Nusselt-Ansatz von Tuncel et al.
will, ersetzt ausschliesslich `calc_h_conv.m`. Der Rest bleibt unberuehrt.
