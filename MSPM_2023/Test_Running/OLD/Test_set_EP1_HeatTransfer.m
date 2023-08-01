function [runs] = Test_set_EP1_HeatTransfer()
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
runs(3) = struct(...
  'Model','EP_1 0,09 DP e0 PP e0 - Modified',...
  'title','',...
  'simTime',4000,... [s]
  'SS',true,...
  'movement_option','C',...
  'rpm',60,... [rpm]
  'max_dt',0.1,... [s]
	'SourceTemp',90 + 273.15,... [K]
  'SinkTemp',5 + 273.15,... [K]
  'EnginePressure',101325);%101325);
for i = 1:length(runs)-1
  runs(i) = runs(end);
end

StrSpeeds = '1,5257';
NumSpeeds = 112.408;
runs(1).Model = 'EP_1 0,09 DP e0 PP e0 - 10P';
runs(2).Model = 'EP_1 0,09 DP e0 PP e0 - 20P';
runs(3).Model = 'EP_1 0,09 DP e0 PP e0 - 30P';
for i = 1:3
  runs(i).title = [runs(i).Model ' - ' StrSpeeds];
  runs(i).rpm = NumSpeeds;
end

end


