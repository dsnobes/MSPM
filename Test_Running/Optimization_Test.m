function [RunConditions] = Optimization_Test()
% Written by Steven Middleton
% Experimental data extraction added by Connor Speer, September 2021.
% Debuged and finalized by Sara Eghbali, 24 Sep 2021
% The purpose of this function is to extract the operating points from a
% set of experimental data and reconfigure it for use in MSPM. This will
% allow quick comparison plots to be made.

%% Input Parameters
pressure = [500000]; % [Pa]
speed = [64]; % [rpm]
simTime = 100; %(s) Simulation time.
minCycles = 4; % minimum number of engine cycles to complete before turning to steady state.
max_dt = 0.1; %(s) Maximum time step.
NodeFactor = 1;


%% Create MSPM Test Structure

    RunConditions = struct(...
      'title','',...
      'simTime',simTime,... [s]
      'rpm',speed,... [rpm]
      'max_dt',max_dt,... [s]
      'EnginePressure',pressure,...
      'NodeFactor',NodeFactor, ...
      'SourceTemp',450,...
      'SinkTemp',270,...
      'PressureBounds',[100000 1000000],...
      'SpeedBounds',[1 1024]);
