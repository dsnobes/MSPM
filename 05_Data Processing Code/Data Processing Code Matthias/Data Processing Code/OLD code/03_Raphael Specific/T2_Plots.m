% Terrapin_Engine_2.0_Plots.m - Written by Connor Speer, February 20/2018

% The script runs the second order model to produce plots for the Terrapin
% Engine 2.0.

%% Plot Aesthetics
set(0,'defaultfigurecolor',[1 1 1])

% For Connor's Thesis Paper %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Location of Figures
x = 500;
y = 500;

% Size of Figures
width = 550;
height = 400;

% Font For Figures
font = 'Arial';
font_size = 11;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Figure 3.X: Power and Efficiency vs. Frequency Using 2nd Order Model
crank_inc = 1; % Crank angle step size for model output [degrees].

% Mean Pressure Variation
Min_freq = 0.5; % Minimum frequency to be simulated in [Hz].
Max_freq = 12; % Maximum frequency to be simulated in [Hz].
freq_inc = 0.5; % Frequency increment in [Hz].

Model_Code = 3; % Code specifying which model to run (3 = Simple Model).
Losses_Code = 4; % Code specifying which losses subfunction to run
part_traj_on_off = 0; % No particle trajectory calculation

ENGINE_DATA = T2_ENGINE_DATA_1; % Structure defining engine geometry and operating conditions.
ENGINE_DATA.Pbore = 0.085;
ENGINE_DATA.V_buffer_max = 0.0032;
ENGINE_DATA.Vclp = 1.733e-04;
ENGINE_DATA.GSH_config = 1; 

% Vary Frequency with 85 mm Piston:
FREQ_DATA = T2_2nd_Order_Vary('freq',Min_freq,Max_freq,freq_inc,ENGINE_DATA);

% Find mean pressure at maximum power
[Max_Power,max_power_index] = max([FREQ_DATA.W_dot]);
freq_at_Max_Power = Min_freq + (max_power_index-1)*freq_inc;

% Find mean pressure at maximum efficiency
[Max_Efficiency,max_efficiency_index] = max([FREQ_DATA.eff_thermal]);
freq_at_Max_Efficiency = Min_freq + (max_efficiency_index-1)*freq_inc;

% Find mean pressure at stall
[Min_Power,free_run_index] = min(abs([FREQ_DATA.W_dot]));
freq_at_Free_Run = Min_freq + (free_run_index-1)*freq_inc;

% Power and Efficiency vs. Frequency 
figure('Position', [x y 326 275])
freq_Range = Min_freq:freq_inc:Max_freq;

freq_Power_Range = [FREQ_DATA.W_dot];
freq_Efficiency_Range = [FREQ_DATA.eff_thermal].*100;

% Plot Power on the left axis
yyaxis left
plot(freq_Range,freq_Power_Range,'r','LineWidth',2)
% ylim([0 inf])
ylabel('Power Output (W)','FontName',font,'FontSize',font_size)
set(gca,'ycolor','r')
% Plot efficiency on the right axis
yyaxis right
plot(freq_Range,freq_Efficiency_Range,'b','LineWidth',2)
% ylim([0 inf])
ylabel('Thermal Efficiency (%)','FontName',font,'FontSize',font_size)
set(gca,'ycolor','b')
xlabel('Engine Frequency (Hz)','FontName',font,'FontSize',font_size)
legend('Power','Efficiency','Location','South') 
set(gca,'fontsize',font_size);
set(gca,'FontName',font)

