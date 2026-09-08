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

% Digitalisiert aus Tuncel et al. 2020, Abb. 1a.
%
% Vorgehen: Achsenkalibrierung ueber den Rahmen der Zeichenflaeche
% (senkrechte Rahmenlinien = 0 h und 120 h, rechte Ordinate 10 degC unten
% bis 60 degC oben). Die beiden Kurven wurden ueber ihre Farbe getrennt
% (Blau = Messung, Orange = Modell des Papers), die grauen Balken der
% Abweichungsdarstellung und der Legendenbereich ausgeschlossen. Je
% Bildspalte wurde die mittlere Zeile der zugehoerigen Pixel bestimmt und
% auf ein Stundenraster interpoliert.
%
% Aufloesung der Vorlage: 8,75 Pixel je Stunde, 0,083 K je Pixel.
% Zwei unabhaengige Extraktionen aus unterschiedlich aufgeloesten Scans
% derselben Abbildung weichen im Mittel um -0.04 K voneinander ab
% (Standardabweichung 0.94 K). Die Unsicherheit liegt damit im
% Bereich weniger Zehntel Kelvin, an steilen Flanken hoeher.
%
% Kontrolle der Zeitachse: Tagesmaxima bei 14, 36, 61, 84 und 108 h,
% also im erwarteten 24-Stunden-Takt.

h_mess = (0:120)';

Tm_mess_h = [ ...
    287.32, 287.31, 287.86, 287.82, 287.32, 286.46, 286.17, 288.40, ...
    293.07, 296.49, 305.51, 309.78, 312.10, 311.37, 312.65, 311.40, ...
    307.10, 310.73, 306.54, 299.84, 295.17, 292.75, 290.34, 288.23, ...
    286.87, 286.28, 285.59, 284.94, 284.16, 284.26, 283.89, 286.65, ...
    294.34, 304.15, 313.52, 318.49, 319.51, 317.55, 315.71, 314.15, ...
    318.38, 314.91, 307.36, 302.77, 296.88, 294.39, 293.03, 291.11, ...
    289.22, 288.02, 286.79, 286.63, 286.19, 285.35, 285.53, 289.53, ...
    296.50, 306.63, 315.01, 320.75, 325.30, 327.24, 326.55, 323.33, ...
    318.77, 312.62, 305.70, 300.04, 296.37, 293.64, 293.03, 292.53, ...
    290.40, 289.37, 286.75, 286.01, 285.22, 285.39, 287.24, 293.25, ...
    300.10, 310.77, 316.10, 321.07, 323.87, 322.43, 322.20, 319.10, ...
    314.48, 309.46, 304.84, 300.43, 297.47, 296.05, 294.93, 293.13, ...
    291.70, 289.83, 288.98, 288.20, 286.77, 286.84, 289.60, 296.38, ...
    305.89, 315.45, 321.83, 326.99, 328.11, 326.99, 326.41, 322.32, ...
    317.65, 311.01, 306.50, 301.83, 298.11, 296.47, 296.00, 293.90, ...
    293.89 ]';



% Der Loeser waehlt seine Zeitpunkte adaptiv, die digitalisierten Punkte
% liegen dagegen auf vollen Stunden. Verglichen wird an den Zeitpunkten,
% die der Loeser ohnehin geliefert hat.
Tm_mess = interp1(h_mess*3600, Tm_mess_h, t, 'linear', 'extrap');

% Modellkurve des Referenzpapers, auf dieselben Zeitpunkte gebracht.
% Sie dient als zweite Vergleichsgroesse: Waehrend Tm_mess zeigt, wie
% weit unser Modell von der Messung abweicht, zeigt Tm_paper, welche
% Abweichung das Referenzmodell mit gemessenen Wetterdaten und einem
% vollstaendigen Nusselt-Ansatz erreicht. Erst dieser zweite Vergleich
% erlaubt die Einordnung, welcher Teil unserer Abweichung auf den
% vereinfachten Ansatz und welcher auf die konstruierten Eingangsdaten
% entfaellt.
Tm_paper = interp1(h_mess*3600, Tm_paper_h, t, 'linear', 'extrap');

% Fehlermasse getrennt fuer Tag und Nacht, siehe calc_errors.m.
% Tuncel et al. geben MAE 0.90 degC ueber den gesamten Zeitraum an, aber
% 2.61 degC allein fuer die Tagesstunden. Ein Vergleich nur ueber den
% Gesamtzeitraum verduennt die Mittagsabweichung mit unauffaelligen
% Nachtwerten und waere nicht aussagekraeftig.
ist_tag = G > p.G_tag_min;
fehler  = calc_errors(Tm, Tm_mess, ist_tag);

fehler       = calc_errors(Tm,       Tm_mess, ist_tag);
fehler_paper = calc_errors(Tm_paper, Tm_mess, ist_tag);

if ~isfolder('results'); mkdir('results'); end
save(fullfile('results', 'validation.mat'), ...
     't', 'Tm', 'Tamb', 'G', 'W_el', 'Tm_mess', 'fehler', 'p');


save(fullfile('results', 'validation.mat'), ...
     't', 'Tm', 'Tamb', 'G', 'W_el', 'Tm_mess', 'Tm_paper', ...
     'fehler', 'fehler_paper', 'p');

fprintf('run_validation fertig. %d Zeitschritte, Tm_max = %.1f degC\n', ...
        numel(t), max(Tm) - 273.15);

if fehler.N > 0
    fprintf('  gesamt   MAE %.2f K | RMSE %.2f K | MBE %+.2f K | N = %d\n', ...
            fehler.MAE, fehler.RMSE, fehler.MBE, fehler.N);
    fprintf('  tagsueber MAE %.2f K | RMSE %.2f K | MBE %+.2f K | N = %d\n', ...
            fehler.tag.MAE, fehler.tag.RMSE, fehler.tag.MBE, fehler.tag.N);
    fprintf('  nachts   MAE %.2f K | RMSE %.2f K | MBE %+.2f K | N = %d\n', ...
            fehler.nacht.MAE, fehler.nacht.RMSE, fehler.nacht.MBE, fehler.nacht.N);
else
    fprintf('  Keine Messwerte hinterlegt, Fehlermasse noch nicht berechenbar.\n');
end


fprintf('\nReferenzmodell (Tuncel et al.) gegen dieselbe Messung:\n');
fprintf('  gesamt    MAE %.2f K | RMSE %.2f K | MBE %+.2f K\n', ...
        fehler_paper.MAE, fehler_paper.RMSE, fehler_paper.MBE);
fprintf('  tagsueber MAE %.2f K | RMSE %.2f K | MBE %+.2f K\n', ...
        fehler_paper.tag.MAE, fehler_paper.tag.RMSE, fehler_paper.tag.MBE);
fprintf('  nachts    MAE %.2f K | RMSE %.2f K | MBE %+.2f K\n', ...
        fehler_paper.nacht.MAE, fehler_paper.nacht.RMSE, fehler_paper.nacht.MBE);