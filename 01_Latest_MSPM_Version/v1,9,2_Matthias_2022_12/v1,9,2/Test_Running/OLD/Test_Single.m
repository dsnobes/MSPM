function [runs] = Test_Single()
% title: String: Filename under which the test data will be saved
% simTime: double: Maximum simulation time over which the model will run
% SS: logical:  True/False on whether or not the model will stop on steady state
% movement_option: character: 'C' Continuous, 'V' Variable Speed
% rpm: Starting speed in RPMS
% max_dt = maximum timestep used by the model
% SourceTemp = Source Temperature assigned to model
% SinkTemp = Sink Temperature assigned to model
% EnginePressure = Pressure assigned to internal gas zones

%% Default parameters
runs = struct(...
  'Model','EP_1 0,09 DP e0 PP e0',...
  'title','Test EP-1 0,09 DP e0 PP e0',...
  'simTime',2,... [s]
  'SS',true,...
  'movement_option','C',...
  'rpm',60,... [rpm]
  'max_dt',0.1,... [s]
	'SourceTemp',90 + 273.15,... [K]
  'SinkTemp',5 + 273.15,... [K]
  'EnginePressure',101325);

end

