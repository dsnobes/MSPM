%% Extract voltage data from DAQ output and plot to analyse DAQ accuracy
% clear, close all

% path = 'X:\04_Stirling_Engine\16_Terrapin Engine (Raphael)\01_Experimental Data & Plots\2021-11-30_November 30th Calibration Data';
% usepath = path;
% 
% dirs = dir(fullfile(usepath, 'A*.txt'));
n = length(dirs);
stor{n} = [];

T_setpoint = 30:20:130;
T_ref = [30.6 50.4 70.4 90.3 110.5 130.6];
figure
hold on

for i = 1:n
    
    [TC_time, ~, ~, ~, ~, ~, ~, ~, ~, ~, TC1_temp, TC2_temp, ~, ~, ~, ~, ~]...
        = importfile_TC(fullfile(usepath, dirs(i).name));
%     [TC_time, ~, ~, ~, ~, ~, ~, ~, ~, ~, stor{i}(:,1), stor{i}(:,2), ~, ~, ~, ~, ~]...
%         = importfile_TC(fullfile(usepath, dirs(i).name));
    
    TC1(i) = mean(TC1_temp);
    TC2(i) = mean(TC2_temp);

    
end

plot(T_setpoint, T_ref-T_setpoint,'o', T_setpoint, TC1-T_setpoint, 'o', T_setpoint, TC2-T_setpoint, 'o')
legend('Reference Thermocouple', 'TC1', 'TC2')
xlabel('Setpoint Temp \circC')
ylabel('Deviation \circC')

