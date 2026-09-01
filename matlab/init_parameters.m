function p = init_parameters()
%INIT_PARAMETERS  Zentrale Parameterdatei des PV-Basismodells.
%
%   p = INIT_PARAMETERS() liefert eine Struct mit allen Modellparametern.
%   Es gibt im gesamten Projekt KEINE Zahlenwerte ausserhalb dieser Datei.
%
%   Einheiten: durchgaengig SI (m, kg, s, K, W, J).
%   Temperaturen intern IMMER in Kelvin. Umrechnung nur beim Plotten.
%
%   Jede Zeile mit einer Zahl braucht eine Quelle im Kommentar.
%   Aufgabenpunkt 3 (Literaturrecherche) wird genau hier abgearbeitet.
%   Stand: alle TODO-Quelle-Marker aufgeloest (siehe doku/annahmen.md fuer
%   die zugehoerigen Annahmen-Eintraege und Kapitel 3 des Protokolls fuer
%   die ausformulierte Begruendung).

% ---------------------------------------------------------------------
% 1) Modulgeometrie
% ---------------------------------------------------------------------
% Kein Datenblatt vorhanden (Entscheidung Startsitzung: Modul primaer nach
% Tuncel et al. 2020, dort aber KEINE Modulabmessungen angegeben, nur
% eta_ref, beta_ref, Neigung). Fuer L und B daher Industriestandard eines
% 60-zelligen c-Si-Moduls (~1.65 m x 0.99 m) angesetzt; das ist die mit
% Abstand haeufigste Modulgroesse fuer Module in dieser Effizienzklasse
% (12.7 %, siehe unten) und ergibt A ~ 1.63 m^2, konsistent mit der
% Modulflaeche A = 1.6 m^2, die Herteleer et al. 2023 (Tab. 1) fuer ihr
% Referenzmodul durchgaengig verwendet. Explizit als Annahme dokumentiert,
% da kein Original-Datenblatt der GUENAM-Anlage vorliegt.
p.L        = 1.650;      % Modullaenge                         [m]   Industriestandard 60-Zellen-Modul; konsistent mit A~1.6 m^2 bei Herteleer et al. 2023, Tab. 1
p.B        = 0.990;      % Modulbreite                         [m]   Industriestandard 60-Zellen-Modul; konsistent mit A~1.6 m^2 bei Herteleer et al. 2023, Tab. 1
p.A        = p.L * p.B;  % Aperturflaeche                      [m^2]

% A_conv: Vorder- UND Rueckseite sind konvektiv wirksam, daher der Faktor 2.
% Das ist eine Annahme ueber die EINBAUSITUATION, kein Literaturwert: sie
% gilt fuer ein freistehend aufgestaendertes Modul, das beidseitig umstroemt
% wird (so war auch das Validierungsmodul der GUENAM-Anlage montiert, Tuncel
% et al. 2020, Kap. 2.4). Fuer ein dach- oder fassadenintegriertes Modul waere
% A_conv = A anzusetzen, weil die Rueckseite dann nicht frei umstroemt ist.
% Die Annahme ist nicht harmlos: die zugrunde liegende McAdams-Korrelation
% (siehe Abschnitt 4) ist fuer EINE ueberstroemte Plattenseite aufgestellt,
% der Faktor 2 verdoppelt also den konvektiven Waermeuebergang. Konvektion
% ist im Anwendungsfall mit rund 49 % der dominante Verlustpfad. Der Fall
% A_conv = A wird deshalb in der Sensitivitaetsanalyse mitgerechnet.
p.A_conv   = 2 * p.A;    % konvektiv wirksame Flaeche (Vorder- + Rueckseite) [m^2]  Annahme: freistehend aufgestaendert, beidseitig umstroemt

% theta wird im Basismodell BEWUSST NICHT VERWENDET. Entscheidung der
% Startsitzung: die Globalstrahlung wird horizontal uebernommen, wie
% GeoSphere sie liefert, ohne Umrechnung auf die geneigte Modulebene. Der
% Wert steht hier, weil er die Geometrie des Validierungsmoduls dokumentiert
% und fuer eine spaetere Erweiterung (Transposition auf Modulebene) gebraucht
% wuerde. Er ist also Dokumentation, kein toter Code.
p.theta    = deg2rad(32);% Neigungswinkel zur Horizontalen     [rad]  Tuncel et al. 2020, Kap. 2.4 (Validierungsmodul GUENAM Ankara: 32 Grad, suedorientiert)

