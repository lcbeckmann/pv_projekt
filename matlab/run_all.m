%RUN_ALL  Zentrale Steuerung des Projekts.
%
%   Flags auf true oder false setzen, dann ausfuehren. Rechnen und
%   Plotten sind getrennt, damit man die Abbildungen anpassen kann, ohne
%   jedes Mal alle Simulationen neu laufen zu lassen.
%
%   Typischer Ablauf beim Feinschliff der Grafiken:
%       rechnen_* = false, plotten_* = true

clear; close all; clc;

% Alle Pfade im Projekt sind relativ (data/, results/, figures/). MATLAB
% muss daher im matlab-Ordner stehen, egal von wo run_all gestartet wurde.
cd(fileparts(mfilename('fullpath')));

addpath(genpath(pwd));

rechnen_validierung   = false;   % erst sinnvoll mit den Paperdaten aus Tuncel Abb. 1
rechnen_anwendung     = true;    % braucht data/geosphere_2019.csv
rechnen_sensitivitaet = false;   % laeuft laenger

plotten_validierung   = false;
plotten_anwendung     = true;
plotten_sensitivitaet = false;

if rechnen_validierung,   run_validation;   end
if rechnen_anwendung,     run_usecase;      end
if rechnen_sensitivitaet, run_sensitivity;  end

if plotten_validierung,   plot_validation;   end
if plotten_anwendung,     plot_usecase;      end
if plotten_sensitivitaet, plot_sensitivity;  end

disp('run_all fertig.');
