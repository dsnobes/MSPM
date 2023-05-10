% plot_and_report.m - Written by Connor Speer, October 2018

clear, clc, close all;
% Produce a summary report of the log files and display it in the command
% window (Could also save it as a text file).

% Produce standard plot set for comparison of standard performance test 
% results and model improvements.

%% Input Parameters
% User selects a folder to post process.
path = 'T:\01_Engineering\00_Stirling Engine Development\01_Terrapin Engine 2.0 (Raphael)\06_Experimental Data';
title = 'Choose folder of *.mat files to plot.';
post_processed_data_folder = uigetdir(path,title);

% Change Current Folder to the one chosen for post-processing
oldFolder = cd(post_processed_data_folder);

%% Collect all post processed data from the selected folders and sub-folders
post_processed_data_filenames = dir('*_M*.mat');

for i = 1:length(post_processed_data_filenames)
    load(post_processed_data_filenames(i).name);    
    reversed_filename = reverse(post_processed_data_filenames(i).name);
    [~,remove_ending] = strtok(reversed_filename,'_');
    remove_ending = remove_ending(2:end);
    rename_structure = strcat('DATA_', reverse(remove_ending));
    eval([rename_structure ' = M_DATA;' 'clear  M_DATA']);
end

DATA = DATA_2018_12_05;
    
%% Plot Set-Up
set(0,'defaultfigurecolor',[1 1 1])

% Location of Figures
x = 500;
y = 500;

% Size of Figures
width = 550;
height = 400;

% Font For Figures
font = 'Arial';
font_size = 11;

% Pro Tips %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To change line width for plots, say "'LineWidth',2".

% To include math symbols with their own font size and font type in the
% axes labels, do this: 
% xlabel({'\fontsize{11} Engine Speed \fontsize{11} \fontname{Cambria Math} \omega \fontsize{11} \fontname{Times New Roman} [RPM]'});

% Here is the degree symbol in case you need it °C. Alternatively, use
% \circ.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Description of Fields in DATA Structure

% ADD DESCRIPTION OF ENGINE CONFIGURATION THAT WILL APPEAR IN PLOT TITLES
% AND BE SAVED IN THE DATA STRUCTURE.

% ALSO, TRY TO STREAMLINE THE ANALYSIS PROCESS BY USING PLOTS WITH
% DIMENSIONLESS VARIABLES PERHAPS

% AIMS OF ANALYSIS
% --> Characterize overall performance
% --> Highlight areas of engine improvement
% --> Highlight areas of model improvement

% Calibrated Temperatures, Pressures, Crank Angles,
% Regulator Measured Pressure, Engine Speed, Experiment Setpoints
% --> These come from the calibrate.m function

%     date --> Date data was collected.
%     time_of_day --> Time data was collected.
%     engine_config --> Engine configuration string.
%     operator --> Name of operator who collected the data.

%     RTD_0 --> Displacer Cylinder Head Inlet (°C)
%     RTD_1 --> Displacer Cylinder Head Outlet (°C)
%     RTD_2 --> Heater Inlet (°C)
%     RTD_3 --> Heater Outlet (°C)
%     RTD_4 --> Cooler Inlet (°C)
%     RTD_5 --> Cooler Outlet (°C)
%     RTD_6 --> Power Cylinder Inlet (°C)
%     RTD_7 --> Power Cylinder Outlet (°C)

%     TC_0 --> Displacer Cylinder Head (Expansion Space) (°C)
%     TC_1 --> Heater/Expansion Space Interface, Bypass Side (°C)
%     TC_2 --> Heater/Expansion Space Interface, Connecting Pipe Side (°C)
%     TC_3 --> Regen/Heater Interface, Bypass Side (°C)
%     TC_4 --> Regen/Heater Interface, Connecting Pipe Side (°C)
%     TC_5 --> Cooler/Regenerator Interface, Bypass Side (°C)
%     TC_6 --> Cooler/Regenerator Interface, Connecting Pipe Side (°C)
%     TC_7 --> Compression Space/Cooler Interface, Bypass Side (°C)
%     TC_8 --> Compression Space/Cooler Interface, Connecting Pipe Side (°C)
%     TC_9 --> Power Cylinder (°C)
%     TC_10 --> Crankcase (°C)

%     p_DCH --> Displacer Cylinder Head Pressure, transducers LW37338 and 772967 (Pa)
%     p_DM --> Displacer Mount Pressure, transducers LW37354 and 772967 (Pa)
%     p_PC --> Power Cylinder Pressure, transducers LW37355 and 772967 (Pa)    
%     p_CC --> Crankcase Pressure, transducers LW37337 and 772966 (Pa)

