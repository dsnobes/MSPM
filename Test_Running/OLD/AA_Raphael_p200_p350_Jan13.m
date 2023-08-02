function [RunConditions] = AA_Raphael_p200_p350_Jan13()
% Written by Steven Middleton
% Experimental data extraction added by Connor Speer, September 2021.
% Debuged and finalized by Sara Eghbali, 24 Sep 2021
% The purpose of this function is to extract the operating points from a
% set of experimental data and reconfigure it for use in MSPM. This will
% allow quick comparison plots to be made.

%% Input Parameters
% Name of experimental data files.
exp_filename{1} = 'G:\Shared drives\NOBES_GROUP\MSPM\[MATLAB_WORKING_FOLDER]\Data Processing Code\06_Post Processing_Experimental\[Experimental Data]\2021-12-16 p200\2021-12-16 p200_T0-1.04\2021-12-16 p200_T0-1.04_RD.mat';
exp_filename{2} = 'G:\Shared drives\NOBES_GROUP\MSPM\[MATLAB_WORKING_FOLDER]\Data Processing Code\06_Post Processing_Experimental\[Experimental Data]\2021-12-23-newBumpy-p350\2021-12-23-newBumpy-p350-T0-0.97\2021-12-23-newBumpy-p350-T0-0.97_RD.mat';
model = 'Raphael_13Jan2022_1mmReg_DCH_off'; % Name of MSPM model geometry.

p_environment{1} = 93.79 *1000; % [Pa] Measured atmospheric pressure at time and location of experiment
p_environment{2} = 91 *1000;
simTime = 60; %(s) Simulation time.
SS = true; % Steady state toggle.
movement_option = 'C';
max_dt = 0.1; %(s) Maximum time step.
NodeFactor = 1;
Uniform_Scale = 1;
HX_Convection = 1;

%% Create MSPM Test Structure

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

% p200
exp_index = 1;
load(exp_filename{exp_index});
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
    RunConditions(i).EnginePressure = RD_DATA(i).pmean + p_environment{exp_index};
    RunConditions(i).title = [RD_DATA(i).filename];
end

len = length(RunConditions);
% p350
exp_index = 2;
load(exp_filename{exp_index});
for i = 1:size(RD_DATA,2)
    i2 = len + i;
    RunConditions(i2) = RunConditions(end);
%     RunConditions(i2).Model = model;
%     RunConditions(i2).simTime = simTime;
    RunConditions(i2).rpm = RD_DATA(i).MB_speed;
    %     RTD_0 --> Displacer Cylinder Head Inlet
    %     RTD_1 --> Displacer Cylinder Head Outlet
    %     RTD_2 --> Heater Inlet
    %     RTD_3 --> Heater Outlet
    %     RTD_4 --> Cooler Inlet
    %     RTD_5 --> Cooler Outlet
    RunConditions(i2).SourceTemp = mean([RD_DATA(i).Tsource_in, RD_DATA(i).Tsource_out]) + 273.15; % Celsius to K
    RunConditions(i2).SinkTemp = mean([RD_DATA(i).Tsink_in, RD_DATA(i).Tsink_out]) + 273.15;
    RunConditions(i2).EnginePressure = RD_DATA(i).pmean + p_environment{exp_index};
    RunConditions(i2).title = [RD_DATA(i).filename];
end

disp("Running Test Set with " + length(RunConditions) + " Cases.")
end