% Normalized Power Losses vs Frequency
figure('Position', [x y 326 275])
P_HEX_rel = [FREQ_DATA.P_HEX]./[FREQ_DATA.ref_cycle_power];
P_mech_rel = [FREQ_DATA.P_mech]./[FREQ_DATA.ref_cycle_power];
P_flow_h_rel = [FREQ_DATA.P_flow_h]./[FREQ_DATA.ref_cycle_power];
P_flow_r_rel = [FREQ_DATA.P_flow_r]./[FREQ_DATA.ref_cycle_power];
P_flow_k_rel = [FREQ_DATA.P_flow_k]./[FREQ_DATA.ref_cycle_power];
% P_GSH_rel = [FREQ_DATA.P_GSH]./[FREQ_DATA.ref_cycle_power];
hold on 
plot(freq_Range,P_HEX_rel.*100,'LineWidth',2)
plot(freq_Range,P_mech_rel.*100,'LineWidth',2)
plot(freq_Range,P_flow_h_rel.*100,'LineWidth',2)
plot(freq_Range,P_flow_r_rel.*100,'LineWidth',2)
plot(freq_Range,P_flow_k_rel.*100,'LineWidth',2)
% plot(freq_Range,P_GSH_rel.*100,'LineWidth',2)
hold off
xlabel('Engine Frequency (Hz)','FontName',font,'FontSize',font_size)
ylabel('Normalized Power Losses (%)','FontName',font,'FontSize',font_size)
legend('Imperfect Heat Transfer','Mechanical Friction','Heater Flow Friction','Regenerator Flow Friction',...
    'Cooler Flow Friction','Gas Spring Hysteresis','Location','North') 
set(gca,'fontsize',font_size);
set(gca,'FontName',font)
ylim([0 100])
xlim([0 12])

% Flow Friction losses vs Frequency
figure('Position', [x y 326 275])
hold on
plot(freq_Range,[FREQ_DATA.P_flow_h],'r','LineWidth',2)
plot(freq_Range,[FREQ_DATA.P_flow_r],'g','LineWidth',2)
plot(freq_Range,[FREQ_DATA.P_flow_k],'b','LineWidth',2)
hold off
xlabel('Engine Frequency (Hz)','FontName',font,'FontSize',font_size)
ylabel('Flow Friction Losses (W)','FontName',font,'FontSize',font_size)
legend('Heater','Regenerator','Cooler','Location','NorthWest') 
set(gca,'fontsize',font_size);
set(gca,'FontName',font)

% Pressure Drops vs Frequency
figure('Position', [x y 326 275])
hold on
plot([FREQ_DATA(end).pdroph]./1000,'r','LineWidth',2)
plot([FREQ_DATA(end).pdropr]./1000,'g','LineWidth',2)
plot([FREQ_DATA(end).pdropk]./1000,'b','LineWidth',2)
hold off
xlabel('Crank Angle (\circ)','FontName',font,'FontSize',font_size)
ylabel('Pressure Drop (kPa)','FontName',font,'FontSize',font_size)
legend('Heater','Regenerator','Cooler','Location','NorthEast') 
set(gca,'fontsize',font_size);
set(gca,'FontName',font)

%% Figure 3.X: Power and Efficiency vs. Mean Pressure Using 2nd Order Model
crank_inc = 1; % Crank angle step size for model output [degrees].

% Mean Pressure Variation
Min_pmean = 100000; % Minimum mean pressure to be simulated in [Pa].
Max_pmean = 100000000; % Maximum mean pressure to be simulated in [Pa].
pmean_inc = 1000000; % Mean pressure increment in [Pa].

Model_Code = 3; % Code specifying which model to run (3 = Simple Model).
Losses_Code = 2; % Code specifying which losses subfunction to run
part_traj_on_off = 0; % No particle trajectory calculation

ENGINE_DATA = T2_ENGINE_DATA_1; % Structure defining engine geometry and operating conditions.
ENGINE_DATA.Pbore = 0.085;
ENGINE_DATA.V_buffer_max = 0.0032;
ENGINE_DATA.Vclp = 1.733e-04;
ENGINE_DATA.GSH_config = 1;

% Vary Frequency with 85 mm Piston:
PMEAN_DATA = T2_2nd_Order_Vary('pmean',Min_pmean,Max_pmean,pmean_inc,ENGINE_DATA);

% Find mean pressure at maximum power
[Max_Power,max_power_index] = max([PMEAN_DATA.W_dot]);
pmean_at_Max_Power = Min_pmean + (max_power_index-1)*pmean_inc;

