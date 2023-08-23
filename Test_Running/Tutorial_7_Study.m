%{
    This file is an example study file that can be used as a starting point for
    running your own optimization studies. It includes all possible parameters to modify and
    the correct set up for creating the RunConditions struct. This file is only a
    template, the parameters will likely not run.
%}
function [RunConditions] = Tutorial_7_Study() % Function name must match filename

%% Set run conditions
% Every element should be a single value
simulation_time = 1; % The time the engine will run for in seconds (this is model time, not the simulation time)
engine_speed = 100; % The engine speed in RPM
max_timestep = 0.1; % The maximum timestep between iterations of the simulation in seconds
source_temperature = 150 + 273.15; % The temperature of the source in the model (includes constant temperature bodies and any sources in matrices)
sink_temperature = 5 + 273.15; % The temperature of the sink in the model (includes constant temperature bodies and any sources in matrices)
engine_pressure = 1000000; % The pressure of the engine in Pa
node_factor = 1; % The node derefinement factor (see documentation for more details)


%% Set study conditions (if you want them to be optimized, if not, remove them from the RunConditions struct below)
pressure_bounds = [900, 1100] .* 1000; % The minimum and maximum pressure bounds for optimization in Pa;
engine_speed_bounds = [90, 110]; % The minimum and maximum speed bounds for optimization in RPM;


%% Create run conditions struct
% DO NOT PUT ANY ARRAYS
RunConditions= struct(...
    'simTime', simulation_time,...
    'rpm', engine_speed,...
    'max_dt', max_timestep,...
    'SourceTemp', source_temperature,...
    'SinkTemp', sink_temperature,...
    'EnginePressure', engine_pressure,...
    'NodeFactor', node_factor,...
    'PressureBounds', pressure_bounds,...
    'SpeedBounds', engine_speed_bounds);

end

