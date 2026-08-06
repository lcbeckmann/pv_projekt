function fig_style()
%FIG_STYLE  Einheitliches Aussehen aller Abbildungen.
%
%   Einmal am Anfang jedes plot_*-Skripts aufrufen. Damit gelten die
%   Einstellungen fuer alle danach erzeugten Figures.
%
%   Hintergrund: die Protokolltipps der LVA kritisieren genau diese
%   Punkte, zu kleine Schrift, fehlende Achsenbeschriftung, nur ueber
%   Farbe unterscheidbare Linien.

set(groot, 'defaultAxesFontSize',      11);
set(groot, 'defaultTextFontSize',      11);
set(groot, 'defaultLineLineWidth',    1.4);
set(groot, 'defaultAxesLineWidth',    0.8);
set(groot, 'defaultAxesBox',          'on');
set(groot, 'defaultAxesXGrid',        'on');
set(groot, 'defaultAxesYGrid',        'on');
set(groot, 'defaultFigureColor',      'w');
set(groot, 'defaultAxesTickLabelInterpreter', 'latex');
set(groot, 'defaultTextInterpreter',          'latex');
set(groot, 'defaultLegendInterpreter',        'latex');

end
