function w = load_weather_paper()
%LOAD_WEATHER_PAPER  Eingangsdaten fuer die Validierung (Aufgabenpunkt 4).
%
%   Datengrundlage: Tuncel et al. 2020, Abb. 1 (5 Tage im Juni, Ankara).
%   Die Werte muessen aus der Abbildung digitalisiert werden, z.B. mit
%   WebPlotDigitizer, und hier als Spalten eingetragen werden.
%
%   ACHTUNG: Zur Umgebungstemperatur macht das Paper keine Angabe.
%   Es muss ein plausibler Wert angenommen werden, siehe Angabe zu 4).
%   Die getroffene Annahme gehoert in die Annahmentabelle des Protokolls.
%
%   Rueckgabe w: Struct mit Interpolanten w.G, w.Tamb, w.v und w.t_end.

% =====================================================================
% PLATZHALTER - MUSS DURCH DIGITALISIERTE PAPERDATEN ERSETZT WERDEN
% Bis dahin: synthetischer Klartag, damit die Toolchain testbar ist.
% =====================================================================
warning('load_weather_paper:Platzhalter', ...
        'Synthetische Platzhalterdaten. Vor Abgabe durch Paperdaten ersetzen.');

n_tage  = 5;
dt      = 3600;                          % Zeitschritt [s], Paper: 1 h
t       = (0 : dt : n_tage*86400)';      % Zeitvektor  [s]

std_tag = mod(t/3600, 24);
G       = max(0, 950 * sin(pi * (std_tag - 6) / 12));   % [W/m^2]
Tamb    = 273.15 + 22 + 8 * sin(2*pi*(std_tag - 9)/24); % [K]
v       = 2.0 * ones(size(t));                          % [m/s]
% =====================================================================

w = build_weather_struct(t, G, Tamb, v);
w.quelle = 'Tuncel et al. 2020, Abb. 1 (PLATZHALTER)';

end
