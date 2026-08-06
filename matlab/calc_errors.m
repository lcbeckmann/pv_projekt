function e = calc_errors(sim, mess)
%CALC_ERRORS  Fehlermasse fuer die Modellvalidierung.
%
%   MAE   mittlerer absoluter Fehler
%   RMSE  Wurzel des mittleren quadratischen Fehlers
%   MBE   mittlerer systematischer Fehler (Vorzeichen zeigt Ueber- oder
%         Unterschaetzung des Modells)
%
%   Die Vorlesung betont, dass die Wahl des Fehlermasses eine bewusste
%   Entscheidung ist. MBE ist hier wichtig, weil ein Modell mit kleinem
%   RMSE trotzdem systematisch danebenliegen kann.

r = sim(:) - mess(:);
gueltig = ~isnan(r);
r = r(gueltig);

e.MAE  = mean(abs(r));
e.RMSE = sqrt(mean(r.^2));
e.MBE  = mean(r);
e.N    = numel(r);

end
