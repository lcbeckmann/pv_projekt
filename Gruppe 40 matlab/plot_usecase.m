%PLOT_USECASE  Abbildungen zu Aufgabenpunkt 5.

close all;
fig_style();

load(fullfile('results', 'usecase.mat'));
t_h = t / 3600; %Umrechnung in h für achsenbeschr.

% --- Temperaturverlauf in °C -----------------------------------
f1 = figure;
plot(t_h, Tm   - 273.15, '-',  'DisplayName', '$T_\mathrm{m}$'); hold on;
plot(t_h, Tamb - 273.15, '--', 'DisplayName', '$T_\mathrm{optimal}$');
yline(25, ':', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.5, 'HandleVisibility', 'off');% Referenzlinien bei 25°C
xlabel('Zeit in h');
ylabel('Temperatur in $^\circ$C');
legend('Location', 'northeastoutside');
f1.Position(3) = f1.Position(3) * 1.25;
save_figure(f1, 'anwendungsfall_temperatur');

% --- Einzelterme der Waermebilanz ------------------------
f2 = figure;
plot(t_h, Q_solar,    '-',  'DisplayName', '$Q_\mathrm{solar}$'); hold on;
plot(t_h, W_el,       '--', 'DisplayName', '$W_\mathrm{el}$');
plot(t_h, Q_konv,     '-.', 'DisplayName', '$Q_\mathrm{konv}$');
plot(t_h, Q_rad,      ':',  'DisplayName', '$Q_\mathrm{rad}$');
plot(t_h, Q_speicher, '-',  'DisplayName', '$C_\mathrm{m}\dot{T}_\mathrm{m}$');
xlabel('Zeit in h');
ylabel('Leistung in W');
legend('Location', 'northeastoutside', 'NumColumns', 1);
f2.Position(3) = f2.Position(3) * 1.35;   %breiter fuer mehr eintraege
save_figure(f2, 'anwendungsfall_bilanz');

% --- Energieanteile ueber den gesamten Zeitraum ----------
f3 = figure;
namen = {'Elektrisch genutzt', 'Verlust Konvektion', 'Verlust Strahlung'};
werte = [energie.el, energie.konv, energie.rad] / energie.solar * 100;
x_pos = [1, 3, 5];              %  groesserer Abstand zwischen den Balken
b = bar(x_pos, werte, 0.5);
xlim([0, 6]);
set(gca, 'XTick', [], 'XTickLabel', {});   % automatische Beschriftung abschalten
ylabel('Anteile der Einstrahlung in \%');
ylim([0, max(werte) * 1.15]);
% Prozentwerte ueber den Balken
xtips = b.XEndPoints;
ytips = b.YEndPoints;
labels = compose('%.1f\\%%', werte);
text(xtips, ytips, labels, 'HorizontalAlignment', 'center','VerticalAlignment', 'bottom');
% Kategorienamen manuell unter den Balken platzieren
y_label_pos = -0.04 * max(werte);
text(x_pos, repmat(y_label_pos, size(x_pos)), namen,'HorizontalAlignment', 'center', 'VerticalAlignment', 'top','Clipping', 'off');

save_figure(f3, 'anwendungsfall_energieanteile');