% ---------------------------------------------------------------------
% 2) Optische Eigenschaften
% ---------------------------------------------------------------------
% alpha_abs und tau_alpha: Standardannahme nach Duffie & Beckman (1991,
% uebernommen in spaeteren Auflagen bis 2013), wonach das Produkt aus
% solarer Transmission und Absorption fuer PV-Module pauschal mit 0.9
% angesetzt wird, da eine praezisere spektrale Aufloesung fuer die
% thermische Modellierung nicht entscheidend ist (Begruendung: der
% Modellfehler durch diese Vereinfachung ist klein gegenueber anderen
% Modellunsicherheiten, siehe z.B. HOMER-Doku, die sich explizit auf
% Duffie & Beckman 1991 beruft). Unabhaengig bestaetigt durch gemessene
% Absorption gekapselter c-Si-Zellen von ca. 90.5% bei AM1.5 (Literatur
% zum Absorptionsgrad von c-Si-Zellen).
p.alpha_abs = 0.90;      % effektiver Absorptionsgrad der Einstrahlung  [-] Duffie & Beckman 1991 (Standardannahme tau*alpha = 0.9)
p.tau_alpha = 0.90;      % Transmissions-Absorptions-Produkt der Zelle  [-] Duffie & Beckman 1991 (Standardannahme tau*alpha = 0.9)

% eps_front, eps_back: Emissionsgrade im langwelligen (IR-)Bereich.
% Driesse, Stein & Theristis (2022, Sandia-Report) geben als Literatur-
% spanne fuer Solarglas 0.84-0.91 und fuer Polymer-Backsheets 0.85-0.89 an
% (basierend auf mehreren zitierten Materialmessungen). Wir setzen je
% einen plausiblen Wert aus der Mitte des jeweiligen Bereichs; unabhaengig
% bestaetigt durch weitere Literatur (Solarglas eps ~ 0.84, PVF-Backsheet
% eps ~ 0.85).
p.eps_front = 0.87;      % Emissionsgrad Frontglas (langwellig)         [-] Driesse, Stein & Theristis 2022 (Bereich 0.84-0.91 fuer Solarglas)
p.eps_back  = 0.87;      % Emissionsgrad Rueckseite                     [-] Driesse, Stein & Theristis 2022 (Bereich 0.85-0.89 fuer Polymer-Backsheet)

% ---------------------------------------------------------------------
% 3) Elektrisches Teilmodell
% ---------------------------------------------------------------------
p.eta_ref  = 0.127;      % Wirkungsgrad bei Referenzbedingungen   [-]    Tuncel et al. 2020, Kap. 2.4
p.beta_ref = 0.0045;     % Temperaturkoeffizient der Leistung     [1/K]  Tuncel et al. 2020, Kap. 2.4
p.T_ref    = 273.15 + 25;% Referenztemperatur (STC)               [K]    IEC 61215 (Standard Test Conditions, 25 degC)

% ---------------------------------------------------------------------
% 4) Konvektion (Basismodell: linearer Ansatz nach McAdams)
%    h = h_a + h_b * v_wind
%    Bewusste Vereinfachung gegenueber dem Nusselt-Ansatz von Tuncel et al.
%    Begruendung siehe Protokoll, Abschnitt "Getroffene Annahmen".
% ---------------------------------------------------------------------
% McAdams-Korrelation h_w = 5.7 + 3.8*v, referenziert bei Duffie & Beckman
% (1991/2013, "Solar Engineering of Thermal Processes") und in der Review
% von Skoplaki & Palyvos (2009) als Standardkorrelation fuer die
% windabhaengige Konvektion an ebenen Kollektor-/Modulflaechen verwendet.
p.h_a      = 5.7;        % freier Anteil                        [W/(m^2 K)]        Duffie & Beckman 1991/2013 (McAdams-Korrelation), zit. n. Skoplaki & Palyvos 2009
p.h_b      = 3.8;        % windabhaengiger Anteil               [W/(m^2 K)/(m/s)]  Duffie & Beckman 1991/2013 (McAdams-Korrelation), zit. n. Skoplaki & Palyvos 2009

% ---------------------------------------------------------------------
% 5) Strahlung
% ---------------------------------------------------------------------
p.sigma    = 5.670374419e-8; % Stefan-Boltzmann-Konstante       [W/(m^2 K^4)] CODATA 2018
p.c_sky    = 0.0552;         % Koeffizient Himmelstemperatur    [K^-0.5]      Swinbank 1963
                             % T_sky = c_sky * T_amb^1.5, T in K
                             % Bodentemperatur wird gleich T_amb gesetzt.

