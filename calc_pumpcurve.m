%% In diesem Skript wird die Pumpenkurve der implementierten Pumpen des Epanet-Modells ermittelt.
% Dazu werden Herstellangaben bzw. gemessenene Pumpendaten eingelesen.
% Anpassung der Datenpunkte erfolgt mithilfe eines Polynomansatz oder einem
% entsprechenden Epanet-Modells.
function calc_pumpcurve(Qpump,Hpump)
% [table,~,raw]= xlsread('...');

% Jockgrim Pumpe 
% H_pumpe = [80.3000; 77.7400; 70.2800;  61.5800;  43.3300];
% Q_pumpe = [0; 75.29; 145.64; 201.43; 272.39];

Grad = length(Qpump)-1; % Polynomgrad
% Grad=5;
p = polyfit(Qpump, Hpump,Grad);
n = 100; % Stützstellen 
Q_pumpe_modell = linspace(0,300,n);
H_pumpe_modell = polyval(p,Q_pumpe_modell);
figure()
plot(Qpump,Hpump,'ob')
hold on
plot(Q_pumpe_modell,H_pumpe_modell,'-r')
title(' Jockgrim: Pumpe 1');
xlabel('Förderstrom Q [m^3/h]');
ylabel('Förderhöhe H [m]');
legend('Datenpunkte','Pumpenkurve');
end

