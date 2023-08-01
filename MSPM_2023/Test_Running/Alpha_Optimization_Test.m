function [RunConditions] = Alpha_Optimization_Test()
% Written by Steven Middleton
% Experimental data extraction added by Connor Speer, September 2021.
% Debuged and finalized by Sara Eghbali, 24 Sep 2021
% The purpose of this function is to extract the operating points from a
% set of experimental data and reconfigure it for use in MSPM. This will
% allow quick comparison plots to be made.

%% Input Parameters
pressure = 1000.*1000; % [Pa]
speed = 30; % [rpm]
simTime = 10; %(s) Simulation time.
minCycles = 10; % minimum number of engine cycles to complete before turning to steady state.
SS = true; % Steady state toggle.
movement_option = 'C';
max_dt = 0.1; %(s) Maximum time step.
NodeFactor = 1;


%% Create MSPM Test Structure

    RunConditions = struct(...
      'Model','July 13 2023 Alpha Model V12',...
      'title','',...
      'simTime',simTime,... [s]
      'SS',SS,...
      'movement_option',movement_option,...
      'rpm',speed,... [rpm]
      'max_dt',max_dt,... [s]
      'SourceTemp',150 + 273.15,... [K]
      'SinkTemp',5 + 273.15,... [K]
      'EnginePressure',pressure,...
      'NodeFactor',NodeFactor,...
      'HX_Convection', 1,...
      'PressureBounds',[101325 100*101325],...
      'SpeedBounds',[20 1000]);

