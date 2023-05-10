% T2_vs_HTG.m - Written by Connor Speer, April 2018

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

%% Single Run PV diagrams and Loss Breakdown
% % Define common operating point
% freq = 2; % Engine frequency in (Hz).
% pmean = 1000000; % Mean pressure in (kPa).
% Tcold = 273 + 5; % Cold side temperatures in (K).
% Thot = 273 + 95; % Hot side gas temperatures in (K).
% 
% % Run model for T2 engine
% ENGINE_DATA = T2_ENGINE_DATA;
% ENGINE_DATA.freq = freq;
% ENGINE_DATA.pmean = pmean;
% ENGINE_DATA.Tsink = Tcold;
% ENGINE_DATA.Tgk = Tcold;
% ENGINE_DATA.Twk = Tcold;
% ENGINE_DATA.Tgc = Tcold;
% ENGINE_DATA.Tsource = Thot;
% ENGINE_DATA.Tgh = Thot;
% ENGINE_DATA.Twh = Thot;
% ENGINE_DATA.Tge = Thot;
% 
% [T2_SECOND_ORDER_DATA,T2_REF_CYCLE_DATA,T2_LOSSES_DATA] = T2_2nd_Order(ENGINE_DATA);
% 
% Vdead_T2 = 1892.08/1e6; % Dead volume of HTG in (m^3).
% Vtotal_T2 = [T2_REF_CYCLE_DATA.Ve] + [T2_REF_CYCLE_DATA.Vc] + ...
%         repelem(Vdead_T2,length([T2_REF_CYCLE_DATA.Ve]));
%     
% % Run model for HTG engine
% ENGINE_DATA = HTG_ENGINE_DATA;
% ENGINE_DATA.freq = freq;
% ENGINE_DATA.pmean = pmean;
% ENGINE_DATA.Tsink = Tcold;
% ENGINE_DATA.Tgk = Tcold;
% ENGINE_DATA.Twk = Tcold;
% ENGINE_DATA.Tgc = Tcold;
% ENGINE_DATA.Tsource = Thot;
% ENGINE_DATA.Tgh = Thot;
% ENGINE_DATA.Twh = Thot;
% ENGINE_DATA.Tge = Thot;
% 
% [HTG_SECOND_ORDER_DATA,HTG_REF_CYCLE_DATA,HTG_LOSSES_DATA] = HTG_2nd_Order(ENGINE_DATA);
% 
% Vdead_HTG = 777.17/1e6; % Dead volume of HTG in (m^3).
% Vtotal_HTG = [HTG_REF_CYCLE_DATA.Ve] + [HTG_REF_CYCLE_DATA.Vc] + ...
%         repelem(Vdead_HTG,length([HTG_REF_CYCLE_DATA.Ve]));
% 
% % Plot Indicator Diagrams
% figure('Position', [x y width height])
% hold on
% plot(Vtotal_T2*1e3, [T2_REF_CYCLE_DATA.p]./1000,'r','LineWidth',2);
% xlabel('Working Space Volume (L)','FontName',font,'FontSize',font_size);
% ylabel('Pressure (kPa)','FontName',font,'FontSize',font_size);
% xlim([4.5 5])
% ylim([900 1150])
% title('Terrapin Engine 2.0')
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)
% hold off
% 
% figure('Position', [x y width height])
% hold on
% plot(Vtotal_HTG*1e3, [HTG_REF_CYCLE_DATA.p]./1000,'k','LineWidth',2);
% xlabel('Working Space Volume (L)','FontName',font,'FontSize',font_size);
% ylabel('Pressure (kPa)','FontName',font,'FontSize',font_size);
% xlim([1 1.5])
% ylim([900 1150])
% title('Modified HTG Engine')
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)
% hold off
% 
% figure('Position', [x y width height])
% plot(Vtotal_T2*1e3, [T2_REF_CYCLE_DATA.p]./1000,'r','LineWidth',2);
% xlabel('Working Space Volume (L)','FontName',font,'FontSize',font_size);
% ylabel('Pressure (kPa)','FontName',font,'FontSize',font_size);
% xlim([4.5 5])
% ylim([900 1150])
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)
% ax1 = gca; % current axes
% ax1.XColor = 'r';
% ax1.YColor = 'r';
% ax1_pos = ax1.Position; % position of first axes
% ax2 = axes('Position',ax1_pos,...
%     'XAxisLocation','top',...
%     'YAxisLocation','right',...
%     'Color','none');
% line(Vtotal_HTG*1e3, [HTG_REF_CYCLE_DATA.p]./1000,'Parent',ax2,'Color','k','LineWidth',2);
% xlim([1 1.5])
% ylim([900 1150])
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)

