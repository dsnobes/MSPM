%{
    This file is an example test file that can be used as a starting point for
    running your own test sets. It includes all possible parameters to modify and
    the correct set up for creating the RunConditions struct. This file is only a
    template, the parameters will likely not run.
%}
function [RunConditions] = Test_File_Template() % Function name must match filename

%% Set run conditions
% It is possible to have every element of the following parameters be an array to have multiple values
model_names = {
    'Example Alpha'
    'Example Beta'
    'Example Gamma'
    };  % Model names
result_titles = '';  % Custom titles: Set as '' to use the model name as the title (ensure there are no name overlaps as the results will be overwritten)
simulation_time = 1200; % The time the engine will run for in seconds (this is model time, not the simulation time)
engine_speed = [60 120 240 480]; % The engine speed in RPM
max_timestep = 0.1; % The maximum timestep between iterations of the simulation in seconds
source_temperature = 150 + 273.15; % The temperature of the source in the model (includes constant temperature bodies and any sources in matrices)
sink_temperature = 5 + 273.15; % The temperature of the sink in the model (includes constant temperature bodies and any sources in matrices)
engine_pressure = [300 400 500] .* 1000; % The pressure of the engine in Pa
node_factor = 1; % The node derefinement factor (see documentation for more details)
hx_convection = 1; % The factor to modify the heat exchanger convection by
regenerator_convection = 1; % The factor to modify the regenerator convection by
outside_matrix_convection = 1; % The factor to modify convection outside a matrix by
friction_factor = 1; % The factor to modify friction by
solid_conduction_factor = 1; % The factor to modify solid conduction by
axial_mixing_coefficient = 1; % The coefficent to modify axial mixing
hx_c1 = 1; % Parameter C1 for custom heat exchangers
hx_c2 = 1; % Parameter C2 for custom heat exchangers
hx_c3 = 1; % Parameter C3 for custom heat exchangers
hx_c4 = 1; % Parameter C4 for custom heat exchangers
hx_surface_area_gas_volume_ratio = 1; % The surface area to gas volume ratio for custom heat exchangers
regenerator_c1 = 1; % Parameter C1 for custom regenerators
regenerator_c2 = 1; % Parameter C2 for custom regenerators
regenerator_c3 = 1; % Parameter C3 for custom regenerators
regenerator_c4 = 1; % Parameter C4 for custom regenerators
regenerator_surface_area_gas_volume_ratio = 1; % The surface area to gas volume ratio for custom regenerators
regenerator_porosity = 0.50; % The porosity for custom regenerators


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
    'NodeFactor', node_factor,...
    'HX_Convection', hx_convection,...
    'Regen_Convection', regenerator_convection,...
    'Outside_Matrix_Convection', outside_matrix_convection,...
    'Friction', friction_factor,...
    'Solid_Conduction', solid_conduction_factor,...
    'Axial_Mixing_Coefficient', axial_mixing_coefficient,...
    'HX_C1', hx_c1,...
    'HX_C2', hx_c2,...
    'HX_C3', hx_c3,...
    'HX_C4', hx_c4,...
    'HX_SA_V', hx_surface_area_gas_volume_ratio,...
    'Regen_C1', regenerator_c1,...
    'Regen_C2', regenerator_c2,...
    'Regen_C3', regenerator_c3,...
    'Regen_C4', regenerator_c4,...
    'Regen_SA_V', regenerator_surface_area_gas_volume_ratio,...
    'Regen_Porosity', regenerator_porosity);


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

