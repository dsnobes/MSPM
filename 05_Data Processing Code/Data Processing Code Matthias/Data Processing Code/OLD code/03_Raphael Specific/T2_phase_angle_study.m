% T2_phase_angle_study.m - Written by Connor Speer, May 2018

% Why does the model predict an optimum phase angle less than 90 degrees?
% What parameters affect the optimum phase angle?

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
%     SOL(counter).ref_cycle_Qh = [REF_CYCLE_DATA(end).Qh].*[ENGINE_DATA.freq];
%     SOL(counter).P_HEX = REF_CYCLE_DATA(1).W_dot_ref-(REF_CYCLE_DATA(end).W*ENGINE_DATA.freq);
%     SOL(counter).P_mech = LOSSES_DATA.P_mech;
%     SOL(counter).P_flow_h = LOSSES_DATA.P_flow_h;
%     SOL(counter).P_flow_r = LOSSES_DATA.P_flow_r;
%     SOL(counter).P_flow_k = LOSSES_DATA.P_flow_k;
%     SOL(counter).P_GSH = LOSSES_DATA.P_GSH;
%     SOL(counter).Q_cond = LOSSES_DATA.Q_cond;
%     SOL(counter).Q_seals = LOSSES_DATA.Q_seals;
%     SOL(counter).Q_app = LOSSES_DATA.Q_app;
%     SOL(counter).Q_insulation = LOSSES_DATA.Q_insulation;
%     SOL(counter).Q_qrloss = LOSSES_DATA.Q_qrloss;
%     counter = counter + 1;
% end
% 
% % Plot 1 - Power and Efficiency vs. Phase Angle
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
% legend('Power','Efficiency','Location','SouthWest') 
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)
% 
% % Plot 2 - Relative Power Losses vs. Phase Angle
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
%     'Cooler Flow Friction','Gas Spring Hysteresis','Location','NorthWest')
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)
% 
% % % Plot 3 - Relative Heat Losses vs. Phase Angle
% Q_flow_h_rel = -[SOL.P_flow_h]./[SOL.ref_cycle_Qh];
% Q_flow_r_rel = -0.5.*[SOL.P_flow_r]./[SOL.ref_cycle_Qh];    
% Q_cond_rel = [SOL.Q_cond]./[SOL.ref_cycle_Qh];
% Q_seals_rel = [SOL.Q_seals]./[SOL.ref_cycle_Qh];
% Q_app_rel = [SOL.Q_app]./[SOL.ref_cycle_Qh];
% Q_insulation_rel = [SOL.Q_insulation]./[SOL.ref_cycle_Qh];
% Q_qrloss_rel = [SOL.Q_qrloss]./[SOL.ref_cycle_Qh];
% 
% figure('Position', [x y width height])
% hold on
% plot(beta_deg_range,Q_flow_h_rel.*100,'LineWidth',2)
% plot(beta_deg_range,Q_flow_r_rel.*100,'LineWidth',2)
% plot(beta_deg_range,Q_cond_rel.*100,'LineWidth',2)
% plot(beta_deg_range,Q_app_rel.*100,'LineWidth',2)
% plot(beta_deg_range,Q_qrloss_rel.*100,'LineWidth',2)
% % plot(beta_deg_range,Q_insulation_rel.*100,'LineWidth',2)
% % plot(beta_deg_range,Q_seals_rel.*100,'LineWidth',2)
% % ylim([0 75])
% xlim([Min_beta_deg Max_beta_deg])
% hold off
% xlabel('Displacer Phase Angle Advance (\circ)','FontName',font,'FontSize',font_size)
% ylabel({'Relative Heat Losses (%)'},'FontName',font,'FontSize',font_size)
% legend('Heater Flow Friction','1/2 Regenerator Flow Friction','Conduction Loss','Appendix Gap Loss',...
%     'Regenerator Enthalpy Loss','Location','NorthWest')
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)

