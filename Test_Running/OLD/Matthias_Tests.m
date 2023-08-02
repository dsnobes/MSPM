function [RunConditions] = Matthias_Tests()
%rpm = [0.5, 1:5];
rpm = [1.5:3.5];
atm = [1:0.5:3, 4:10];
n_rpm = length(rpm);
n_p = length(atm);
n = n_rpm*n_p;
RunConditions(n) = struct(...
    'Model','AA_Beta_2,5atm_3Hz_5in_95C_5C_18DP - Eff - Optimized',...
    'title','',...
    'simTime',60,... [s]
    'SS',true,...
    'movement_option','C',...
    'rpm',60,... [rpm]
    'max_dt',0.1,... [s]
    'SourceTemp',95 + 273.15,... [K]
    'SinkTemp',5 + 273.15,... [K]
    'EnginePressure',101325,...
    'NodeFactor',1,...
    'Uniform_Scale',1,...
    'HX_Convection', 1);
%'PressureBounds',[101325 10*101325],...
%'SpeedBounds',[20 1000]);
for i = 1:n
    RunConditions(i) = RunConditions(end);
end

for j = 1:n_p
    for i = 1:n_rpm
        ind = i+(j-1)*n_rpm;
        RunConditions(ind).rpm = rpm(i)*60;
        RunConditions(ind).EnginePressure = atm(j)*101325;
        RunConditions(ind).title = ['Efficiency Optimized, Pmean- ' num2str(atm(j)) ', rpm- ' num2str(rpm(i))];
    end
end
end

