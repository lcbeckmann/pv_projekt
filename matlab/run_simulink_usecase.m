% run_simulink_usecase.m
% Anwendungsfall: GeoSphere-Messwoche 24.06. bis 01.07.2019 im
% Simulink-Modell. Rechnet und speichert, plottet nicht.

w = load_weather_geosphere(fullfile('data','geosphere_2019.csv'));
wetter = w.matrix;

out = sim('pv_simulink', 'StopTime', num2str(w.t_end), 'MaxStep', '300');

Tm = out.logsout.get('Tm').Values.Data;
fprintf('Tm: min %.1f degC, max %.1f degC\n', min(Tm)-273.15, max(Tm)-273.15);