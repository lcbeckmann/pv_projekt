% run_simulink_referenz.m
% Stationaerer Verifikationsfall (NOCT-Bedingung) im Simulink-Modell.
% Dient als Regressionstest: nach jeder Modelaenderung ausfuehren.

p = init_parameters();

% Konstante Randbedingungen, zwei Stuetzstellen genuegen.
% Spalten wie w.matrix: [Zeit, G, Tamb, v]
wetter = [    0, 800, 293.15, 1;
          20000, 800, 293.15, 1];

out = sim('pv_simulink', ...
          'StopTime', '20000', ...
          'RelTol',   num2str(p.RelTol), ...
          'AbsTol',   num2str(p.AbsTol));

fprintf('\n=== Referenzfall (G=800, v=1, T_amb=293.15) ===\n');
for name = {'Tm','Q_solar','Q_konv','Q_rad','W_el'}
    fprintf('%-8s = %8.2f\n', name{1}, ...
            out.logsout.get(name{1}).Values.Data(end));
end
fprintf('Soll: Tm = 311.88 K, W_el = 140.14 W\n\n');