% Find mean pressure at maximum efficiency
[Max_Efficiency,max_efficiency_index] = max([PMEAN_DATA.eff_thermal]);
pmean_at_Max_Efficiency = Min_pmean + (max_efficiency_index-1)*pmean_inc;

% Find mean pressure at stall
[Min_Power,free_run_index] = min(abs([PMEAN_DATA.W_dot]));
pmean_at_Free_Run = Min_pmean + (free_run_index-1)*pmean_inc;

% Power and Efficiency vs. Mean Pressure 
figure('Position', [x y 326 275])
pmean_Range = Min_pmean:pmean_inc:Max_pmean;
pmean_Range_kPa = pmean_Range./1000;

pmean_Power_Range = [PMEAN_DATA.W_dot];
pmean_Efficiency_Range = [PMEAN_DATA.eff_thermal].*100;

% Plot Power on the left axis
yyaxis left
plot(pmean_Range_kPa,pmean_Power_Range,'r','LineWidth',2)
% ylim([0 inf])
ylabel('Power Output (W)','FontName',font,'FontSize',font_size)
set(gca,'ycolor','r')
% Plot efficiency on the right axis
yyaxis right
plot(pmean_Range_kPa,pmean_Efficiency_Range,'b','LineWidth',2)
% ylim([0 inf])
ylabel('Thermal Efficiency (%)','FontName',font,'FontSize',font_size)
set(gca,'ycolor','b')
xlabel('Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
legend('Power','Efficiency','Location','South') 
set(gca,'fontsize',font_size);
set(gca,'FontName',font)

% Normalized Power Losses vs Mean Pressure
figure('Position', [x y 326 275])
P_HEX_rel = [PMEAN_DATA.P_HEX]./[PMEAN_DATA.ref_cycle_power];
P_mech_rel = [PMEAN_DATA.P_mech]./[PMEAN_DATA.ref_cycle_power];
P_flow_h_rel = [PMEAN_DATA.P_flow_h]./[PMEAN_DATA.ref_cycle_power];
P_flow_r_rel = [PMEAN_DATA.P_flow_r]./[PMEAN_DATA.ref_cycle_power];
P_flow_k_rel = [PMEAN_DATA.P_flow_k]./[PMEAN_DATA.ref_cycle_power];
% P_GSH_rel = [PMEAN_DATA.P_GSH]./[PMEAN_DATA.ref_cycle_power];
hold on 
plot(pmean_Range_kPa,P_HEX_rel.*100,'LineWidth',2)
plot(pmean_Range_kPa,P_mech_rel.*100,'LineWidth',2)
plot(pmean_Range_kPa,P_flow_h_rel.*100,'LineWidth',2)
plot(pmean_Range_kPa,P_flow_r_rel.*100,'LineWidth',2)
plot(pmean_Range_kPa,P_flow_k_rel.*100,'LineWidth',2)
% plot(pmean_Range_kPa,P_GSH_rel.*100,'LineWidth',2)
hold off
xlabel('Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
ylabel('Normalized Power Losses (%)','FontName',font,'FontSize',font_size)
legend('Imperfect Heat Transfer','Mechanical Friction','Heater Flow Friction','Regenerator Flow Friction',...
    'Cooler Flow Friction','Gas Spring Hysteresis','Location','North') 
set(gca,'fontsize',font_size);
set(gca,'FontName',font)
ylim([0 100])

%% Figure 3.X: Power and Efficiency vs. Thermal Source Temperature Using 2nd Order Model
% Thermal Source Temperature Variation
Min_TH = 273 + 50; % Minimum thermal source temperature to be simulated in [K].
Max_TH = 273 + 1000; % Maximum thermal source temperature to be simulated in [K].
TH_inc = 50; % Thermal source temperature increment in [K].

% Plot 1 - Power and Efficiency vs. Hot Source Temperature, As-Built
ENGINE_DATA = T2_ENGINE_DATA_1;
ENGINE_DATA.Pbore = 0.085;
ENGINE_DATA.V_buffer_max = 0.0032;
ENGINE_DATA.Vclp = 1.733e-04;
ENGINE_DATA.GSH_config = 1;

counter = 1;
for TH = Min_TH:TH_inc:Max_TH
    ENGINE_DATA.Tsource = TH;
    ENGINE_DATA.Tge = TH;
    ENGINE_DATA.Tgh = TH;
    ENGINE_DATA.Twh = TH;
    
    [SECOND_ORDER_DATA,REF_CYCLE_DATA,LOSSES_DATA] ...
        = T2_2nd_Order(ENGINE_DATA);
    
    SOL(counter).second_order_power = SECOND_ORDER_DATA.W_dot;
    SOL(counter).second_order_efficiency = SECOND_ORDER_DATA.eff_thermal;
    SOL(counter).ref_cycle_power = [REF_CYCLE_DATA(end).W].*[ENGINE_DATA.freq];
    SOL(counter).P_HEX = REF_CYCLE_DATA(1).W_dot_ref-(REF_CYCLE_DATA(end).W*ENGINE_DATA.freq);
    SOL(counter).P_mech = LOSSES_DATA.P_mech;
    SOL(counter).P_flow_h = LOSSES_DATA.P_flow_h;
    SOL(counter).P_flow_r = LOSSES_DATA.P_flow_r;
    SOL(counter).P_flow_k = LOSSES_DATA.P_flow_k;
    SOL(counter).P_GSH = LOSSES_DATA.P_GSH;
    counter = counter + 1;
end
    
figure('Position', [x y 326 275])

TH_Range = Min_TH:TH_inc:Max_TH;
TH_Range_Celcius = TH_Range - 273.15;

% Plot Power on the left axis
yyaxis left
plot(TH_Range_Celcius,[SOL.second_order_power],'r','LineWidth',2)
% ylim([0 inf])
ylabel('Power Output (W)','FontName',font,'FontSize',font_size)
set(gca,'ycolor','r')
% Plot efficiency on the right axis
yyaxis right
plot(TH_Range_Celcius,[SOL.second_order_efficiency]*100,'b','LineWidth',2)
% ylim([0 inf])
ylabel('Thermal Efficiency (%)','FontName',font,'FontSize',font_size)
set(gca,'ycolor','b')

xlabel('Heater Wall Temperature (\circC)','FontName',font,'FontSize',font_size)
legend('Power','Efficiency','Location','SouthEast') 
set(gca,'fontsize',font_size);
set(gca,'FontName',font)

% Plot 2 - Relative Power Losses As-Built
P_HEX_rel = [SOL.P_HEX]./[SOL.ref_cycle_power];
P_mech_rel = [SOL.P_mech]./[SOL.ref_cycle_power];
P_flow_h_rel = [SOL.P_flow_h]./[SOL.ref_cycle_power];
P_flow_r_rel = [SOL.P_flow_r]./[SOL.ref_cycle_power];
P_flow_k_rel = [SOL.P_flow_k]./[SOL.ref_cycle_power];
% P_GSH_rel = [SOL.P_GSH]./[SOL.ref_cycle_power];

figure('Position', [x y 326 275])
hold on
plot(TH_Range_Celcius,P_HEX_rel.*100,'LineWidth',2)
plot(TH_Range_Celcius,P_mech_rel.*100,'LineWidth',2)
plot(TH_Range_Celcius,P_flow_h_rel.*100,'LineWidth',2)
plot(TH_Range_Celcius,P_flow_r_rel.*100,'LineWidth',2)
plot(TH_Range_Celcius,P_flow_k_rel.*100,'LineWidth',2)
% plot(TH_Range_Celcius,P_GSH_rel.*100,'LineWidth',2)
ylim([0 100])
xlim([200 1000])
hold off
xlabel('Heater Wall Temperature (\circC)','FontName',font,'FontSize',font_size)
ylabel({'Relative Power Losses (%)'},'FontName',font,'FontSize',font_size)
legend('Imperfect Heat Transfer','Mechanical Friction','Heater Flow Friction','Regenerator Flow Friction',...
    'Cooler Flow Friction','Gas Spring Hysteresis','Location','NorthEast')
set(gca,'fontsize',font_size);
set(gca,'FontName',font)