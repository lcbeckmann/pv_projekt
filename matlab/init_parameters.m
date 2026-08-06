function p = init_parameters()
%INIT_PARAMETERS  Zentrale Parameterdatei des PV-Basismodells.
%
%   p = INIT_PARAMETERS() liefert eine Struct mit allen Modellparametern.
%   Es gibt im gesamten Projekt KEINE Zahlenwerte ausserhalb dieser Datei.
%
%   Einheiten: durchgaengig SI (m, kg, s, K, W, J).
%   Temperaturen intern IMMER in Kelvin. Umrechnung nur beim Plotten.
%
%   Jede Zeile mit einer Zahl braucht eine Quelle im Kommentar.
%   Aufgabenpunkt 3 (Literaturrecherche) wird genau hier abgearbeitet.
%   Alle mit TODO markierten Werte sind Platzhalter und muessen belegt werden.

% ---------------------------------------------------------------------
% 1) Modulgeometrie
% ---------------------------------------------------------------------
p.L        = 1.650;      % Modullaenge                         [m]   TODO Quelle (Datenblatt)
p.B        = 0.990;      % Modulbreite                         [m]   TODO Quelle (Datenblatt)
p.A        = p.L * p.B;  % Aperturflaeche                      [m^2]
p.A_conv   = 2 * p.A;    % konvektiv wirksame Flaeche (Vorder- + Rueckseite) [m^2]
p.theta    = deg2rad(32);% Neigungswinkel zur Horizontalen     [rad]  Tuncel et al. 2020

% ---------------------------------------------------------------------
% 2) Optische Eigenschaften
% ---------------------------------------------------------------------
p.alpha_abs = 0.90;      % effektiver Absorptionsgrad der Einstrahlung  [-] TODO Quelle
p.tau_alpha = 0.90;      % Transmissions-Absorptions-Produkt der Zelle  [-] TODO Quelle
p.eps_front = 0.85;      % Emissionsgrad Frontglas (langwellig)         [-] TODO Quelle
p.eps_back  = 0.90;      % Emissionsgrad Rueckseite                     [-] TODO Quelle

% ---------------------------------------------------------------------
% 3) Elektrisches Teilmodell
% ---------------------------------------------------------------------
p.eta_ref  = 0.127;      % Wirkungsgrad bei Referenzbedingungen   [-]    Tuncel et al. 2020
p.beta_ref = 0.0045;     % Temperaturkoeffizient der Leistung     [1/K]  Tuncel et al. 2020
p.T_ref    = 273.15 + 25;% Referenztemperatur (STC)               [K]    IEC 61215

% ---------------------------------------------------------------------
% 4) Konvektion (Basismodell: linearer Ansatz nach McAdams)
%    h = h_a + h_b * v_wind
%    Bewusste Vereinfachung gegenueber dem Nusselt-Ansatz von Tuncel et al.
%    Begruendung siehe Protokoll, Abschnitt "Getroffene Annahmen".
% ---------------------------------------------------------------------
p.h_a      = 5.7;        % freier Anteil                        [W/(m^2 K)] TODO Quelle
p.h_b      = 3.8;        % windabhaengiger Anteil               [W/(m^2 K)/(m/s)] TODO Quelle

% ---------------------------------------------------------------------
% 5) Strahlung
% ---------------------------------------------------------------------
p.sigma    = 5.670374419e-8; % Stefan-Boltzmann-Konstante       [W/(m^2 K^4)] CODATA 2018
p.c_sky    = 0.0552;         % Koeffizient Himmelstemperatur    [K^-0.5]      Swinbank 1963
                             % T_sky = c_sky * T_amb^1.5, T in K
                             % Bodentemperatur wird gleich T_amb gesetzt.

% ---------------------------------------------------------------------
% 6) Waermekapazitaet aus dem Schichtaufbau
%    C_m = A * sum_n ( d_n * rho_n * cp_n )
%    Spalten: Dicke [m] | Dichte [kg/m^3] | spez. Waermekap. [J/(kg K)]
% ---------------------------------------------------------------------
schichten = [ ...
    3.2e-3, 2500, 500 ;  ... % Frontglas          TODO Quelle
    0.5e-3,  960, 2090;  ... % EVA vorne          TODO Quelle
    0.2e-3, 2330,  677;  ... % Silizium-Zellen    TODO Quelle
    0.5e-3,  960, 2090;  ... % EVA hinten         TODO Quelle
    0.3e-3, 1200, 1250 ];    % Rueckseitenfolie   TODO Quelle

p.schichten = schichten;
p.c_area    = sum(schichten(:,1) .* schichten(:,2) .* schichten(:,3)); % [J/(m^2 K)]
p.C_m       = p.c_area * p.A;                                          % [J/K]

% ---------------------------------------------------------------------
% 7) Numerik
% ---------------------------------------------------------------------
p.solver   = 'ode45';    % Begruendung siehe Protokoll, Kap. 4.2
p.RelTol   = 1e-6;       % bewusst gesetzt, nicht Default
p.AbsTol   = 1e-6;       % bezieht sich auf T in K

end
