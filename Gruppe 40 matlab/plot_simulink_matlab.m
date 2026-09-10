% plot_simulink_matlab.m
% Vergleich Simulink gegen MATLAB-Kern ueber den Anwendungsfall (Kap. 8.3).
% Plottet NUR, Daten aus results/.

close all;
fig_style();

ml = load(fullfile('results','usecase.mat'));
sl = load(fullfile('results','simulink_usecase.mat'));

% Beide Loesungen liegen auf unterschiedlichen Zeitgittern, weil ode45 die
% Schritte selbst waehlt. Fuer die Differenz muss auf ein gemeinsames
% Raster interpoliert werden; gewaehlt wird die Aufloesung der Rohdaten.
t_vgl = (0 : 600 : sl.w.t_end)';
Tm_sl = interp1(sl.res.t, sl.res.Tm, t_vgl);
Tm_ml = interp1(ml.t,     ml.Tm,     t_vgl);
d     = Tm_sl - Tm_ml;

t_tage = t_vgl / 86400;

fig = figure('Units','centimeters','Position',[2 2 16 11]);

% oben: beide Verlaeufe
ax1 = subplot(2,1,1);
plot(t_tage, Tm_ml - 273.15, 'k-');
hold on;
plot(t_tage, Tm_sl - 273.15, 'k--');
hold off;
ylabel('$T_\mathrm{m}$ [$^\circ$C]');
xlim([0 t_tage(end)]);
xticks(0:1:floor(t_tage(end)));
legend({'MATLAB','Simulink'}, 'Location','northeast');

% unten: Differenz
ax2 = subplot(2,1,2);
plot(t_tage, d*1000, 'k-');
xlabel('Zeit [d]');
ylabel('$\Delta T_\mathrm{m}$ [mK]');
xlim([0 t_tage(end)]);
ylim([-150 150]);
xticks(0:1:floor(t_tage(end)));

linkaxes([ax1 ax2],'x');

if ~isfolder('figures'); mkdir('figures\'); end
exportgraphics(fig, fullfile('figures/','vergleich_simulink_matlab.pdf'), ...
               'ContentType','vector');

fprintf('max |dTm| = %.4f K\n', max(abs(d)));
fprintf('RMS       = %.4f K\n', rms(d));
fprintf('Startwert Simulink %.2f K, MATLAB %.2f K\n', Tm_sl(1), Tm_ml(1));