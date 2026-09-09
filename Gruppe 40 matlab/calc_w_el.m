function W_el = calc_w_el(G, Tm, p)
%CALC_W_EL  Elektrische Leistung des Moduls.                    Gl. (2.3)
%
%   W_el = G * A * (tau*alpha) * eta_ref * [1 - beta_ref * (Tm - T_ref)]
%
%   Quelle: Tuncel et al. 2020, Gl. (10).
%   Diese Temperaturabhaengigkeit ist der Grund, warum das elektrische
%   Teilmodell auf die Waermebilanz zurueckwirkt und das Gesamtsystem
%   eine Differentialgleichung und keine explizite Formel ist.
%
%   Keine Begrenzung auf W_el >= 0: der Klammerausdruck wird erst bei
%   Tm - T_ref > 1/beta_ref (rund 222 K) negativ, also nie im
%   betrachteten Betriebsbereich. Eine Begrenzung wuerde eine
%   Unstetigkeit einbringen, die dem Solver schadet.

W_el = G * p.A * p.tau_alpha * p.eta_ref .* (1 - p.beta_ref * (Tm - p.T_ref));

end
