function [RunConditions] = Experimental_Data_Comparison_Nov26()
% Written by Steven Middleton
% Experimental data extraction added by Connor Speer, September 2021.
% Debuged and finalized by Sara Eghbali, 24 Sep 2021
% The purpose of this function is to extract the operating points from a
% set of experimental data and reconfigure it for use in MSPM. This will
% allow quick comparison plots to be made.

%% Input Parameters
exp_filename = 'G:\Shared drives\NOBES_GROUP\MSPM\[MATLAB_WORKING_FOLDER]\Data Processing Code\06_Post Processing_Experimental\2019_04_12_RD.mat'; % Name of experimental data file.
model = 'Raphael_26Nov2021_from05NovVersion_Sensors_CrankMotion_Nodes748'; % Name of MSPM model geometry.
% modelSine = 'Raphael_12Nov2021_from05NovVersion_Sensors_SinMotion_Nodes748'; % Name of MSPM model geometry.

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

% For crank model
for i = 1:size(RD_DATA,2)
    RunConditions(i) = RunConditions(end);
    RunConditions(i).Model = model;
    RunConditions(i).rpm = RD_DATA(i).MB_speed;
    %     RTD_0 --> Displacer Cylinder Head Inlet
    %     RTD_1 --> Displacer Cylinder Head Outlet
    %     RTD_2 --> Heater Inlet
    %     RTD_3 --> Heater Outlet
    %     RTD_4 --> Cooler Inlet
    %     RTD_5 --> Cooler Outlet
    RunConditions(i).SourceTemp = mean([mean(RD_DATA(i).RTD_2), mean(RD_DATA(i).RTD_3)]) + 273.15; % K to Celsius
    RunConditions(i).SinkTemp = mean([mean(RD_DATA(i).RTD_4), mean(RD_DATA(i).RTD_5)]) + 273.15;
    RunConditions(i).EnginePressure = RD_DATA(i).pmean;
    %    RunConditions(i).title = ['Experimental Data Comparison, rpm- ' num2str(RD_DATA(i).MB_speed) ' Pmean- ' num2str(RD_DATA(i).pmean) ' SourceTemp- ' num2str(RD_DATA(i).hot_bath_setpoint) ' SinkTemp- ' num2str(RD_DATA(i).cold_bath_setpoint)];
    RunConditions(i).title = ['Materials_' RD_DATA(i).filename];
end

disp("Running Test Set with " + length(RunConditions) + " Cases.")
end

