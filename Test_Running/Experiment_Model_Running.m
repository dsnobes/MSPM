function [RunConditions] = Experiment_Model_Running()
    % Written by Steven Middleton
    % Experimental data extraction added by Connor Speer, September 2021.
    % Debuged and finalized by Sara Eghbali, 24 Sep 2021
    % The purpose of this function is to extract the operating points from a
    % set of experimental data and reconfigure it for use in MSPM. This will
    % allow quick comparison plots to be made.
    
    %% Input Parameters
    % Name of experimental data files.
    model = {
        'Raphael New HX - Fixed HX',...
        }; % Name of MSPM model geometry.
    
    
    % Load in extract file
    extract_file = "X:\03_COOP_and_Summer_Students\2023\Matteo Falsetti\Experiment Data Extract\21-Aug-2023_Extract.mat";
    load(extract_file, "extract_table");

    
    pressures = extract_table.p_abs; % [Pa]
    speeds = extract_table.encoder_speed; % [rpm]
    heater_temps = extract_table.avg_heater;
    cooler_temps = extract_table.avg_cooler;
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
        for cond = 1:length(speeds)
            RunConditions(n) = RunConditions_temp;
            RunConditions(n).Model = model{i};
            RunConditions(n).rpm = speeds(cond);
            RunConditions(n).EnginePressure = pressures(cond);
            RunConditions(n).SourceTemp = heater_temps(cond) + 273.15;
            RunConditions(n).SinkTemp = cooler_temps(cond) + 273.15;
            RunConditions(n).title = convertStringsToChars(strcat(model{i}, "_RPM-", num2str(floor(speeds(cond))), "_P-", num2str(floor(pressures(cond)))));
            n = n+1;

        end
    end
    
    disp("Running Test Set with " + length(RunConditions) + " Cases."+newline)
    end
    
    