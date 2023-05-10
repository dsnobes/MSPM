function [runs] = OCT_6_Tests()
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
for i = 10:-1:1
    runs(i) = struct(...
      'Model','EP_1 0,09 DP e0 PP e0 - Clean',...
      'title','',...
      'simTime',4000,... [s]
      'SS',true,...
      'movement_option','C',...
      'rpm',60,... [rpm]
      'max_dt',0.1,... [s]
      'SourceTemp',90 + 273.15,... [K]
      'SinkTemp',5 + 273.15,... [K]
      'EnginePressure',101325,...
      'NodeFactor',1,...
      'Uniform_Scale',1);
end

runs(1).Model = 'EP_1 0,09 DP e0 PP e0 - All Metal';
runs(1).title = 'EP_1 e0e0 - metal';

runs(2).Model = 'EP_1 0,09 DP e0 PP e0 - All Plastic';
runs(2).title = 'EP_1 e0e0 - plastic';

runs(3).title = 'EP_1 e0e0 - baseline';
runs(4).EnginePressure = 101325 * 0.5;
runs(4).title = 'EP_1 e0e0 - 0,5 Atm';
runs(5).EnginePressure = 101325 * 1.5;
runs(5).title = 'EP_1 e0e0 - 1,5 Atm';
runs(6).EnginePressure = 101325 * 2.0;
runs(6).title = 'EP_1 e0e0 - 2,0 Atm';
runs(7).EnginePressure = 101325 * 3.0;
runs(7).title = 'EP_1 e0e0 - 3,0 Atm';
runs(8).EnginePressure = 101325 * 4.0;
runs(8).title = 'EP_1 e0e0 - 4,0 Atm';
runs(9).EnginePressure = 101325 * 6.0;
runs(9).title = 'EP_1 e0e0 - 6,0 Atm';
runs(10).EnginePressure = 101325 * 10.0;
runs(10).title = 'EP_1 e0e0 - 10,0 Atm';
end


