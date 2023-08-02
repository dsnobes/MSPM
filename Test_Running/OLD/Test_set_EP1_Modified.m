function [runs] = Test_set_EP1_Modified()
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

%{
StrSpeeds = {'0,2','0,555767', '0,6007', ...
  '0,702133', '0,905133', '1,089633', ...
  '1,19915', '1,271017',  '1,40555', ...
  '1,582467', '1,8132', '2,0'};
NumSpeeds = [12, 33.346, 36.042, 42.128, ...
  54.308, 65.378, 71.949, 76.261, ...
  84.333, 94.948, 108.792, 120];
%}
% StrSpeeds = {'0,2','0,555767', '0,905133', '1,19915', '1,582467', '2,0', '2,5', '3,0', '4,0'};
% NumSpeeds = [12, 33.346, 54.308, 71.949, 94.948, 120, 150, 180, 240];
% 
% for i = 1:length(StrSpeeds)
%   runs(i).Model = 'EP_1 0,09 DP e1_5B PP e1_5B';
%   runs(i).title = ['90_5, atmos, ' StrSpeeds{i} ...
%     ' hz, EP-1 0,09 DP e1_5B PP e1_5B'];
%   runs(i).rpm = NumSpeeds(i);
% end

% offset = length(StrSpeeds);
% %{
% StrSpeeds = {'0,2', '0,4', '0,58195', '0,88175', ...
%   '0,95585', '1,044483333', ...
%   '1,14245', '1,24065', '1,4333',...
%   '1,51405', '1,6444', '1,826466667', ...
%   '2'};
% NumSpeeds = [12, 24, 34.917, 52.905, 57.351, 62.669, ...
%   68.547, 74.439, 85.998, 90.843, ...
%   98.664, 109.588, 120];
% %}
% StrSpeeds = {'0,2', '0,5820', '0,8818', '1,2407', '1,6444', '2', '2,5', '3,0', '4,0'};
% NumSpeeds = [12, 34.917, 52.905, 74.439, 98.664, 120, 150, 180, 240];
% for i = 1:length(StrSpeeds)
%   runs(i+offset).Model = 'EP_1 0,09 DP e1_5B PP e0';
%   runs(i+offset).title = ['90_5, atmos, ' StrSpeeds{i} ...
%     ' hz, EP-1 0,09 DP e1_5B PP e0'];
%   runs(i+offset).rpm = NumSpeeds(i);
% end

offset = 0;%offset + length(StrSpeeds);
%{
StrSpeeds = {'0,2', '0,4', '0,6', '0,8', '1,0', '1,105483333', ...
  '1,395783333', '1,5257', '1,66765', ...
  '1,873466667', '2,037716667', ...
  '2,260616667', '2,4'};
NumSpeeds = [12, 24, 36, 48, 60, 66.329, 83.747, ...
  91.542, 100.059, 112.408, 122.263, ...
  135.637, 144];
%}
% StrSpeeds = {'0,2', '0,6', '1,1055', '1,5257', '1,8735', '2,2606', '2,5', '3,0', '4,0'};
% NumSpeeds = [12, 36, 66.329, 91.542, 112.408, 135.637, 150, 180, 240];
StrSpeeds = {'1,1055', '1,5257', '1,8735', '2,2606'};
NumSpeeds = [66.329, 91.542, 112.408, 135.637];
for i = 1:length(StrSpeeds)
  runs(i+offset).Model = 'EP_1 0,09 DP e0 PP e0 - Modified';
  runs(i+offset).title = ['90_5, atmos, ' StrSpeeds{i} ...
    ' hz, EP-1 0,09 DP e0 PP e0 _ Modified'];
  runs(i+offset).rpm = NumSpeeds(i);
end

% offset = offset + length(StrSpeeds);
% StrSpeeds = {'0,2', '0,5', '1,0', '1,5', '2,0', '2,5', '3,0', '4,0'};
% NumSpeeds = [12, 30, 60, 90, 120, 150, 180, 240];
% for i = 1:length(StrSpeeds)
%   runs(i+offset).Model = 'EP_1 0,09 DP e1_5V PP e0';
%   runs(i+offset).title = ['90_5, atmos, ' StrSpeeds{i} ...
%     ' hz, EP-1 0,09 DP e1_5V PP e0'];
%   runs(i+offset).rpm = NumSpeeds(i);
% end
% 
% offset = offset + length(StrSpeeds);
% StrSpeeds = {'0,2', '0,5', '1,0', '1,5', '2,0', '2,5', '3,0', '4,0'};
% NumSpeeds = [12, 30, 60, 90, 120, 150, 180, 240];
% for i = 1:length(StrSpeeds)
%   runs(i+offset).Model = 'EP_1 0,09 DP e1_5V PP e1_5B';
%   runs(i+offset).title = ['90_5, atmos, ' StrSpeeds{i} ...
%     ' hz, EP-1 0,0 9DP e1_5V PP e1_5B'];
%   runs(i+offset).rpm = NumSpeeds(i);
% end
% 
% offset = offset + length(StrSpeeds);
% StrSpeeds = {'0,2', '0,5', '1,0', '1,5', '2,0', '2,5', '3,0', '4,0'};
% NumSpeeds = [12, 30, 60, 90, 120, 150, 180, 240];
% for i = 1:length(StrSpeeds)
%   runs(i+offset).Model = 'EP_1 0,09 DP e1_5V PP e1_5V';
%   runs(i+offset).title = ['90_5, atmos, ' StrSpeeds{i} ...
%     ' hz, EP-1 0,09 DP e1_5V PP e1_5V'];
%   runs(i+offset).rpm = NumSpeeds(i);
% end
% 
% offset = offset + length(StrSpeeds);
% StrSpeeds = {'0,2', '0,5', '1,0', '1,5', '2,0', '2,5', '3,0', '4,0'};
% NumSpeeds = [12, 30, 60, 90, 120, 150, 180, 240];
% for i = 1:length(StrSpeeds)
%   runs(i+offset).Model = 'EP_1 0,09 DP pureV PP pureB';
%   runs(i+offset).title = ['90_5, atmos, ' StrSpeeds{i} ...
%     ' hz, EP-1 0,09 DP pureV PP pureB'];
%   runs(i+offset).rpm = NumSpeeds(i);
% end
end


