function calibrate(Raw_Data_Folder)

% Written by Connor Speer, September 2018
% Torque Sensor added, variables added, code for fits simplified by Matthias Lottmann, 2021

% This script uses the calibration data to adjust the raw log files and
% saves them as MATLAB files for future post processing. The MATLAB file 
% will contain information for the entire folder and share the folder's 
% name.

%% Input Parameters
PSI_to_Pa = 6894.757;

% RTD Calibration Data Folder
% RTD_Cal_Folder = 'G:\Shared drives\NOBES_GROUP\MSPM\[MATLAB_WORKING_FOLDER]\Data Processing Code\06_Post Processing_Experimental\[Experimental Data]\00_Calibration\October 6th Calibration Data\RTD';
RTD_Cal_Folder = 'G:\Shared drives\NOBES_GROUP\MSPM\[MATLAB_WORKING_FOLDER]\Data Processing Code\06_Post Processing_Experimental\[Experimental Data]\00_Calibration\Cal_2022_06_10\RTD';

% TC Calibration Data Folder
TC_Cal_Folder = 'G:\Shared drives\NOBES_GROUP\MSPM\[MATLAB_WORKING_FOLDER]\Data Processing Code\06_Post Processing_Experimental\[Experimental Data]\00_Calibration\Cal_2022_06_10\TC';

%% Preallocate Space For the DATA Structure
% Collect all the log file names from the RTD calibration data folder
log_files_info = dir(fullfile(Raw_Data_Folder, '*.txt'));
n_setpoints = length(log_files_info)/3;

C_DATA(n_setpoints).filename = [];
C_DATA(n_setpoints).time_RTD = [];
C_DATA(n_setpoints).RTD_0 = [];
C_DATA(n_setpoints).RTD_1 = [];
C_DATA(n_setpoints).RTD_2 = [];
C_DATA(n_setpoints).RTD_3 = [];
C_DATA(n_setpoints).RTD_4 = [];
C_DATA(n_setpoints).RTD_5 = [];
C_DATA(n_setpoints).RTD_6 = [];
C_DATA(n_setpoints).RTD_7 = [];
C_DATA(n_setpoints).time_TC = [];
C_DATA(n_setpoints).TC_0 = [];
C_DATA(n_setpoints).TC_1 = [];
C_DATA(n_setpoints).TC_2 = [];
C_DATA(n_setpoints).TC_3 = [];
C_DATA(n_setpoints).TC_4 = [];
C_DATA(n_setpoints).TC_5 = [];
C_DATA(n_setpoints).TC_6 = [];
C_DATA(n_setpoints).TC_7 = [];
C_DATA(n_setpoints).TC_8 = [];
C_DATA(n_setpoints).TC_9 = [];
C_DATA(n_setpoints).TC_10 = [];
C_DATA(n_setpoints).time_VC = [];
C_DATA(n_setpoints).theta = [];
C_DATA(n_setpoints).p_DCH = [];
C_DATA(n_setpoints).p_DM = [];
C_DATA(n_setpoints).p_PC = [];
C_DATA(n_setpoints).p_CC = [];
C_DATA(n_setpoints).p_PC_static = [];
C_DATA(n_setpoints).p_CC_static = [];
C_DATA(n_setpoints).MB_speed = [];
C_DATA(n_setpoints).MB_speed_transient = [];

C_DATA(n_setpoints).p_regulator = [];
C_DATA(n_setpoints).torque_sensor_transient = [];

% C_DATA(n_setpoints).dens_hot = []; 
% C_DATA(n_setpoints).dens_cold = []; 
% C_DATA(n_setpoints).c_hot = []; 
% C_DATA(n_setpoints).c_cold = []; 
C_DATA(n_setpoints).hot_bath_setpoint = [];
C_DATA(n_setpoints).cold_bath_setpoint = [];
C_DATA(n_setpoints).hot_liquid_flowrate = [];
C_DATA(n_setpoints).cold_liquid_flowrate = [];
C_DATA(n_setpoints).pmean_setpoint = [];
C_DATA(n_setpoints).torque_setpoint = [];
C_DATA(n_setpoints).teknic_setpoint = [];

%% Fit Curves to the Calibration Data (Only do this once)
% RTDs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --> Same procedure as TCs. See below.

% Collect all the log file names from the RTD calibration data folder
RTD_log_files_info = dir(fullfile(RTD_Cal_Folder, '*.txt'));

% Preallocate space for the structure array
RTD_DATA(length(RTD_log_files_info)).RTD_0_corr = [];
RTD_DATA(length(RTD_log_files_info)).RTD_1_corr = [];
RTD_DATA(length(RTD_log_files_info)).RTD_2_corr = [];
RTD_DATA(length(RTD_log_files_info)).RTD_3_corr = [];
RTD_DATA(length(RTD_log_files_info)).RTD_4_corr = [];
RTD_DATA(length(RTD_log_files_info)).RTD_5_corr = [];
RTD_DATA(length(RTD_log_files_info)).RTD_6_corr = [];
RTD_DATA(length(RTD_log_files_info)).RTD_7_corr = [];

% Initialize counter variable
counter = 1;
counter_max = 0.5*length(RTD_log_files_info);

WaitBar = waitbar(0,'Analyzing RTD calibration data...');

