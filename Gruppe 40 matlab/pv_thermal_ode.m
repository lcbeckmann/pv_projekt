function dTm_dt = pv_thermal_ode(t, Tm, p, w)
%PV_THERMAL_ODE  Rechte Seite der Waermebilanz des PV-Moduls.
%
%   dTm_dt = PV_THERMAL_ODE(t, Tm, p, w)
%
%   t   Zeit seit Simulationsbeginn   [s]
%   Tm  Modultemperatur (Zustand)     [K]
%   p   Parameter-Struct aus init_parameters
%   w   Wetter-Struct mit den Interpolanten w.G, w.Tamb, w.v
%
%   Modell: C_m * dTm/dt = Q_solar - W_el - Q_konv - Q_rad     Gl. (2.1)
%
%   Das System hat genau einen unabhaengigen Energiespeicher (die
%   Waermekapazitaet des Moduls), also genau einen Zustand Tm.
%   Diese Funktion enthaelt bewusst keine Fallunterscheidungen und keine
%   Datenaufbereitung. Sie wird vom Solver sehr oft aufgerufen.

% Wettergroessen zum aktuellen Zeitpunkt (Solver fragt Zwischenzeiten ab!)
G    = w.G(t);       % Globalstrahlung in Modulebene   [W/m^2]
Tamb = w.Tamb(t);    % Umgebungstemperatur             [K]
v    = w.v(t);       % Windgeschwindigkeit             [m/s]

% Einzelterme der Bilanz
Q_solar = p.alpha_abs * G * p.A;                % Gl. (2.2)  [W]
W_el    = calc_w_el(G, Tm, p);                  % Gl. (2.3)  [W]
h_conv  = calc_h_conv(v, p);                    % Gl. (2.4)  [W/(m^2 K)]
Q_konv  = h_conv * p.A_conv * (Tm - Tamb);      % Gl. (2.5)  [W]
Q_rad   = calc_q_rad(Tm, Tamb, p);              % Gl. (2.6)  [W]

dTm_dt = (Q_solar - W_el - Q_konv - Q_rad) / p.C_m;   % Gl. (2.1)

end
