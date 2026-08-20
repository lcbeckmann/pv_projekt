function e = calc_errors(sim, mess, ist_tag)
%CALC_ERRORS  Fehlermasse fuer die Modellvalidierung.
%
%   e = CALC_ERRORS(sim, mess)
%   e = CALC_ERRORS(sim, mess, ist_tag)
%
%   MAE   mittlerer absoluter Fehler
%   RMSE  Wurzel des mittleren quadratischen Fehlers
%   MBE   mittlerer systematischer Fehler (Vorzeichen zeigt Ueber- oder
%         Unterschaetzung des Modells)
%
%   Die Vorlesung betont, dass die Wahl des Fehlermasses eine bewusste
%   Entscheidung ist. MBE ist hier wichtig, weil ein Modell mit kleinem
%   RMSE trotzdem systematisch danebenliegen kann.
%
%   Residuum r = sim - mess. Ein negatives MBE bedeutet also, dass das
%   Modell unterschaetzt. Diese Konvention entspricht der von Tuncel et al.
%   2020, die ihr MBE von -1,64 degC als Unterschaetzung bezeichnen. Nur
%   dadurch sind unsere Zahlen mit denen des Papers vergleichbar.
%
%   Mit dem optionalen dritten Argument ist_tag (logischer Vektor, true
%   fuer Zeitschritte bei Tageslicht) werden zusaetzlich getrennte
%   Fehlermasse fuer Tag und Nacht berechnet.
%
%   WARUM diese Trennung noetig ist: Tuncel et al. geben fuer denselben
%   Datensatz MAE = 0,90 degC ueber den gesamten Zeitraum an, aber
%   MAE = 2,61 degC tagsueber. Nachts liegt das Modul nahe an der
%   Umgebungstemperatur, dort ist wenig Dynamik und der Fehler klein. Wer
%   ueber 24 Stunden mittelt, verduennt die Abweichung der Mittagsstunden
%   mit vielen unauffaelligen Nachtwerten und vergleicht anschliessend
%   zwei verschiedene Dinge.

r       = sim(:) - mess(:);
gueltig = ~isnan(r);

e = fehlermasse(r(gueltig));

if nargin >= 3
    ist_tag = logical(ist_tag(:));
    e.tag   = fehlermasse(r(gueltig &  ist_tag));
    e.nacht = fehlermasse(r(gueltig & ~ist_tag));
end

end


function e = fehlermasse(r)
%FEHLERMASSE  Die drei Masse fuer einen bereits gefilterten Residuenvektor.

e.MAE  = mean(abs(r));
e.RMSE = sqrt(mean(r.^2));
e.MBE  = mean(r);
e.N    = numel(r);

end