% Open Calibration Log Files
for i = 1:1:length(RTD_log_files_info)       
    filename_RTD = strcat(RTD_Cal_Folder,'\',RTD_log_files_info(i).name);
    [~,~,~,~,...
    ~,~,~,...
    ~,~,~,RTD_0,RTD_1,RTD_2,RTD_3,...
    RTD_4,RTD_5,RTD_6,RTD_7] = importfile_RTD(filename_RTD);
%     RTD_0 --> Displacer Cylinder Head Inlet
%     RTD_1 --> Displacer Cylinder Head Outlet
%     RTD_2 --> Heater Inlet
%     RTD_3 --> Heater Outlet
%     RTD_4 --> Cooler Inlet
%     RTD_5 --> Cooler Outlet
%     RTD_6 --> Power Cylinder Inlet
%     RTD_7 --> Power Cylinder Outlet

    % Calculate the average reading for each RTD
    RTD_DATA(counter).RTD_0_avg = mean(RTD_0); %(°C)
    RTD_DATA(counter).RTD_1_avg = mean(RTD_1); %(°C)
    RTD_DATA(counter).RTD_2_avg = mean(RTD_2); %(°C)
    RTD_DATA(counter).RTD_3_avg = mean(RTD_3); %(°C)
    RTD_DATA(counter).RTD_4_avg = mean(RTD_4); %(°C)
    RTD_DATA(counter).RTD_5_avg = mean(RTD_5); %(°C)
    RTD_DATA(counter).RTD_6_avg = mean(RTD_6); %(°C)
    RTD_DATA(counter).RTD_7_avg = mean(RTD_7); %(°C)
    
    % Calculate the "true" temperature as the average of all RTDs
    RTD_true = mean([mean(RTD_0) mean(RTD_1) mean(RTD_2) mean(RTD_3)  mean(RTD_5) mean(RTD_6) mean(RTD_7)]); %(°C)
    %mean(RTD_4)
    % Calculate the correction term for each RTD
    RTD_DATA(counter).RTD_0_corr = RTD_true - mean(RTD_0); %(°C)
    RTD_DATA(counter).RTD_1_corr = RTD_true - mean(RTD_1); %(°C)
    RTD_DATA(counter).RTD_2_corr = RTD_true - mean(RTD_2); %(°C)
    RTD_DATA(counter).RTD_3_corr = RTD_true - mean(RTD_3); %(°C)
    RTD_DATA(counter).RTD_4_corr = RTD_true - mean(RTD_4); %(°C)
    RTD_DATA(counter).RTD_5_corr = RTD_true - mean(RTD_5); %(°C)
    RTD_DATA(counter).RTD_6_corr = RTD_true - mean(RTD_6); %(°C)
    RTD_DATA(counter).RTD_7_corr = RTD_true - mean(RTD_7); %(°C)
        
    % Increment the counter variable
    counter = counter + 1;
    
    % Update Wait Bar
    waitbar(counter / counter_max)
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    RTD_true_log(i)=RTD_true;
end
close(WaitBar);

% Fit curves to correction terms
[fits.RTD_0, gofs.RTD_0] = fit([RTD_DATA.RTD_0_avg]',[RTD_DATA.RTD_0_corr]','poly3');
[fits.RTD_1, gofs.RTD_1] = fit([RTD_DATA.RTD_1_avg]',[RTD_DATA.RTD_1_corr]','poly3');
[fits.RTD_2, gofs.RTD_2] = fit([RTD_DATA.RTD_2_avg]',[RTD_DATA.RTD_2_corr]','poly3');
[fits.RTD_3, gofs.RTD_3] = fit([RTD_DATA.RTD_3_avg]',[RTD_DATA.RTD_3_corr]','poly3');
[fits.RTD_4, gofs.RTD_4] = fit([RTD_DATA.RTD_4_avg]',[RTD_DATA.RTD_4_corr]','poly3');
[fits.RTD_5, gofs.RTD_5] = fit([RTD_DATA.RTD_5_avg]',[RTD_DATA.RTD_5_corr]','poly3');
[fits.RTD_6, gofs.RTD_6] = fit([RTD_DATA.RTD_6_avg]',[RTD_DATA.RTD_6_corr]','poly3');
[fits.RTD_7, gofs.RTD_7] = fit([RTD_DATA.RTD_7_avg]',[RTD_DATA.RTD_7_corr]','poly3');

%%
% THESIS plots
% x = RTD_true_log;
% colors = {'k','b','r','g'};
% colors = repmat(colors,1,2);
% markers = repelem({'o','>'},4);
% 
% figure
% hold on
% xlabel('"True" reference temperature [\circC]')
% ylabel('Error before calibration [\circC]')
% for i=[0:3,5:7]
%     scatter(x, eval("-[RTD_DATA.RTD_"+i+"_corr]"), 30,colors{i+1}, markers{i+1})
% end
% nicefigure('thesis_half')
% 
% figure
% hold on
% xlabel('"True" reference temperature [\circC]')
% ylabel('Error after calibration [\circC]')
% for i=[0:3,5:7]
%     scatter(x, (eval("[RTD_DATA.RTD_"+i+"_avg] + fits.RTD_"+i+"([RTD_DATA.RTD_"+i+"_avg])'") - x), 30,colors{i+1}, markers{i+1})
% end
% nicefigure('thesis_half')

% Other plots
% figure
% plot(fits.RTD_0,[RTD_DATA.RTD_0_avg]',[RTD_DATA.RTD_0_corr]','*')
% xlabel('RTD 0 avg (°C)')
% ylabel('Correction Term (°C)')
%     
% figure
% plot(fits.RTD_1,[RTD_DATA.RTD_1_avg]',[RTD_DATA.RTD_1_corr]','*')
% xlabel('RTD 1 avg (°C)')
% ylabel('Correction Term (°C)')
% 
% figure
% plot(fits.RTD_2,[RTD_DATA.RTD_2_avg]',[RTD_DATA.RTD_2_corr]','*')
% xlabel('RTD 2 avg (°C)')
% ylabel('Correction Term (°C)')
% 
% figure
% plot(fits.RTD_3,[RTD_DATA.RTD_3_avg]',[RTD_DATA.RTD_3_corr]','*')
% xlabel('RTD 3 avg (°C)')
% ylabel('Correction Term (°C)')
% 
% figure
% plot(fits.RTD_4,[RTD_DATA.RTD_4_avg]',[RTD_DATA.RTD_4_corr]','*')
% xlabel('RTD 4 avg (°C)')
% ylabel('Correction Term (°C)')
% 
% figure
% plot(fits.RTD_5,[RTD_DATA.RTD_5_avg]',[RTD_DATA.RTD_5_corr]','*')
% xlabel('RTD 5 avg (°C)')
% ylabel('Correction Term (°C)')
% 
% figure
% plot(fits.RTD_6,[RTD_DATA.RTD_6_avg]',[RTD_DATA.RTD_6_corr]','*')
% xlabel('RTD 6 avg (°C)')
% ylabel('Correction Term (°C)')
% 
% figure
% plot(fits.RTD_7,[RTD_DATA.RTD_7_avg]',[RTD_DATA.RTD_7_corr]','*')
% xlabel('RTD 7 avg (°C)')
% ylabel('Correction Term (°C)')


%% Thermocouples %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --> Calculate the average temperature measurement at each calibration
% point.
% --> Take these average temperatures to be the "true" temperatures.
% --> Calculate the correction terms for each TC at each calibration point
% as the difference between the measured value and the "true" value.
% --> Fit curves to the correction terms of each TC.
% --> Use the equations of the curves to calculate the corresponding
% correction term for each TC measurement
% --> Add the correction terms to the measured data points to apply the
% calibration

% Collect all the log file names from the thermocouple test data folder
TC_log_files_info = dir(fullfile(TC_Cal_Folder, '*.txt'));

% Preallocate space for the structure array
TC_DATA(length(TC_log_files_info)).TC_0_corr = [];
TC_DATA(length(TC_log_files_info)).TC_1_corr = [];
TC_DATA(length(TC_log_files_info)).TC_2_corr = [];
TC_DATA(length(TC_log_files_info)).TC_3_corr = [];
TC_DATA(length(TC_log_files_info)).TC_4_corr = [];
TC_DATA(length(TC_log_files_info)).TC_5_corr = [];
TC_DATA(length(TC_log_files_info)).TC_6_corr = [];
TC_DATA(length(TC_log_files_info)).TC_7_corr = [];
TC_DATA(length(TC_log_files_info)).TC_8_corr = [];
TC_DATA(length(TC_log_files_info)).TC_9_corr = [];
TC_DATA(length(TC_log_files_info)).TC_10_corr = [];

% Initialize counter variable
counter = 1;
counter_max = 0.5*length(TC_log_files_info);

WaitBar = waitbar(0,'Analyzing TC calibration data...');

% Open Calibration Log Files
for i = 1:1:length(TC_log_files_info)       
    filename_TC = strcat(TC_Cal_Folder,'\',TC_log_files_info(i).name);
    [~,TC_0,TC_1,TC_2,TC_3,TC_4,TC_5,TC_6,TC_7,TC_8,TC_9,...
    TC_10,~,~,~,~,~] = importfile_TC(filename_TC);
%     TC_0 --> Displacer Cylinder Head (Expansion Space)
%     TC_1 --> Heater/Expansion Space Interface, Bypass Side (Far Side)
%     TC_2 --> Heater/Expansion Space Interface, Connecting Pipe Side
%     TC_3 --> Regen/Heater Interface, Bypass Side
%     TC_4 --> Regen/Heater Interface, Connecting Pipe Side
%     TC_5 --> Cooler/Regenerator Interface, Bypass Side
%     TC_6 --> Cooler/Regenerator Interface, Connecting Pipe Side
%     TC_7 --> Compression Space/Cooler Interface, Bypass Side
%     TC_8 --> Compression Space/Cooler Interface, Connecting Pipe Side
%     TC_9 --> Power Cylinder
%     TC_10 --> Crankcase
%     TC_11 -->
%     TC_12 -->
%     TC_13 -->
%     TC_14 -->
%     TC_15 -->

    % Calculate the average reading for each thermocouple
    TC_DATA(counter).TC_0_avg = mean(TC_0); %(°C)
    TC_DATA(counter).TC_1_avg = mean(TC_1); %(°C)
    TC_DATA(counter).TC_2_avg = mean(TC_2); %(°C)
    TC_DATA(counter).TC_3_avg = mean(TC_3); %(°C)
    TC_DATA(counter).TC_4_avg = mean(TC_4); %(°C)
    TC_DATA(counter).TC_5_avg = mean(TC_5); %(°C)
    TC_DATA(counter).TC_6_avg = mean(TC_6); %(°C)
    TC_DATA(counter).TC_7_avg = mean(TC_7); %(°C)
    TC_DATA(counter).TC_8_avg = mean(TC_8); %(°C)
    TC_DATA(counter).TC_9_avg = mean(TC_9); %(°C)
    TC_DATA(counter).TC_10_avg = mean(TC_10); %(°C)
    
    % Calculate the "true" temperature as the average of all TCs
    TC_true = mean([mean(TC_0) mean(TC_1) mean(TC_2) mean(TC_4) ...
        mean(TC_5) mean(TC_6) mean(TC_7) mean(TC_8) mean(TC_9) mean(TC_10)]); %(°C)
    
    % Calculate the correction term for each TC
    TC_DATA(counter).TC_0_corr = TC_true - mean(TC_0); %(°C)
    TC_DATA(counter).TC_1_corr = TC_true - mean(TC_1); %(°C)
    TC_DATA(counter).TC_2_corr = TC_true - mean(TC_2); %(°C)
    TC_DATA(counter).TC_3_corr = TC_true - mean(TC_3); %(°C)
    TC_DATA(counter).TC_4_corr = TC_true - mean(TC_4); %(°C)
    TC_DATA(counter).TC_5_corr = TC_true - mean(TC_5); %(°C)
    TC_DATA(counter).TC_6_corr = TC_true - mean(TC_6); %(°C)
    TC_DATA(counter).TC_7_corr = TC_true - mean(TC_7); %(°C)
    TC_DATA(counter).TC_8_corr = TC_true - mean(TC_8); %(°C)
    TC_DATA(counter).TC_9_corr = TC_true - mean(TC_9); %(°C)
    TC_DATA(counter).TC_10_corr = TC_true - mean(TC_10); %(°C)

    % Increment the counter variable
    counter = counter + 1;
    
    % Update Wait Bar
    waitbar(counter / counter_max)
    %%%%%%%%%%%%%%%%%%%
    TC_true_log(i) = TC_true;
end
close(WaitBar);

% Fit curves to correction terms
[fits.TC_0, gofs.TC_0] = fit([TC_DATA.TC_0_avg]',[TC_DATA.TC_0_corr]','poly3');
[fits.TC_1, gofs.TC_1] = fit([TC_DATA.TC_1_avg]',[TC_DATA.TC_1_corr]','poly3');
[fits.TC_2, gofs.TC_2] = fit([TC_DATA.TC_2_avg]',[TC_DATA.TC_2_corr]','poly3');
[fits.TC_3, gofs.TC_3] = fit([TC_DATA.TC_3_avg]',[TC_DATA.TC_3_corr]','poly3');
[fits.TC_4, gofs.TC_4] = fit([TC_DATA.TC_4_avg]',[TC_DATA.TC_4_corr]','poly3');
[fits.TC_5, gofs.TC_5] = fit([TC_DATA.TC_5_avg]',[TC_DATA.TC_5_corr]','poly3');
[fits.TC_6, gofs.TC_6] = fit([TC_DATA.TC_6_avg]',[TC_DATA.TC_6_corr]','poly3');
[fits.TC_7, gofs.TC_7] = fit([TC_DATA.TC_7_avg]',[TC_DATA.TC_7_corr]','poly3');
[fits.TC_8, gofs.TC_8] = fit([TC_DATA.TC_8_avg]',[TC_DATA.TC_8_corr]','poly3');
[fits.TC_9, gofs.TC_9] = fit([TC_DATA.TC_9_avg]',[TC_DATA.TC_9_corr]','poly3');
[fits.TC_10, gofs.TC_10] = fit([TC_DATA.TC_10_avg]',[TC_DATA.TC_10_corr]','poly3');

%%
% % THESIS plots
% colors = {'k','b','r','g','m','c'};
% colors = repmat(colors,1,3);
% markers = repelem({'o','>','s'},6);
% 
% np = 1;
% ys = [];
% figure
% hold on
% xlabel('"True" reference temperature [\circC]')
% ylabel('Error before calibration [\circC]')
% for i=0:10
%     y = eval("-[TC_DATA.TC_"+i+"_corr]");
%     ys = [ys y];
%     scatter(TC_true_log, y, 30,colors{np}, markers{np})
%     np = np+1;
% end
% for i=[0:3,5:7]
%     y = eval("-[RTD_DATA.RTD_"+i+"_corr]");
%     ys = [ys y];
%     scatter(RTD_true_log, y, 30,colors{np}, markers{np})
%     np = np+1;
% end
% nicefigure('thesis_half')
% rsserror = rssq(ys);
% disp("RSS error before cali: "+rsserror)
% 
% np = 1;
% ys = [];
% figure
% hold on
% xlabel('"True" reference temperature [\circC]')
% ylabel('Error after calibration [\circC]')
% for i=0:10
%     y = eval("[TC_DATA.TC_"+i+"_avg] + fits.TC_"+i+"([TC_DATA.TC_"+i+"_avg])'") - TC_true_log;
%     ys = [ys y];
%     scatter(TC_true_log, y, 30,colors{np}, markers{np})
%     np = np+1;
% end
% for i=[0:3,5:7]
%     y = eval("[RTD_DATA.RTD_"+i+"_avg] + fits.RTD_"+i+"([RTD_DATA.RTD_"+i+"_avg])'") - RTD_true_log;
%     ys = [ys y];
%     scatter(RTD_true_log, y, 30,colors{np}, markers{np})
%     np = np+1;
% end
% nicefigure('thesis_small')
% rsserror = rssq(ys);
% disp(newline+"RSS error after cali: "+rsserror)
% 
% 
% % % Other plots
% figure
% plot(fits.TC_0,[TC_DATA.TC_0_avg]',[TC_DATA.TC_0_corr]','*')
% xlabel('TC 0 avg (°C)')
% ylabel('Correction Term (°C)')
% 
% figure
% plot(fits.TC_1,[TC_DATA.TC_1_avg]',[TC_DATA.TC_1_corr]','*')
% xlabel('TC 1 avg (°C)')
% ylabel('Correction Term (°C)')
% 
% figure
% plot(fits.TC_2,[TC_DATA.TC_2_avg]',[TC_DATA.TC_2_corr]','*')
% xlabel('TC 2 avg (°C)')
% ylabel('Correction Term (°C)')
% 
% figure
% plot(fits.TC_3,[TC_DATA.TC_3_avg]',[TC_DATA.TC_3_corr]','*')
% xlabel('TC 3 avg (°C)')
% ylabel('Correction Term (°C)')
% 
% figure
% plot(fits.TC_4,[TC_DATA.TC_4_avg]',[TC_DATA.TC_4_corr]','*')
% xlabel('TC 4 avg (°C)')
% ylabel('Correction Term (°C)')
% 
% figure
% plot(fits.TC_5,[TC_DATA.TC_5_avg]',[TC_DATA.TC_5_corr]','*')
% xlabel('TC 5 avg (°C)')
% ylabel('Correction Term (°C)')
% 
% figure
% plot(fits.TC_6,[TC_DATA.TC_6_avg]',[TC_DATA.TC_6_corr]','*')
% xlabel('TC 6 avg (°C)')
% ylabel('Correction Term (°C)')
% 
% figure
% plot(fits.TC_7,[TC_DATA.TC_7_avg]',[TC_DATA.TC_7_corr]','*')
% xlabel('TC 7 avg (°C)')
% ylabel('Correction Term (°C)')
% 
% figure
% plot(fits.TC_8,[TC_DATA.TC_8_avg]',[TC_DATA.TC_8_corr]','*')
% xlabel('TC 8 avg (°C)')
% ylabel('Correction Term (°C)')
% 
% figure
% plot(fits.TC_9,[TC_DATA.TC_9_avg]',[TC_DATA.TC_9_corr]','*')
% xlabel('TC 9 avg (°C)')
% ylabel('Correction Term (°C)')
% 
% figure
% plot(fits.TC_10,[TC_DATA.TC_10_avg]',[TC_DATA.TC_10_corr]','*')
% xlabel('TC 10 avg (°C)')
% ylabel('Correction Term (°C)')

%% Dynamic Pressure Transducers %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --> Same procedure as static pressure

% Calibration Data for LW37338 Transducer
PSI_LW37338 = [1 2 3 4 5 10 20 30 40 50]; %(psig)
Vdc_LW37338 = [0.0996 0.1988 0.2971 0.3960 0.4940 0.989 1.986 2.985 3.975 4.980]; % Calibration outputs in (Volts)

[fits.DP_LW37338, gofs.DP_LW37338] = fit(Vdc_LW37338',PSI_LW37338','poly1');

% Calibration Data for LW37354 Transducer
PSI_LW37354 = [1 2 3 4 5 10 20 30 40 50]; %(psig)
Vdc_LW37354 = [0.101 0.202 0.302 0.403 0.502 1.016 2.028 3.041 4.052 5.073]; % Calibration outputs in (Volts)

[fits.DP_LW37354, gofs.DP_LW37354] = fit(Vdc_LW37354',PSI_LW37354','poly1');

% Calibration Data for LW37355 Transducer
PSI_LW37355 = [1 2 3 4 5 10 20 30 40 50]; %(psig)
Vdc_LW37355 = [0.102 0.205 0.306 0.409 0.510 1.029 2.056 3.088 4.118 5.151]; % Calibration outputs in (Volts)

[fits.DP_LW37355, gofs.DP_LW37355] = fit(Vdc_LW37355',PSI_LW37355','poly1');
 
% Calibration Data for LW37337 Transducer
PSI_LW37337 = [1 2 3 4 5 10 20 30 40 50]; %(psig)
Vdc_LW37337 = [0.0951 0.1905 0.2870 0.3805 0.4761 0.953 1.903 2.863 3.816 4.751]; % Calibration outputs in (Volts)

[fits.DP_LW37337, gofs.DP_LW37337] = fit(Vdc_LW37337',PSI_LW37337','poly1');

% figure
% plot(fits.DP_LW37337)
% hold on
% plot(Vdc_LW37337, fits.DP_LW37337(Vdc_LW37337),'o');
% plot(-Vdc_LW37337, fits.DP_LW37337(-Vdc_LW37337),'o');
% legend('1','2','3')

%% Static Pressure Transducers %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --> Fit curve to calibration data to get an equation that converts
% voltage to Pa for each transducer
% --> Use equations to convert measured voltages into pressures

% Calibration Data for 772967 Transducer
PSI_772967 = [0 40 80 120 160 200 0]; %(psig)
Vdc_772967 = [0.000 2.006 4.002 5.998 7.986 9.968 0.000]; % Calibration outputs in (Volts)

fits.SP_772967 = fit(Vdc_772967',PSI_772967','poly1');

% Calibration Data for 772966 Transducer
PSI_772966 = [0 40 80 120 160 200 0]; %(psig)
Vdc_772966 = [0.000 2.008 4.010 6.002 7.987 9.971 0.000]; % Calibration outputs in (Volts)

fits.SP_772966 = fit(Vdc_772966',PSI_772966','poly1');

%% Torque Sensor (Futek TRS600 - FSH01997 10Nm) %%%%%%%%%%%%%%%%%%%%%%%%%%%
NM_TRS600 = [0 1.695 3.389 5.084 6.779 8.474 9.999 0];
Vdc_TRS600 = [0 0.846 1.698 2.543 3.391 4.238 5.001 0.013];
% using only points for 0, 1.695, 0 Nm since others are out of experiment range
fits.TRS600 = fit(Vdc_TRS600([1,2,end])', NM_TRS600([1,2,end])','poly1');

%% Convert Raw Measured Data into Calibrated Data
% --> Do this in a loop that repeats for every log file in the specified
% folder.

% Collect all the log file names from the raw data folder
Raw_Data_Files_Info = dir(fullfile(Raw_Data_Folder, '*.txt'));

% Initialize counter variable
counter = 1;

% Open Raw Data Files, Calibrate, and Save
for i = 1:3:length(Raw_Data_Files_Info)       
    filename_RTD = strcat(Raw_Data_Folder,'\',Raw_Data_Files_Info(i).name);
    
    [~,~,hot_bath_setpoint,cold_bath_setpoint,...
    hot_liquid_flowrate,cold_liquid_flowrate,pmean_setpoint,...
    torque_setpoint,teknic_setpoint,RTD_time,RTD_0_raw,RTD_1_raw,RTD_2_raw,RTD_3_raw,...
    RTD_4_raw,RTD_5_raw,RTD_6_raw,RTD_7_raw] = importfile_RTD(filename_RTD);
%     RTD_0 --> Displacer Cylinder Head Inlet
%     RTD_1 --> Displacer Cylinder Head Outlet
%     RTD_2 --> Heater Inlet
%     RTD_3 --> Heater Outlet
%     RTD_4 --> Cooler Inlet
%     RTD_5 --> Cooler Outlet
%     RTD_6 --> Power Cylinder Inlet
%     RTD_7 --> Power Cylinder Outlet

    % Time for RTDs   
    time_inc_RTD = (RTD_time(end)-RTD_time(1))/length(RTD_time); %(s)
    N_RTD = length(RTD_time);
    time_RTD = (0:N_RTD-1)*time_inc_RTD;
    time_RTD = time_RTD(:);
    %Use this if data has jump in time (e.g. several txt files stitched together)
% time_RTD = RTD_time-RTD_time(1);
    
    filename_TC = strcat(Raw_Data_Folder,'\',Raw_Data_Files_Info(i+1).name);
    [TC_time,TC_0_raw,TC_1_raw,TC_2_raw,TC_3_raw,TC_4_raw,TC_5_raw,...
     TC_6_raw,TC_7_raw,TC_8_raw,TC_9_raw,TC_10_raw,~,~,...
     ~,~,~] = importfile_TC(filename_TC);
%     TC_0 --> Displacer Cylinder Head (Expansion Space)
%     TC_1 --> Heater/Expansion Space Interface, Bypass Side
%     TC_2 --> Heater/Expansion Space Interface, Connecting Pipe Side
%     TC_3 --> Regen/Heater Interface, Bypass Side
%     TC_4 --> Regen/Heater Interface, Connecting Pipe Side
%     TC_5 --> Cooler/Regenerator Interface, Bypass Side
%     TC_6 --> Cooler/Regenerator Interface, Connecting Pipe Side
%     TC_7 --> Compression Space/Cooler Interface, Bypass Side
%     TC_8 --> Compression Space/Cooler Interface, Connecting Pipe Side
%     TC_9 --> Power Cylinder
%     TC_10 --> Crankcase
%     TC_11 -->
%     TC_12 -->
%     TC_13 -->
%     TC_14 -->
%     TC_15 -->

    % Time for Thermocouples   
    time_inc_TC = (TC_time(end)-TC_time(1))/length(TC_time); %(s)
    N_TC = length(TC_time);
    time_TC = (0:N_TC-1)*time_inc_TC;
    time_TC = time_TC(:);
%Use this if data has jump in time (e.g. several txt files stitched together)
%         time_TC = TC_time-TC_time(1);
    filename_Volt_Count = strcat(Raw_Data_Folder,'\',Raw_Data_Files_Info(i+2).name);
    [VC_time,ctr0,AI_0_raw,AI_1_raw,AI_2_raw,AI_3_raw,AI_4_raw,AI_5_raw,AI_6_raw,...
     AI_7_raw,AI16_raw,~,~,~,~,~,...
     ~,~] = importfile_Volt_Count(filename_Volt_Count);
%     ctr0 --> 500 PPR Rotary Encoder Output
%     AI_0 --> Displacer Cylinder Head Dynamic Pressure
%     AI_1 --> Displacer Mount Dynamic Pressure
%     AI_2 --> Power Cylinder Dynamic Pressure     
%     AI_3 --> Crankcase Dynamic Pressure
%     AI_4 --> Power Cylinder Static Pressure
%     AI_5 --> Crankcase Static Pressure
%     AI_6 --> Speed Output Signal from Magnetic Brake
%     AI_7 --> Pressure Measurement Output from Regulator
%     AI_16 --> Torque Sensor (Futek TRS600 - FSH01997 10Nm) torque signal
%     AI_17 -->
%     AI_18 -->
%     AI_19 -->
%     AI_20 -->
%     AI_21 -->
%     AI_22 -->
%     AI_23 -->

    % Time for Voltages and Counter    
    time_inc_VC = (VC_time(end)-VC_time(1))/length(VC_time); %(s)
    N_VC = length(VC_time);
    time_VC = (0:N_VC-1)*time_inc_VC;
    time_VC = time_VC(:); %(s)
%Use this if data has jump in time (e.g. several txt files stitched together)
%         time_VC = VC_time-VC_time(1);

    
    % Apply calibration to RTDs
    corr_terms_RTD_0 = fits.RTD_0(RTD_0_raw); %(°C)
    RTD_0 = RTD_0_raw + corr_terms_RTD_0; %(°C)
    
        corr_terms_RTD_1 = fits.RTD_1(RTD_1_raw); %(°C)
    RTD_1 = RTD_1_raw + corr_terms_RTD_1; %(°C)

        corr_terms_RTD_2 = fits.RTD_2(RTD_2_raw); %(°C)
    RTD_2 = RTD_2_raw + corr_terms_RTD_2; %(°C)

        corr_terms_RTD_3 = fits.RTD_3(RTD_3_raw); %(°C)
    RTD_3 = RTD_3_raw + corr_terms_RTD_3; %(°C)

        corr_terms_RTD_4 = fits.RTD_4(RTD_4_raw); %(°C)
%     RTD_4 = RTD_4_raw + corr_terms_RTD_4; %(°C)
    %% Disable calibration for RTD 4 as there is  no cal data at its temp range.
    RTD_4 = RTD_4_raw; %(°C)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        corr_terms_RTD_5 = fits.RTD_5(RTD_5_raw); %(°C)
    RTD_5 = RTD_5_raw + corr_terms_RTD_5; %(°C)

        corr_terms_RTD_6 = fits.RTD_6(RTD_6_raw); %(°C)
    RTD_6 = RTD_6_raw + corr_terms_RTD_6; %(°C)

        corr_terms_RTD_7 = fits.RTD_7(RTD_7_raw); %(°C)
    RTD_7 = RTD_7_raw + corr_terms_RTD_7; %(°C)
   
    % Apply calibration to TCs
    corr_terms_TC_0 = fits.TC_0(TC_0_raw); %(°C)
    TC_0 = TC_0_raw + corr_terms_TC_0; %(°C)

    corr_terms_TC_1 = fits.TC_1(TC_1_raw); %(°C)
    TC_1 = TC_1_raw + corr_terms_TC_1; %(°C)

    corr_terms_TC_2 = fits.TC_2(TC_2_raw); %(°C)
    TC_2 = TC_2_raw + corr_terms_TC_2; %(°C)

    corr_terms_TC_3 = fits.TC_3(TC_3_raw); %(°C)
    TC_3 = TC_3_raw + corr_terms_TC_3; %(°C)

    corr_terms_TC_4 = fits.TC_4(TC_4_raw); %(°C)
    TC_4 = TC_4_raw + corr_terms_TC_4; %(°C)

    corr_terms_TC_5 = fits.TC_5(TC_5_raw); %(°C)
    TC_5 = TC_5_raw + corr_terms_TC_5; %(°C)

    corr_terms_TC_6 = fits.TC_6(TC_6_raw); %(°C)
    TC_6 = TC_6_raw + corr_terms_TC_6; %(°C)
    
    corr_terms_TC_7 = fits.TC_7(TC_7_raw); %(°C)
    TC_7 = TC_7_raw + corr_terms_TC_7; %(°C)
    
    corr_terms_TC_8 = fits.TC_8(TC_8_raw); %(°C)
    TC_8 = TC_8_raw + corr_terms_TC_8; %(°C)

    corr_terms_TC_9 = fits.TC_9(TC_9_raw); %(°C)
    TC_9 = TC_9_raw + corr_terms_TC_9; %(°C)
    
    corr_terms_TC_10 = fits.TC_10(TC_10_raw); %(°C)
    TC_10 = TC_10_raw + corr_terms_TC_10; %(°C)
    
    % Apply calibration to static pressure transducers
    SP_772967 = fits.SP_772967(AI_4_raw) *PSI_to_Pa; %(Pa)
    
    SP_772966 = fits.SP_772966(AI_5_raw) *PSI_to_Pa; %(Pa)
    
    % Apply calibration to dynamic pressure transducers
    DP_LW37338 = fits.DP_LW37338(AI_0_raw) *PSI_to_Pa; %(Pa)

    DP_LW37354 = fits.DP_LW37354(AI_1_raw) *PSI_to_Pa; %(Pa)
    
    DP_LW37355 = fits.DP_LW37355(AI_2_raw) *PSI_to_Pa; %(Pa)

    DP_LW37337 = fits.DP_LW37337(AI_3_raw) *PSI_to_Pa; %(Pa)
   
    % Apply calibration for Torque Sensor Measurement (10 Nm / 5 Volt)
    torque_sensor_transient = fits.TRS600(AI16_raw); % (Nm)

    
    % Add Static and Dynamic Pressure Measurements
%%%%%%% Standard setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     p_DCH --> Displacer Cylinder Head Pressure, transducers LW37338 and 772967 (Pa)
    p_DCH = mean(SP_772967) + DP_LW37338; %(Pa)
    
%     p_DM --> Displacer Mount Pressure, transducers LW37354 and 772967 (Pa)
    p_DM = mean(SP_772967) + DP_LW37354; %(Pa)
    
%     p_PC --> Power Cylinder Pressure, transducers LW37355 and 772967 (Pa)
    p_PC = mean(SP_772967) + DP_LW37355; %(Pa)
    
%     p_CC --> Crankcase Pressure, transducers LW37337 and 772966 (Pa)
    p_CC = mean(SP_772966) + DP_LW37337; %(Pa)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % %%%%%%% Setup 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     p_DCH = mean(SP_772967) + DP_LW37354; %(Pa)
%     p_DM = mean(SP_772967) + DP_LW37338; %(Pa)
%     p_PC = mean(SP_772967) + DP_LW37355; %(Pa)
%     p_CC = mean(SP_772966) + DP_LW37337; %(Pa)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%% Setup 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     p_DCH = mean(SP_772967) + DP_LW37355; %(Pa)
%     p_DM = mean(SP_772967) + DP_LW37338; %(Pa)
%     p_PC = mean(SP_772967) + DP_LW37354; %(Pa)
%     p_CC = mean(SP_772966) + DP_LW37337; %(Pa)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% %%%%%%% Setup 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     p_DCH = mean(SP_772967) + DP_LW37338; %(Pa)
%     p_DM = mean(SP_772967) + DP_LW37355; %(Pa)
%     p_PC = mean(SP_772967) + DP_LW37337; %(Pa)
%     p_CC = mean(SP_772966) + DP_LW37354; %(Pa)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%%%%%%% Setup 4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     p_DCH = mean(SP_772967) + DP_LW37337; %(Pa)
%     p_DM = mean(SP_772967) + DP_LW37355; %(Pa)
%     p_PC = mean(SP_772967) + DP_LW37338; %(Pa)
%     p_CC = mean(SP_772966) + DP_LW37354; %(Pa)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Convert crank angles from degrees to radians.
    theta = ctr0*(pi/180); % (rad)

    % Magnetic Brake Speed Output (250 RPM/volt)
    MB_speed_transient = AI_6_raw*250;
    MB_speed = mean(MB_speed_transient); % Speed Output Signal from Magnetic Brake (RPM)
    
    % Regulator Measured Pressure (15 PSI/Volt)
    p_regulator = AI_7_raw *15 *PSI_to_Pa; % (Pa)
    

    %% Store Results in Output Structure
    C_DATA(counter).filename = Raw_Data_Files_Info(i).name;
    C_DATA(counter).time_RTD = time_RTD;
    C_DATA(counter).RTD_0 = RTD_0;
    C_DATA(counter).RTD_1 = RTD_1;
    C_DATA(counter).RTD_2 = RTD_2;
    C_DATA(counter).RTD_3 = RTD_3;
    C_DATA(counter).RTD_4 = RTD_4;
    C_DATA(counter).RTD_5 = RTD_5;
    C_DATA(counter).RTD_6 = RTD_6;
    C_DATA(counter).RTD_7 = RTD_7;
    C_DATA(counter).time_TC = time_TC;
    C_DATA(counter).TC_0 = TC_0;
    C_DATA(counter).TC_1 = TC_1;
    C_DATA(counter).TC_2 = TC_2;
    C_DATA(counter).TC_3 = TC_3; % <-- CHANGE BACK WHEN THERMOCOUPLE 3 IS FIXED (DONE)
    C_DATA(counter).TC_4 = TC_4;
    C_DATA(counter).TC_5 = TC_5;
    C_DATA(counter).TC_6 = TC_6;
    C_DATA(counter).TC_7 = TC_7;
    C_DATA(counter).TC_8 = TC_8;
    C_DATA(counter).TC_9 = TC_9;
    C_DATA(counter).TC_10 = TC_10;
    C_DATA(counter).time_VC = time_VC;
    C_DATA(counter).theta = theta;
    C_DATA(counter).p_DCH = fillmissing(p_DCH,'linear'); % Fill in NaNs with linearly interpolated values. 
    C_DATA(counter).p_DM = fillmissing(p_DM,'linear');
    C_DATA(counter).p_PC = fillmissing(p_PC,'linear');
    C_DATA(counter).p_CC = fillmissing(p_CC,'linear');
    C_DATA(counter).p_PC_static = fillmissing(SP_772967,'linear');
    C_DATA(counter).p_CC_static = fillmissing(SP_772966,'linear');
    C_DATA(counter).MB_speed = MB_speed;
    C_DATA(counter).MB_speed_transient = MB_speed_transient;
    C_DATA(counter).p_regulator = p_regulator;
    C_DATA(counter).torque_sensor_transient = torque_sensor_transient;

%     C_DATA(counter).dens_hot = dens_hot; 
%     C_DATA(counter).dens_cold = dens_cold; 
%     C_DATA(counter).c_hot = c_hot; 
%     C_DATA(counter).c_cold = c_cold; 
    C_DATA(counter).hot_bath_setpoint = hot_bath_setpoint;
    C_DATA(counter).cold_bath_setpoint = cold_bath_setpoint;
    C_DATA(counter).hot_liquid_flowrate = hot_liquid_flowrate;
    C_DATA(counter).cold_liquid_flowrate = cold_liquid_flowrate;
    C_DATA(counter).pmean_setpoint = pmean_setpoint;
    C_DATA(counter).torque_setpoint = torque_setpoint;
    C_DATA(counter).teknic_setpoint = teknic_setpoint;
      
    counter = counter + 1;
end

reversed_file_path = reverse(Raw_Data_Folder);
reversed_folder_name = strtok(reversed_file_path,'\');
folder_name = reverse(reversed_folder_name);
Calibrated_Data_Filename = strcat(Raw_Data_Folder,'\',folder_name,'_CAL.mat');

save(Calibrated_Data_Filename,'C_DATA','-v7.3')

% %%
% for i=1:length(C_DATA)
%     equal1(i) = all([C_DATA(i).RTD_2]==[C_DATA2(i).RTD_2]);
%         equal2(i) = all([C_DATA(i).RTD_4]==[C_DATA2(i).RTD_4]);
% 
% end