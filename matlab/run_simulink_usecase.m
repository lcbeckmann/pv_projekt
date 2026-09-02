% run_simulink_usecase.m
% Aufgabenpunkt 8: derselbe Anwendungsfall im Simulink-Modell.
% Rechnet NUR. Ergebnis landet in results/simulink_usecase.mat.

p = init_parameters();
w = load_weather_geosphere();
Tm_start = w.Tamb_vec(1);
wetter = w.matrix;

out = sim('pv_simulink', ...
          'StopTime', num2str(w.t_end), ...
          'MaxStep',  '300', ...
          'RelTol',   num2str(p.RelTol), ...
          'AbsTol',   num2str(p.AbsTol));

res    = struct();
res.t  = out.logsout.get('Tm').Values.Time;
for name = {'Tm','Q_solar','Q_konv','Q_rad','W_el','SoC','P_charge'}
    res.(name{1}) = out.logsout.get(name{1}).Values.Data;
end

if ~isfolder('results'); mkdir('results'); end
save(fullfile('results','simulink_usecase.mat'), 'res', 'p', 'w');

fprintf('Tm: min %.1f degC, max %.1f degC\n', ...
        min(res.Tm)-273.15, max(res.Tm)-273.15);