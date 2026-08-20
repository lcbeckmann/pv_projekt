function w = load_weather_paper()
%LOAD_WEATHER_PAPER  Eingangsdaten fuer die Validierung (Aufgabenpunkt 4).
%
%   Datengrundlage: Tuncel et al. 2020, Kap. 3 + Abb. 1 (5-Tage-Intervall
%   im Juni, GUENAM-Anlage Ankara, poly-c-Si-Modul, 32 Grad Neigung,
%   suedorientiert).
%
%   WICHTIGE EINSCHRAENKUNG (Gruppenentscheidung, siehe annahmen.md):
%   Tuncel et al. 2020 veroeffentlichen in Abb. 1 NUR die gemessene und
%   geschaetzte Modultemperatur sowie elektrische Leistung - NICHT die
%   antreibenden Wetterdaten (G, T_amb, Wind), die stuendlich an der
%   GUENAM-Wetterstation gemessen wurden. Diese Rohdaten sind im Paper
%   nicht veroeffentlicht und es existiert kein offener Datensatz dazu
%   (anders als bei Herteleer et al. 2023).
%
%   Beschlossene Loesung (Option B aus der Gruppendiskussion): Es werden
%   plausible, synthetische Wetterkurven fuer den beschriebenen Zeitraum
%   konstruiert, die den qualitativen Angaben im Paper folgen (Kap. 3:
%   "the first two days are partially cloudy, and the following three
%   are clear days"). Das ist eine EXPLIZITE ANNAHME, keine Messung.
%
%   KONSEQUENZ FUER DIE FEHLERAUSWERTUNG: Da hier mit angenommenem statt
%   gemessenem Wetter gerechnet wird, sagt die Abweichung zur
%   digitalisierten Tm_mess-Kurve (siehe run_validation.m) nicht sauber
%   aus, ob Modellfehler oder Wetterannahme-Fehler ueberwiegen. Diese
%   Einschraenkung gehoert explizit in die Diskussion des Validierungs-
%   kapitels im Protokoll.
%
%   Rueckgabe w: Struct mit Interpolanten w.G, w.Tamb, w.v und w.t_end.

% ---------------------------------------------------------------------
% Zeitachse: 5 Tage, stuendliche Werte (Tuncel et al. 2020 nutzen ebenfalls
% Delta t = 1 h mit implizitem Euler-Verfahren, siehe Kap. 2.4).
% ---------------------------------------------------------------------
n_tage = 5;
dt     = 3600;                          % Zeitschritt [s], nach Tuncel et al. 2020, Kap. 2.4
t      = (0 : dt : n_tage*86400)';      % Zeitvektor  [s]

std_tag = mod(t/3600, 24);              % Stunde des Tages [0, 24)
tag_idx = floor(t/86400);               % Tag-Index 0..4

% ---------------------------------------------------------------------
% Einstrahlung G: Tagesgang als geglaettete Sinus-Halbwelle zwischen
% Sonnenauf- und -untergang, angepasst an Ankara im Juni (Breitengrad
% ca. 39.9 N, Tageslaenge im Juni ca. 15 h). Sonnenauf-/untergangszeiten
% grob nach astronomischer Tageslaenge fuer diesen Breitengrad und Monat.
% ---------------------------------------------------------------------
sonnenauf    = 5.0;                     % [h], Ankara Juni, grobe Rundung
sonnenunter  = 20.0;                    % [h], Ankara Juni, grobe Rundung
tageslaenge  = sonnenunter - sonnenauf; % [h]

winkel   = pi * (std_tag - sonnenauf) / tageslaenge;
winkel   = max(0, min(pi, winkel));     % ausserhalb Tagfenster: 0, verhindert komplexe/neg. Werte
G_klar   = 1000 * sin(winkel).^1.2;     % [W/m^2], Spitzenwert 1000 W/m^2 = G_STC, Exponent 1.2 fuer realistischeren, spitzeren Mittagspeak

% Bewoelkungsfaktor nach Tuncel et al. 2020, Kap. 3: erste 2 Tage
% "partially cloudy" (Daempfung + Schwankung durch Wolkendurchzug),
% letzte 3 Tage "clear days" (Faktor 1, keine Daempfung).
bewoelkt      = tag_idx < 2;
cloud_faktor  = ones(size(t));
cloud_faktor(bewoelkt) = 0.55 + 0.25 * sin(2*pi*t(bewoelkt) / (3*3600));
G = max(0, G_klar .* cloud_faktor);

% ---------------------------------------------------------------------
% Umgebungstemperatur: Tagesgang mit realistischem Phasenversatz (Maximum
% nachmittags, nicht zur Mittagszeit), Amplitude fuer semi-arides
% Kontinentalklima im Juni (Ankara) nach allgemeiner Klimacharakteristik,
% da Tuncel et al. 2020 keine expliziten T_amb-Werte angeben.
% ANNAHME: Tagesmittel 22 degC, Tagesamplitude +-8 K, Maximum um 15:00 Uhr.
% ---------------------------------------------------------------------
Tamb = 273.15 + 22 + 8 * sin(2*pi*(std_tag - 9)/24);   % [K]

% ---------------------------------------------------------------------
% Windgeschwindigkeit: Tuncel et al. 2020 geben keine Werte an. ANNAHME:
% moderater, leicht tagesperiodischer Wind (staerker am Nachmittag),
% typischer Bereich fuer Standorte im Landesinneren ohne Kuestenlage.
% ---------------------------------------------------------------------
v = 2.0 + 0.8 * max(0, sin(2*pi*(std_tag - 8)/24));    % [m/s]

w = build_weather_struct(t, G, Tamb, v);
w.quelle = ['Tuncel et al. 2020, Kap. 3 (Tageszyklus-Beschreibung); ' ...
            'G, Tamb, v selbst als ANNAHME konstruiert (Option B, ' ...
            'siehe annahmen.md) - keine Rohmessdaten im Paper verfuegbar.'];

end
