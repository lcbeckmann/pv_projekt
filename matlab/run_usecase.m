%RUN_USECASE  Aufgabenpunkt 5: Anwendungsfall mit GeoSphere-Daten.
%
%   Rechnet NUR. Ergebnis landet in results/usecase.mat.
%   Zusaetzlich werden die Einzelterme der Bilanz mitgeschrieben, weil die
%   Angabe nach dem dominanten Verlustterm fragt.

close all;

p = init_parameters();
w = load_weather_geosphere();

tspan = [0, w.t_end];
T0    = w.Tamb(0);
opts  = odeset('RelTol', p.RelTol, 'AbsTol', p.AbsTol);

[t, Tm] = ode45(@(t, T) pv_thermal_ode(t, T, p, w), tspan, T0, opts);

% Einzelterme nachrechnen (Postprocessing, nicht im Solver)
G       = w.G(t);
Tamb    = w.Tamb(t);
v       = w.v(t);

Q_solar = p.alpha_abs .* G .* p.A;
W_el    = calc_w_el(G, Tm, p);
Q_konv  = calc_h_conv(v, p) .* p.A_conv .* (Tm - Tamb);
Q_rad   = calc_q_rad(Tm, Tamb, p);
Q_speicher = Q_solar - W_el - Q_konv - Q_rad;   % = C_m * dTm/dt

energie.solar  = trapz(t, Q_solar);
energie.el     = trapz(t, W_el);
energie.konv   = trapz(t, Q_konv);
energie.rad    = trapz(t, Q_rad);

% isfolder statt exist(...,'dir'): exist sucht auch im MATLAB-Suchpfad und
% meldet den Ordner dann als vorhanden, obwohl save relativ zum aktuellen
% Arbeitsverzeichnis schreibt.
if ~isfolder('results'); mkdir('results'); end
save(fullfile('results', 'usecase.mat'), ...
     't', 'Tm', 'Tamb', 'G', 'v', 'W_el', ...
     'Q_solar', 'Q_konv', 'Q_rad', 'Q_speicher', 'energie', 'p', 'w');

fprintf('run_usecase fertig. Energieanteile in kWh:\n');
fprintf('  Einstrahlung %.2f | elektrisch %.2f | Konvektion %.2f | Strahlung %.2f\n', ...
        energie.solar/3.6e6, energie.el/3.6e6, ...
        energie.konv/3.6e6, energie.rad/3.6e6);
