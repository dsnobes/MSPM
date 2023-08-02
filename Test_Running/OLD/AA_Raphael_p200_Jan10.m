function [RunConditions] = AA_Raphael_p200_Jan10()
% Written by Steven Middleton
% Experimental data extraction added by Connor Speer, September 2021.
% Debuged and finalized by Sara Eghbali, 24 Sep 2021
% The purpose of this function is to extract the operating points from a
% set of experimental data and reconfigure it for use in MSPM. This will
% allow quick comparison plots to be made.

%% Input Parameters
[exp_file, exp_path] = uigetfile('',"Choose experimental '_RD.mat' file to create MSPM runs."); % Name of experimental data file.
exp_filename = fullfile(exp_path,exp_file);
model = 'Raphael_13Jan2022_1mmReg_DCH_off'; % Name of MSPM model geometry.

p_environment = 93.75 *1000; % [Pa] Measured atmospheric pressure at time and location of experiment
simTime = 60; %(s) Simulation time.
SS = true; % Steady state toggle.
movement_option = 'C';
max_dt = 0.1; %(s) Maximum time step.
NodeFactor = 1;
Uniform_Scale = 1;
HX_Convection = 1;

%% Create MSPM Test Structure
load(exp_filename);

RunConditions = struct(...
    'Model', model,...
    'title','',...
    'simTime', simTime,... [s]
    'SS', SS,...
    'movement_option', movement_option,...
    'rpm', 60,... [rpm]
    'max_dt', max_dt,... [s]
    'SourceTemp',150 + 273.15,... [K]
    'SinkTemp',5 + 273.15,... [K]
    'EnginePressure',101325*10,...
    'NodeFactor', NodeFactor,...
    'Uniform_Scale', Uniform_Scale,...
    'HX_Convection', HX_Convection);

for i = 1:size(RD_DATA,2)
    RunConditions(i) = RunConditions(end);
%     RunConditions(i).Model = model;
%     RunConditions(i).simTime = simTime;
    RunConditions(i).rpm = RD_DATA(i).MB_speed;
    %     RTD_0 --> Displacer Cylinder Head Inlet
    %     RTD_1 --> Displacer Cylinder Head Outlet
    %     RTD_2 --> Heater Inlet
    %     RTD_3 --> Heater Outlet
    %     RTD_4 --> Cooler Inlet
    %     RTD_5 --> Cooler Outlet
    RunConditions(i).SourceTemp = mean([RD_DATA(i).Tsource_in, RD_DATA(i).Tsource_out]) + 273.15; % Celsius to K
    RunConditions(i).SinkTemp = mean([RD_DATA(i).Tsink_in, RD_DATA(i).Tsink_out]) + 273.15;
    RunConditions(i).EnginePressure = RD_DATA(i).pmean + p_environment;
    RunConditions(i).title = [RD_DATA(i).filename];
end

% len = length(RunConditions);

% for i = 1:size(RD_DATA,2)
%     i2 = len + i;
%     RunConditions(i2) = RunConditions(end);
%     RunConditions(i2).Model = model;
%     RunConditions(i2).simTime = 10;
%     RunConditions(i2).rpm = RD_DATA(i).MB_speed;
%     %     RTD_0 --> Displacer Cylinder Head Inlet
%     %     RTD_1 --> Displacer Cylinder Head Outlet
%     %     RTD_2 --> Heater Inlet
%     %     RTD_3 --> Heater Outlet
%     %     RTD_4 --> Cooler Inlet
%     %     RTD_5 --> Cooler Outlet
%     RunConditions(i2).SourceTemp = mean([RD_DATA(i).Tsource_in, RD_DATA(i).Tsource_out]) + 273.15; % Celsius to K
%     RunConditions(i2).SinkTemp = mean([RD_DATA(i).Tsink_in, RD_DATA(i).Tsink_out]) + 273.15;
%     RunConditions(i2).EnginePressure = RD_DATA(i).pmean + p_environment;
%     RunConditions(i2).title = [RD_DATA(i).filename '_simTime_10'];
% end

disp("Running Test Set with " + length(RunConditions) + " Cases.")
end

