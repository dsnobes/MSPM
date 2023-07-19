function [RunConditions] = Raphael_Scaling_All()
% Scaling test set for Raphael

%% Input Parameters
% Name of experimental data files.
model = {
    'Raphael New HX - Type 1 - Scale 1',...
    'Raphael New HX - Type 1 - Scale 2',...
    'Raphael New HX - Type 1 - Scale 5',...
    'Raphael New HX - Type 1 - Scale 10',...
    'Raphael New HX - Type 2 - Scale 1',...
    'Raphael New HX - Type 2 - Scale 2',...
    'Raphael New HX - Type 2 - Scale 5',...
    'Raphael New HX - Type 2 - Scale 10',...
    }; % Name of MSPM model geometry.

pressures = [300 435 570] .*1000; % [Pa]
speeds = [1 2 4 8 16 32 64 128 256 512]; % [rpm]
simTime = 1200; %(s) Simulation time.
minCycles = 5; % minimum number of engine cycles to complete before turning to steady state.
SS = true; % Steady state toggle.
movement_option = 'C';
max_dt = 0.1; %(s) Maximum time step.
NodeFactor = 1;


%% Create MSPM Test Structure

RunConditions_temp = struct(... %Default values
    'Model', model{1},...
    'title', 'Raphael_New_HX_Scaling_Type_1',...
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

