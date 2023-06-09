function [RunConditions] = Raphael_Helium_Testing_Full()
% Written by Steven Middleton
% Experimental data extraction added by Connor Speer, September 2021.
% Debuged and finalized by Sara Eghbali, 24 Sep 2021
% The purpose of this function is to extract the operating points from a
% set of experimental data and reconfigure it for use in MSPM. This will
% allow quick comparison plots to be made.

%% Input Parameters
% Name of experimental data files.
model = {
    'Raphael New HX - Air',...
    'Raphael New HX - Helium 100',...
    'Raphael New HX - Helium 99',...
    'Raphael New HX - Helium 95',...
    }; % Name of MSPM model geometry.

pressures = [300 345 390 435 480 525 570] .*1000; % [Pa]
speeds = [100 135 170 205 240 275 310 345 380 415 450 485 520]; % [rpm]
simTime = 600; %(s) Simulation time.
minCycles = 10; % minimum number of engine cycles to complete before turning to steady state.
SS = true; % Steady state toggle.
movement_option = 'C';
max_dt = 0.1; %(s) Maximum time step.
NodeFactor = 1;


%% Create MSPM Test Structure

RunConditions_temp = struct(... %Default values
    'Model', model{1},...
    'title', 'Raphael_New_HX',...
    'simTime', simTime,... [s]
    'minCycles', minCycles,...
    'SS', SS,...
    'movement_option', movement_option,...
    'rpm', 60,... [rpm]
    'max_dt', max_dt,... [s]
    'EnginePressure',101325*10,...
    'SourceTemp',150 + 273.15,... [K]
    'SinkTemp',5 + 273.15,... [K]
    'NodeFactor', NodeFactor); %,...


n=1;
for i = 1:length(model)
    for speed = 1:length(speeds)
        for pressure = 1:length(pressures)
            RunConditions(n) = RunConditions_temp;
            RunConditions(n).Model = model{i};
            RunConditions(n).rpm = speeds(speed);
            RunConditions(n).EnginePressure = pressures(pressure);
            RunConditions(n).title = convertStringsToChars(strcat(model{i}, "_RPM-", num2str(speeds(speed)), "_P-", num2str(pressures(pressure))));
            n = n+1;
        end
    end
end

disp("Running Test Set with " + length(RunConditions) + " Cases."+newline)
end

