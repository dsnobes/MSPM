function [runs] = Slow_SAGE()
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
runs(10) = struct(...
  'Model','SAGE Slow - HELIUM',...
  'title','',...
  'simTime',4000,... [s]
  'SS',true,...
  'movement_option','C',...
  'rpm',1000,... [rpm]
  'max_dt',0.01,... [s]
	'SourceTemp',95 + 273.15,... [K]
  'SinkTemp',5 + 273.15,... [K]
  'EnginePressure',101325,...
  'NodeFactor',1.0);
for i = 1:length(runs)-1
  runs(i) = runs(end);
end

rpms = [30 60 90 120 150 180 210 240 270 300];
for i = 1:10
  runs(i).title = ['SAGE ' num2str(rpms(i)) ' - HELIUM'];
  runs(i).rpm = rpms(i);
end

end

