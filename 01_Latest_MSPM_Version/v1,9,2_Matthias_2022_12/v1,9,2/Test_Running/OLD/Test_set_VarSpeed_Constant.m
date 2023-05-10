function [runs] = Test_set_VarSpeed_Constant()
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
runs(4) = struct(...
  'Model','EP_1 0,09 DP e0 PP e0',...
  'title','',...
  'simTime',4000,... [s]
  'SS',true,...
  'movement_option','C',...
  'rpm',60,... [rpm]
  'max_dt',0.1,... [s]
	'SourceTemp',90 + 273.15,... [K]
  'SinkTemp',5 + 273.15,... [K]
  'EnginePressure',101325);
for i = 1:length(runs)-1
  runs(i) = runs(end);
end

%{
StrSpeeds = {'0,2','0,555767', '0,6007', ...
  '0,702133', '0,905133', '1,089633', ...
  '1,19915', '1,271017',  '1,40555', ...
  '1,582467', '1,8132', '2,0'};
NumSpeeds = [12, 33.346, 36.042, 42.128, ...
  54.308, 65.378, 71.949, 76.261, ...
  84.333, 94.948, 108.792, 120];
%}
% StrSpeeds = {'1,130698'};
% NumSpeeds = [67.84188];
% 
% for i = 1:length(StrSpeeds)
%   runs(i).Model = 'EP_1 0,09 DP e0 PP e0 - 30P';
%   runs(i).title = ['90_5, atmos, ' StrSpeeds{i} ...
%     ' hz Variable, EP-1 0,09 DP e0 PP e0'];
%   runs(i).movement_option = 'V';
%   runs(i).rpm = NumSpeeds(i);
% end

offset = 0;%length(StrSpeeds);

StrSpeeds = {'1,918805','1,130698'};
NumSpeeds = [115.1283, 67.84188];

for i = 1:length(StrSpeeds)
  runs(i+offset).Model = 'EP_1 0,09 DP e0 PP e0 - 30P';
  runs(i+offset).title = ['90_5, atmos, ' StrSpeeds{i} ...
    ' hz Variable, EP-1 0,09 DP e0 PP e0'];
  runs(i+offset).rpm = NumSpeeds(i);
end

offset = offset + length(StrSpeeds);
%{
StrSpeeds = {'0,2', '0,4', '0,58195', '0,88175', ...
  '0,95585', '1,044483333', ...
  '1,14245', '1,24065', '1,4333',...
  '1,51405', '1,6444', '1,826466667', ...
  '2'};
NumSpeeds = [12, 24, 34.917, 52.905, 57.351, 62.669, ...
  68.547, 74.439, 85.998, 90.843, ...
  98.664, 109.588, 120];
%}
StrSpeeds = {'1,346884', '0,602163'};
NumSpeeds = [80.81304, 36.12978];
for i = 1:length(StrSpeeds)
  runs(i+offset).Model = 'EP_1 0,09 DP e1_5B PP e1_5B - 30P';
  runs(i+offset).title = ['90_5, atmos, ' StrSpeeds{i} ...
    ' hz Variable, EP-1 0,09 DP e1_5B PP e0'];
  runs(i+offset).rpm = NumSpeeds(i);
end

end