%% Power, Efficiency, and Losses vs. Engine Frequency
% % Engine Frequency Variation
% Min_freq = 0.5; % Minimum frequency to be simulated in [Hz].
% Max_freq = 12; % Maximum frequency to be simulated in [Hz].
% freq_inc = 0.25; % Frequency increment in [Hz].
% 
% % Define common operating parameters
% pmean = 1000000; % Mean pressure in (Pa).
% Tcold = 273 + 5; % Cold side temperatures in (K).
% Thot = 273 + 95; % Hot side gas temperatures in (K).
% 
% crank_inc = 1; % Crank angle step size for model output [degrees].
% Model_Code = 3; % Code specifying which model to run (3 = Simple Model).
% part_traj_on_off = 0; % No particle trajectory calculation
% 
% % Run model for T2 engine
% ENGINE_DATA = T2_ENGINE_DATA;
% ENGINE_DATA.pmean = pmean;
% ENGINE_DATA.Tsink = Tcold;
% ENGINE_DATA.Tgk = Tcold;
% ENGINE_DATA.Twk = Tcold;
% ENGINE_DATA.Tgc = Tcold;
% ENGINE_DATA.Tsource = Thot;
% ENGINE_DATA.Tgh = Thot;
% ENGINE_DATA.Twh = Thot;
% ENGINE_DATA.Tge = Thot;
% 
% T2_FREQ_DATA = T2_2nd_Order_Vary('freq',Min_freq,Max_freq,freq_inc,ENGINE_DATA);
% 
% % Power and Efficiency vs. Frequency 
% figure('Position', [x y width height])
% freq_Range = Min_freq:freq_inc:Max_freq;
% 
% freq_Power_Range = [T2_FREQ_DATA.W_dot];
% freq_Efficiency_Range = [T2_FREQ_DATA.eff_thermal].*100;
% 
% % Plot Power on the left axis
% yyaxis left
% plot(freq_Range,freq_Power_Range,'r','LineWidth',2)
% ylim([0 60])
% ylabel('Power Output (W)','FontName',font,'FontSize',font_size)
% set(gca,'ycolor','r')
% % Plot efficiency on the right axis
% yyaxis right
% plot(freq_Range,freq_Efficiency_Range,'b','LineWidth',2)
% ylim([0 5])
% ylabel('Thermal Efficiency (%)','FontName',font,'FontSize',font_size)
% set(gca,'ycolor','b')
% xlabel('Engine Frequency (Hz)','FontName',font,'FontSize',font_size)
% legend('Power','Efficiency','Location','South') 
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)
% 
% % Normalized Power Losses vs Frequency
% figure('Position', [x y width height])
% P_HEX_rel = [T2_FREQ_DATA.P_HEX]./[T2_FREQ_DATA.ref_cycle_power];
% P_mech_rel = [T2_FREQ_DATA.P_mech]./[T2_FREQ_DATA.ref_cycle_power];
% P_flow_h_rel = [T2_FREQ_DATA.P_flow_h]./[T2_FREQ_DATA.ref_cycle_power];
% P_flow_r_rel = [T2_FREQ_DATA.P_flow_r]./[T2_FREQ_DATA.ref_cycle_power];
% P_flow_k_rel = [T2_FREQ_DATA.P_flow_k]./[T2_FREQ_DATA.ref_cycle_power];
% P_GSH_rel = [T2_FREQ_DATA.P_GSH]./[T2_FREQ_DATA.ref_cycle_power];
% hold on 
% plot(freq_Range,P_HEX_rel.*100,'LineWidth',2)
% plot(freq_Range,P_mech_rel.*100,'LineWidth',2)
% plot(freq_Range,P_flow_h_rel.*100,'LineWidth',2)
% plot(freq_Range,P_flow_r_rel.*100,'LineWidth',2)
% plot(freq_Range,P_flow_k_rel.*100,'LineWidth',2)
% plot(freq_Range,P_GSH_rel.*100,'LineWidth',2)
% xlim([0 12])
% ylim([0 100])
% hold off
% xlabel('Engine Frequency (Hz)','FontName',font,'FontSize',font_size)
% ylabel('Normalized Power Losses (%)','FontName',font,'FontSize',font_size)
% legend('Imperfect Heat Transfer','Mechanical Friction','Heater Flow Friction','Regenerator Flow Friction',...
%     'Cooler Flow Friction','Gas Spring Hysteresis','Location','North') 
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)
% 
% 
% % Run model for HTG engine
% ENGINE_DATA = HTG_ENGINE_DATA;
% ENGINE_DATA.pmean = pmean;
% ENGINE_DATA.Tsink = Tcold;
% ENGINE_DATA.Tgk = Tcold;
% ENGINE_DATA.Twk = Tcold;
% ENGINE_DATA.Tgc = Tcold;
% ENGINE_DATA.Tsource = Thot;
% ENGINE_DATA.Tgh = Thot;
% ENGINE_DATA.Twh = Thot;
% ENGINE_DATA.Tge = Thot;
% 
% HTG_FREQ_DATA = HTG_2nd_Order_Vary('freq',Min_freq,Max_freq,freq_inc,ENGINE_DATA);
% 
% % Power and Efficiency vs. Frequency 
% figure('Position', [x y width height])
% freq_Range = Min_freq:freq_inc:Max_freq;
% 
% freq_Power_Range = [HTG_FREQ_DATA.W_dot];
% freq_Efficiency_Range = [HTG_FREQ_DATA.eff_thermal].*100;
% 
% % Plot Power on the left axis
% yyaxis left
% plot(freq_Range,freq_Power_Range,'r','LineWidth',2)
% ylim([0 60])
% ylabel('Power Output (W)','FontName',font,'FontSize',font_size)
% set(gca,'ycolor','r')
% % Plot efficiency on the right axis
% yyaxis right
% plot(freq_Range,freq_Efficiency_Range,'b','LineWidth',2)
% ylim([0 5])
% ylabel('Thermal Efficiency (%)','FontName',font,'FontSize',font_size)
% set(gca,'ycolor','b')
% xlabel('Engine Frequency (Hz)','FontName',font,'FontSize',font_size)
% legend('Power','Efficiency','Location','North') 
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)
% 
% % Normalized Power Losses vs Frequency
% figure('Position', [x y width height])
% P_HEX_rel = [HTG_FREQ_DATA.P_HEX]./[HTG_FREQ_DATA.ref_cycle_power];
% P_mech_rel = [HTG_FREQ_DATA.P_mech]./[HTG_FREQ_DATA.ref_cycle_power];
% P_flow_h_rel = [HTG_FREQ_DATA.P_flow_h]./[HTG_FREQ_DATA.ref_cycle_power];
% P_flow_r_rel = [HTG_FREQ_DATA.P_flow_r]./[HTG_FREQ_DATA.ref_cycle_power];
% P_flow_k_rel = [HTG_FREQ_DATA.P_flow_k]./[HTG_FREQ_DATA.ref_cycle_power];
% P_GSH_rel = [HTG_FREQ_DATA.P_GSH]./[HTG_FREQ_DATA.ref_cycle_power];
% hold on 
% plot(freq_Range,P_HEX_rel.*100,'LineWidth',2)
% plot(freq_Range,P_mech_rel.*100,'LineWidth',2)
% plot(freq_Range,P_flow_h_rel.*100,'LineWidth',2)
% plot(freq_Range,P_flow_r_rel.*100,'LineWidth',2)
% plot(freq_Range,P_flow_k_rel.*100,'LineWidth',2)
% plot(freq_Range,P_GSH_rel.*100,'LineWidth',2)
% xlim([0 12])
% ylim([0 100])
% hold off
% xlabel('Engine Frequency (Hz)','FontName',font,'FontSize',font_size)
% ylabel('Normalized Power Losses (%)','FontName',font,'FontSize',font_size)
% legend('Imperfect Heat Transfer','Mechanical Friction','Heater Flow Friction','Regenerator Flow Friction',...
%     'Cooler Flow Friction','Gas Spring Hysteresis','Location','North') 
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)

