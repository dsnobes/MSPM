function reduce(Raw_Data_Folder, ENGINE_DATA, short_output, have_DCH_source, p_environment)

% Written by Connor Speer - October 2017
% Modified by Connor Speer - July 2018
% Modified by Matthias Lottmann - 2021-2022:
% New variables, function options added, code simplifications

% Process experimental data and return it in a structure for plotting
% elsewhere.
%% Use this if running this script on its own.
% Raw_Data_Folder = uigetdir;

%% Inputs
% Properties of Heat Transfer Liquids

% IRRELEVANT (not used later)
% dens_hot = 930; %(kg/m^3) - for SIL 180 at 20 deg C

% hot liquid specific heat now calculated temperature dependent in loop.
% c_hot = 1510; %(J/kgK) - for SIL 180 at 20 deg C

% Matthias 2021 Dec 08: Water/Ethylene glycol 70/30 mix, 5 deg C
% https://www.engineeringtoolbox.com/ethylene-glycol-d_146.html
% dens_cold = 1057.5; %(kg/m^3)

% RELEVANT
c_cold = 3770; %(J/kgK)

m_dot_Cooler = 0.0235576; %(kg/s) THIS WAS MEASURED VIA BUCKET TEST!!!!
    % Connor's value
%     m_dot_Cooler = 0.027624; %(kg/s) THIS WAS MEASURED VIA BUCKET TEST!!!!


% Connor's values
% dens_cold = 1101.12; %(kg/m^3) - for 50% ethylene glycol water mix at 10 deg C
% c_cold = 3118.57; %(J/kgK) - for 50% ethylene glycol water mix at 10 deg C
% dens_cold = 1000; %(kg/m^3) - for water
% c_cold = 4184; %(J/kgK) - for water