%     theta --> 500 PPR Rotary Encoder Output (rad)
%     p_regulator --> Pressure Measurement Output from Regulator (Pa)
%     MB_speed --> Speed Output Signal from Magnetic Brake (RPM)

%     hot_bath_setpoint --> Hot Water/Oil Bath Setpoint (°C)
%     cold_bath_setpoint --> Cold Water/Glycol Bath Setpoint (°C)
%     hot_liquid_flowrate --> Hot Liquid Flow Rate (m^3/s)
%     cold_liquid_flowrate --> Cold Liquid Flow Rate (m^3/s)
%     pmean_setpoint --> Mean Pressure Setpoint (Pa)
%     torque_setpoint --> Torque Setpoint (Nm)
%     teknic_setpoint --> Teknic Setpoint (RPM)

% Pressures Averaged at Each Crank Angle Degree for Ease
% of Plotting Against the Model, Measured Engine Speed as a Function 
% of Crank Angle (Rotary Encoder),Measured Average Temperatures of Engine
% Spaces, Measured Indicated Work, Forced Work,
% Crankcase Gas Spring Hysteresis, Measured Heat Transfer Rates in All Four
% Water Jackets, Measured Shaft Power and Thermal Efficiency, Measured
% Beale and West Numbers, 
% --> These come from the post_process.m function

%     p_DCH_avg --> Displacer Cylinder Head Pressure, transducers LW37338 and 772967 (Pa)
%     p_DM_avg --> Displacer Mount Pressure, transducers LW37354 and 772967 (Pa)
%     p_PC_avg --> Power Cylinder Pressure, transducers LW37355 and 772967 (Pa)    
%     p_CC_avg --> Crankcase Pressure, transducers LW37337 and 772966 (Pa)
%     Encoder_speed --> Speed Calculated at each crank angle degree from Encoder (RPM)

%     Tge_exp --> Expansion Space Gas Temperature (°C)
%     Tgh_exp --> Heater Gas Temperature (°C)
%     Tgr_exp --> Regenerator Gas Temperature (°C)
%     Tgk_exp --> Cooler Gas Temperature (°C)
%     Tgc_exp --> Compression Space Gas Temperature (°C)
%     TgCC_exp --> Crankcase Gas Temperature (°C)

%     Torque --> Magnetic Brake Torque Setpoint (Nm)
%     pmean_setpoint --> Pressure Regulator Setpoint (Pa)
%     hot_bath_setpoint --> Hot Oil Bath Setpoint (°C)
%     cold_bath_setpoint --> Cold Glycol Bath Setpoint (°C)

%     Wind_exp --> Experimental Indicated Work (J)
%     FW_exp --> Experimental Forced Work (J)
%     CC_GSH_exp --> Experimental Crankcase Gas Spring Hysteresis (J)

%     Qdot_DCH_exp --> Displacer Cylinder Head Water Jacket (W)
%     Qdot_heater_exp --> Heater Water Jacket (W)
%     Qdot_cooler_exp --> Cooler Water Jacket (W)
%     Qdot_PC_exp --> Power Cylinder Water Jacket (W)

%     P_shaft_exp --> Measured Shaft Power (W)
%     efficiency_exp --> Measured Thermal Efficiency (%)

%     Beale_exp --> Measured Beale number
%     West_exp --> Measured West number


% Model Results: Volume of Working Space, Compression Space, Expansion Space for Each
% Crank Angle Degree, Isothermal and Adiabatic Indicator Diagrams, HEX and
% Regenerator Pressure Drops, Conduction Loss Rate and Components, 
% Insulation Heat Loss, Shaft Power, Thermal Efficiency, Torque, 
% Heat Input and Rejection Rates, HEX Temperature Drops, HEX Surface Temperatures.
% --> These come from the run_model.m function.

%     Ve --> Expansion Space Volume (m^3)
%     Vc --> Compression Space Volume (m^3)
%     Vtotal --> Total Working Space Volume (m^3)
%     Vtotal_rounded --> Total Volume For Eacg Crank Angle Degree (m^3)

%     p_isothermal --> Ideal Isothermal Model Pressure (Pa)
%     p_adiabatic --> Ideal Adiabatic Model Pressure (Pa)

%     p_buffer_isothermal --> Isothermal Crankcase Pressure Model (Pa)
%     p_buffer_adiabatic --> Adiabatic Crankcase Pressure Model (Pa)

%     pdrop_h_model --> Heater Pressure Drop (Pa)
%     pdrop_r_model --> Regenerator Pressure Drop (Pa)
%     pdrop_k_model --> Cooler Pressure Drop (Pa)

%     Q_cond_model --> Conduction Loss Rate (W)
%     Q_insulation_model --> Insulation Heat Transfer Rate (W)

%     P_shaft_model --> Shaft Power (W)
%     efficiency_model --> Thermal Efficiency (%)
%     torque_model --> Torque (Nm)

