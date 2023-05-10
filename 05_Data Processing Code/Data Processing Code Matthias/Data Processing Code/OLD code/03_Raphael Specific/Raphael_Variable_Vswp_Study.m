% Raphael_Variable_Vswp_Study.m - Written by Connor Speer, September 2019

clear, clc, close all;

%% Plot Aesthetics
set(0,'defaultfigurecolor',[1 1 1])

% Location of Figures
x = 500;
y = 500;

% Size of Figures
width = 550;
height = 400;

% Font For Figures
font = 'Arial';
font_size = 16;

%% Calculate Optimum Piston Diameter for a Range of Hot Side Temperatures (Repeat calculation for cold side temperatures later)
% Piston Diameter Variation
Min_Pbore = 0.110; %(m) Minimum piston diameter to be simulated.
Max_Pbore = 0.250; %(m) Maximum piston diameter to be simulated.
Pbore_inc = 0.010; %(m) Piston diameter increment.

% Hot Side Temperature Variation
Min_Thot = 50 + 273.15; % Minimum Hot Side Temperature to be simulated in (K).
Max_Thot = 400 + 273.15; % Maximum Hot Side Temperature to be simulated in (K).
Thot_inc = 50; % Hot Side Temperature increment in (K).

% Define common operating parameters
freq = 3; % Engine frequency in (Hz).
pmean = 1000000; % Mean pressure in (Pa).
Tcold = 5 + 273.15; % Cold side temperature in (K).

% Preallocate space for solution structures
PBORE_SOL(length(Min_Pbore:Pbore_inc:Max_Pbore)).second_order_power = [];
PBORE_SOL(length(Min_Pbore:Pbore_inc:Max_Pbore)).second_order_efficiency = [];
PBORE_SOL(length(Min_Pbore:Pbore_inc:Max_Pbore)).Thot = [];
PBORE_SOL(length(Min_Pbore:Pbore_inc:Max_Pbore)).Pbore = [];

THOT_SOL(length(Min_Thot:Thot_inc:Max_Thot)).second_order_power = [];
THOT_SOL(length(Min_Thot:Thot_inc:Max_Thot)).second_order_efficiency = [];
THOT_SOL(length(Min_Thot:Thot_inc:Max_Thot)).Thot = [];
THOT_SOL(length(Min_Thot:Thot_inc:Max_Thot)).Pbore = [];

PBORE_CONSTANT_SOL(length(Min_Thot:Thot_inc:Max_Thot)).second_order_power = [];
PBORE_CONSTANT_SOL(length(Min_Thot:Thot_inc:Max_Thot)).second_order_efficiency = [];
PBORE_CONSTANT_SOL(length(Min_Thot:Thot_inc:Max_Thot)).Thot = [];
PBORE_CONSTANT_SOL(length(Min_Thot:Thot_inc:Max_Thot)).Pbore = [];

PBORE_MAX_POWER_SOL(length(Min_Thot:Thot_inc:Max_Thot)).second_order_power = [];
PBORE_MAX_POWER_SOL(length(Min_Thot:Thot_inc:Max_Thot)).second_order_efficiency = [];
PBORE_MAX_POWER_SOL(length(Min_Thot:Thot_inc:Max_Thot)).Thot = [];
PBORE_MAX_POWER_SOL(length(Min_Thot:Thot_inc:Max_Thot)).Pbore = [];

PBORE_MAX_EFFICIENCY_SOL(length(Min_Thot:Thot_inc:Max_Thot)).second_order_power = [];
PBORE_MAX_EFFICIENCY_SOL(length(Min_Thot:Thot_inc:Max_Thot)).second_order_efficiency = [];
PBORE_MAX_EFFICIENCY_SOL(length(Min_Thot:Thot_inc:Max_Thot)).Thot = [];
PBORE_MAX_EFFICIENCY_SOL(length(Min_Thot:Thot_inc:Max_Thot)).Pbore = [];

