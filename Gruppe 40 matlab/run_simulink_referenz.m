% run_simulink_refernz
% Stationaerer Verifikationsfall, gerechnet mit beiden Implementierungen.
% Dient als Regressionstest nach jeder Aenderung an einem der Modelle.

p = init_parameters();

G0 = 800; v0 = 1; Tamb0 = 293.15; t_end = 20000;

% ---------- Simulink ----------
wetter = [0, G0, Tamb0, v0; t_end, G0, Tamb0, v0];

out = sim('pv_simulink', ...
          'StopTime', num2str(t_end), ...
          'RelTol',   num2str(p.RelTol), ...
          'AbsTol',   num2str(p.AbsTol));

namen = {'Tm','Q_solar','Q_konv','Q_rad','W_el'};
sl = zeros(1,5);
for k = 1:5
    sl(k) = out.logsout.get(namen{k}).Values.Data(end);
end

% ---------- MATLAB-Kern ----------
% Dasselbe konstante Wetter als Struct, damit derselbe Code laeuft
% wie im Anwendungsfall.
w = build_weather_struct([0; t_end], [G0; G0], [Tamb0; Tamb0], [v0; v0]);

opts = odeset('RelTol', p.RelTol, 'AbsTol', p.AbsTol);
[t, Tm] = ode45(@(t,T) pv_thermal_ode(t, T, p, w), [0 t_end], p.Tm0, opts);

Tm_end = Tm(end);
ml = [Tm_end, ...
      p.alpha_abs * G0 * p.A, ...
      calc_h_conv(v0, p) * p.A_conv * (Tm_end - Tamb0), ...
      calc_q_rad(Tm_end, Tamb0, p), ...
      calc_w_el(G0, Tm_end, p)];

% ---------- Ausgabe ----------
fprintf('\n=== Referenzfall: G=%.0f W/m^2, v=%.1f m/s, T_amb=%.2f K ===\n', ...
        G0, v0, Tamb0);
fprintf('%-10s %12s %12s %12s\n', '', 'Simulink', 'MATLAB', 'Differenz');
for k = 1:5
    fprintf('%-10s %12.4f %12.4f %12.2e\n', ...
            namen{k}, sl(k), ml(k), sl(k)-ml(k));
end
fprintf('\nBilanzrest Simulink: %.2e W\n', sl(2)-sl(3)-sl(4)-sl(5));
fprintf('Bilanzrest MATLAB:   %.2e W\n\n', ml(2)-ml(3)-ml(4)-ml(5));