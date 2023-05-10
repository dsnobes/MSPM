function [runs] = Test_set_SAGE()
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
runs(5) = struct(...
  'Model','EP_1 0,09 DP e1_5 PP e1_5',...
  'title','',...
  'simTime',10,... [s]
  'SS',true,...
  'movement_option','C',...
  'rpm',1000,... [rpm]
  'max_dt',0.01,... [s]
	'SourceTemp',150 + 273.15,... [K]
  'SinkTemp',40 + 273.15,... [K]
  'EnginePressure',5000000,...
  'NodeFactor',double(0.1));
for i = 1:length(runs)-1
  runs(i) = runs(end);
end

runs(1).Model = 'SAGE 135, 150 - HELIUM';
runs(1).title = runs(1).Model;
runs(1).SourceTemp = 150 + 273.15;

runs(2).Model = 'SAGE 165, 150 - HELIUM';
runs(2).title = runs(2).Model;
runs(2).SourceTemp = 150 + 273.15;

runs(3).Model = 'SAGE 90, 750 - HELIUM';
runs(3).title = runs(3).Model;
runs(3).SourceTemp = 750 + 273.15;

runs(4).Model = 'SAGE 135, 750 - HELIUM';
runs(4).title = runs(4).Model;
runs(4).SourceTemp = 750 + 273.15;

runs(5).Model = 'SAGE 165, 750 - HELIUM';
runs(5).title = runs(5).Model;
runs(5).SourceTemp = 750 + 273.15;

runs(1:4) = [];
end

