%PLOT_VALIDATION  Abbildungen zu Aufgabenpunkt 4.
%
%   Laedt nur die gespeicherten Ergebnisse. Die Simulation laeuft dabei
%   NICHT erneut. Wer die Optik aendern will, ruft nur dieses Skript auf.

close all;
fig_style();

load(fullfile('results', 'validation.mat'));

t_h = t / 3600;      % Stunden, angenehmer zu lesen als Sekunden

% --- Abbildung 1: Modul- und Umgebungstemperatur -----------------------
f1 = figure;
plot(t_h, Tm   - 273.15, '-',  'DisplayName', 'Modell $T_\mathrm{m}$'); hold on;
plot(t_h, Tamb - 273.15, '--', 'DisplayName', 'Umgebung $T_\mathrm{amb}$');
if any(~isnan(Tm_mess))
    plot(t_h, Tm_mess - 273.15, ':', 'DisplayName', 'Messung Paper');
end
xlabel('Zeit in h');
ylabel('Temperatur in $^\circ$C');
legend('Location', 'best');
save_figure(f1, 'validierung_temperatur');

% --- Abbildung 2: Residuum --------------------------------------------
% Kein title() ueber dem Plot: die Protokolltipps der LVA verlangen, dass
% die Kernaussage in der Bildunterschrift steht und sich nicht zwischen
% Titel, Achsenbeschriftung und Caption wiederholt. Die Fehlermasse werden
% deshalb auf die Konsole ausgegeben und von dort in die Caption des
% Protokolls uebernommen.
if any(~isnan(Tm_mess))
    f2 = figure;
    plot(t_h, Tm - Tm_mess, '-');
    yline(0, 'k--', 'HandleVisibility', 'off');
    xlabel('Zeit in h');
    ylabel('Abweichung in K');
    save_figure(f2, 'validierung_residuum');

    fprintf(['Fuer die Bildunterschrift: MAE %.2f K, RMSE %.2f K, ' ...
             'MBE %+.2f K (tagsueber: MAE %.2f K, MBE %+.2f K).\n'], ...
            fehler.MAE, fehler.RMSE, fehler.MBE, ...
            fehler.tag.MAE, fehler.tag.MBE);
end
