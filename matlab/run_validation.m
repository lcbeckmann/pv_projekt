%RUN_VALIDATION  Aufgabenpunkt 4: Validierung gegen die Paperdaten.
%
%   Rechnet NUR. Ergebnis landet in results/validation.mat.
%   Geplottet wird in plot_validation.m.

clear; close all;

p = init_parameters();
w = load_weather_paper();

tspan = [0, w.t_end];
T0    = w.Tamb(0);           % Start im thermischen Gleichgewicht mit der Luft
opts  = odeset('RelTol', p.RelTol, 'AbsTol', p.AbsTol);

[t, Tm] = ode45(@(t, T) pv_thermal_ode(t, T, p, w), tspan, T0, opts);

% Nachgelagerte Groessen (kein Zustand, daher hier und nicht in der ODE)
G     = w.G(t);
Tamb  = w.Tamb(t);
W_el  = calc_w_el(G, Tm, p);

% Fehlermasse: erst sinnvoll, wenn die Messwerte aus dem Paper vorliegen
Tm_mess = nan(size(t));      % TODO digitalisierte Messwerte einsetzen
fehler  = calc_errors(Tm, Tm_mess);

if ~exist('results', 'dir'); mkdir('results'); end
save(fullfile('results', 'validation.mat'), ...
     't', 'Tm', 'Tamb', 'G', 'W_el', 'Tm_mess', 'fehler', 'p');

fprintf('run_validation fertig. %d Zeitschritte, Tm_max = %.1f degC\n', ...
        numel(t), max(Tm) - 273.15);
