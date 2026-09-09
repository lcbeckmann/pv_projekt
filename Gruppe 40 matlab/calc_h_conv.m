function h = calc_h_conv(v, p)
%CALC_H_CONV  Kombinierter Waermeuebergangskoeffizient.         Gl. (2.4)
%
%   h = h_a + h_b * v
%
%   Basismodell: freie und erzwungene Konvektion werden in einem
%   linearen Ansatz zusammengefasst (McAdams-Typ). Der Nusselt-Ansatz
%   von Tuncel et al. mit vier Stroemungsregimen und Windrichtung wird
%   bewusst nicht verwendet, siehe Protokoll Abschnitt 2.5.
%
%   Erweiterungspunkt: Wer den Nusselt-Ansatz nachruesten will, ersetzt
%   ausschliesslich diese Funktion. Der Rest des Codes bleibt gleich.

h = p.h_a + p.h_b * v;

end
