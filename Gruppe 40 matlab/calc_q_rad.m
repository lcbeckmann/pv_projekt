function Q_rad = calc_q_rad(Tm, Tamb, p)
%CALC_Q_RAD  Netto-Strahlungsverlust des Moduls.                Gl. (2.6)
%
%   Vorderseite strahlt gegen den Himmel, Rueckseite gegen den Boden.
%   Bodentemperatur = Umgebungstemperatur (Annahme, siehe Protokoll).
%   Himmelstemperatur nach Swinbank: T_sky = c_sky * Tamb^1.5, Tamb in K.

T_sky = p.c_sky * Tamb.^1.5;                          % [K]

Q_rad = p.sigma * p.A * ( ...
          p.eps_front * (Tm.^4 - T_sky.^4) + ...
          p.eps_back  * (Tm.^4 - Tamb.^4) );          % [W]

end
