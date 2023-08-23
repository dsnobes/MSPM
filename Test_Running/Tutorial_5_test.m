%{
    This file is an example test file that can be used as a starting point for
    running your own test sets. It includes all possible parameters to modify and
    the correct set up for creating the RunConditions struct. This file is only a
    template, the parameters will likely not run.
%}
function [RunConditions] = Tutorial_5_test() % Function name must match filename

%% Set run conditions
% It is possible to have every element of the following parameters be an array to have multiple values
model_names = {
    'Sample Alpha - Tutorial 5'
    };  % Model names
result_titles = '';  % Custom titles: Set as '' to use the model name as the title (ensure there are no name overlaps as the results will be overwritten)
simulation_time = 10; % The time the engine will run for in seconds (this is model time, not the simulation time)
engine_speed = [60 120]; % The engine speed in RPM
max_timestep = 0.1; % The maximum timestep between iterations of the simulation in seconds
source_temperature = 150 + 273.15; % The temperature of the source in the model (includes constant temperature bodies and any sources in matrices)
sink_temperature = 5 + 273.15; % The temperature of the sink in the model (includes constant temperature bodies and any sources in matrices)
engine_pressure = [1000 1200] .* 1000; % The pressure of the engine in Pa
node_factor = 1; % The node derefinement factor (see documentation for more details)

%% Create run conditions template/defaults
% This is loaded when creating the run conditions struct
% It contains the default values or any constants across all runs
% DO NOT PUT ANY ARRAYS INTO THIS TEMPLATE
RunConditions_template = struct(...
    'Model','Example',...
    'title', result_titles,...
    'simTime', simulation_time,...
    'rpm', 1,...
    'max_dt', max_timestep,...
    'SourceTemp', source_temperature,...
    'SinkTemp', sink_temperature,...
    'EnginePressure', 1,...
    'NodeFactor', node_factor);


%% Creating the RunConditions struct
% The struct holds the individual structs for each run. Each individual struct must contain the nine required parameters
% The struct is created by loading the template then changing the parameters that change from run to run
% To do this, a nested loop for every element that changes is created, however it is possible to do this
% in other ways depending on your requirements. The only requirement is that the struct is complete and 
% a part of the RunConditions struct
% It is recommended to assign a custom title to each of the indivudal runs to prevent overwriting results

n=1;
% Nested loops
for i = 1:length(model_names)
    for speed = 1:length(engine_speed)
        for pressure = 1:length(engine_pressure)
            % Load in template struct
            RunConditions(n) = RunConditions_template;

            % Set the varying parameters
            RunConditions(n).Model = model_names{i};
            RunConditions(n).rpm = engine_speed(speed);
            RunConditions(n).EnginePressure = engine_pressure(pressure);

            % Set the custom title
            RunConditions(n).title = convertStringsToChars(strcat(model_names{i}, "_RPM-", num2str(engine_speed(speed)), "_P-", num2str(engine_pressure(pressure))));
            n = n+1;
        end
    end
end

disp("Running Test Set with " + length(RunConditions) + " Cases."+newline)
end