%% Power, Efficiency, and Losses vs. Mean Pressure
% % Mean Pressure Variation
% Min_pmean = 100000; % Minimum mean pressure to be simulated in [Pa].
% Max_pmean = 1000000; % Maximum mean pressure to be simulated in [Pa].
% pmean_inc = 100000; % Mean pressure increment in [Hz].
% 
% % Define common operating parameters
% freq = 3; % Engine frequency in (Hz).
% Tcold = 273 + 5; % Cold side temperatures in (K).
% Thot = 273 + 95; % Hot side gas temperatures in (K).
% 
% crank_inc = 1; % Crank angle step size for model output [degrees].
% Model_Code = 3; % Code specifying which model to run (3 = Simple Model).
% part_traj_on_off = 0; % No particle trajectory calculation
% 
% % Run model for T2 engine
% ENGINE_DATA = T2_ENGINE_DATA;
% ENGINE_DATA.freq = freq;
% ENGINE_DATA.Tsink = Tcold;
% ENGINE_DATA.Tgk = Tcold;
% ENGINE_DATA.Twk = Tcold;
% ENGINE_DATA.Tgc = Tcold;
% ENGINE_DATA.Tsource = Thot;
% ENGINE_DATA.Tgh = Thot;
% ENGINE_DATA.Twh = Thot;
% ENGINE_DATA.Tge = Thot;
% 
% T2_PMEAN_DATA = T2_2nd_Order_Vary('pmean',Min_pmean,Max_pmean,pmean_inc,ENGINE_DATA);
% 
% % Power and Efficiency vs. Mean Pressure 
% figure('Position', [x y width height])
% pmean_Range = Min_pmean:pmean_inc:Max_pmean;
% 
% pmean_Power_Range = [T2_PMEAN_DATA.W_dot];
% pmean_Efficiency_Range = [T2_PMEAN_DATA.eff_thermal].*100;
% 
% % Plot Power on the left axis
% yyaxis left
% plot(pmean_Range./1000,pmean_Power_Range,'r','LineWidth',2)
% ylim([0 60])
% ylabel('Power Output (W)','FontName',font,'FontSize',font_size)
% set(gca,'ycolor','r')
% % Plot efficiency on the right axis
% yyaxis right
% plot(pmean_Range./1000,pmean_Efficiency_Range,'b','LineWidth',2)
% ylim([0 5])
% ylabel('Thermal Efficiency (%)','FontName',font,'FontSize',font_size)
% set(gca,'ycolor','b')
% xlabel('Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
% legend('Power','Efficiency','Location','South') 
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)
% 
% % Normalized Power Losses vs Frequency
% figure('Position', [x y width height])
% P_HEX_rel = [T2_PMEAN_DATA.P_HEX]./[T2_PMEAN_DATA.ref_cycle_power];
% P_mech_rel = [T2_PMEAN_DATA.P_mech]./[T2_PMEAN_DATA.ref_cycle_power];
% P_flow_h_rel = [T2_PMEAN_DATA.P_flow_h]./[T2_PMEAN_DATA.ref_cycle_power];
% P_flow_r_rel = [T2_PMEAN_DATA.P_flow_r]./[T2_PMEAN_DATA.ref_cycle_power];
% P_flow_k_rel = [T2_PMEAN_DATA.P_flow_k]./[T2_PMEAN_DATA.ref_cycle_power];
% P_GSH_rel = [T2_PMEAN_DATA.P_GSH]./[T2_PMEAN_DATA.ref_cycle_power];
% hold on 
% plot(pmean_Range./1000,P_HEX_rel.*100,'LineWidth',2)
% plot(pmean_Range./1000,P_mech_rel.*100,'LineWidth',2)
% plot(pmean_Range./1000,P_flow_h_rel.*100,'LineWidth',2)
% plot(pmean_Range./1000,P_flow_r_rel.*100,'LineWidth',2)
% plot(pmean_Range./1000,P_flow_k_rel.*100,'LineWidth',2)
% plot(pmean_Range./1000,P_GSH_rel.*100,'LineWidth',2)
% % xlim([0 12])
% ylim([0 60])
% hold off
% xlabel('Engine Frequency (Hz)','FontName',font,'FontSize',font_size)
% ylabel('Normalized Power Losses (%)','FontName',font,'FontSize',font_size)
% legend('Imperfect Heat Transfer','Mechanical Friction','Heater Flow Friction','Regenerator Flow Friction',...
%     'Cooler Flow Friction','Gas Spring Hysteresis','Location','North') 
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)
% 
% 
% % Run model for HTG engine
% ENGINE_DATA = HTG_ENGINE_DATA;
% ENGINE_DATA.freq = freq;
% ENGINE_DATA.Tsink = Tcold;
% ENGINE_DATA.Tgk = Tcold;
% ENGINE_DATA.Twk = Tcold;
% ENGINE_DATA.Tgc = Tcold;
% ENGINE_DATA.Tsource = Thot;
% ENGINE_DATA.Tgh = Thot;
% ENGINE_DATA.Twh = Thot;
% ENGINE_DATA.Tge = Thot;
% 
% HTG_PMEAN_DATA = HTG_2nd_Order_Vary('pmean',Min_pmean,Max_pmean,pmean_inc,ENGINE_DATA);
% 
% % Power and Efficiency vs. Frequency 
% figure('Position', [x y width height])
% pmean_Range = Min_pmean:pmean_inc:Max_pmean;
% 
% pmean_Power_Range = [HTG_PMEAN_DATA.W_dot];
% pmean_Efficiency_Range = [HTG_PMEAN_DATA.eff_thermal].*100;
% 
% % Plot Power on the left axis
% yyaxis left
% plot(pmean_Range./1000,pmean_Power_Range,'r','LineWidth',2)
% ylim([0 60])
% ylabel('Power Output (W)','FontName',font,'FontSize',font_size)
% set(gca,'ycolor','r')
% % Plot efficiency on the right axis
% yyaxis right
% plot(pmean_Range./1000,pmean_Efficiency_Range,'b','LineWidth',2)
% ylim([0 5])
% ylabel('Thermal Efficiency (%)','FontName',font,'FontSize',font_size)
% set(gca,'ycolor','b')
% xlabel('Mean Pressure (kPa)','FontName',font,'FontSize',font_size)
% legend('Power','Efficiency','Location','North') 
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)
% 
% % Normalized Power Losses vs Frequency
% figure('Position', [x y width height])
% P_HEX_rel = [HTG_PMEAN_DATA.P_HEX]./[HTG_PMEAN_DATA.ref_cycle_power];
% P_mech_rel = [HTG_PMEAN_DATA.P_mech]./[HTG_PMEAN_DATA.ref_cycle_power];
% P_flow_h_rel = [HTG_PMEAN_DATA.P_flow_h]./[HTG_PMEAN_DATA.ref_cycle_power];
% P_flow_r_rel = [HTG_PMEAN_DATA.P_flow_r]./[HTG_PMEAN_DATA.ref_cycle_power];
% P_flow_k_rel = [HTG_PMEAN_DATA.P_flow_k]./[HTG_PMEAN_DATA.ref_cycle_power];
% P_GSH_rel = [HTG_PMEAN_DATA.P_GSH]./[HTG_PMEAN_DATA.ref_cycle_power];
% hold on 
% plot(pmean_Range./1000,P_HEX_rel.*100,'LineWidth',2)
% plot(pmean_Range./1000,P_mech_rel.*100,'LineWidth',2)
% plot(pmean_Range./1000,P_flow_h_rel.*100,'LineWidth',2)
% plot(pmean_Range./1000,P_flow_r_rel.*100,'LineWidth',2)
% plot(pmean_Range./1000,P_flow_k_rel.*100,'LineWidth',2)
% plot(pmean_Range./1000,P_GSH_rel.*100,'LineWidth',2)
% % xlim([0 12])
% % ylim([0 100])
% hold off
% xlabel('Engine Frequency (Hz)','FontName',font,'FontSize',font_size)
% ylabel('Normalized Power Losses (%)','FontName',font,'FontSize',font_size)
% legend('Imperfect Heat Transfer','Mechanical Friction','Heater Flow Friction','Regenerator Flow Friction',...
%     'Cooler Flow Friction','Gas Spring Hysteresis','Location','North') 
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)

