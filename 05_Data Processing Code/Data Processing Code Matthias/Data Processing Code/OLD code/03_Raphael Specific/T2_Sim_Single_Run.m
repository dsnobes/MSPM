% T2_Sim_Single_Run.m - Written by Connor Speer, February 2018

% Simulates a single operating point of the Terrapin Engine 2.0 using the
% second order model.

%% Input Parameters:
ENGINE_DATA = T2_ENGINE_DATA;
% ENGINE_DATA = T2_DISPLACER_CYLINDER_ONLY_DATA;

% Define common operating parameters
freq = 140/60; % Engine frequency in (Hz).
pmean = 450000; % Mean pressure in (Pa).
Tcold = 273 + 5; % Cold side temperatures in (K).
Thot = 273 + 150; % Hot side temperatures in (K).

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
ENGINE_DATA.p_buffer_exp = pmean;

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

%% Call to 2nd Order Model
[SECOND_ORDER_DATA,REF_CYCLE_DATA,LOSSES_DATA] = T2_2nd_Order(ENGINE_DATA);

%% Plot Results
Vdead = 1892.08/1e6; % Dead volume of T2 in (m^3).
% Vdead = (551.9 + 326.052 + 551.9 + 87.77 + 58.52)/1e6; % Dead volume of T2 Displacer Cylinder Only in (m^3).
Vtotal = [REF_CYCLE_DATA.Ve] + [REF_CYCLE_DATA.Vc] + ...
        repelem(Vdead,length([REF_CYCLE_DATA.Ve]));

% Plot Indicator Diagrams
figure('Position', [x y width height])
hold on
plot(Vtotal.*1e3, [REF_CYCLE_DATA.p]./1000,'r','LineWidth',2);
xlabel('Working Space Volume (L)','FontName',font,'FontSize',font_size);
ylabel('Pressure (kPa)','FontName',font,'FontSize',font_size);
% xlim([4.5 5])
% ylim([900 1150])
title('Raphael')
set(gca,'fontsize',font_size);
set(gca,'FontName',font)
hold off
