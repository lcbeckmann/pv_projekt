function w = build_weather_struct(t, G, Tamb, v)
%BUILD_WEATHER_STRUCT  Baut die Interpolanten fuer die Wettereingaenge.
%
%   Warum ueberhaupt Interpolation: der ODE-Solver waehlt seine
%   Zeitschritte selbst und fragt Zeitpunkte ab, die zwischen den
%   Messwerten liegen. Die Interpolanten werden EINMAL hier gebaut und
%   nicht bei jedem Aufruf der rechten Seite neu.
%
%   Lineare Interpolation, weil die Messgroessen zwischen den Stuetzstellen
%   keinen physikalisch begruendbaren hoeheren Verlauf haben. Spline waere
%   glatter, kann aber bei Bewoelkungsspruengen ueberschwingen und negative
%   Einstrahlung erzeugen.

t    = t(:);
G    = G(:);
Tamb = Tamb(:);
v    = v(:);

w.G     = griddedInterpolant(t, G,    'linear', 'nearest');
w.Tamb  = griddedInterpolant(t, Tamb, 'linear', 'nearest');
w.v     = griddedInterpolant(t, v,    'linear', 'nearest');

w.t     = t;
w.t_end = t(end);
w.dt    = median(diff(t));

% Matrix fuer den From-Workspace-Block in Simulink.
% Spaltenreihenfolge ist FEST: [Zeit, G, Tamb, v].
w.G_vec    = G;
w.Tamb_vec = Tamb;
w.v_vec    = v;

w.matrix = [t, G, Tamb, v];
end
