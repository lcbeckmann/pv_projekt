function save_figure(fig, name)
%SAVE_FIGURE  Speichert eine Figure als Vektor-PDF fuer das Protokoll.
%
%   save_figure(gcf, 'validierung_tm')
%
%   Vektorformat, weil die Checkliste der LVA nach publikationsfaehiger
%   Grafik fragt. Kein Screenshot, kein PNG.
%   Die Groesse wird hier fest vorgegeben, damit die Schriftgroesse im
%   fertigen Dokument ueber alle Abbildungen gleich bleibt.

if ~isfolder('figures'); mkdir('figures'); end

breite = 15.0;   % cm, entspricht etwa der Textbreite in A4
hoehe  =  8.0;   % cm

set(fig, 'Units', 'centimeters', 'Position', [2 2 breite hoehe]);
exportgraphics(fig, fullfile('figures', [name '.pdf']), ...
               'ContentType', 'vector', 'BackgroundColor', 'white');

fprintf('Abbildung gespeichert: figures/%s.pdf\n', name);

end