%% Power, Efficiency, and Losses vs. Thermal Source Temperature
% % Thermal Source Temperature Variation
% Min_TH = 273 + 50; % Minimum thermal source temperature to be simulated in [K].
% Max_TH = 273 + 150; % Maximum thermal source temperature to be simulated in [K].
% TH_inc = 5; % Thermal source temperature increment in [K].
% 
% % Define common operating parameters
% freq = 3; % Engine frequency in (Hz).
% pmean = 1000000; % Mena pressure in (kPa).
% Tcold = 273 + 5; % Cold side temperatures in (K).
% 
% % Run Model for T2 Engine
% ENGINE_DATA = T2_ENGINE_DATA;
% ENGINE_DATA.freq = freq;
% ENGINE_DATA.pmean = pmean;
% ENGINE_DATA.Tsink = Tcold;
% ENGINE_DATA.Tgk = Tcold;
% ENGINE_DATA.Twk = Tcold;
% ENGINE_DATA.Tgc = Tcold;
% 
% counter = 1;
% for TH = Min_TH:TH_inc:Max_TH
%     ENGINE_DATA.Tsource = TH;
%     ENGINE_DATA.Tge = TH;
%     ENGINE_DATA.Tgh = TH;
%     ENGINE_DATA.Twh = TH;
%     
%     [SECOND_ORDER_DATA,REF_CYCLE_DATA,LOSSES_DATA] ...
%         = T2_2nd_Order(ENGINE_DATA);
%     
%     SOL(counter).second_order_power = SECOND_ORDER_DATA.W_dot;
%     SOL(counter).second_order_efficiency = SECOND_ORDER_DATA.eff_thermal;
%     SOL(counter).ref_cycle_power = [REF_CYCLE_DATA(end).W].*[ENGINE_DATA.freq];
%     SOL(counter).P_HEX = REF_CYCLE_DATA(1).W_dot_ref-(REF_CYCLE_DATA(end).W*ENGINE_DATA.freq);
%     SOL(counter).P_mech = LOSSES_DATA.P_mech;
%     SOL(counter).P_flow_h = LOSSES_DATA.P_flow_h;
%     SOL(counter).P_flow_r = LOSSES_DATA.P_flow_r;
%     SOL(counter).P_flow_k = LOSSES_DATA.P_flow_k;
%     SOL(counter).P_GSH = LOSSES_DATA.P_GSH;
%     counter = counter + 1;
% end
%     
% figure('Position', [x y width height])
% 
% TH_Range = Min_TH:TH_inc:Max_TH;
% TH_Range_Celcius = TH_Range - 273.15;
% 
% % Plot Power on the left axis
% yyaxis left
% plot(TH_Range_Celcius,[SOL.second_order_power],'r','LineWidth',2)
% ylim([0 inf])
% ylabel('Power Output (W)','FontName',font,'FontSize',font_size)
% set(gca,'ycolor','r')
% % Plot efficiency on the right axis
% yyaxis right
% plot(TH_Range_Celcius,[SOL.second_order_efficiency]*100,'b','LineWidth',2)
% ylim([0 inf])
% ylabel('Thermal Efficiency (%)','FontName',font,'FontSize',font_size)
% set(gca,'ycolor','b')
% 
% xlabel('Heater Wall Temperature (\circC)','FontName',font,'FontSize',font_size)
% legend('Power','Efficiency','Location','SouthEast') 
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)
% 
% % Plot 2 - Relative Power Losses As-Built
% P_HEX_rel = [SOL.P_HEX]./[SOL.ref_cycle_power];
% P_mech_rel = [SOL.P_mech]./[SOL.ref_cycle_power];
% P_flow_h_rel = [SOL.P_flow_h]./[SOL.ref_cycle_power];
% P_flow_r_rel = [SOL.P_flow_r]./[SOL.ref_cycle_power];
% P_flow_k_rel = [SOL.P_flow_k]./[SOL.ref_cycle_power];
% P_GSH_rel = [SOL.P_GSH]./[SOL.ref_cycle_power];
% 
% figure('Position', [x y width height])
% hold on
% plot(TH_Range_Celcius,P_HEX_rel.*100,'LineWidth',2)
% plot(TH_Range_Celcius,P_mech_rel.*100,'LineWidth',2)
% plot(TH_Range_Celcius,P_flow_h_rel.*100,'LineWidth',2)
% plot(TH_Range_Celcius,P_flow_r_rel.*100,'LineWidth',2)
% plot(TH_Range_Celcius,P_flow_k_rel.*100,'LineWidth',2)
% plot(TH_Range_Celcius,P_GSH_rel.*100,'LineWidth',2)
% ylim([0 100])
% xlim([Min_TH-273.15 Max_TH-273.15])
% hold off
% xlabel('Heater Wall Temperature (\circC)','FontName',font,'FontSize',font_size)
% ylabel({'Relative Power Losses (%)'},'FontName',font,'FontSize',font_size)
% legend('Imperfect Heat Transfer','Mechanical Friction','Heater Flow Friction','Regenerator Flow Friction',...
%     'Cooler Flow Friction','Gas Spring Hysteresis','Location','NorthEast')
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)
% 
% % Run Model for HTG Engine
% ENGINE_DATA = HTG_ENGINE_DATA;
% ENGINE_DATA.freq = freq;
% ENGINE_DATA.pmean = pmean;
% ENGINE_DATA.Tsink = Tcold;
% ENGINE_DATA.Tgk = Tcold;
% ENGINE_DATA.Twk = Tcold;
% ENGINE_DATA.Tgc = Tcold;
% 
% counter = 1;
% for TH = Min_TH:TH_inc:Max_TH
%     ENGINE_DATA.Tsource = TH;
%     ENGINE_DATA.Tge = TH;
%     ENGINE_DATA.Tgh = TH;
%     ENGINE_DATA.Twh = TH;
%     
%     [SECOND_ORDER_DATA,REF_CYCLE_DATA,LOSSES_DATA] ...
%         = HTG_2nd_Order(ENGINE_DATA);
%     
%     SOL(counter).second_order_power = SECOND_ORDER_DATA.W_dot;
%     SOL(counter).second_order_efficiency = SECOND_ORDER_DATA.eff_thermal;
%     SOL(counter).ref_cycle_power = [REF_CYCLE_DATA(end).W].*[ENGINE_DATA.freq];
%     SOL(counter).P_HEX = REF_CYCLE_DATA(1).W_dot_ref-(REF_CYCLE_DATA(end).W*ENGINE_DATA.freq);
%     SOL(counter).P_mech = LOSSES_DATA.P_mech;
%     SOL(counter).P_flow_h = LOSSES_DATA.P_flow_h;
%     SOL(counter).P_flow_r = LOSSES_DATA.P_flow_r;
%     SOL(counter).P_flow_k = LOSSES_DATA.P_flow_k;
%     SOL(counter).P_GSH = LOSSES_DATA.P_GSH;
%     counter = counter + 1;
% end
%     
% figure('Position', [x y width height])
% 
% TH_Range = Min_TH:TH_inc:Max_TH;
% TH_Range_Celcius = TH_Range - 273.15;
% 
% % Plot Power on the left axis
% yyaxis left
% plot(TH_Range_Celcius,[SOL.second_order_power],'r','LineWidth',2)
% ylim([0 120])
% ylabel('Power Output (W)','FontName',font,'FontSize',font_size)
% set(gca,'ycolor','r')
% % Plot efficiency on the right axis
% yyaxis right
% plot(TH_Range_Celcius,[SOL.second_order_efficiency]*100,'b','LineWidth',2)
% ylim([0 6])
% ylabel('Thermal Efficiency (%)','FontName',font,'FontSize',font_size)
% set(gca,'ycolor','b')
% 
% xlabel('Heater Wall Temperature (\circC)','FontName',font,'FontSize',font_size)
% legend('Power','Efficiency','Location','SouthEast') 
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)
% 
% % Plot 2 - Relative Power Losses As-Built
% P_HEX_rel = [SOL.P_HEX]./[SOL.ref_cycle_power];
% P_mech_rel = [SOL.P_mech]./[SOL.ref_cycle_power];
% P_flow_h_rel = [SOL.P_flow_h]./[SOL.ref_cycle_power];
% P_flow_r_rel = [SOL.P_flow_r]./[SOL.ref_cycle_power];
% P_flow_k_rel = [SOL.P_flow_k]./[SOL.ref_cycle_power];
% P_GSH_rel = [SOL.P_GSH]./[SOL.ref_cycle_power];
% 
% figure('Position', [x y width height])
% hold on
% plot(TH_Range_Celcius,P_HEX_rel.*100,'LineWidth',2)
% plot(TH_Range_Celcius,P_mech_rel.*100,'LineWidth',2)
% plot(TH_Range_Celcius,P_flow_h_rel.*100,'LineWidth',2)
% plot(TH_Range_Celcius,P_flow_r_rel.*100,'LineWidth',2)
% plot(TH_Range_Celcius,P_flow_k_rel.*100,'LineWidth',2)
% plot(TH_Range_Celcius,P_GSH_rel.*100,'LineWidth',2)
% ylim([0 100])
% xlim([Min_TH-273.15 Max_TH-273.15])
% hold off
% xlabel('Heater Wall Temperature (\circC)','FontName',font,'FontSize',font_size)
% ylabel({'Relative Power Losses (%)'},'FontName',font,'FontSize',font_size)
% legend('Imperfect Heat Transfer','Mechanical Friction','Heater Flow Friction','Regenerator Flow Friction',...
%     'Cooler Flow Friction','Gas Spring Hysteresis','Location','NorthEast')
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)