%%
reversed_file_path = reverse(Raw_Data_Folder);
reversed_folder_name = strtok(reversed_file_path,'\');
folder_name = reverse(reversed_folder_name);
Calibrated_Data_Filename = strcat(Raw_Data_Folder,'\',folder_name,'_CAL.mat');

% Collect all the log file names from the test data folder
load(Calibrated_Data_Filename, 'C_DATA');
[~,number_of_files] = size(C_DATA);

%% Preallocate Space For DATA_STRUCTURE
% RD_DATA(number_of_files).filename = [];
% 
% if ~short_output
%     RD_DATA(number_of_files).time_RTD = [];
%     RD_DATA(number_of_files).RTD_0 = [];
%     RD_DATA(number_of_files).RTD_1 = [];
%     RD_DATA(number_of_files).RTD_2 = [];
%     RD_DATA(number_of_files).RTD_3 = [];
%     RD_DATA(number_of_files).RTD_4 = [];
%     RD_DATA(number_of_files).RTD_5 = [];
%     RD_DATA(number_of_files).RTD_6 = [];
%     RD_DATA(number_of_files).RTD_7 = [];
%     RD_DATA(number_of_files).time_TC = [];
%     RD_DATA(number_of_files).TC_0 = [];
%     RD_DATA(number_of_files).TC_1 = [];
%     RD_DATA(number_of_files).TC_2 = [];
%     RD_DATA(number_of_files).TC_3 = [];
%     RD_DATA(number_of_files).TC_4 = [];
%     RD_DATA(number_of_files).TC_5 = [];
%     RD_DATA(number_of_files).TC_6 = [];
%     RD_DATA(number_of_files).TC_7 = [];
%     RD_DATA(number_of_files).TC_8 = [];
%     RD_DATA(number_of_files).TC_9 = [];
%     RD_DATA(number_of_files).TC_10 = [];
%     RD_DATA(number_of_files).time_VC = [];
%     RD_DATA(number_of_files).theta = [];
%     RD_DATA(number_of_files).p_DCH = [];
%     RD_DATA(number_of_files).p_DM = [];
%     RD_DATA(number_of_files).p_PC = [];
%     RD_DATA(number_of_files).p_CC = [];
%     RD_DATA(number_of_files).p_regulator = [];
%     RD_DATA(number_of_files).torque_sensor_transient = [];
%     RD_DATA(number_of_files).MB_speed_transient = [];
% end
% 
% RD_DATA(number_of_files).MB_speed = [];
% RD_DATA(number_of_files).encoder_speed = [];
% % RD_DATA(number_of_files).dens_hot = [];
% % RD_DATA(number_of_files).dens_cold = [];
% RD_DATA(number_of_files).c_hot_in = [];
% RD_DATA(number_of_files).c_hot_out = [];
% RD_DATA(number_of_files).c_cold = [];
% RD_DATA(number_of_files).hot_bath_setpoint = [];
% RD_DATA(number_of_files).cold_bath_setpoint = [];
% RD_DATA(number_of_files).hot_liquid_flowrate = [];
% RD_DATA(number_of_files).cold_liquid_flowrate = [];
% RD_DATA(number_of_files).pmean_setpoint = [];
% RD_DATA(number_of_files).torque_setpoint = [];
% RD_DATA(number_of_files).torque_sensor = [];
% RD_DATA(number_of_files).teknic_setpoint = [];
% 
% % From the post_process sub-function
% RD_DATA(number_of_files).p_DCH_avg = [];
% RD_DATA(number_of_files).p_DM_avg = [];
% RD_DATA(number_of_files).p_PC_avg = [];
% RD_DATA(number_of_files).p_CC_avg = [];
% RD_DATA(number_of_files).pmean = [];
% RD_DATA(number_of_files).pmean_CC = [];
% RD_DATA(number_of_files).p_atm = [];
% 
% RD_DATA(number_of_files).Tge = [];
% RD_DATA(number_of_files).Tgh_far = [];
% RD_DATA(number_of_files).Tgh_pipe = [];
% RD_DATA(number_of_files).Tgh = [];
% RD_DATA(number_of_files).Tgr = [];
% RD_DATA(number_of_files).Tgk = [];
% RD_DATA(number_of_files).Tgc = [];
% RD_DATA(number_of_files).TgCC = [];
% 
% RD_DATA(number_of_files).Tgh_inlet_far = [];
% RD_DATA(number_of_files).Tgh_inlet_pipe = [];
% RD_DATA(number_of_files).Tgh_inlet = [];
% RD_DATA(number_of_files).Tgh_reg_far = [];
% RD_DATA(number_of_files).Tgh_reg_pipe = [];
% RD_DATA(number_of_files).Tgh_reg = [];
% 
% RD_DATA(number_of_files).Tgk_inlet_far = [];
% RD_DATA(number_of_files).Tgk_inlet_pipe_1 = [];
% RD_DATA(number_of_files).Tgk_inlet_pipe_2 = [];
% RD_DATA(number_of_files).Tgk_inlet = [];
% RD_DATA(number_of_files).Tgk_reg = [];
% RD_DATA(number_of_files).TgPP = [];
% 
% if have_DCH_source
%     RD_DATA(number_of_files).Tsource_DCH_in = [];
%     RD_DATA(number_of_files).Tsource_DCH_out = [];
% end
% RD_DATA(number_of_files).Tsource_in = [];
% RD_DATA(number_of_files).Tsource_out = [];
% RD_DATA(number_of_files).Tsink_in = [];
% RD_DATA(number_of_files).Tsink_out = [];
% 
% RD_DATA(number_of_files).Wind = [];
% RD_DATA(number_of_files).FW = [];
% RD_DATA(number_of_files).W_CC = [];
% RD_DATA(number_of_files).CC_GSH = [];
% 
% RD_DATA(number_of_files).Qdot_DCH = [];
% 
% RD_DATA(number_of_files).Qdot_heater = [];
% RD_DATA(number_of_files).Qdot_cooler = [];
% %RD_DATA(number_of_files).Qdot_PC = [];
% 
% RD_DATA(number_of_files).P_shaft_tsensor = [];
% RD_DATA(number_of_files).P_shaft_tsensor_MB_speed = [];
% RD_DATA(number_of_files).P_shaft_setpoint_MB_speed = [];
% RD_DATA(number_of_files).efficiency_shaft = [];
% RD_DATA(number_of_files).efficiency_ind = [];
% RD_DATA(number_of_files).Beale = [];
% RD_DATA(number_of_files).West = [];
% 
% if ~short_output
%     RD_DATA(number_of_files).Ve = [];
%     RD_DATA(number_of_files).Vc = [];
%     RD_DATA(number_of_files).Vtotal = [];
% end
% 
% RD_DATA(number_of_files).Ve_rounded = [];
% RD_DATA(number_of_files).Vc_rounded = [];
% RD_DATA(number_of_files).Vtotal_rounded = [];
% RD_DATA(number_of_files).V_CC_rounded = [];

% Initialize counter variable
counter = 1;

WaitBar = waitbar(0,'Processing experimental data ...');

% Open pre-calibrated log files
for i = 1:number_of_files
    %% Calculate Data from the File %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Gas temperatures
    Tge = mean(C_DATA(i).TC_0); % Average Expansion Space Gas Temperature (°C)
    
    Tgh_inlet_far = mean(C_DATA(i).TC_1); % Far Side Average Heater Inlet/Outlet Gas Temperature (°C)
    Tgh_inlet_pipe = mean(C_DATA(i).TC_2); % Conn Pipe Side Average Heater Inlet/Outlet Gas Temperature (°C)
    Tgh_inlet = mean([mean(C_DATA(i).TC_1), mean(C_DATA(i).TC_2)]); % Average Heater Inlet/Outlet Gas Temperature (°C)
       
    Tgh_reg_far = mean(C_DATA(i).TC_3); % Far Side Average Heater/Regenerator interface Gas Temperature (°C)
    Tgh_reg_pipe = mean(C_DATA(i).TC_4); % Conn Pipe Average Heater/Regenerator interface Gas Temperature (°C)
    Tgh_reg = mean([mean(C_DATA(i).TC_3), mean(C_DATA(i).TC_4)]); % Average Heater/Regenerator interface Gas Temperature (°C)

    Tgh_far = mean([Tgh_inlet_far, Tgh_reg_far]); % Far Side Average Heater Gas Temperature (°C)
    Tgh_pipe = mean([Tgh_inlet_pipe, Tgh_reg_pipe]); % Conn Pipe Side Average Heater Gas Temperature (°C)
    Tgh = mean([Tgh_inlet, Tgh_reg]); % Average Heater Gas Temperature (°C)
    
    
    % TC_6 is at same position as TC_8 because it cannot be pushed up into
    % the cooler due to design error in crankcase!
    Tgk_inlet_far = mean(C_DATA(i).TC_7); % Far Side Average Cooler Inlet/Outlet Gas Temperature (°C)
    Tgk_inlet_pipe_1 = mean(C_DATA(i).TC_8); % Conn Pipe Side Average Cooler Inlet/Outlet Gas Temperature (°C)
    Tgk_inlet_pipe_2 = mean(C_DATA(i).TC_6); % Conn Pipe Side Average Cooler Inlet/Outlet Gas Temperature (°C)
    Tgk_inlet = mean([mean(C_DATA(i).TC_7), mean(C_DATA(i).TC_8)]); % Average Cooler Inlet/Outlet Gas Temperature (°C)    
    
    Tgk_reg = mean(C_DATA(i).TC_5); % Average Cooler/Regenerator interface Gas Temperature (°C)
    % this sensor sometimes loses connection and produces measurements wildly out of bounds. replace these with NaN.
    if ~(Tgk_reg<160 && Tgk_reg>0)
        Tgk_reg = NaN; 
        Tgk = NaN;
        Tgr = NaN;
    else
        Tgk = mean([Tgk_reg, Tgk_inlet]); % Average Cooler Gas Temperature (°C)
        % Average Regenerator Gas Temperature (Log Mean Method)
        Tgr = (Tgh_reg - Tgk_reg) / log(Tgh_reg / Tgk_reg); %(°C)
    end
    
    TgPP = mean(C_DATA(i).TC_9); % Average Power Piston Space Gas Temperature (°C)
    Tgc = mean([TgPP, Tgk_inlet]); % Average Compression Space Gas Temperature (°C), aprx. from PP and cooler inlet
    TgCC = mean(C_DATA(i).TC_10); % Average Crankcase Gas Temperature (°C)
    
    
    % Liquid Temperatures
    if have_DCH_source
    Tsource_DCH_in = mean(C_DATA(i).RTD_0); % Average Displacer cylinder head Inlet Liquid Temperature (°C)
    Tsource_DCH_out = mean(C_DATA(i).RTD_1); % Average Displacer cylinder head Outlet Liquid Temperature (°C)
    end
    Tsource_in = mean(C_DATA(i).RTD_2); % Average Heater Inlet Liquid Temperature (°C)
    Tsource_out = mean(C_DATA(i).RTD_3); % Average Heater Outlet Liquid Temperature (°C)
    Tsink_in = mean(C_DATA(i).RTD_4); % Average Cooler Inlet Liquid Temperature (°C)
    Tsink_out = mean(C_DATA(i).RTD_5); % Average Cooler Outlet Liquid Temperature (°C)
    
    % Calculate Crankshaft Speed from Encoder Measurement %%%%%%%%%%%%%%%%%
    % Convert theta to monotonically increasing
    %--> Step through theta one row at a time
    %--> For each row, check if it is larger or smaller than the previous row
    %--> If larger, add the difference to the total crank angle count
    %--> If smaller, add the entire value to the total crank angle count
    
    theta_mono = zeros(length(C_DATA(i).theta),1); % Preallocate space
    theta_mono(1) = C_DATA(i).theta(1);
    for j = 2:length(C_DATA(i).theta)
        if C_DATA(i).theta(j) >= C_DATA(i).theta(j-1)
            theta_mono(j) = theta_mono(j-1) + (C_DATA(i).theta(j)-C_DATA(i).theta(j-1));
        else
            theta_mono(j) = theta_mono(j-1) + C_DATA(i).theta(j);
        end
    end
    %%
    % Calculate encoder speeds
    %--> This is a moving average with an interval of 40 samples. At 1000
    % Hz sampling rate and 200 RPM this corresponds to 50 degrees of
    % rotation.
    avg_int = 40;
    delta_theta_mono = zeros(length(C_DATA(i).theta),1); % Preallocate space
    delta_time = zeros(length(C_DATA(i).theta),1); % Preallocate space
    omega = zeros(length(C_DATA(i).theta),1); % Preallocate space
    
    for k = (avg_int/2+1):(length(C_DATA(i).theta)-avg_int/2)
        delta_theta_mono(k) = theta_mono(k+avg_int/2) - theta_mono(k-avg_int/2); %(rad)
        delta_time(k) = C_DATA(i).time_VC(k+avg_int/2) - C_DATA(i).time_VC(k-avg_int/2); %(s)
        omega(k) = delta_theta_mono(k)/delta_time(k); %(rad/s)
    end
    % fill start and end values
    omega(1:avg_int/2) = omega(avg_int/2+1); %(rad/s)
    omega((end-avg_int/2-1):end) = omega(end-avg_int/2); %(rad/s)
    
    
    encoder_speed_raw = omega.*(60/(2*pi)); %(RPM)
    
    % Average for each crank angle degree
    [encoder_speed_transient] = PV_data_avg(C_DATA(i).theta,encoder_speed_raw); %(RPM)
%     Remove any remaining NaN. not sure why sometimes there is still a NaN value.
    nans = isnan(encoder_speed_transient);
    if any(nans)
        warning(nnz(nans)+" NaN values in encoder speed at setpoint index "+counter)
    end
    encoder_speed = mean(encoder_speed_transient(~nans));
    
%     % Plot encoder speed
%     figure(1)
%     hold on
%     plot(0:359, encoder_speed, 'k', 'Displayname',num2str(avg_int))
%     xlim([0,359])
%     xlabel('Crank angle [deg]')
%     ylabel('Speed [rpm]')
%     legend   
    
    %%
    % Calculate Liquid Mass Flow Rates
    [m_dot_DCH, m_dot_Heater] = SIL_180_flow_rate_calc(C_DATA(i).hot_bath_setpoint);
    
    %     m_dot_Cooler = C_DATA(i).cold_liquid_flowrate*C_DATA(i).dens_cold; %(kg/s)
    %     m_dot_PC = m_dot_Cooler; %(kg/s)
    
    % Calculate Temperature dependent Specific heat
    c_hot_in = SIL_180_specific_heat_calc(Tsource_in);
    c_hot_out = SIL_180_specific_heat_calc(Tsource_out);

    % Calculate Heat Transfer Rates
    if have_DCH_source
        %Add c_hot_in and c_hot_out if using this Heat exchanger!
        Qdot_DCH = m_dot_DCH*c_hot*(mean(C_DATA(i).RTD_0)-mean(C_DATA(i).RTD_1)); %(W)
    else
        Qdot_DCH = 0;
    end
    Qdot_heater = m_dot_Heater* (c_hot_in*Tsource_in - c_hot_out*Tsource_out); %(W)
    Qdot_cooler = m_dot_Cooler*c_cold*(Tsink_out-Tsink_in); %(W)
    %     Qdot_PC = m_dot_PC*c_cold*(mean(C_DATA(i).RTD_7)-mean(C_DATA(i).RTD_6)); %(W)
    Qdot_PC = 0; %(W) THIS WATER JACKET IS NOT BEING USED RIGHT NOW!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    % Torque measured by sensor
    torque_sensor = mean(C_DATA(i).torque_sensor_transient);
    % Calculate the measured power output
    % MATT: Power calculated from Magnetic brake speed? Inaccurate? Why not 'encoder_speed'? ------------------------------------------------------------------------------------------------------------------------------------
    % MATT May 20 2022: Changed 'P_shaft_tsensor' to use encoder speed
    % MATT: Could also calculate power from transient torque & speed
    P_shaft_tsensor = torque_sensor*encoder_speed*((2*pi)/60); %(W)
    P_shaft_tsensor_MB_speed = torque_sensor*(C_DATA(i).MB_speed*((2*pi)/60)); %(W)
    P_shaft_setpoint_MB_speed = C_DATA(i).torque_setpoint*(C_DATA(i).MB_speed*((2*pi)/60)); %(W)

    % Calculate the mean pressure
    pmean = mean([mean(C_DATA(i).p_DCH), mean(C_DATA(i).p_DM), mean(C_DATA(i).p_PC)]);
    pmean_CC = mean(C_DATA(i).p_CC);
    % Calculate the Beale number
    Beale = P_shaft_tsensor/((pmean)*(C_DATA(i).MB_speed/60)*ENGINE_DATA.Vswp);
    
    % Calculate the West Number
    T_factor = ((Tsource_in+273.15)+(Tsink_in+273.15)) / (Tsource_in-Tsink_in);
    West = Beale*T_factor;
    
    % Average the Pressures for Each Crank Angle Degree
    [p_DCH_avg] = PV_data_avg(C_DATA(i).theta,C_DATA(i).p_DCH); %(Pa)
    [p_DM_avg] = PV_data_avg(C_DATA(i).theta,C_DATA(i).p_DM); %(Pa)
    [p_PC_avg] = PV_data_avg(C_DATA(i).theta,C_DATA(i).p_PC); %(Pa)
    [p_CC_avg] = PV_data_avg(C_DATA(i).theta,C_DATA(i).p_CC); %(Pa)
    
    p_DCH_avg = fillmissing(p_DCH_avg,'linear'); % Fill in NaNs with linearly interpolated values.
    p_DM_avg = fillmissing(p_DM_avg,'linear');
    p_PC_avg = fillmissing(p_PC_avg,'linear');
    p_CC_avg = fillmissing(p_CC_avg,'linear');
    
    %     % Calculate the work lost to regenerator flow friction
    %     dW_regen_FF = (p_DCH_avg - p_DM_avg).*(pi/4).*(0.096.^2).*dVe_rounded; %[J]
    %     W_lost_regen_FF = sum(dW_regen_FF); %[J]
    %     P_lost_regen_FF = W_lost_regen_FF*Engine_Hz; %[W]
    
    % Calculate volumes at measured crank angles
    [Vc,Ve,~,~,~] = volume(C_DATA(i).theta, ENGINE_DATA);
    Vtotal = ENGINE_DATA.Vdead + Vc + Ve;
    Vtotal = Vtotal(:);
    
    % Calculate volumes at rounded crank angles to go with average pressures
    theta_deg_rounded = (0:1:359)+10;
    theta_rounded = theta_deg_rounded*(pi/180);
    theta_rounded = theta_rounded(:);
    [Vc_rounded,Ve_rounded,~,~,V_CC_rounded] = volume(theta_rounded, ENGINE_DATA);
    Vtotal_rounded = ENGINE_DATA.Vdead + Vc_rounded + Ve_rounded;
%     Vtotal_rounded = Vtotal_rounded(:);
    
    
% Matthias: code below is identical to that in 'volume' function. Using output of 'volume' instead (above).    
%     % Crankcase Volume Variations
%     Pbore = ENGINE_DATA.Pbore; % piston bore [m]
%     Pr1 = ENGINE_DATA.Pr1; % piston desaxe offset in [m]
%     Pr2 = ENGINE_DATA.Pr2; % piston crank radius in [m]
%     Pr3 = ENGINE_DATA.Pr3; % piston connecting rod length [m]
%     
%     Ptheta2 = pi - theta_rounded;
%     
%     Ptheta3 = pi - asin((-Pr1+(Pr2*sin(Ptheta2)))/Pr3);
%     Pr4 = Pr2*cos(Ptheta2) - Pr3*cos(Ptheta3);
%     Pr4max = sqrt(((Pr2+Pr3)^2)-(Pr1^2));
%     
%     % Crankcase Volume Variations in (m^3)
%     V_CC_rounded = ENGINE_DATA.V_buffer_max - ((Pr4max-Pr4)*(((pi/4)*(Pbore^2)))); %(m^3)
%     V_CC_rounded = V_CC_rounded(:);
    

    % Calculate Experimental Indicated Work and Power
%     Wind_exp = polyarea(Vtotal_rounded,p_PC_avg); %OBSOLETE
    V_closed = [Vtotal_rounded; Vtotal_rounded(1)];
    p_closed = [p_PC_avg; p_PC_avg(1)];
    Wind = trapz(V_closed,p_closed);
    
    % Calculate the measured thermal efficiency
    efficiency_shaft = P_shaft_tsensor / (Qdot_DCH+Qdot_heater); %(dim.less)
    efficiency_ind = Wind * encoder_speed /60 /(Qdot_DCH+Qdot_heater); %(dim.less)
    
%     polyarea(V_CC_rounded,p_CC_avg)*C_DATA(i).MB_speed*(1/60); %OBSOLETE
    V_CC_closed = [V_CC_rounded; V_CC_rounded(1)];
    p_CC_closed = [p_CC_avg; p_CC_avg(1)];
    % Crankcase indicated work
    W_CC = trapz(V_CC_closed,p_CC_closed);
    % Crankcase Gas Spring Hysteresis Loss
    CC_GSH = W_CC*encoder_speed*(1/60);
    
    % Calculate Experimental Forced Work %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    P_engine_exp = p_PC_avg; %[Pa]
    P_buffer_exp = p_CC_avg; %[Pa]
    
    % Call forced work subfunction
    FW = FW_Subfunction_v4(P_engine_exp, P_buffer_exp, Vtotal_rounded);
%     [~, FW_old, ~] = FW_Subfunction_v3(theta_rounded,P_engine_exp,P_buffer_exp,Vtotal_rounded,ENGINE_DATA.effect,0);
    
    %% Store Results in Output Structure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % From the calibrate sub-function
    RD_DATA(counter).filename = C_DATA(i).filename;
    
    if ~short_output
        RD_DATA(counter).time_RTD = C_DATA(i).time_RTD;
        RD_DATA(counter).RTD_0 = C_DATA(i).RTD_0;
        RD_DATA(counter).RTD_1 = C_DATA(i).RTD_1;
        RD_DATA(counter).RTD_2 = C_DATA(i).RTD_2;
        RD_DATA(counter).RTD_3 = C_DATA(i).RTD_3;
        RD_DATA(counter).RTD_4 = C_DATA(i).RTD_4;
        RD_DATA(counter).RTD_5 = C_DATA(i).RTD_5;
        RD_DATA(counter).RTD_6 = C_DATA(i).RTD_6;
        RD_DATA(counter).RTD_7 = C_DATA(i).RTD_7;
        RD_DATA(counter).time_TC = C_DATA(i).time_TC;
        RD_DATA(counter).TC_0 = C_DATA(i).TC_0;
        RD_DATA(counter).TC_1 = C_DATA(i).TC_1;
        RD_DATA(counter).TC_2 = C_DATA(i).TC_2;
        RD_DATA(counter).TC_3 = C_DATA(i).TC_3;
        RD_DATA(counter).TC_4 = C_DATA(i).TC_4;
        RD_DATA(counter).TC_5 = C_DATA(i).TC_5;
        RD_DATA(counter).TC_6 = C_DATA(i).TC_6;
        RD_DATA(counter).TC_7 = C_DATA(i).TC_7;
        RD_DATA(counter).TC_8 = C_DATA(i).TC_8;
        RD_DATA(counter).TC_9 = C_DATA(i).TC_9;
        RD_DATA(counter).TC_10 = C_DATA(i).TC_10;
        RD_DATA(counter).time_VC = C_DATA(i).time_VC;
        RD_DATA(counter).theta = C_DATA(i).theta;
        RD_DATA(counter).p_DCH = C_DATA(i).p_DCH;
        RD_DATA(counter).p_DM = C_DATA(i).p_DM;
        RD_DATA(counter).p_PC = C_DATA(i).p_PC;
        RD_DATA(counter).p_CC = C_DATA(i).p_CC;
        RD_DATA(counter).p_regulator = C_DATA(i).p_regulator;
        RD_DATA(counter).torque_sensor_transient = C_DATA(i).torque_sensor_transient;
        RD_DATA(counter).MB_speed_transient = C_DATA(i).MB_speed_transient;
    end
    
    RD_DATA(counter).MB_speed = C_DATA(i).MB_speed;
    RD_DATA(counter).encoder_speed = encoder_speed;
    RD_DATA(counter).encoder_speed_transient = encoder_speed_transient;
%     RD_DATA(counter).encoder_speed_raw = encoder_speed_raw;
    
    %     RD_DATA(counter).dens_hot = C_DATA(i).dens_hot;
    %     RD_DATA(counter).dens_cold = C_DATA(i).dens_cold;
    RD_DATA(counter).c_hot_in = c_hot_in;
    RD_DATA(counter).c_hot_out = c_hot_out;
    RD_DATA(counter).c_cold = c_cold;
    RD_DATA(counter).hot_bath_setpoint = C_DATA(i).hot_bath_setpoint;
    RD_DATA(counter).cold_bath_setpoint = C_DATA(i).cold_bath_setpoint;
    RD_DATA(counter).hot_liquid_flowrate = C_DATA(i).hot_liquid_flowrate;
    RD_DATA(counter).cold_liquid_flowrate = C_DATA(i).cold_liquid_flowrate;
    RD_DATA(counter).pmean_setpoint = C_DATA(i).pmean_setpoint;
    RD_DATA(counter).torque_setpoint = C_DATA(i).torque_setpoint;
    RD_DATA(counter).torque_sensor = torque_sensor;
    RD_DATA(counter).teknic_setpoint = C_DATA(i).teknic_setpoint;
    
    % From the post_process sub-function
    RD_DATA(counter).p_DCH_avg = p_DCH_avg;
    RD_DATA(counter).p_DM_avg = p_DM_avg;
    RD_DATA(counter).p_PC_avg = p_PC_avg;
    RD_DATA(counter).p_CC_avg = p_CC_avg;
    RD_DATA(counter).pmean = pmean;
    RD_DATA(counter).pmean_CC = pmean_CC;
    RD_DATA(counter).p_atm = p_environment;
   
    RD_DATA(counter).Tge = Tge;
    RD_DATA(counter).Tgh_far = Tgh_far;
    RD_DATA(counter).Tgh_pipe = Tgh_pipe;
    RD_DATA(counter).Tgh = Tgh;
    RD_DATA(counter).Tgr = Tgr;
    RD_DATA(counter).Tgk = Tgk;
    RD_DATA(counter).Tgc = Tgc;
    RD_DATA(counter).TgCC = TgCC;
    
    
    RD_DATA(counter).Tgh_inlet_far = Tgh_inlet_far;
    RD_DATA(counter).Tgh_inlet_pipe = Tgh_inlet_pipe;
    RD_DATA(counter).Tgh_inlet = Tgh_inlet;    
    RD_DATA(counter).Tgh_reg_far = Tgh_reg_far;
    RD_DATA(counter).Tgh_reg_pipe = Tgh_reg_pipe;
    RD_DATA(counter).Tgh_reg = Tgh_reg;
    
    RD_DATA(counter).Tgk_inlet_far = Tgk_inlet_far;
    RD_DATA(counter).Tgk_inlet_pipe_1 = Tgk_inlet_pipe_1;
    RD_DATA(counter).Tgk_inlet_pipe_2 = Tgk_inlet_pipe_2;
    RD_DATA(counter).Tgk_inlet = Tgk_inlet;
    RD_DATA(counter).Tgk_reg = Tgk_reg;
    RD_DATA(counter).TgPP = TgPP;      

    
    if have_DCH_source
        RD_DATA(counter).Tsource_DCH_in = Tsource_DCH_in;
        RD_DATA(counter).Tsource_DCH_out = Tsource_DCH_out;
    end
    RD_DATA(counter).Tsource_in = Tsource_in;
    RD_DATA(counter).Tsource_out = Tsource_out;
    RD_DATA(counter).Tsink_in = Tsink_in;
    RD_DATA(counter).Tsink_out = Tsink_out;
    
    RD_DATA(counter).Wind = Wind;
    RD_DATA(counter).FW = FW;
%     RD_DATA(counter).FW_old = FW_old; %%%%%%%%%%%%%%%%%%%%%%%REMOVE later
    RD_DATA(counter).W_CC = W_CC;
    RD_DATA(counter).CC_GSH = CC_GSH;
    
    RD_DATA(counter).Qdot_DCH = Qdot_DCH;
    RD_DATA(counter).Qdot_heater = Qdot_heater;
    RD_DATA(counter).Qdot_cooler = Qdot_cooler;
    RD_DATA(counter).Qdot_PC = Qdot_PC;
    
    RD_DATA(counter).P_shaft_tsensor = P_shaft_tsensor;
    RD_DATA(counter).P_shaft_tsensor_MB_speed = P_shaft_tsensor_MB_speed;
    RD_DATA(counter).P_shaft_setpoint_MB_speed = P_shaft_setpoint_MB_speed;
    RD_DATA(counter).efficiency_shaft = efficiency_shaft;
    RD_DATA(counter).efficiency_ind = efficiency_ind;
    RD_DATA(counter).Beale = Beale;
    RD_DATA(counter).West = West;
    
    if ~short_output
        RD_DATA(counter).Ve = Ve;
        RD_DATA(counter).Vc = Vc;
        RD_DATA(counter).Vtotal = Vtotal;
    end
    
    RD_DATA(counter).Ve_rounded = Ve_rounded;
    RD_DATA(counter).Vc_rounded = Vc_rounded;
    RD_DATA(counter).Vtotal_rounded = Vtotal_rounded;
    RD_DATA(counter).V_CC_rounded = V_CC_rounded;
    
    counter = counter + 1;
    
    % Update Wait Bar
    waitbar(counter / number_of_files)
    
end

% Save Data
% reversed_file_path = reverse(Raw_Data_Folder);
% reversed_folder_name = strtok(reversed_file_path,'\');
% folder_name = reverse(reversed_folder_name);
% Post_Processed_Data_Filename = 'G:\Shared drives\NOBES_GROUP\MSPM\[MATLAB_WORKING_FOLDER]\Data Processing Code\06_Post Processing_Experimental\[Experimental Data]\2021-12-23-newBumpy-p350\2021-12-23-newBumpy-p350-T0-0.97\2021-12-23-newBumpy-p350-T0-0.97_RD_short.mat';
Post_Processed_Data_Filename = strcat(Raw_Data_Folder,'\',folder_name,'_RD.mat');

save(Post_Processed_Data_Filename,'RD_DATA','-v7.3')

close(WaitBar)