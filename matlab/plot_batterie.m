% plot_batterie.m
% Ladeverlauf der Batterie ueber den Anwendungsfall (Kapitel 8.2).
% Plottet NUR, Daten aus results/simulink_usecase.mat.

close all;
fig_style();

daten = load(fullfile('results', 'simulink_usecase.mat'));
res   = daten.res;

t_tage = res.t / 86400;                  % [d]
P_lade = res.P_charge;                   % [W]

% Der Integrator begrenzt nur seinen Ausgang, sein Eingang laeuft weiter.
% Fuer die Darstellung wird die Ladeleistung ab Erreichen der
% Ladeschlussgrenze auf null gesetzt.
P_lade(res.SoC >= 1 - 1e-6) = 0;

fig = figure('Units', 'centimeters', 'Position', [2 2 16 11]);

ax1 = subplot(2,1,1);
plot(t_tage, res.SoC, 'k-');
hold on; yline(1, 'k--', 'LineWidth', 1.0); hold off;
ylabel('$\mathrm{SoC}$ [--]');
ylim([0 1.08]); xlim([0 t_tage(end)]);
xticks(0:1:floor(t_tage(end)));

idx = find(res.SoC >= 1 - 1e-6, 1);
if ~isempty(idx)
    hold on;
    plot(t_tage(idx), res.SoC(idx), 'ko', 'MarkerFaceColor', 'k', ...
         'MarkerSize', 4);
    text(t_tage(idx) + 0.12, 0.94, ...
         sprintf('Ladeschlussgrenze bei $t = %.1f$\\,d', t_tage(idx)), ...
         'FontSize', 9, 'VerticalAlignment', 'top');
    hold off;
end

ax2 = subplot(2,1,2);
plot(t_tage, P_lade, 'k-');
xlabel('Zeit [d]');
ylabel('$P_\mathrm{lade}$ [W]');
xlim([0 t_tage(end)]); ylim([0 max(P_lade)*1.1]);
xticks(0:1:floor(t_tage(end)));

linkaxes([ax1 ax2], 'x');

if ~isfolder('abbildungen'); mkdir('abbildungen'); end
exportgraphics(fig, fullfile('abbildungen','batterie_ladung.pdf'), ...
               'ContentType', 'vector');

fprintf('SoC Start %.3f, Ende %.3f\n', res.SoC(1), res.SoC(end));
if ~isempty(idx)
    fprintf('Ladeschlussgrenze nach %.2f d (%.1f h)\n', ...
            t_tage(idx), res.t(idx)/3600);
end
fprintf('max. Ladeleistung %.1f W\n', max(P_lade));