function w = load_weather_geosphere(csv_datei)
%LOAD_WEATHER_GEOSPHERE  Messdaten der GeoSphere Austria (Aufgabenpunkt 5).
%
%   w = LOAD_WEATHER_GEOSPHERE(csv_datei)
%   Zeitraum: 24.06.2019 bis 01.07.2019
%   [degC]  -> wird hier nach K umgerechnet


if nargin < 1
    csv_datei = fullfile('data', 'geosphere_2019.csv');
end

T = readtable(csv_datei);

zeit    = T.time;          % 
G       = T.cglo;          %  [W/m^2]
Tamb_C  = T.tl;            %  [degC]
v       = T.ff;            %  [m/s]

% Zeitachse in sekunden seit Beginn
if ~isdatetime(zeit)
    zeit = datetime(zeit, 'InputFormat', 'yyyy-MM-dd''T''HH:mmXXX','TimeZone','UTC');
    zeit.TimeZone = 'UTC+2';
end
t = seconds(zeit - zeit(1));

% Luecken behandeln: lineare Interpolation
gueltig = ~isnan(G) & ~isnan(Tamb_C) & ~isnan(v);
if any(~gueltig)
    fprintf('Hinweis: %d von %d Zeilen enthalten Luecken.\n', ...
            sum(~gueltig), numel(gueltig));
end
t      = t(gueltig);
G      = G(gueltig);
Tamb   = Tamb_C(gueltig) + 273.15;
v      = v(gueltig);

w = build_weather_struct(t, G, Tamb, v);
w.quelle    = csv_datei;
w.startzeit = zeit(1);

end
