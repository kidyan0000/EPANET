close all;
clear;
%% Load EPANET Network
G = epanet('Jockgrim_Skeleton.inp'); % Load EPANET Input file

G.setQualityType('chem','mg/L');%Sets the type of water quality analysis called for

% Sensor Locations
sensor_id = G.getNodeNameID %Retrieves the ID label of all nodes or some nodes with a specified index
sensor_index = G.getNodeIndex(sensor_id); % Retrieves the index of a node with a specified ID

%% Simulation Setup

t_d= 1/12; % days
G.setTimeSimulationDuration(t_d*24*60*60); % Set Simulation duration of 2 Days
G.setTimeHydraulicStep(0.1);
G.setTimeReportingStep(900);
% line 2087: totalsteps=obj.getTimeSimulationDuration/obj.getTimeHydraulicStep
% G.setTimePatternStep(0.1);

%% Get Network data
%Retrieves the ID label of a particular time pattern
%Retrieves the index of a particular time pattern
%Retrieves the number of time periods in a specific time pattern
%Retrieves the multiplier factor for a specific time period in a time pattern
demand_pattern = G.getPattern;
roughness_coeff = G.getLinkRoughnessCoeff; % Retrieves the value of all link roughness
node_id = G.getNodeNameID; % Retrieves the ID label of all nodes or some nodes with a specified index

%% Scenarios
Ns = 2;            % Number of scenarios to simulate
u_p = 0.20;         % pattern uncertainty
u_r = 0.20;         % roughness coefficient uncertainty
max_inj_conc = 2.0; % maximum Arsenic source concentration
inj_start_time =0;  %(Dt = 1h)
inj_duration = 8;  % maximum duration of 8 hours
% Scenarios
inj_sc=[randi(G.NodeCount,Ns,1), max_inj_conc*rand(Ns,1), ... % Injection location, magnitude, ...
    randi(8,Ns,1)+inj_start_time, randi(inj_duration,Ns,1)];  % Injection start time, duration 

PatternIndex=[2,3,4];

%% Run epochs
% Randomize hydraulics
zeroNodes=zeros(1,G.getNodeCount); % Retrieves the number of nodes
for i = 1:Ns
    tic
    
    r_p = -u_p + 2*u_p.*rand(size(demand_pattern,1),size(demand_pattern,2));
    new_demand_pattern = demand_pattern + demand_pattern.*r_p;
    PAT_INDEX = G.addPattern('new_PAT', new_demand_pattern); % Set new patterns
    
    r_r = -u_r + 2*u_r.*rand(size(roughness_coeff,1),size(roughness_coeff,2));
    new_roughness_coeff = roughness_coeff + roughness_coeff.*r_r;
    G.setLinkRoughnessCoeff(new_roughness_coeff); % Set new roughness coefficients
    
    disp(['Iteration ', int2str(i)])
    
    tmp_values = zeroNodes;
   
    % Randomize injection
    G.setNodeSourceType(inj_sc(i,1),'SETPOINT') % Sets the values of source types
    tmp_values(inj_sc(i,1)) = 57000;
    G.setNodeSourceQuality(tmp_values) % Sets the values of source qualities
    tmp_values_pat_ind = zeroNodes;
    tmp_values_pat_ind(inj_sc(i,1)) = PAT_INDEX;
    G.setNodeSourcePatternIndex(tmp_values_pat_ind) % Sets the values of source pattern indices
    
    Q{i} = G.getComputedQualityTimeSeries('quality', sensor_index).NodeQuality; % Solve hydraulics and quality dynamics
    
    figure;
    plot(Q{i})
end
toc

