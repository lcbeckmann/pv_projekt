%PLOT_SENSITIVITY  Abbildungen zu Aufgabenpunkt 6.

close all;
fig_style();

load(fullfile('results', 'sensitivity.mat'));

namen = fieldnames(ergebnis);

for k = 1:numel(namen)
    name = namen{k};
    d    = ergebnis.(name);

    % relative Aenderung gegenueber dem Nominalfall (mittlerer Wert)
    i_nom  = ceil(numel(d.werte)/2);
    x_rel  = d.werte / d.werte(i_nom);

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