Thot_counter = 1;
for Thot = Min_Thot:Thot_inc:Max_Thot
    Pbore_counter = 1;
    for Pbore = Min_Pbore:Pbore_inc:Max_Pbore
        % Run Model for Raphael Engine
        ENGINE_DATA = T2_ENGINE_DATA;
        ENGINE_DATA.Pbore = Pbore;
        ENGINE_DATA.freq = freq;
        ENGINE_DATA.pmean = pmean;
        ENGINE_DATA.Tsink = Tcold;
        ENGINE_DATA.Tgk = Tcold;
        ENGINE_DATA.Twk = Tcold;
        ENGINE_DATA.Tgc = Tcold;
        ENGINE_DATA.Tsource = Thot;
        ENGINE_DATA.Tgh = Thot;
        ENGINE_DATA.Twh = Thot;
        ENGINE_DATA.Tge = Thot;
        p_PC_avg = pmean;
        p_CC_avg = pmean;
        ENGINE_DATA.p_buffer_exp = pmean;
        Tge_exp = Thot;
        Tgc_exp = Tcold;

        [SECOND_ORDER_DATA,REF_CYCLE_DATA,LOSSES_DATA,PARTICLE_TRAJECTORY_DATA,MECHANISM_DATA]...
            = T2_2nd_Order(ENGINE_DATA,p_PC_avg,p_CC_avg,Tge_exp,Tgc_exp);

        PBORE_SOL(Pbore_counter).second_order_power = SECOND_ORDER_DATA.W_dot;
        PBORE_SOL(Pbore_counter).second_order_efficiency = SECOND_ORDER_DATA.eff_thermal;
        PBORE_SOL(Pbore_counter).Thot = Thot;
        PBORE_SOL(Pbore_counter).Pbore = Pbore;
        
        Pbore_counter = Pbore_counter + 1;
    end
    
    THOT_SOL(Thot_counter).Thot = Thot;
    
    % Find P_bore at maximum power for each Thot
    [max_power,max_power_index] = max([PBORE_SOL.second_order_power]);
    THOT_SOL(Thot_counter).max_power = max_power;
    THOT_SOL(Thot_counter).Pbore_at_max_power = PBORE_SOL(max_power_index).Pbore;
    
    % Find P_bore at maximum power for each Thot
    [max_efficiency,max_efficiency_index] = max([PBORE_SOL.second_order_efficiency]);
    THOT_SOL(Thot_counter).max_efficiency = max_efficiency;
    THOT_SOL(Thot_counter).Pbore_at_max_efficiency = PBORE_SOL(max_efficiency_index).Pbore;
    
    Thot_counter = Thot_counter + 1;
end

% Plot 1 - Pbores for best power and efficiency vs temperature
figure('Position', [x y width height])

Thot_range = Min_Thot:Thot_inc:Max_Thot;
hold on
plot(Thot_range - 273.15,[THOT_SOL.Pbore_at_max_power].*1000,'r','LineWidth',2)
plot(Thot_range - 273.15,[THOT_SOL.Pbore_at_max_efficiency].*1000,'b','LineWidth',2)
% ylim([0 inf])
ylabel('Piston Diameter (mm)','FontName',font,'FontSize',font_size)
xlabel('Hot Side Temperature (\circC)','FontName',font,'FontSize',font_size)
legend('Maximum Power','Maximum Efficiency','Location','SouthWest') 
set(gca,'fontsize',font_size);
set(gca,'FontName',font)

%% Calculate Power and Efficiency vs Temperature for The Piston Diameter Optimized for the Mean Temperature
Thot_counter = 1;
for Thot = Min_Thot:Thot_inc:Max_Thot
    % Run Model for Raphael Engine
    ENGINE_DATA = T2_ENGINE_DATA;
    ENGINE_DATA.Pbore = 0.170;
    ENGINE_DATA.freq = freq;
    ENGINE_DATA.pmean = pmean;
    ENGINE_DATA.Tsink = Tcold;
    ENGINE_DATA.Tgk = Tcold;
    ENGINE_DATA.Twk = Tcold;
    ENGINE_DATA.Tgc = Tcold;
    ENGINE_DATA.Tsource = Thot;
    ENGINE_DATA.Tgh = Thot;
    ENGINE_DATA.Twh = Thot;
    ENGINE_DATA.Tge = Thot;
    p_PC_avg = pmean;
    p_CC_avg = pmean;
    ENGINE_DATA.p_buffer_exp = pmean;
    Tge_exp = Thot;
    Tgc_exp = Tcold;

    [SECOND_ORDER_DATA,REF_CYCLE_DATA,LOSSES_DATA,PARTICLE_TRAJECTORY_DATA,MECHANISM_DATA]...
        = T2_2nd_Order(ENGINE_DATA,p_PC_avg,p_CC_avg,Tge_exp,Tgc_exp);

    PBORE_CONSTANT_SOL(Thot_counter).second_order_power = SECOND_ORDER_DATA.W_dot;
    PBORE_CONSTANT_SOL(Thot_counter).second_order_efficiency = SECOND_ORDER_DATA.eff_thermal;
    PBORE_CONSTANT_SOL(Thot_counter).Thot = Thot;
    PBORE_CONSTANT_SOL(Thot_counter).Pbore = ENGINE_DATA.Pbore;

    Thot_counter = Thot_counter + 1;