%% Optimum Phase Angle as a Function of Thermal Source Temperature
% % Phase Angle Variation
% Min_beta_deg = 60; % Minimum beta to be simulated in [deg].
% Max_beta_deg = 90; % Maximum beta to be simulated in [deg].
% beta_deg_inc = 1; % Beta increment in [deg].
% 
% % Hot Side Temperature Variation
% Min_Thot = 273 + 50; % Minimum hot side temperature to be simulated in [K].
% Max_Thot = 273 + 500; % Maximum hot side temperature to be simulated in [K].
% Thot_inc = 5; % Hot side temperature increment in [K].
% 
% % Define common operating parameters
% freq = 3; % Engine frequency in (Hz).
% pmean = 1000000; % Mean pressure in (Pa).
% Tcold = 273 + 5; % Cold side temperatures in (K).
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % waitbar = waitbar(0,'Please wait...');
% % locus_counter_max = length(Min_Thot:Thot_inc:Max_Thot) + 1;
% 
% locus_counter = 1;
% for Thot = Min_Thot:Thot_inc:Max_Thot % Hot side temperatures in (K).
%     % Run Model for T2 Engine
%     ENGINE_DATA = T2_ENGINE_DATA;
%     ENGINE_DATA.freq = freq;
%     ENGINE_DATA.pmean = pmean;
%     ENGINE_DATA.Tsink = Tcold;
%     ENGINE_DATA.Tgk = Tcold;
%     ENGINE_DATA.Twk = Tcold;
%     ENGINE_DATA.Tgc = Tcold;
%     ENGINE_DATA.Tsource = Thot;
%     ENGINE_DATA.Tgh = Thot;
%     ENGINE_DATA.Twh = Thot;
%     ENGINE_DATA.Tge = Thot;
% 
%     counter = 1;
%     for beta_deg = Min_beta_deg:beta_deg_inc:Max_beta_deg
%         ENGINE_DATA.beta_deg = beta_deg;
% 
%         [SECOND_ORDER_DATA,REF_CYCLE_DATA,LOSSES_DATA] ...
%             = T2_2nd_Order(ENGINE_DATA);
% 
%         SOL(counter).second_order_power = SECOND_ORDER_DATA.W_dot;
%         SOL(counter).second_order_efficiency = SECOND_ORDER_DATA.eff_thermal;
%         counter = counter + 1;
%     end
%     % Find phase angle at maximum power
%     [Max_Power,max_power_index] = max([SOL.second_order_power]);
%     LOCUS(locus_counter).beta_deg_at_max_power = Min_beta_deg + (max_power_index-1)*beta_deg_inc;
%     
%     % Find phase angle at maximum efficiency
%     [Max_Efficiency,max_efficiency_index] = max([SOL.second_order_efficiency]);
%     LOCUS(locus_counter).beta_deg_at_max_efficiency = Min_beta_deg + (max_efficiency_index-1)*beta_deg_inc;
%     
%     locus_counter = locus_counter + 1;
%     
% %     waitbar(locus_counter/locus_counter_max,waitbar);
% end
% 
% close(waitbar)
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % Plot 1 - Optimum Power and Efficiency Loci vs. Phase Angle
% figure('Position', [x y width height])
% 
% Thot_range = (Min_Thot:Thot_inc:Max_Thot) - 273;
% 
% hold on
% plot(Thot_range,[LOCUS.beta_deg_at_max_power],'r','LineWidth',2)
% plot(Thot_range,[LOCUS.beta_deg_at_max_efficiency],'b','LineWidth',2)
% xlabel('Heater Wall Temperature (\circC)','FontName',font,'FontSize',font_size)
% ylabel('Phase Angle (\circ)','FontName',font,'FontSize',font_size)
% legend('Maximum Power Locus','Maximum Efficiency Locus','Location','SouthWest') 
% set(gca,'fontsize',font_size);
% set(gca,'FontName',font)
% hold off

%% Optimum Phase Angle As a Function of Piston Diameter
% Phase Angle Variation
Min_beta_deg = 60; % Minimum beta to be simulated in [deg].
Max_beta_deg = 90; % Maximum beta to be simulated in [deg].
beta_deg_inc = 1; % Beta increment in [deg].

% Piston Diameter Variation
Min_Pbore = 0.010; % Minimum piston diameter to be simulated in [m].
Max_Pbore = 0.100; % Maximum piston diameter to be simulated in [m].
Pbore_inc = 0.001; % Piston diameter increment in [m].

% Define common operating parameters
freq = 3; % Engine frequency in (Hz).
pmean = 1000000; % Mean pressure in (Pa).
Tcold = 273 + 5; % Cold side temperatures in (K).
Thot = 273 + 95; % Hot side temperatures in (K).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% waitbar = waitbar(0,'Please wait...');
% locus_counter_max = length(Min_Thot:Thot_inc:Max_Thot) + 1;

locus_counter = 1;
for Pbore = Min_Pbore:Pbore_inc:Max_Pbore % Hot side temperatures in (K).
    % Run Model for T2 Engine
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

    counter = 1;
    for beta_deg = Min_beta_deg:beta_deg_inc:Max_beta_deg
        ENGINE_DATA.beta_deg = beta_deg;

        [SECOND_ORDER_DATA,REF_CYCLE_DATA,LOSSES_DATA] ...
            = T2_2nd_Order(ENGINE_DATA);

        SOL(counter).second_order_power = SECOND_ORDER_DATA.W_dot;
        SOL(counter).second_order_efficiency = SECOND_ORDER_DATA.eff_thermal;
        counter = counter + 1;
    end
    % Find phase angle at maximum power
    [Max_Power,max_power_index] = max([SOL.second_order_power]);
    LOCUS(locus_counter).beta_deg_at_max_power = Min_beta_deg + (max_power_index-1)*beta_deg_inc;
    
    % Find phase angle at maximum efficiency
    [Max_Efficiency,max_efficiency_index] = max([SOL.second_order_efficiency]);
    LOCUS(locus_counter).beta_deg_at_max_efficiency = Min_beta_deg + (max_efficiency_index-1)*beta_deg_inc;
    
    locus_counter = locus_counter + 1;
    
%     waitbar(locus_counter/locus_counter_max,waitbar);
end

% close(waitbar)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot 1 - Optimum Power and Efficiency Loci vs. Phase Angle
figure('Position', [x y width height])

Pbore_range = (Min_Pbore:Pbore_inc:Max_Pbore);

hold on
plot(Pbore_range.*1000,[LOCUS.beta_deg_at_max_power],'r','LineWidth',2)
plot(Pbore_range.*1000,[LOCUS.beta_deg_at_max_efficiency],'b','LineWidth',2)
xlabel('Piston Diameter (mm)','FontName',font,'FontSize',font_size)
ylabel('Phase Angle (\circ)','FontName',font,'FontSize',font_size)
legend('Maximum Power Locus','Maximum Efficiency Locus','Location','SouthWest') 
set(gca,'fontsize',font_size);
set(gca,'FontName',font)
hold off