%     Qdot_in_model --> Heat Input Rate (W)
%     Qdot_rej_model --> Heat Rejection Rate (W)
    
% % Collect all the log file names from the test data folder
% data_files_info = dir(fullfile(data_folder, '*.log'));
% 
% % Initialize counter variable
% counter = 1;
% counter_max = length(data_files_info);
% 
% waitbar(0,'Generating reports and plots ...');

% for i = 1:length(data_files_info)   
    % Import DATA Structure Created by calibrate.m, post_process.m, and run_model.m
%     load('plot_data.mat')

    %% Calculations for Plots (These should be moved to the other functions.)
%     % Calculate the ideal isothermal model Error in Predicting Indicated
%     % Work
%     Error_isothermal = ((W_ind_isothermal-Wind_exp)/Wind_exp)*100; %(%)
% 
%     % Calculate the ideal isothermal model loss factor
%     Loss_Factor_isothermal = P_shaft_exp/P_ind_isothermal;
% 
%     % Calculate the ideal adiabatic model error in predicting indicated
%     % work
%     Error_adiabatic = ((W_ind_adiabatic-Wind_exp)/Wind_exp)*100;

    % Determine the best operating point for shaft power
    [P_max,P_max_index] = max([DATA.P_shaft_exp]);

    % Determine the best operating point for thermal efficiency
    [efficiency_max,efficiency_max_index] = max([DATA.efficiency_exp]);

    % Determine the operating point with worst model agreement
        
    %% Raw Data Plots    
    % Water Temperatures vs. Time
    figure('Position', [x y width height])
    hold on
    plot([DATA(P_max_index).time_RTD],[DATA(P_max_index).RTD_0],'*r')
    plot([DATA(P_max_index).time_RTD],[DATA(P_max_index).RTD_1],'*k')
    plot([DATA(P_max_index).time_RTD],[DATA(P_max_index).RTD_2],'*b')
    plot([DATA(P_max_index).time_RTD],[DATA(P_max_index).RTD_3],'*g')
    plot([DATA(P_max_index).time_RTD],[DATA(P_max_index).RTD_4],'*m')
    plot([DATA(P_max_index).time_RTD],[DATA(P_max_index).RTD_5],'*y')
    plot([DATA(P_max_index).time_RTD],[DATA(P_max_index).RTD_6],'*c')
    plot([DATA(P_max_index).time_RTD],[DATA(P_max_index).RTD_7],'*')
    xlabel('Time (s)','FontName',font,'FontSize',font_size)
    ylabel('Water Temperatures (\circC)','FontName',font,'FontSize',font_size);
    legend('RTD_0','RTD_1','RTD_2','RTD_3','RTD_4','RTD_5','RTD_6','RTD_7')
%     title('At Max Power Operating Point');
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)

    % Water Temperatures vs. Crank Angle
    % --> Tricky because theta is stored in a different log file
    % --> Would need to match up times in RTD and Voltage files
    
    % Gas Temperatures vs. Time
    figure('Position', [x y width height])
    hold on
    plot([DATA(P_max_index).time_TC],[DATA(P_max_index).TC_0],'*r')
    plot([DATA(P_max_index).time_TC],[DATA(P_max_index).TC_1],'*k')
    plot([DATA(P_max_index).time_TC],[DATA(P_max_index).TC_2],'*b')
    plot([DATA(P_max_index).time_TC],[DATA(P_max_index).TC_3],'*g')
    plot([DATA(P_max_index).time_TC],[DATA(P_max_index).TC_4],'*m')
    plot([DATA(P_max_index).time_TC],[DATA(P_max_index).TC_5],'*y')
    plot([DATA(P_max_index).time_TC],[DATA(P_max_index).TC_6],'*c')
    plot([DATA(P_max_index).time_TC],[DATA(P_max_index).TC_7],'*')
    plot([DATA(P_max_index).time_TC],[DATA(P_max_index).TC_8],'*')
    plot([DATA(P_max_index).time_TC],[DATA(P_max_index).TC_9],'*')
    plot([DATA(P_max_index).time_TC],[DATA(P_max_index).TC_10],'*')
    xlabel('Time (s)','FontName',font,'FontSize',font_size)
    ylabel('Gas Temperatures (\circC)','FontName',font,'FontSize',font_size);
    legend('TC_0','TC_1','TC_2','TC_3','TC_4','TC_5','TC_6','TC_7','TC_8','TC_9','TC_10')
