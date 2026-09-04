%RUN_SENSITIVITY  Aufgabenpunkt 6: Parametersensitivitaetsanalyse.
%
%   Vorgehen: ein Parameter wird variiert, alle anderen bleiben auf dem
%   Nominalwert (One-at-a-time). Bewertet wird die Aenderung von
%   Maximaltemperatur, Mitteltemperatur und Energieertrag.
%
%   Interessanter Diskussionspunkt fuers Protokoll: Tuncel et al. finden
%   bei Stundenwerten praktisch keinen Einfluss der Waermekapazitaet.
%   Herteleer et al. argumentieren fuer Sekunden- bis Minutenaufloesung
%   ueber die Zeitkonstante tau. Mit 10-Minuten-Daten liegen wir dazwischen.

close all;
p_nom = init_parameters();
w     = load_weather_geosphere();

% Zu untersuchende Parameter und ihre Variationsbereiche
%
% A_conv deckt die Annahme ueber die Einbausituation ab: der Nominalfall
% 2*A gilt fuer ein freistehend aufgestaendertes, beidseitig umstroemtes
% Modul, der untere Rand 1*A fuer ein dach- oder fassadenintegriertes, bei
% dem die Rueckseite nicht frei umstroemt wird. Diese Annahme ist als
% einzige nicht durch Literatur belegt und betrifft mit der Konvektion den
% dominanten Verlustpfad, siehe init_parameters.m Abschnitt 1.
%
% h_a und h_b werden beide variiert, da fuer die McAdams-Korrelation eine
% breite Literaturstreuung besteht (siehe Abschnitt 3.1 des Protokolls).
studien = { ...
'C_m',       p_nom.C_m       * [0.25 0.5 1 2 4]      ; ...
'h_a',       p_nom.h_a       * [0.5 0.75 1 1.5 2]    ; ...
'h_b',       p_nom.h_b       * [0.5 0.75 1 1.5 2]    ; ...
'A_conv',    p_nom.A         * [1 1.25 1.5 1.75 2]   ; ...
'alpha_abs', [0.80 0.85 0.90 0.93 0.96]              ; ...
'eps_front', [0.75 0.80 0.85 0.90 0.95]              ; ...
'beta_ref',  [0.0035 0.0040 0.0045 0.0050 0.0055]    };

opts  = odeset('RelTol', p_nom.RelTol, 'AbsTol', p_nom.AbsTol);
tspan = [0, w.t_end];

ergebnis = struct();

for k = 1:size(studien, 1)
    name   = studien{k, 1};
    werte  = studien{k, 2};

    Tm_max  = zeros(size(werte));
    Tm_mean = zeros(size(werte));
    E_el    = zeros(size(werte));

    for i = 1:numel(werte)
        p = p_nom;
        p.(name) = werte(i);

        [t, Tm] = ode45(@(t, T) pv_thermal_ode(t, T, p, w), tspan, w.Tamb(0), opts);

        W_el       = calc_w_el(w.G(t), Tm, p);
        Tm_max(i)  = max(Tm);
        Tm_mean(i) = mean(Tm);
        E_el(i)    = trapz(t, W_el);
    end

    ergebnis.(name).werte   = werte;
    ergebnis.(name).nominal = p_nom.(name);   % Bezugswert fuer die Darstellung
    ergebnis.(name).Tm_max  = Tm_max;
    ergebnis.(name).Tm_mean = Tm_mean;
    ergebnis.(name).E_el    = E_el;

    fprintf('Sensitivitaet %s fertig.\n', name);
end

if ~isfolder('results'); mkdir('results'); end
save(fullfile('results', 'sensitivity.mat'), 'ergebnis', 'p_nom');