% Optimum Swept Volume Ratios
% Piston Diameter Variation
Min_Pbore = 0.060; % Minimum piston diameter to be simulated in [m].
Max_Pbore = 0.180; % Maximum piston diameter to be simulated in [m].
Pbore_inc = 0.005; % Piston diameter increment in [m].

% Define common operating parameters
freq = 3; % Engine frequency in (Hz).
pmean = 100000; % Mean pressure in (kPa).
Tcold = 273 + 5; % Cold side temperatures in (K).
Thot = 273 + 150; % Hot side temperatures in (K).

% Run Model for T2 Engine
ENGINE_DATA = T2_ENGINE_DATA;
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

counter = 1;
for Pbore = Min_Pbore:Pbore_inc:Max_Pbore
    ENGINE_DATA.Pbore = Pbore;
    
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
    
figure('Position', [x y width height])

freq_range = Min_Pbore:Pbore_inc:Max_Pbore; %(m)
Pbore_range_mm = freq_range.*1000; %(mm)

% Plot Power on the left axis
yyaxis left
plot(Pbore_range_mm,[SOL.second_order_power],'r','LineWidth',2)
% ylim([0 inf])
ylabel('Power Output (W)','FontName',font,'FontSize',font_size)
set(gca,'ycolor','r')
% Plot efficiency on the right axis
yyaxis right
plot(Pbore_range_mm,[SOL.second_order_efficiency]*100,'b','LineWidth',2)
% ylim([0 inf])
ylabel('Thermal Efficiency (%)','FontName',font,'FontSize',font_size)
set(gca,'ycolor','b')

xlabel('Piston Diameter (mm)','FontName',font,'FontSize',font_size)
legend('Power','Efficiency','Location','SouthEast') 
set(gca,'fontsize',font_size);
set(gca,'FontName',font)

% Plot 2 - Relative Power Losses As-Built
P_HEX_rel = [SOL.P_HEX]./[SOL.ref_cycle_power];
P_mech_rel = [SOL.P_mech]./[SOL.ref_cycle_power];
P_flow_h_rel = [SOL.P_flow_h]./[SOL.ref_cycle_power];
P_flow_r_rel = [SOL.P_flow_r]./[SOL.ref_cycle_power];
P_flow_k_rel = [SOL.P_flow_k]./[SOL.ref_cycle_power];
P_GSH_rel = [SOL.P_GSH]./[SOL.ref_cycle_power];

figure('Position', [x y width height])
hold on
plot(Pbore_range_mm,P_HEX_rel.*100,'LineWidth',2)
plot(Pbore_range_mm,P_mech_rel.*100,'LineWidth',2)
plot(Pbore_range_mm,P_flow_h_rel.*100,'LineWidth',2)
plot(Pbore_range_mm,P_flow_r_rel.*100,'LineWidth',2)
plot(Pbore_range_mm,P_flow_k_rel.*100,'LineWidth',2)
plot(Pbore_range_mm,P_GSH_rel.*100,'LineWidth',2)
ylim([0 85])
xlim([Min_Pbore*1000 Max_Pbore*1000])
hold off
xlabel('Piston Diameter (mm)','FontName',font,'FontSize',font_size)
ylabel({'Relative Power Losses (%)'},'FontName',font,'FontSize',font_size)
legend('Imperfect Heat Transfer','Mechanical Friction','Heater Flow Friction','Regenerator Flow Friction',...
    'Cooler Flow Friction','Gas Spring Hysteresis','Location','NorthEast')
set(gca,'fontsize',font_size);
set(gca,'FontName',font)