% ---------------------------------------------------------------------
% 6) Waermekapazitaet aus dem Schichtaufbau
%    C_m = A * sum_n ( d_n * rho_n * cp_n )
%    Spalten: Dicke [m] | Dichte [kg/m^3] | spez. Waermekap. [J/(kg K)]
%
%    Primaerquelle fuer alle fuenf Zeilen: Herteleer et al. 2023, Tab. 1
%    ("representative glass-tedlar Smart PV module"), dort transparent je
%    Schicht mit L, rho, cp ausgewiesen. Rahmen und Luftfilme werden NICHT
%    mitgerechnet, da unser Modul-Whitebox-Modell (Aufgabenpunkt 1) den
%    Aluminiumrahmen nicht als eigenen Waermespeicher fuehrt (siehe
%    Bilanzraum-Definition in KI_Kontext.md: "Modul ohne Rahmen").
%    Ergaenzender, unabhaengiger Vergleichswert (nur als Plausibilitaets-
%    check, nicht als Ersatz): Tuncel et al. 2020, Kap. 2.3+3, berechnen
%    fuer ihr (anderes) poly-c-Si-Modul c_eq ~ 5.7 kJ/(m^2 K) nach
%    identischer Summenformel (dort mit Daten aus Jones & Underwood 2001).
%    Das liegt in derselben Groessenordnung wie der hier verwendete
%    Schichtstapel-Wert (~7.6 kJ/(m^2 K)), siehe
%    doku/Schichtaufbau_Cm_Dokumentation.md fuer die vollstaendige
%    Herleitung und den Tabellenvergleich.
% ---------------------------------------------------------------------
schichten = [ ...
    3.2e-3, 3000, 500 ;  ... % Frontglas          Herteleer et al. 2023, Tab. 1 (Solarglas, gehaertet; korrigiert von 2500 auf 3000 kg/m^3)
    0.5e-3,  960, 2090;  ... % EVA vorne          Herteleer et al. 2023, Tab. 1
    0.2e-3, 2330,  677;  ... % Silizium-Zellen    Herteleer et al. 2023, Tab. 1 (dort zwei Zellschichten je 0.1 mm, hier zusammengefasst zu 0.2 mm)
    0.5e-3,  960, 2090;  ... % EVA hinten         Herteleer et al. 2023, Tab. 1
    0.3e-3, 1200, 1250 ];    % Rueckseitenfolie   Herteleer et al. 2023, Tab. 1 (Tedlar/PVF-Backsheet)

p.schichten = schichten;
p.c_area    = sum(schichten(:,1) .* schichten(:,2) .* schichten(:,3)); % [J/(m^2 K)]
p.C_m       = p.c_area * p.A;                                          % [J/K]


p.Tm0 = 298.15;   % [K] Anfangswert der Modultemperatur

% ---------------------------------------------------------------------
% 7) Numerik
% ---------------------------------------------------------------------
p.solver   = 'ode45';    % Begruendung siehe Protokoll, Kap. 4.2
p.RelTol   = 1e-6;       % bewusst gesetzt, nicht Default
p.AbsTol   = 1e-6;       % bezieht sich auf T in K

% ---------------------------------------------------------------------
% 8) Auswertung
% ---------------------------------------------------------------------
% Schwelle, ab der ein Zeitschritt als "tagsueber" gilt. Gebraucht fuer die
% getrennten Fehlermasse in calc_errors.m. Tuncel et al. 2020 geben MAE
% sowohl fuer den gesamten Zeitraum (0.90 degC) als auch nur fuer den Tag
% (2.61 degC) an, definieren die Grenze aber nicht. Wir setzen sie bewusst
% niedrig, damit Daemmerungsphasen noch zum Tag zaehlen und der Tagwert
% nicht kuenstlich guenstig wird.
p.G_tag_min = 20;        % Untergrenze Globalstrahlung fuer "Tag"  [W/m^2]  eigene Festlegung, siehe doku/annahmen.md

% --- Batterie (Aufgabenpunkt 7) ---
% Eigenes Modell
p.E_nenn   = 7 * 3.6e6;   % [J]  Nennenergie, entspricht 7 kWh
p.eta_lade = 0.90;          % [-]  Laderegler und Wandler zusammengefasst
p.SoC0     = 0.20;          % [-]  Anfangsladezustand

end
