# Protokoll, LaTeX-Teil

## Arbeiten in Overleaf

Jedes Kapitel ist eine eigene Datei in `kapitel/`. Alle bearbeiten
gleichzeitig, aber jeder bleibt in seiner Datei. Wer in `main.tex` etwas
aendert, sagt kurz Bescheid.

Ganz oben in jeder Kapiteldatei steht ein Kommentarblock mit `VERANTWORTLICH:`.
Dort den Namen eintragen.

## Regeln

1. Einheiten immer ueber `siunitx`, also `\SI{25}{\celsius}` statt `25 °C`.
2. Symbole ueber die Makros aus `main.tex` setzen, damit alle dasselbe
   schreiben: `\Tm`, `\Tamb`, `\Cm`, `\Qkonv` und so weiter.
3. Jede Gleichung bekommt ein `\label{eq:...}`. Die gleiche Nummer wird im
   MATLAB-Code als Kommentar gesetzt.
4. Querverweise ueber `\cref{}`, nicht von Hand.
5. Abbildungen aus `../matlab/figures/` einbinden, nicht von Hand kopieren.
   Der Pfad ist ueber `\graphicspath` schon gesetzt.

## Abbildungen

Die Protokolltipps der LVA kritisieren konkret:

- fehlende Achsenbeschriftung und Einheiten
- zu kleine Schrift, zu kleine Plots
- gleiche Linienart fuer alle Kurven
- Simulink-Scopes im Protokoll
- Redundanz zwischen Titel, Achsenbeschriftung und Bildunterschrift
- nichtssagende Bildunterschriften

Die Bildunterschrift muss die Abbildung allein verstaendlich machen und die
Kernaussage benennen. Kein Plottitel, wenn die Caption dasselbe sagt.

## Kompilieren

pdflatex, bibtex, pdflatex, pdflatex. In Overleaf reicht der Compile-Button.
