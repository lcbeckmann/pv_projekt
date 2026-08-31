%PLOT_SENSITIVITY  Abbildungen zu Aufgabenpunkt 6.
close all;
fig_style();
load(fullfile('results', 'sensitivity.mat'));
namen = fieldnames(ergebnis);
for k = 1:numel(namen)
    name = namen{k};
    d    = ergebnis.(name);
end
% Tornado-Diagramme: zusammenfassende Darstellung, welcher Parameter
% welche Zielgroesse am staerksten beeinflusst. Fuer jeden Parameter wird
% die Spanne der prozentualen Abweichung vom Nominalergebnis ueber alle
% Testwerte gebildet; die Parameter werden nach dieser Spanne sortiert,
% groesster Einfluss oben.
%
% Wichtig: Die schwebenden Balken werden NICHT durch wiederholte barh()-
% Aufrufe mit individuellem 'BaseValue' in einer Schleife erzeugt. MATLAB
% verwendet fuer mehrere per hold-on uebereinandergelegte Bar-Objekte nur
% eine gemeinsame Baseline pro Achse, die vom zuletzt gezeichneten Balken
% ueberschrieben wird - alle Balken haetten dann denselben, falschen
% linken Rand. Stattdessen wird ein einziger gestapelter barh()-Aufruf
% verwendet: eine unsichtbare erste Serie (Basiswert, kann negativ sein)
% traegt jeden Balken an seine korrekte Position, die zweite, sichtbare
% Serie zeichnet nur die eigentliche Spannweite obendrauf.
%
% Zusaetzliche obere Achse: Die Balken sind in Prozent skaliert, aber die
% absolute Aenderung ist fuer eine physikalische Einordnung oft
% hilfreicher (z.B. 0.75 % von T_m,max in Kelvin klingt klein, entspricht
% aber ca. 2-3 K). Da sich innerhalb eines Tornado-Diagramms alle Balken
% auf denselben Nominalwert beziehen, ist die Umrechnung Prozent ->
% absolute Einheit fuer das gesamte Diagramm eine einzige lineare
% Skalierung. Eine zweite, deckungsgleiche Achse oben (gleiche Position,
% umskaliertes XLim) zeigt daher exakt dieselben Balken zusaetzlich in
% Kelvin bzw. kWh, ohne den Plot zu verdoppeln.
zielgroessen = {'Tm_max', 'E_el'};
zielgroessen_label = {'$T_\mathrm{m,max}$', 'Energieertrag $E_\mathrm{el}$'};
% Referenzwert je Zielgroesse fuer die obere Achse: Da im Nominalfall alle
% Parameter gleichzeitig auf ihrem Nominalwert liegen, ist die Simulation
% an diesem Punkt fuer jede der sechs Studien identisch - es genuegt, den
% Referenzwert aus der ersten Studie (C_m) zu entnehmen.
d_ref            = ergebnis.(namen{1});
[~, i_nom_ref]   = min(abs(d_ref.werte - d_ref.nominal));
referenzwert.Tm_max = d_ref.Tm_max(i_nom_ref);            % [K]
referenzwert.E_el    = d_ref.E_el(i_nom_ref) / 3.6e6;      % [kWh]
einheit_label = struct('Tm_max', 'K', 'E_el', 'kWh');

for z = 1:numel(zielgroessen)
    zielgroesse = zielgroessen{z};
    abweichung_unten = zeros(numel(namen), 1);
    abweichung_oben  = zeros(numel(namen), 1);
for k = 1:numel(namen)
        name = namen{k};
        d    = ergebnis.(name);
        [~, i_nom] = min(abs(d.werte - d.nominal));
        nominalwert = d.(zielgroesse)(i_nom);
        rel_abweichung = (d.(zielgroesse) - nominalwert) / nominalwert * 100;
        abweichung_unten(k) = min(rel_abweichung);
        abweichung_oben(k)  = max(rel_abweichung);
end
% Sortierung nach Spannweite, groesster Einfluss zuoberst im Plot.
    spannweite   = abweichung_oben - abweichung_unten;
    [~, idx]     = sort(spannweite, 'ascend');
    namen_sortiert     = namen(idx);
    abweichung_unten_s = abweichung_unten(idx);
    spannweite_s       = spannweite(idx);
    f = figure;
    b = barh(1:numel(namen_sortiert), [abweichung_unten_s, spannweite_s], 'stacked');
    b(1).FaceColor = 'none';   % unsichtbare Basis, traegt nur die Position
    b(1).EdgeColor = 'none';
    b(2).FaceColor = [0.16 0.47 0.84];
    b(2).EdgeColor = 'none';
    hold on;
    xline(0, 'Color', [0.4 0.4 0.4], 'LineWidth', 0.75);
    yticks(1:numel(namen_sortiert));
    yticklabels(strrep(namen_sortiert, '_', '\_'));
    xlabel(sprintf('Abweichung %s vom Nominalwert in \\%%', zielgroessen_label{z}));
    box on;

    % Obere Achse: gleiche Balken, umgerechnet in absolute Einheit.
    ax_unten = gca;
    ax_unten.Units = 'normalized';
    pos = ax_unten.Position;
    ax_oben = axes('Position', pos, 'Color', 'none', ...
        'XAxisLocation', 'top', 'YAxisLocation', 'right', ...
        'YTick', [], 'YColor', 'none');
    ax_oben.YLim = ax_unten.YLim;
    ax_oben.XLim = ax_unten.XLim / 100 * referenzwert.(zielgroesse);
    xlabel(ax_oben, sprintf('Abweichung %s in %s', ...
        zielgroessen_label{z}, einheit_label.(zielgroesse)));
    linkprop([ax_unten ax_oben], 'Position');
    axes(ax_unten);  % Hauptachse als aktuelle Achse zuruecksetzen

    save_figure(f, ['tornado_' zielgroesse]);
end
