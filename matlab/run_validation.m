%RUN_VALIDATION  Aufgabenpunkt 4: Validierung gegen die Paperdaten.
%
%   Rechnet NUR. Ergebnis landet in results/validation.mat.
%   Geplottet wird in plot_validation.m.

close all;

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

% ---------------------------------------------------------------------
% Gemessene Modultemperatur Tm_mess, digitalisiert aus Tuncel et al. 2020,
% Abb. 1a (blaue Kurve "Tm, measured"). Vorgehen: Seite als Bild
% gerendert, Achsenkalibrierung über die Pixelposition der Achsenbox
% bestimmt, Kurve per Farbklassifizierung (Blauton der Messkurve vs.
% Orangeton der Schaetzkurve, graue Deviation-Balken ausgeschlossen)
% pixelweise extrahiert und auf ein Stundenraster (0-120 h) gebracht.
% Genauigkeit: Grafikaufloesung des Papers (~150-300 dpi), Schaetzung
% +/- 0.5-1 K je Punkt - fuer Fehlermetriken (MAE/RMSE) ausreichend
% genau, aber KEINE Presiongarantie wie bei Original-Rohdaten.
% WICHTIG (siehe annahmen.md): Die zugehoerigen Wetter-Eingangsdaten
% (G, Tamb, v in load_weather_paper.m) sind selbst eine Annahme
% (Option B) und keine Messung - die Fehlermetrik unten spiegelt daher
% Modellfehler UND Wetterannahme-Fehler zusammen, nicht trennbar.
% ---------------------------------------------------------------------
h_mess = (0:120)';   % Stunden seit Beginn
Tm_mess_h = [ ...     % [K], digitalisiert aus Abb. 1a, Stundenraster
    287.21, 287.21, 287.21, 287.21, 287.21, 287.41, 287.80, 287.70, ...
    287.31, 286.32, 286.77, 291.03, 295.34, 302.59, 309.98, 311.86, ...
    311.66, 312.46, 311.62, 307.86, 309.87, 303.74, 297.39, 293.50, ...
    290.42, 288.66, 287.11, 286.32, 285.72, 284.93, 284.14, 284.04, ...
    284.66, 290.12, 299.70, 309.57, 317.83, 319.29, 317.88, 316.03, ...
    314.04, 317.78, 314.90, 307.34, 301.64, 295.43, 293.50, 291.43, ...
    289.57, 288.20, 286.81, 286.66, 286.22, 285.23, 285.73, 288.96, ...
    299.33, 311.11, 317.34, 324.01, 327.06, 327.17, 325.70, 320.05, ...
    315.26, 308.78, 301.38, 296.61, 294.18, 293.15, 292.64, 290.10, ...
    289.13, 286.45, 285.72, 285.13, 285.79, 290.69, 298.58, 310.16, ...
    316.25, 321.45, 323.84, 322.41, 321.95, 318.79, 313.64, 308.36, ...
    302.91, 299.36, 296.49, 295.32, 292.98, 291.88, 289.58, 289.23, ...
    288.06, 286.84, 287.12, 289.98, 300.36, 313.54, 319.42, 327.07, ...
    327.90, 327.20, 326.32, 322.22, 316.34, 310.85, 305.29, 300.46, ...
    297.38, 296.32, 294.32, 293.74, 293.74, 293.74, 293.74, 293.74, ...
    293.74 ]';

Tm_mess = interp1(h_mess*3600, Tm_mess_h, t, 'linear', 'extrap');
fehler  = calc_errors(Tm, Tm_mess);

if ~exist('results', 'dir'); mkdir('results'); end
save(fullfile('results', 'validation.mat'), ...
     't', 'Tm', 'Tamb', 'G', 'W_el', 'Tm_mess', 'fehler', 'p');

fprintf('run_validation fertig. %d Zeitschritte, Tm_max = %.1f degC\n', ...
        numel(t), max(Tm) - 273.15);