end
    
% Plot 2 - Power and Efficiency vs. Thot for Constant Pbore
figure('Position', [x y width height])

% Plot Power on the left axis
yyaxis left
plot(Thot_range - 273.15,[PBORE_CONSTANT_SOL.second_order_power],'r','LineWidth',2)
% ylim([0 inf])
ylabel('Power Output (W)','FontName',font,'FontSize',font_size)
set(gca,'ycolor','r')
% Plot efficiency on the right axis
yyaxis right
plot(Thot_range - 273.15,[PBORE_CONSTANT_SOL.second_order_efficiency]*100,'b','LineWidth',2)
% ylim([0 inf])
ylabel('Thermal Efficiency (%)','FontName',font,'FontSize',font_size)
set(gca,'ycolor','b')

xlabel('Hot Side Temperature (\circC)','FontName',font,'FontSize',font_size)
legend('Power','Efficiency','Location','SouthWest')
title('Constant Pbore')
set(gca,'fontsize',font_size);
set(gca,'FontName',font)

%% Calculate Power and Efficiency vs Temperature for Variable Piston Diameter (Best Power)
Thot_counter = 1;
for Thot = Min_Thot:Thot_inc:Max_Thot
    % Run Model for Raphael Engine
    ENGINE_DATA = T2_ENGINE_DATA;
    
    ENGINE_DATA.Pbore = THOT_SOL(Thot_counter).Pbore_at_max_power;
    
    ENGINE_DATA.freq = freq;
    ENGINE_DATA.pmean = pmean;
    ENGINE_DATA.Tsink = Tcold;
    ENGINE_DATA.Tgk = Tcold;
    ENGINE_DATA.Twk = Tcold;
    ENGINE_DATA.Tgc = Tcold;
    ENGINE_DATA.Tsource = Thot;
    ENGINE_DATA.Tgh = Thot;
    ENGINE_DATA.Twh = Thot;
    ENGINE_DATA.Tge = Thot;
    p_PC_avg = pmean;
    p_CC_avg = pmean;
    ENGINE_DATA.p_buffer_exp = pmean;
    Tge_exp = Thot;
    Tgc_exp = Tcold;

    [SECOND_ORDER_DATA,REF_CYCLE_DATA,LOSSES_DATA,PARTICLE_TRAJECTORY_DATA,MECHANISM_DATA]...
        = T2_2nd_Order(ENGINE_DATA,p_PC_avg,p_CC_avg,Tge_exp,Tgc_exp);

    PBORE_MAX_POWER_SOL(Thot_counter).second_order_power = SECOND_ORDER_DATA.W_dot;
    PBORE_MAX_POWER_SOL(Thot_counter).second_order_efficiency = SECOND_ORDER_DATA.eff_thermal;
    PBORE_MAX_POWER_SOL(Thot_counter).Thot = Thot;
    PBORE_MAX_POWER_SOL(Thot_counter).Pbore = ENGINE_DATA.Pbore;

    Thot_counter = Thot_counter + 1;
end

% Plot 3 - Power and Efficiency vs. Thot for Max Power Pbore
figure('Position', [x y width height])

% Plot Power on the left axis
yyaxis left
plot(Thot_range - 273.15,[PBORE_MAX_POWER_SOL.second_order_power],'r','LineWidth',2)
% ylim([0 inf])
ylabel('Power Output (W)','FontName',font,'FontSize',font_size)
set(gca,'ycolor','r')
% Plot efficiency on the right axis
yyaxis right
plot(Thot_range - 273.15,[PBORE_MAX_POWER_SOL.second_order_efficiency]*100,'b','LineWidth',2)
% ylim([0 inf])
ylabel('Thermal Efficiency (%)','FontName',font,'FontSize',font_size)
set(gca,'ycolor','b')

xlabel('Hot Side Temperature (\circC)','FontName',font,'FontSize',font_size)
legend('Power','Efficiency','Location','SouthWest')
title('Max Power Pbore')
set(gca,'fontsize',font_size);
set(gca,'FontName',font)

