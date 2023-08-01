function [RunConditions] = AA_Raphael_from_given_setpoints()
% Written by Steven Middleton
% Experimental data extraction added by Connor Speer, September 2021.
% Debuged and finalized by Sara Eghbali, 24 Sep 2021
% The purpose of this function is to extract the operating points from a
% set of experimental data and reconfigure it for use in MSPM. This will
% allow quick comparison plots to be made.

%% Input Parameters
% Name of experimental data files.
model = {'Raphael_2022-05-26_FinEnhSurf_Custom_h_DefaultMesher.mat'}; % Name of MSPM model geometry.
pmean = ([300]) *1000; % [Pa]
speed = ([150]); % [rpm]
TH = 150; %[K]
TC = 5; %[K]
p_environment = 94 *1000; % [Pa] Measured atmospheric pressure at time and location of experiment
simTime = 60; %(s) Simulation time.
SS = true; % Steady state toggle.
movement_option = 'C';
max_dt = 0.1; %(s) Maximum time step.
NodeFactor = 1;
Uniform_Scale = 1;
HX_Convection = 1;

%% Create MSPM Test Structure

RunConditions_temp = struct(... %Default values
    'Model', model{1},...
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

n=1;
for i = 1:length(model)
    for p = pmean
        for s = speed
            RunConditions(n) = RunConditions_temp;
            RunConditions(n).Model = model{i};
            %     RunConditions(i).simTime = simTime;
            RunConditions(n).rpm = s;
            RunConditions(n).SourceTemp = TH + 273.15;
            RunConditions(n).SinkTemp = TC + 273.15;
           %     RTD_0 --> Displacer Cylinder Head Inlet
            %     RTD_1 --> Displacer Cylinder Head Outlet
            %     RTD_2 --> Heater Inlet
            %     RTD_3 --> Heater Outlet
            %     RTD_4 --> Cooler Inlet
            %     RTD_5 --> Cooler Outlet
            %     RunConditions(i).SourceTemp = mean([RD_DATA(i).Tsource_in, RD_DATA(i).Tsource_out]) + 273.15; % Celsius to K
            %     RunConditions(i).SinkTemp = mean([RD_DATA(i).Tsink_in, RD_DATA(i).Tsink_out]) + 273.15;
            RunConditions(n).EnginePressure = p + p_environment;
            RunConditions(n).title = [model{i} '_TH' num2str(TH) '_TC' num2str(TC) '_p' num2str(p/1000) '_rpm' num2str(s)];
        n = n+1;
        end
    end
end


disp("Running Test Set with " + length(RunConditions) + " Cases.")
end

