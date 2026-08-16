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

% Farben explizit auf hell setzen. Laeuft MATLAB im Dark Mode, sind
% Achsenflaeche und Beschriftung sonst dunkel und wandern so in das
% exportierte PDF. Im gedruckten Protokoll ist das unbrauchbar.
set(groot, 'defaultAxesColor',        'w');
set(groot, 'defaultAxesXColor',       'k');
set(groot, 'defaultAxesYColor',       'k');
set(groot, 'defaultAxesGridColor',    'k');
set(groot, 'defaultTextColor',        'k');
set(groot, 'defaultLegendColor',      'w');
set(groot, 'defaultLegendEdgeColor',  'k');
set(groot, 'defaultLegendTextColor',  'k');
set(groot, 'defaultAxesTickLabelInterpreter', 'latex');
set(groot, 'defaultTextInterpreter',          'latex');
set(groot, 'defaultLegendInterpreter',        'latex');

end