%     title('At Max Power Operating Point')
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    hold off

    % Gas Pressures vs. Time
    figure('Position', [x y width height])
    hold on
    plot([DATA(P_max_index).time_VC],[DATA(P_max_index).p_DCH]./1000,'.r')
    plot([DATA(P_max_index).time_VC],[DATA(P_max_index).p_DM]./1000,'.k')
    plot([DATA(P_max_index).time_VC],[DATA(P_max_index).p_PC]./1000,'.b')
    plot([DATA(P_max_index).time_VC],[DATA(P_max_index).p_CC]./1000,'.g')
    xlabel('Time (s)','FontName',font,'FontSize',font_size)
    ylabel('Gas Pressures (kPa)','FontName',font,'FontSize',font_size);
    legend('DCH','DM','PC','CC')
%     title('At Max Power Operating Point')
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    hold off
    
    % Gas Pressures vs. Crank Angle
    figure('Position', [x y width height])
    hold on
%     plot([DATA(P_max_index).theta].*(180/pi),[DATA(P_max_index).p_DCH]./1000,'.r')
%     plot([DATA(P_max_index).theta].*(180/pi),[DATA(P_max_index).p_DM]./1000,'.k')
    plot([DATA(P_max_index).theta].*(180/pi),[DATA(P_max_index).p_PC]./1000,'.b')
    plot([DATA(P_max_index).theta].*(180/pi),[DATA(P_max_index).p_CC]./1000,'.g')
    xlabel('Crank Angle (\circ)','FontName',font,'FontSize',font_size)
    ylabel('Gas Pressures (kPa)','FontName',font,'FontSize',font_size);
%     legend('DCH','DM','PC','CC')
    legend('Engine','Crankcase')
