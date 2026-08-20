%PLOT_SENSITIVITY  Abbildungen zu Aufgabenpunkt 6.

close all;
fig_style();

load(fullfile('results', 'sensitivity.mat'));

namen = fieldnames(ergebnis);

for k = 1:numel(namen)
    name = namen{k};
    d    = ergebnis.(name);

    % Relative Aenderung gegenueber dem Nominalfall. Der Bezugswert wird aus
    % dem in run_sensitivity mitgeschriebenen Nominalwert bestimmt, nicht aus
    % der Mitte der Reihe: bei A_conv liegt der Nominalfall am oberen Rand
    % (beidseitig umstroemt), bei eps_front zwischen zwei Stuetzstellen.
    [~, i_nom] = min(abs(d.werte - d.nominal));
    x_rel      = d.werte / d.nominal;

    f = figure;
    yyaxis left;
    plot(x_rel, d.Tm_max - 273.15, '-o');
    ylabel('$T_\mathrm{m,max}$ in $^\circ$C');

    yyaxis right;
    plot(x_rel, d.E_el / d.E_el(i_nom) * 100, '--s');
    ylabel('Energieertrag in \% vom Nominalfall');

    xlabel(sprintf('%s bezogen auf Nominalwert', strrep(name, '_', '\_')));
    save_figure(f, ['sensitivitaet_' name]);
end
