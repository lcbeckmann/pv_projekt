%PLOT_USECASE  Abbildungen zu Aufgabenpunkt 5.

close all;
fig_style();

load(fullfile('results', 'usecase.mat'));
t_h = t / 3600;

% --- Abbildung 1: Temperaturverlauf -----------------------------------
f1 = figure;
plot(t_h, Tm   - 273.15, '-',  'DisplayName', '$T_\mathrm{m}$'); hold on;
plot(t_h, Tamb - 273.15, '--', 'DisplayName', '$T_\mathrm{amb}$');
% Referenzlinien bei 20°C und 25°C
yline(20, ':', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
yline(25, ':', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
xlabel('Zeit in h');
ylabel('Temperatur in $^\circ$C');
legend('Location', 'northeastoutside');   % Legende ausserhalb, verdeckt nichts
f1.Position(3) = f1.Position(3) * 1.25;   % Abbildung verbreitern fuer die Legende
save_figure(f1, 'anwendungsfall_temperatur');

% --- Abbildung 2: Einzelterme der Waermebilanz ------------------------
% Diese Abbildung beantwortet die Frage nach dem dominanten Verlustterm.
f2 = figure;
plot(t_h, Q_solar,    '-',  'DisplayName', '$Q_\mathrm{solar}$'); hold on;
plot(t_h, W_el,       '--', 'DisplayName', '$W_\mathrm{el}$');
plot(t_h, Q_konv,     '-.', 'DisplayName', '$Q_\mathrm{konv}$');
plot(t_h, Q_rad,      ':',  'DisplayName', '$Q_\mathrm{rad}$');
plot(t_h, Q_speicher, '-',  'DisplayName', '$C_\mathrm{m}\dot{T}_\mathrm{m}$');
xlabel('Zeit in h');
ylabel('Leistung in W');
legend('Location', 'northeastoutside', 'NumColumns', 1);  % 1 Spalte = schmaler, ausserhalb
f2.Position(3) = f2.Position(3) * 1.35;   % mehr Breite: 5 Eintraege brauchen Platz
save_figure(f2, 'anwendungsfall_bilanz');

% --- Abbildung 3: Energieanteile ueber den gesamten Zeitraum ----------
f3 = figure;
namen  = {'elektrisch', 'Konvektion', 'Strahlung'};
werte  = [energie.el, energie.konv, energie.rad] / energie.solar * 100;
bar(categorical(namen, namen), werte);
ylabel('Anteil an der Einstrahlung in \%');
save_figure(f3, 'anwendungsfall_energieanteile');