%     title('At Max Power Operating Point')
    xlim([0 360])
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    hold off
    
    % Crank Angle vs. Time
    
    %% Display Report in Command Window and Save as Text File
    % Date and time data was collected.
    % Engine configuration.
    % Description/notes for test.
    % Data at best operating point.
    % Ranges of values tested for each variable.

    %% Produce Plots and Save as PNG files 
    % Shaft Power vs. Speed for Several Mean Pressures
    figure('Position', [x y width height])
    pointsize = 30;
    scatter([DATA.MB_speed],[DATA.P_shaft_exp], pointsize, [DATA.pmean]./1000,'*')
    xlabel('Engine Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel('Shaft Power (W)','FontName',font,'FontSize',font_size);
    c = colorbar;
    ylabel(c,'Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
    colormap(jet)
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    
    % Shaft Power vs. Speed for Several Mean Pressures with Overlaid 2nd Order Model
    figure('Position', [x y width height])
    pointsize = 30;
    hold on
    scatter([DATA.MB_speed],[DATA.P_shaft_exp], pointsize, [DATA.pmean]./1000,'*')
    scatter([DATA.MB_speed],[DATA.P_shaft_model], pointsize, [DATA.pmean]./1000,'o')
    xlabel('Engine Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel('Shaft Power (W)','FontName',font,'FontSize',font_size);
    c = colorbar;
    ylabel(c,'Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
    colormap(jet)
    legend('Experimental Data','Model')
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    hold off

    % Thermal Efficiency vs. Speed for Several Mean Pressures
    figure('Position', [x y width height])
    pointsize = 30;
    scatter([DATA.MB_speed],[DATA.efficiency_exp], pointsize, [DATA.pmean]./1000,'*')
    xlabel('Engine Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel('Thermal Efficiency (%)','FontName',font,'FontSize',font_size);
    c = colorbar;
    ylabel(c,'Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
    colormap(jet)
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    
    % Thermal Efficiency vs. Speed for Several Mean Pressures with Overlaid 2nd Order Model
    figure('Position', [x y width height])
    pointsize = 30;
    hold on
    scatter([DATA.MB_speed],[DATA.efficiency_exp], pointsize, [DATA.pmean]./1000,'*')
    scatter([DATA.MB_speed],[DATA.efficiency_model], pointsize, [DATA.pmean]./1000,'o')
    xlabel('Engine Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel('Thermal Efficiency (%)','FontName',font,'FontSize',font_size);
    c = colorbar;
    ylabel(c,'Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
    colormap(jet)
    legend('Experimental Data','Model')
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    hold off

    % Error in Shaft Power and Thermal Efficiency   
    figure('Position', [x y width height])
    pointsize = 30;
    scatter([DATA.MB_speed],(([DATA.P_shaft_model]-[DATA.P_shaft_exp])./[DATA.P_shaft_exp]).*100, pointsize, [DATA.pmean]./1000,'*')
    xlabel('Engine Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel('Shaft Power Error (%)','FontName',font,'FontSize',font_size);
    c = colorbar;
    ylabel(c,'Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
    colormap(jet)
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)

    figure('Position', [x y width height])
    pointsize = 30;
    scatter([DATA.MB_speed],(([DATA.efficiency_model]-[DATA.efficiency_exp])./[DATA.efficiency_exp]).*100, pointsize, [DATA.pmean]./1000,'*')
    xlabel('Engine Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel('Efficiency Error (%)','FontName',font,'FontSize',font_size);
    c = colorbar;
    ylabel(c,'Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
    colormap(jet)
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    
    % Heat Input Rate vs. Speed for Colorbar Mean Pressure with
    % Overlaid Model
    figure('Position', [x y width height])
    pointsize = 30;
    hold on
    scatter([DATA.MB_speed],[DATA.Qdot_DCH_exp]+[DATA.Qdot_heater_exp], pointsize, [DATA.pmean]./1000,'*')
    scatter([DATA.MB_speed],[DATA.Qdot_in_model], pointsize, [DATA.pmean]./1000,'o')
    xlabel('Engine Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel('Heat Input Rate (W)','FontName',font,'FontSize',font_size);
    c = colorbar;
    ylabel(c,'Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
    colormap(jet)
    legend('Experimental Data','Model')
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    hold off
    
    % Error in Heat Input Rate   
    figure('Position', [x y width height])
    pointsize = 30;
    scatter([DATA.MB_speed],((([DATA.Qdot_DCH_exp]+[DATA.Qdot_heater_exp])-[DATA.Qdot_in_model])./([DATA.Qdot_DCH_exp]+[DATA.Qdot_heater_exp])).*100, pointsize, [DATA.pmean]./1000,'*')
    xlabel('Engine Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel('Heat Input Rate Error (%)','FontName',font,'FontSize',font_size);
    c = colorbar;
    ylabel(c,'Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
    colormap(jet)
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    
    
    % Heat Rejection Rate vs. Speed for Colorbar Mean Pressure with
    % Overlaid Model
    figure('Position', [x y width height])
    pointsize = 30;
    hold on
    scatter([DATA.MB_speed],[DATA.Qdot_PC_exp]+[DATA.Qdot_cooler_exp], pointsize, [DATA.pmean]./1000,'*')
    scatter([DATA.MB_speed],[DATA.Qdot_rej_model], pointsize, [DATA.pmean]./1000,'o')
    xlabel('Engine Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel('Heat Rejection Rate (W)','FontName',font,'FontSize',font_size);
    c = colorbar;
    ylabel(c,'Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
    colormap(jet)
    legend('Experimental Data','Model')
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    hold off
    
    % Error in Heat Rejection Rate    
    figure('Position', [x y width height])
    pointsize = 30;
    scatter([DATA.MB_speed],((([DATA.Qdot_PC_exp]+[DATA.Qdot_cooler_exp])-[DATA.Qdot_rej_model])./([DATA.Qdot_PC_exp]+[DATA.Qdot_cooler_exp])).*100, pointsize, [DATA.pmean]./1000,'*')
    xlabel('Engine Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel('Heat Rejection Rate Error (%)','FontName',font,'FontSize',font_size);
    c = colorbar;
    ylabel(c,'Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
    colormap(jet)
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    
    % Torque vs. Speed and Mean Pressure
    figure('Position', [x y width height])
    pointsize = 30;
    scatter([DATA.MB_speed],[DATA.torque_setpoint], pointsize, [DATA.pmean]./1000,'*')
    xlabel('Engine Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel('Torque (Nm)','FontName',font,'FontSize',font_size);
    c = colorbar;
    ylabel(c,'Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
    colormap(jet)
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    
    % Speed Fluctuation Amplitude vs. Speed for Colorbar Mean Pressure with
    % Overlaid Model

    % Crankcase Gas Spring Hysteresis vs. Speed and Mean Pressure
    % with Overlaid Empirical Model    
    figure('Position', [x y width height])
    pointsize = 30;
    scatter([DATA.MB_speed],[DATA.CC_GSH_exp], pointsize, [DATA.pmean]./1000,'*')
    xlabel('Engine Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel({'Crankcase Gas Spring';' Hysteresis Loss (W)'},'FontName',font,'FontSize',font_size);
    c = colorbar;
    ylabel(c,'Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
    colormap(jet)
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    
%     % Indicator Diagram for Max Power Operating Point with Overlaid Model
%     figure('Position', [x y width height])
%     hold on
%     plot([DATA(P_max_index).Vtotal_rounded]./1000,[DATA(P_max_index).p_PC_avg]./1000,'*r')
%     plot([DATA(P_max_index).Vtotal_rounded]./1000,[DATA(P_max_index).p_CC_avg]./1000,'*b')
%     plot([DATA(P_max_index).Vtotal_rounded]./1000,[DATA(P_max_index).p_adiabatic]./1000,'-r')
%     plot([DATA(P_max_index).Vtotal_rounded]./1000,[DATA(P_max_index).p_buffer_adiabatic]./1000,'-b')
%     xlabel('Engine Volume (L)','FontName',font,'FontSize',font_size)
%     ylabel({'Engine Pressure (kPa)'},'FontName',font,'FontSize',font_size)
%     legend('Engine Pressure','Buffer Pressure','Location','northeast')
%     title('Max Power Operating Point')
%     set(gca,'fontsize',font_size);
%     set(gca,'FontName',font)
%     hold off
    
    % Indicator Diagram for Max Power Operating Point with Overlaid Model
    figure('Position', [x y width height])
    hold on
    plot([DATA(P_max_index).Vtotal_rounded].*1000,[DATA(P_max_index).p_PC_avg]./1000,'*r')
    plot([DATA(P_max_index).Vtotal_rounded].*1000,[DATA(P_max_index).p_CC_avg]./1000,'*b')
%     plot([DATA(P_max_index).Vtotal_rounded].*1000,[DATA(P_max_index).p_adiabatic]./1000,'-r')
%     plot([DATA(P_max_index).Vtotal_rounded].*1000,[DATA(P_max_index).p_buffer_adiabatic]./1000,'-b')
    xlabel('Engine Volume (L)','FontName',font,'FontSize',font_size)
    ylabel({'Engine Pressure (kPa)'},'FontName',font,'FontSize',font_size)
    legend('Engine Pressure','Buffer Pressure','Location','northeast')
%     title('Max Power Operating Point')
    set(gca,'fontsize',font_size);
    set(gca,'FontName',font)
    hold off
    
    % !!!!! Pressure Drop Across HEXs vs. Crank Angle for Max Power Operating Point with Overlaid Model
    theta_rounded = 0:1:359;
    figure('Position', [x y width height])
    hold on
    plot(theta_rounded,([DATA(P_max_index).p_DM_avg] - [DATA(P_max_index).p_DCH_avg])./1000,'*k')
    plot(theta_rounded,([DATA(P_max_index).pdrop_h_model] + [DATA(P_max_index).pdrop_r_model] + [DATA(P_max_index).pdrop_k_model])./1000,'or')
    xlabel('Crank Angle (\circ)','FontName',font,'FontSize',font_size)
    ylabel({'HEXs + Regen Pressure Drop (kPa)'},'FontName',font,'FontSize',font_size)
%     title('Max Power Operating Point')
    legend('Data','Model')
    set(gca,'fontsize',font_size);
    set(gca,'FontName',font)
    hold off
    
    % !!!!! Pressure Drop Across HEXs vs. Crank Angle for Max Power Operating Point with Overlaid Model
    theta_rounded = 0:1:359;
    figure('Position', [x y width height])
    hold on
    plot(theta_rounded,([DATA(P_max_index).p_DM_avg] - [DATA(P_max_index).p_DCH_avg])./1000,'*k')
    plot(theta_rounded,100.*[DATA(P_max_index).pdrop_h_model]./1000,'or')
    plot(theta_rounded,[DATA(P_max_index).pdrop_r_model]./1000,'og')
    plot(theta_rounded,100.*[DATA(P_max_index).pdrop_k_model]./1000,'ob')
    xlabel('Crank Angle (\circ)','FontName',font,'FontSize',font_size)
    ylabel({'HEXs + Regen Pressure Drop (kPa)'},'FontName',font,'FontSize',font_size)
%     title('Max Power Operating Point')
    legend('Data','Model Heater','Model Regen','Model Cooler')
    set(gca,'fontsize',font_size);
    set(gca,'FontName',font)
    hold off
    
%     theta_rounded = 0:1:359;
%     for i = 1:37
%         figure('Position', [x y width height])
%         hold on
%         plot(theta_rounded,([DATA(i).p_DM_avg] - [DATA(i).p_DCH_avg])./1000,'*k')
%         plot(theta_rounded,([DATA(i).pdrop_h_model] + [DATA(i).pdrop_r_model] + [DATA(i).pdrop_k_model])./1000,'or')
%         xlabel('Crank Angle (\circ)','FontName',font,'FontSize',font_size)
%         ylabel({'HEXs + Regen Pressure Drop (kPa)'},'FontName',font,'FontSize',font_size)
%     %     title('Max Power Operating Point')
%         legend('Data','Model')
%         set(gca,'fontsize',font_size);
%         set(gca,'FontName',font)
%         hold off
%     end
    
    % Regenerator Pressure Drop Amplitude vs. Speed
    figure('Position', [x y width height])
    plot([DATA.MB_speed],(max([DATA.p_DM]-[DATA.p_DCH]) - min([DATA.p_DM]-[DATA.p_DCH]))./1000,'*k')
    xlabel('Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel({'HEXs + Regen Pressure Drop (kPa)'},'FontName',font,'FontSize',font_size)
    set(gca,'fontsize',font_size);
    set(gca,'FontName',font)
    hold off
    
    % Regenerator Pressure Drop Amplitude vs. Speed and Pressure
    figure('Position', [x y width height])
    pointsize = 30;
    scatter([DATA.MB_speed],(max([DATA.p_DM]-[DATA.p_DCH]) - min([DATA.p_DM]-[DATA.p_DCH]))./1000, pointsize, [DATA.pmean]./1000,'*')
    xlabel('Engine Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel({'HEXs + Regen Pressure Drop (kPa)'},'FontName',font,'FontSize',font_size)
    c = colorbar;
    ylabel(c,'Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
    colormap(jet)
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)

    % Indicator Diagram with Worst Model Agreement with Overlaid Model

    % Indicator Diagram Error vs. Speed and Mean Pressure

    % Crankcase Indicator Diagram with Overlaid Model for BOP

    % Pressure Drop Amplitude Across HEX vs. Speed and Mean Pressure with Overlaid Model

    % Heater Temperature Drop vs. Speed and Mean Pressure
    Tdrop_heater = ((mean([DATA.RTD_3])+mean([DATA.RTD_2]))/2) - [DATA.Tgh_exp];
    figure('Position', [x y width height])
    pointsize = 30;
    scatter([DATA.MB_speed],Tdrop_heater, pointsize, [DATA.pmean]./1000,'*')
    xlabel('Engine Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel('Heater Temperature Drop (°C)','FontName',font,'FontSize',font_size);
    c = colorbar;
    ylabel(c,'Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
    colormap(jet)
%     ylim([7.5 13])
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    
    % Cooler Temperature Drop vs. Speed and Mean Pressure
    Tdrop_cooler = [DATA.Tgk_exp] - ((mean([DATA.RTD_5])+mean([DATA.RTD_4]))/2);
    figure('Position', [x y width height])
    pointsize = 30;
    scatter([DATA.MB_speed],Tdrop_cooler, pointsize, [DATA.pmean]./1000,'*')
    xlabel('Engine Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel('Cooler Temperature Drop (°C)','FontName',font,'FontSize',font_size);
    c = colorbar;
    ylabel(c,'Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
    colormap(jet)
%     ylim([7.5 13])
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    
    % Temperatures on Either Side of the Displacer Cylinder vs Speed and Mean
    % Pressure (Preferential Flow Evidence)
    figure('Position', [x y width height])
    pointsize = 30;
    hold on
    scatter([DATA.MB_speed],mean([DATA.TC_1]), pointsize, [DATA.pmean]./1000,'*')
    scatter([DATA.MB_speed],mean([DATA.TC_3]), pointsize, [DATA.pmean]./1000,'*')
    scatter([DATA.MB_speed],mean([DATA.TC_5]), pointsize, [DATA.pmean]./1000,'*')
    scatter([DATA.MB_speed],mean([DATA.TC_7]), pointsize, [DATA.pmean]./1000,'*')
    scatter([DATA.MB_speed],mean([DATA.TC_2]), pointsize, [DATA.pmean]./1000,'o')
    scatter([DATA.MB_speed],mean([DATA.TC_4]), pointsize, [DATA.pmean]./1000,'o')
    scatter([DATA.MB_speed],mean([DATA.TC_6]), pointsize, [DATA.pmean]./1000,'o')
    scatter([DATA.MB_speed],mean([DATA.TC_8]), pointsize, [DATA.pmean]./1000,'o')
    xlabel('Engine Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel('Temperature (°C)','FontName',font,'FontSize',font_size);
    c = colorbar;
    ylabel(c,'Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
    colormap(jet)
    legend('Bypass','Bypass','Bypass','Bypass','C Pipe','C Pipe','C Pipe','C Pipe')
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    hold off
    
    % Expansion Space and Compression Space Temperatures vs Speed and Mean
    % Pressure
    figure('Position', [x y width height])
    pointsize = 30;
    hold on
    scatter([DATA.MB_speed],[DATA.Tgc_exp], pointsize, [DATA.pmean]./1000,'*')
    scatter([DATA.MB_speed],[DATA.Tge_exp], pointsize, [DATA.pmean]./1000,'o')
    xlabel('Engine Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel('Temperature (°C)','FontName',font,'FontSize',font_size);
    c = colorbar;
    ylabel(c,'Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
    colormap(jet)
    legend('Compression Space','Expansion Space')
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    hold off
    
    % Temperature Difference B/W Expansion and Compression Space vs. Speed and Mean Pressure
    figure('Position', [x y width height])
    pointsize = 30;
    scatter([DATA.MB_speed],[DATA.Tge_exp]-[DATA.Tgc_exp], pointsize, [DATA.pmean]./1000,'*')
    xlabel('Engine Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel('\DeltaT B/W Expansion and Compression Space (°C)','FontName',font,'FontSize',font_size);
    c = colorbar;
    ylabel(c,'Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
    colormap(jet)
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    
    % Heater and Cooler Temperatures vs. Speed and Mean Pressure
    figure('Position', [x y width height])
    pointsize = 30;
    hold on
    scatter([DATA.MB_speed],[DATA.Tgh_exp], pointsize, [DATA.pmean]./1000,'*')
    scatter([DATA.MB_speed],[DATA.Tgk_exp], pointsize, [DATA.pmean]./1000,'o')
    xlabel('Engine Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel('Temperature (°C)','FontName',font,'FontSize',font_size);
    c = colorbar;
    ylabel(c,'Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
    colormap(jet)
    legend('Heater','Cooler')
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    hold off
    
    % Temperature Difference B/W Heater and Cooler vs. Speed and Mean Pressure
    figure('Position', [x y width height])
    pointsize = 30;
    scatter([DATA.MB_speed],[DATA.Tgh_exp]-[DATA.Tgk_exp], pointsize, [DATA.pmean]./1000,'*')
    xlabel('Engine Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel('\DeltaT B/W Heater & Cooler (°C)','FontName',font,'FontSize',font_size);
    c = colorbar;
    ylabel(c,'Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
    colormap(jet)
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    
    % Expansion Space Indicator Diagram with Overlaid Model (BOP?)

    % Relative Influence of Cold Liquid Jackets
    figure('Position', [x y width height])
    pointsize = 30;
    hold on
    scatter([DATA.MB_speed],[DATA.Qdot_PC_exp], pointsize, [DATA.pmean]./1000,'*')
    scatter([DATA.MB_speed],[DATA.Qdot_cooler_exp], pointsize, [DATA.pmean]./1000,'o')
    xlabel('Engine Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel('Heat Rejection Rate (W)','FontName',font,'FontSize',font_size);
    c = colorbar;
    ylabel(c,'Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
    colormap(jet)
    legend('Power Cylinder','Cooler')
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    hold off
    
    figure('Position', [x y width height])
    pointsize = 30;
    hold on
    P_Cyl_Contribution = ([DATA.Qdot_PC_exp]./([DATA.Qdot_PC_exp]+[DATA.Qdot_cooler_exp])).*100;
    scatter([DATA.MB_speed],P_Cyl_Contribution, pointsize, [DATA.pmean]./1000,'*')
    xlabel('Engine Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel('P Cyl WJ Contribution (%)','FontName',font,'FontSize',font_size);
    c = colorbar;
    ylabel(c,'Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
    colormap(jet)
    legend('Power Cylinder','Cooler')
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    hold off
    
    % Relative Influence of Hot Liquid Jackets
    figure('Position', [x y width height])
    pointsize = 30;
    scatter([DATA.MB_speed],[DATA.Qdot_DCH_exp], pointsize, [DATA.pmean]./1000,'*')
    scatter([DATA.MB_speed],[DATA.Qdot_heater_exp], pointsize, [DATA.pmean]./1000,'o')
    xlabel('Engine Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel('Heat Input Rate (W)','FontName',font,'FontSize',font_size);
    c = colorbar;
    ylabel(c,'Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
    colormap(jet)
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    
    figure('Position', [x y width height])
    pointsize = 30;
    D_Cyl_Head_Contribution = ([DATA.Qdot_DCH_exp]./([DATA.Qdot_DCH_exp]+[DATA.Qdot_heater_exp])).*100;
    scatter([DATA.MB_speed],D_Cyl_Head_Contribution, pointsize, [DATA.pmean]./1000,'*')
    xlabel('Engine Speed (RPM)','FontName',font,'FontSize',font_size)
    ylabel('D Cyl Head WJ Contribution (%)','FontName',font,'FontSize',font_size);
    c = colorbar;
    ylabel(c,'Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
    colormap(jet)
    set(gca,'fontsize',font_size)
    set(gca,'FontName',font)
    
    % Speed Fluctuations vs. Crank Angle for Best Operating Point with
    % Overlaid Model
    for P_max_index = 1:37
    theta_rounded = 0:360;
    figure('Position', [x y width height])
    hold on
    plot([DATA(P_max_index).theta].*(180/pi),[DATA(P_max_index).encoder_speed],'*k')
    plot(theta_rounded,[DATA(P_max_index).model_speed],'or')
    xlabel('Crank Angle (\circ)','FontName',font,'FontSize',font_size)
    ylabel({'HEXs + Regen Pressure Drop (kPa)'},'FontName',font,'FontSize',font_size)
    ylim([10 300])
    legend('Data','Model')
    set(gca,'fontsize',font_size);
    set(gca,'FontName',font)
    hold off
    end
% end