%% Optimum Phase Angle for T2 Engine
% % Phase Angle Variation
% Min_beta_deg = 50; % Minimum beta to be simulated in [K].
% Max_beta_deg = 110; % Maximum beta to be simulated in [K].
% beta_deg_inc = 5; % Beta increment in [K].
% 
% % Define common operating parameters
% freq = 3; % Engine frequency in (Hz).
% pmean = 1000000; % Mean pressure in (kPa).
% Tcold = 273 + 5; % Cold side temperatures in (K).
% Thot = 273 + 95; % Hot side temperatures in (K).
% 
% % Run Model for T2 Engine
% ENGINE_DATA = T2_ENGINE_DATA;
% ENGINE_DATA.freq = freq;
% ENGINE_DATA.pmean = pmean;
% ENGINE_DATA.Tsink = Tcold;
% ENGINE_DATA.Tgk = Tcold;
% ENGINE_DATA.Twk = Tcold;
% ENGINE_DATA.Tgc = Tcold;
% ENGINE_DATA.Tsource = Thot;
% ENGINE_DATA.Tgh = Thot;
% ENGINE_DATA.Twh = Thot;
% ENGINE_DATA.Tge = Thot;
% 
% counter = 1;
% for beta_deg = Min_beta_deg:beta_deg_inc:Max_beta_deg
%     ENGINE_DATA.beta_deg = beta_deg;
%     
%     [SECOND_ORDER_DATA,REF_CYCLE_DATA,LOSSES_DATA] ...
%         = T2_2nd_Order(ENGINE_DATA);
%     
%     SOL(counter).second_order_power = SECOND_ORDER_DATA.W_dot;
%     SOL(counter).second_order_efficiency = SECOND_ORDER_DATA.eff_thermal;
%     SOL(counter).ref_cycle_power = [REF_CYCLE_DATA(end).W].*[ENGINE_DATA.freq];
%     SOL(counter).P_HEX = REF_CYCLE_DATA(1).W_dot_ref-(REF_CYCLE_DATA(end).W*ENGINE_DATA.freq);
%     SOL(counter).P_mech = LOSSES_DATA.P_mech;
%     SOL(counter).P_flow_h = LOSSES_DATA.P_flow_h;
%     SOL(counter).P_flow_r = LOSSES_DATA.P_flow_r;
%     SOL(counter).P_flow_k = LOSSES_DATA.P_flow_k;
%     SOL(counter).P_GSH = LOSSES_DATA.P_GSH;
%     counter = counter + 1;
% end
%     
% figure('Position', [x y width height])
% 
% beta_deg_range = Min_beta_deg:beta_deg_inc:Max_beta_deg;
% 
% % Plot Power on the left axis
% yyaxis left
% plot(beta_deg_range,[SOL.second_order_power],'r','LineWidth',2)
% % ylim([0 inf])
% ylabel('Power Output (W)','FontName',font,'FontSize',font_size)
% set(gca,'ycolor','r')
% % Plot efficiency on the right axis
% yyaxis right
% plot(beta_deg_range,[SOL.second_order_efficiency]*100,'b','LineWidth',2)
% % ylim([0 inf])
% ylabel('Thermal Efficiency (%)','FontName',font,'FontSize',font_size)
% set(gca,'ycolor','b')
% 
% xlabel('Displacer Phase Angle Advance (\circ)','FontName',font,'FontSize',font_size)
% legend('Power','Efficiency','Location','SouthEast') 
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)
% 
% % Plot 2 - Relative Power Losses As-Built
% P_HEX_rel = [SOL.P_HEX]./[SOL.ref_cycle_power];
% P_mech_rel = [SOL.P_mech]./[SOL.ref_cycle_power];
% P_flow_h_rel = [SOL.P_flow_h]./[SOL.ref_cycle_power];
% P_flow_r_rel = [SOL.P_flow_r]./[SOL.ref_cycle_power];
% P_flow_k_rel = [SOL.P_flow_k]./[SOL.ref_cycle_power];
% P_GSH_rel = [SOL.P_GSH]./[SOL.ref_cycle_power];
% 
% figure('Position', [x y width height])
% hold on
% plot(beta_deg_range,P_HEX_rel.*100,'LineWidth',2)
% plot(beta_deg_range,P_mech_rel.*100,'LineWidth',2)
% plot(beta_deg_range,P_flow_h_rel.*100,'LineWidth',2)
% plot(beta_deg_range,P_flow_r_rel.*100,'LineWidth',2)
% plot(beta_deg_range,P_flow_k_rel.*100,'LineWidth',2)
% plot(beta_deg_range,P_GSH_rel.*100,'LineWidth',2)
% ylim([0 75])
% xlim([Min_beta_deg Max_beta_deg])
% hold off
% xlabel('Displacer Phase Angle Advance (\circ)','FontName',font,'FontSize',font_size)
% ylabel({'Relative Power Losses (%)'},'FontName',font,'FontSize',font_size)
% legend('Imperfect Heat Transfer','Mechanical Friction','Heater Flow Friction','Regenerator Flow Friction',...
%     'Cooler Flow Friction','Gas Spring Hysteresis','Location','NorthEast')
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)

