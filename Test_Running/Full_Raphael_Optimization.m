%{
    This file is an example study file that can be used as a starting point for
    running your own optimization studies. It includes all possible parameters to modify and
    the correct set up for creating the RunConditions struct. This file is only a
    template, the parameters will likely not run.
%}
function [RunConditions] = Full_Raphael_Optimization() % Function name must match filename

%% Set run conditions
% Every element should be a single value
simulation_time = 1200; % The time the engine will run for in seconds (this is model time, not the simulation time)
engine_speed = 60; % The engine speed in RPM
max_timestep = 0.1; % The maximum timestep between iterations of the simulation in seconds
source_temperature = 150 + 273.15; % The temperature of the source in the model (includes constant temperature bodies and any sources in matrices)
sink_temperature = 5 + 273.15; % The temperature of the sink in the model (includes constant temperature bodies and any sources in matrices)
engine_pressure = 300000; % The pressure of the engine in Pa
node_factor = 1; % The node derefinement factor (see documentation for more details)

%% Set study conditions (if you want them to be optimized, if not, remove them from the RunConditions struct below)
pressure_bounds = [100, 1000] .* 1000; % The minimum and maximum pressure bounds for optimization in Pa;
engine_speed_bounds = [1, 1000]; % The minimum and maximum speed bounds for optimization in RPM;


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
    'Regen_Porosity', regenerator_porosity,...
    'PressureBounds', pressure_bounds,...
    'SpeedBounds', engine_speed_bounds);

end