%% Calculate Power and Efficiency vs Temperature for Variable Piston Diameter (Best Efficiency)
Thot_counter = 1;
for Thot = Min_Thot:Thot_inc:Max_Thot
    % Run Model for Raphael Engine
    ENGINE_DATA = T2_ENGINE_DATA;
    
    ENGINE_DATA.Pbore = THOT_SOL(Thot_counter).Pbore_at_max_efficiency;
    
    ENGINE_DATA.freq = freq;
    ENGINE_DATA.pmean = pmean;
    ENGINE_DATA.Tsink = Tcold;
    ENGINE_DATA.Tgk = Tcold;
    ENGINE_DATA.Twk = Tcold;
    ENGINE_DATA.Tgc = Tcold;
    ENGINE_DATA.Tsource = Thot;
    ENGINE_DATA.Tgh = Thot;
    ENGINE_DATA.Twh = Thot;
    ENGINE_DATA.Tge = Thot;
    p_PC_avg = pmean;
    p_CC_avg = pmean;
    ENGINE_DATA.p_buffer_exp = pmean;
    Tge_exp = Thot;
    Tgc_exp = Tcold;

    [SECOND_ORDER_DATA,REF_CYCLE_DATA,LOSSES_DATA,PARTICLE_TRAJECTORY_DATA,MECHANISM_DATA]...
        = T2_2nd_Order(ENGINE_DATA,p_PC_avg,p_CC_avg,Tge_exp,Tgc_exp);

    PBORE_MAX_EFFICIENCY_SOL(Thot_counter).second_order_power = SECOND_ORDER_DATA.W_dot;
    PBORE_MAX_EFFICIENCY_SOL(Thot_counter).second_order_efficiency = SECOND_ORDER_DATA.eff_thermal;
    PBORE_MAX_EFFICIENCY_SOL(Thot_counter).Thot = Thot;
    PBORE_MAX_EFFICIENCY_SOL(Thot_counter).Pbore = ENGINE_DATA.Pbore;

    Thot_counter = Thot_counter + 1;
end

% Plot 4 - Power and Efficiency vs. Thot for Max Efficiency Pbore
figure('Position', [x y width height])

% Plot Power on the left axis
yyaxis left
plot(Thot_range - 273.15,[PBORE_MAX_EFFICIENCY_SOL.second_order_power],'r','LineWidth',2)
% ylim([0 inf])
ylabel('Power Output (W)','FontName',font,'FontSize',font_size)
set(gca,'ycolor','r')
% Plot efficiency on the right axis
yyaxis right
plot(Thot_range - 273.15,[PBORE_MAX_EFFICIENCY_SOL.second_order_efficiency]*100,'b','LineWidth',2)
% ylim([0 inf])
ylabel('Thermal Efficiency (%)','FontName',font,'FontSize',font_size)
set(gca,'ycolor','b')

xlabel('Hot Side Temperature (\circC)','FontName',font,'FontSize',font_size)
legend('Power','Efficiency','Location','SouthWest')
title('Max Efficiency Pbore')
set(gca,'fontsize',font_size);
set(gca,'FontName',font)

%% Combination/Summary Plots
% Efficiency vs. Thot
figure('Position', [x y width height])
hold on
plot(Thot_range - 273.15,[PBORE_CONSTANT_SOL.second_order_efficiency].*100,'r','LineWidth',2)
plot(Thot_range - 273.15,[PBORE_MAX_POWER_SOL.second_order_efficiency].*100,'b','LineWidth',2)
plot(Thot_range - 273.15,[PBORE_MAX_EFFICIENCY_SOL.second_order_efficiency].*100,'g','LineWidth',2)
ylim([0 inf])
ylabel('Thermal Efficiency (%)','FontName',font,'FontSize',font_size)
xlabel('Hot Side Temperature (\circC)','FontName',font,'FontSize',font_size)
legend('Constant Pbore','Max Power Pbore','Max Efficiency Pbore','Location','SouthWest')
set(gca,'fontsize',font_size);
set(gca,'FontName',font)

% Power vs. Thot
figure('Position', [x y width height])
hold on
plot(Thot_range - 273.15,[PBORE_CONSTANT_SOL.second_order_power],'r','LineWidth',2)
plot(Thot_range - 273.15,[PBORE_MAX_POWER_SOL.second_order_power],'b','LineWidth',2)
plot(Thot_range - 273.15,[PBORE_MAX_EFFICIENCY_SOL.second_order_power],'g','LineWidth',2)
ylim([0 inf])
ylabel('Power (W)','FontName',font,'FontSize',font_size)
xlabel('Hot Side Temperature (\circC)','FontName',font,'FontSize',font_size)
legend('Constant Pbore','Max Power Pbore','Max Efficiency Pbore','Location','SouthWest')
set(gca,'fontsize',font_size);
set(gca,'FontName',font)