% %% Working Fluid Comparison (H2, He, Air, SF6)
% % Engine Frequency Variation
% Min_freq = 0.5; % Minimum frequency to be simulated in [Hz].
% Max_freq = 12; % Maximum frequency to be simulated in [Hz].
% freq_inc = 0.25; % Frequency increment in [Hz].
% 
% % Define common operating parameters
% pmean = 1000000; % Mean pressure in (kPa).
% Tcold = 273 + 5; % Cold side temperatures in (K).
% Thot = 273 + 95; % Hot side temperatures in (K).
% 
% % Run Model for T2 Engine with Air
% ENGINE_DATA = T2_ENGINE_DATA;
% ENGINE_DATA.gas_type = 'ai';
% ENGINE_DATA.pmean = pmean;
% ENGINE_DATA.Tsink = Tcold;
% ENGINE_DATA.Tgk = Tcold;
% ENGINE_DATA.Twk = Tcold;
% ENGINE_DATA.Tgc = Tcold;
% ENGINE_DATA.Tsource = Thot;
% ENGINE_DATA.Tgh = Thot;
% ENGINE_DATA.Twh = Thot;
% ENGINE_DATA.Tge = Thot;
% 
% counter = 1;
% for freq = Min_freq:freq_inc:Max_freq
%     ENGINE_DATA.freq = freq;
%     
%     [SECOND_ORDER_DATA,REF_CYCLE_DATA,LOSSES_DATA] ...
%         = T2_2nd_Order(ENGINE_DATA);
%     
%     AIR_SOL(counter).second_order_power = SECOND_ORDER_DATA.W_dot;
%     AIR_SOL(counter).second_order_efficiency = SECOND_ORDER_DATA.eff_thermal;
%     AIR_SOL(counter).ref_cycle_power = [REF_CYCLE_DATA(end).W].*[ENGINE_DATA.freq];
%     AIR_SOL(counter).P_HEX = REF_CYCLE_DATA(1).W_dot_ref-(REF_CYCLE_DATA(end).W*ENGINE_DATA.freq);
%     AIR_SOL(counter).P_mech = LOSSES_DATA.P_mech;
%     AIR_SOL(counter).P_flow_h = LOSSES_DATA.P_flow_h;
%     AIR_SOL(counter).P_flow_r = LOSSES_DATA.P_flow_r;
%     AIR_SOL(counter).P_flow_k = LOSSES_DATA.P_flow_k;
%     AIR_SOL(counter).P_GSH = LOSSES_DATA.P_GSH;
%     counter = counter + 1;
% end
% 
% % Run Model for T2 Engine with Helium
% ENGINE_DATA = T2_ENGINE_DATA;
% ENGINE_DATA.gas_type = 'he';
% ENGINE_DATA.pmean = pmean;
% ENGINE_DATA.Tsink = Tcold;
% ENGINE_DATA.Tgk = Tcold;
% ENGINE_DATA.Twk = Tcold;
% ENGINE_DATA.Tgc = Tcold;
% ENGINE_DATA.Tsource = Thot;
% ENGINE_DATA.Tgh = Thot;
% ENGINE_DATA.Twh = Thot;
% ENGINE_DATA.Tge = Thot;
% 
% counter = 1;
% for freq = Min_freq:freq_inc:Max_freq
%     ENGINE_DATA.freq = freq;
%     
%     [SECOND_ORDER_DATA,REF_CYCLE_DATA,LOSSES_DATA] ...
%         = T2_2nd_Order(ENGINE_DATA);
%     
%     HE_SOL(counter).second_order_power = SECOND_ORDER_DATA.W_dot;
%     HE_SOL(counter).second_order_efficiency = SECOND_ORDER_DATA.eff_thermal;
%     HE_SOL(counter).ref_cycle_power = [REF_CYCLE_DATA(end).W].*[ENGINE_DATA.freq];
%     HE_SOL(counter).P_HEX = REF_CYCLE_DATA(1).W_dot_ref-(REF_CYCLE_DATA(end).W*ENGINE_DATA.freq);
%     HE_SOL(counter).P_mech = LOSSES_DATA.P_mech;
%     HE_SOL(counter).P_flow_h = LOSSES_DATA.P_flow_h;
%     HE_SOL(counter).P_flow_r = LOSSES_DATA.P_flow_r;
%     HE_SOL(counter).P_flow_k = LOSSES_DATA.P_flow_k;
%     HE_SOL(counter).P_GSH = LOSSES_DATA.P_GSH;
%     counter = counter + 1;
% end
% 
% % Run Model for T2 Engine with Hydrogen
% ENGINE_DATA = T2_ENGINE_DATA;
% ENGINE_DATA.gas_type = 'hy';
% ENGINE_DATA.pmean = pmean;
% ENGINE_DATA.Tsink = Tcold;
% ENGINE_DATA.Tgk = Tcold;
% ENGINE_DATA.Twk = Tcold;
% ENGINE_DATA.Tgc = Tcold;
% ENGINE_DATA.Tsource = Thot;
% ENGINE_DATA.Tgh = Thot;
% ENGINE_DATA.Twh = Thot;
% ENGINE_DATA.Tge = Thot;
% 
% counter = 1;
% for freq = Min_freq:freq_inc:Max_freq
%     ENGINE_DATA.freq = freq;
%     
%     [SECOND_ORDER_DATA,REF_CYCLE_DATA,LOSSES_DATA] ...
%         = T2_2nd_Order(ENGINE_DATA);
%     
%     H2_SOL(counter).second_order_power = SECOND_ORDER_DATA.W_dot;
%     H2_SOL(counter).second_order_efficiency = SECOND_ORDER_DATA.eff_thermal;
%     H2_SOL(counter).ref_cycle_power = [REF_CYCLE_DATA(end).W].*[ENGINE_DATA.freq];
%     H2_SOL(counter).P_HEX = REF_CYCLE_DATA(1).W_dot_ref-(REF_CYCLE_DATA(end).W*ENGINE_DATA.freq);
%     H2_SOL(counter).P_mech = LOSSES_DATA.P_mech;
%     H2_SOL(counter).P_flow_h = LOSSES_DATA.P_flow_h;
%     H2_SOL(counter).P_flow_r = LOSSES_DATA.P_flow_r;
%     H2_SOL(counter).P_flow_k = LOSSES_DATA.P_flow_k;
%     H2_SOL(counter).P_GSH = LOSSES_DATA.P_GSH;
%     counter = counter + 1;
% end
% 
% % Run Model for T2 Engine with Sulfur Hexafluoride
% ENGINE_DATA = T2_ENGINE_DATA;
% ENGINE_DATA.gas_type = 'sf6';
% ENGINE_DATA.pmean = pmean;
% ENGINE_DATA.Tsink = Tcold;
% ENGINE_DATA.Tgk = Tcold;
% ENGINE_DATA.Twk = Tcold;
% ENGINE_DATA.Tgc = Tcold;
% ENGINE_DATA.Tsource = Thot;
% ENGINE_DATA.Tgh = Thot;
% ENGINE_DATA.Twh = Thot;
% ENGINE_DATA.Tge = Thot;
% 
% counter = 1;
% for freq = Min_freq:freq_inc:Max_freq
%     ENGINE_DATA.freq = freq;
%     
%     [SECOND_ORDER_DATA,REF_CYCLE_DATA,LOSSES_DATA] ...
%         = T2_2nd_Order(ENGINE_DATA);
%     
%     SF6_SOL(counter).second_order_power = SECOND_ORDER_DATA.W_dot;
%     SF6_SOL(counter).second_order_efficiency = SECOND_ORDER_DATA.eff_thermal;
%     SF6_SOL(counter).ref_cycle_power = [REF_CYCLE_DATA(end).W].*[ENGINE_DATA.freq];
%     SF6_SOL(counter).P_HEX = REF_CYCLE_DATA(1).W_dot_ref-(REF_CYCLE_DATA(end).W*ENGINE_DATA.freq);
%     SF6_SOL(counter).P_mech = LOSSES_DATA.P_mech;
%     SF6_SOL(counter).P_flow_h = LOSSES_DATA.P_flow_h;
%     SF6_SOL(counter).P_flow_r = LOSSES_DATA.P_flow_r;
%     SF6_SOL(counter).P_flow_k = LOSSES_DATA.P_flow_k;
%     SF6_SOL(counter).P_GSH = LOSSES_DATA.P_GSH;
%     counter = counter + 1;
% end
% 
% % Plot Power Curves
% figure('Position', [x y width height])
% 
% freq_range = Min_freq:freq_inc:Max_freq; %(Hz)
% 
% hold on
% plot(freq_range,[AIR_SOL.second_order_power],'r','LineWidth',2)
% plot(freq_range,[HE_SOL.second_order_power],'g','LineWidth',2)
% plot(freq_range,[H2_SOL.second_order_power],'b','LineWidth',2)
% plot(freq_range,[SF6_SOL.second_order_power],'k','LineWidth',2)
% ylim([0 inf])
% ylabel('Power Output (W)','FontName',font,'FontSize',font_size)
% xlabel('Engine Frequency (Hz)','FontName',font,'FontSize',font_size)
% legend('Air','Helium','Hydrogen','Sulfur Hexafluoride','Location','SouthEast')  
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)
% hold off
% 
% % Plot Efficiency Curves
% figure('Position', [x y width height])
% hold on
% plot(freq_range,[AIR_SOL.second_order_efficiency]*100,'r','LineWidth',2)
% plot(freq_range,[HE_SOL.second_order_efficiency]*100,'g','LineWidth',2)
% plot(freq_range,[H2_SOL.second_order_efficiency]*100,'b','LineWidth',2)
% plot(freq_range,[SF6_SOL.second_order_efficiency]*100,'k','LineWidth',2)
% ylim([0 inf])
% ylabel('Thermal Efficiency (%)','FontName',font,'FontSize',font_size)
% xlabel('Engine Frequency (Hz)','FontName',font,'FontSize',font_size)
% legend('Air','Helium','Hydrogen','Sulfur Hexafluoride','Location','SouthEast') 
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)
% hold off
% 
% % Plot 2 - Relative Power Losses As-Built for Air
% P_HEX_rel = [AIR_SOL.P_HEX]./[AIR_SOL.ref_cycle_power];
% P_mech_rel = [AIR_SOL.P_mech]./[AIR_SOL.ref_cycle_power];
% P_flow_h_rel = [AIR_SOL.P_flow_h]./[AIR_SOL.ref_cycle_power];
% P_flow_r_rel = [AIR_SOL.P_flow_r]./[AIR_SOL.ref_cycle_power];
% P_flow_k_rel = [AIR_SOL.P_flow_k]./[AIR_SOL.ref_cycle_power];
% P_GSH_rel = [AIR_SOL.P_GSH]./[AIR_SOL.ref_cycle_power];
% 
% figure('Position', [x y width height])
% hold on
% plot(freq_range,P_HEX_rel.*100,'LineWidth',2)
% plot(freq_range,P_mech_rel.*100,'LineWidth',2)
% plot(freq_range,P_flow_h_rel.*100,'LineWidth',2)
% plot(freq_range,P_flow_r_rel.*100,'LineWidth',2)
% plot(freq_range,P_flow_k_rel.*100,'LineWidth',2)
% plot(freq_range,P_GSH_rel.*100,'LineWidth',2)
% ylim([0 100])
% xlim([Min_freq Max_freq])
% hold off
% xlabel('Engine Frequency (Hz)','FontName',font,'FontSize',font_size)
% ylabel({'Relative Power Losses (%)'},'FontName',font,'FontSize',font_size)
% legend('Imperfect Heat Transfer','Mechanical Friction','Heater Flow Friction','Regenerator Flow Friction',...
%     'Cooler Flow Friction','Gas Spring Hysteresis','Location','NorthEast')
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)
% 
% % Plot 2 - Relative Power Losses As-Built for Helium
% P_HEX_rel = [HE_SOL.P_HEX]./[HE_SOL.ref_cycle_power];
% P_mech_rel = [HE_SOL.P_mech]./[HE_SOL.ref_cycle_power];
% P_flow_h_rel = [HE_SOL.P_flow_h]./[HE_SOL.ref_cycle_power];
% P_flow_r_rel = [HE_SOL.P_flow_r]./[HE_SOL.ref_cycle_power];
% P_flow_k_rel = [HE_SOL.P_flow_k]./[HE_SOL.ref_cycle_power];
% P_GSH_rel = [HE_SOL.P_GSH]./[HE_SOL.ref_cycle_power];
% 
% figure('Position', [x y width height])
% hold on
% plot(freq_range,P_HEX_rel.*100,'LineWidth',2)
% plot(freq_range,P_mech_rel.*100,'LineWidth',2)
% plot(freq_range,P_flow_h_rel.*100,'LineWidth',2)
% plot(freq_range,P_flow_r_rel.*100,'LineWidth',2)
% plot(freq_range,P_flow_k_rel.*100,'LineWidth',2)
% plot(freq_range,P_GSH_rel.*100,'LineWidth',2)
% ylim([0 100])
% xlim([Min_freq Max_freq])
% hold off
% xlabel('Engine Frequency (Hz)','FontName',font,'FontSize',font_size)
% ylabel({'Relative Power Losses (%)'},'FontName',font,'FontSize',font_size)
% legend('Imperfect Heat Transfer','Mechanical Friction','Heater Flow Friction','Regenerator Flow Friction',...
%     'Cooler Flow Friction','Gas Spring Hysteresis','Location','NorthEast')
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)
% 
% % Plot 2 - Relative Power Losses As-Built for Hydrogen
% P_HEX_rel = [H2_SOL.P_HEX]./[H2_SOL.ref_cycle_power];
% P_mech_rel = [H2_SOL.P_mech]./[H2_SOL.ref_cycle_power];
% P_flow_h_rel = [H2_SOL.P_flow_h]./[H2_SOL.ref_cycle_power];
% P_flow_r_rel = [H2_SOL.P_flow_r]./[H2_SOL.ref_cycle_power];
% P_flow_k_rel = [H2_SOL.P_flow_k]./[H2_SOL.ref_cycle_power];
% P_GSH_rel = [H2_SOL.P_GSH]./[H2_SOL.ref_cycle_power];
% 
% figure('Position', [x y width height])
% hold on
% plot(freq_range,P_HEX_rel.*100,'LineWidth',2)
% plot(freq_range,P_mech_rel.*100,'LineWidth',2)
% plot(freq_range,P_flow_h_rel.*100,'LineWidth',2)
% plot(freq_range,P_flow_r_rel.*100,'LineWidth',2)
% plot(freq_range,P_flow_k_rel.*100,'LineWidth',2)
% plot(freq_range,P_GSH_rel.*100,'LineWidth',2)
% ylim([0 100])
% xlim([Min_freq Max_freq])
% hold off
% xlabel('Engine Frequency (Hz)','FontName',font,'FontSize',font_size)
% ylabel({'Relative Power Losses (%)'},'FontName',font,'FontSize',font_size)
% legend('Imperfect Heat Transfer','Mechanical Friction','Heater Flow Friction','Regenerator Flow Friction',...
%     'Cooler Flow Friction','Gas Spring Hysteresis','Location','NorthEast')
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)
% 
% % Plot 2 - Relative Power Losses As-Built for Sulfur Hexafluoride
% P_HEX_rel = [SF6_SOL.P_HEX]./[SF6_SOL.ref_cycle_power];
% P_mech_rel = [SF6_SOL.P_mech]./[SF6_SOL.ref_cycle_power];
% P_flow_h_rel = [SF6_SOL.P_flow_h]./[SF6_SOL.ref_cycle_power];
% P_flow_r_rel = [SF6_SOL.P_flow_r]./[SF6_SOL.ref_cycle_power];
% P_flow_k_rel = [SF6_SOL.P_flow_k]./[SF6_SOL.ref_cycle_power];
% P_GSH_rel = [SF6_SOL.P_GSH]./[SF6_SOL.ref_cycle_power];
% 
% figure('Position', [x y width height])
% hold on
% plot(freq_range,P_HEX_rel.*100,'LineWidth',2)
% plot(freq_range,P_mech_rel.*100,'LineWidth',2)
% plot(freq_range,P_flow_h_rel.*100,'LineWidth',2)
% plot(freq_range,P_flow_r_rel.*100,'LineWidth',2)
% plot(freq_range,P_flow_k_rel.*100,'LineWidth',2)
% plot(freq_range,P_GSH_rel.*100,'LineWidth',2)
% ylim([0 100])
% xlim([Min_freq Max_freq])
% hold off
% xlabel('Engine Frequency (Hz)','FontName',font,'FontSize',font_size)
% ylabel({'Relative Power Losses (%)'},'FontName',font,'FontSize',font_size)
% legend('Imperfect Heat Transfer','Mechanical Friction','Heater Flow Friction','Regenerator Flow Friction',...
%     'Cooler Flow Friction','Gas Spring Hysteresis','Location','NorthEast')
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)