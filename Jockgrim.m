clear;
close all;
clc;

start_toolkit;

%% Running Hydraulic Day Time Simulation
% Load a network
% inpfile = input('Enter your INP-File from choosen directory: '); % Jockgrim_Standard.inp
% d = epanet(inpfile);
% Jockgrim_Skeleton.inp
inp_file = input('Enter the INP-File from choosen directory: ','s');
G = epanet(inp_file)
%% Pump Curve of all assemblied pumps
for s = 1:G.getLinkPumpCount
   pump_curve = G.getCurveValue(s);
   Q  = pump_curve(:,1);
   H  = pump_curve(:,2);
   calc_pumpcurve(Q,H);
   s=s+1;
   hold on
end
%% Initialize Network
% Initialize Nodes (Junction, Reservoir, Tank)
BaseDemand_first = G.NodeBaseDemands{1,1}';  % Basis Verbrauch (1. Messdatenreihe)

Pattern_Choice = menu('Which Pattern do you want to run?','Kon','Messung','New'); 

Pattern_Messung = G.Pattern(Pattern_Choice,:); % Pattern Messung (Multiplier x 24 hrs)

% Changing Initial Tank Level
Temp_NodeTankInitialLevel = G.getNodeTankInitialLevel;
TankIndex = G.getNodeTankIndex;  % Index of Tanks
Temp_NodeTankInitialLevel(1,TankIndex)= [5.0 5.4 6.0];
G.setNodeTankInitialLevel(Temp_NodeTankInitialLevel);

% for i=1:length(G.Pattern(Pattern_Choice,:));    
% end

% Initialize Links (Pipes, Pumps, Valves)

%% Run hydraulic analysis of pressurized network
% Set simulation time duration

hrs = 1;
G.setTimeSimulationDuration(hrs*3600);

% Hydraulic analysis using ENepanet binary file (fastest)
% (This function ignores events)
% hyd_res_1 = G.getComputedTimeSeries;
% 
% % Hydraulic analysis using epanet2d.exe binary file
% % (This function ignores events)
% hyd_res_2 = d.getBinComputedAllParameters 
% 
%% Hydraulic analysis using the functions ENopenH, ENinit, ENrunH, ENgetnodevalue/&ENgetlinkvalue, ENnextH, ENcloseH
% (This function contains events)
 hyd_res = G.getComputedHydraulicTimeSeries 

% Hydraulic analysis step-by-step using the functions ENopenH, ENinit, ENrunH, ENgetnodevalue/&ENgetlinkvalue, ENnextH, ENcloseH
% (This function contains events)
% tic
% G.openHydraulicAnalysis;
% G.initializeHydraulicAnalysis;
% tstep=1;P=[];T_H=[];D=[];H=[];F=[];
% while (tstep>0)
%     t=G.runHydraulicAnalysis;
%     P=[P; G.getNodePressure];
%     D=[D; G.getNodeActualDemand];
%     H=[H; G.getNodeHydaulicHead];
%     F=[F; G.getLinkFlows];
%     T_H=[T_H; t];
%     tstep=G.nextHydraulicAnalysisStep;
% end
% G.closeHydraulicAnalysis;
% toc

%% This Section analyzises the computed hydraulic results

G.getStatistic % Number of iterations to reach solution (iter) and convergence error in solution (relerr)
               
G.getLinkEnergy; % recieved energy consumption in the considered time frame

%% serveral Hydraulic Plots
% Change time-stamps from seconds to hours
hrs_time = hyd_res.Time/3600;

node_indices = [1, 3, 5];
node_names = G.getNodeNameID(node_indices)
for i=node_indices
    figure;
    plot(hrs_time, hyd_res.Pressure(:,i));
    title(['Pressure for the node id "', G.getNodeNameID{i},'"']);
    xlabel('Time (hrs)'); 
    ylabel(['Pressure (', G.NodePressureUnits,')'])
end

% Plot water velocity for specific links
link_indices = [4, 8, 10];
link_names = G.getNodeNameID(link_indices)
for i=link_indices
    figure;
    plot(hrs_time, hyd_res.Velocity(:,i));
    title(['Velocity for the link id "', G.getLinkNameID{i},'"']);
    xlabel('Time (hrs)'); 
    ylabel(['Velocity (', G.LinkVelocityUnits,')'])
end

% Plot water flow for specific links
link_indices = [2, 3, 9];
for i=link_indices
    figure;
    plot(hrs_time, hyd_res.Flow(:,i));
    title(['Flow for the link id "', G.getLinkNameID{i},'"']);
    xlabel('Time (hrs)'); 
    ylabel(['Flow (', G.LinkFlowUnits,')'])
end

%% End of Program
G.unload        % unload INP-File
fprintf('End of Calculation.\n');
% fprintf('Go to Report file %s. \n,'s');

