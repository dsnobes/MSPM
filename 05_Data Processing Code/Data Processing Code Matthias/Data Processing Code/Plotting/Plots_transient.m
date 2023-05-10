%%
setpoint_name = 'leak test Mar16: ';


%% TC and RTD mapping from data to thesis
% 'thesis name = data name'
%   RTD 0 = RTD_2 --> Heater Inlet
%   RTD 1 =  RTD_3 --> Heater Outlet
%   RTD 2 =  RTD_4 --> Cooler Inlet
%   RTD 3 =  RTD_5 --> Cooler Outlet

%   TC 0 = TC_0 --> Expansion Space
%   TC 1 =  TC_1 --> Heater/Expansion Space Interface, A Side
%   TC 2 =  TC_2 --> Heater/Expansion Space Interface, B Side
%   TC 3 =  TC_3 --> Regen/Heater Interface, A Side
%   TC 4 =  TC_4 --> Regen/Heater Interface, B Side
%   TC 5 =  TC_5 --> Cooler/Regenerator Interface, A Side
%   TC 6 =  TC_7 --> Compression Space/Cooler Interface, A Side
%   TC 7 =  TC_8 or TC_6 --> Compression Space/Cooler Interface, B Side
%   TC 8 =  TC_9 --> Power Cylinder
%   TC 9 =  TC_10 --> Crankcase

% TC_6 is same location as TC_8!
%% MODEL DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Gas temps of one datapoint
%hot
dp_index = 11;
figure
hold on
xlabel('Crank angle')
ylabel('Temp (\circC)')
legend('Interpreter', 'none')
x = linspace(0,360,199);
plot(x,MSPM_DATA(dp_index).Tge, 'DisplayName','Tge') 
plot(x,MSPM_DATA(dp_index).Tgh_inlet, 'DisplayName','Tgh_inlet')
plot(x,MSPM_DATA(dp_index).Tgh_center, 'DisplayName','Tgh_center')
plot(x,MSPM_DATA(dp_index).Tgh_reg, 'DisplayName','Tgh_reg')
plot(x,MSPM_DATA(dp_index).Tgh_reg_TopOfReg_test, 'DisplayName','Tgh_reg_TopOfReg_test')
plot(x,MSPM_DATA(dp_index).Tgr_center, 'DisplayName','Tgr_center')
yline(MSPM_DATA(dp_index).Tgr_log, 'DisplayName','Tgr_log')
xline(0,'-',{'Expansion begins','Gas moving cold->hot'}, 'DisplayName','')
xline(90,'-',{'All Gas on hot side'})
xline(180,'-',{'Compression begins','Gas moving hot->cold'})
xline(270,'-',{'All Gas on cold side'})

%cold
figure
hold on
xlabel('Crank angle')
ylabel('Temp (\circC)')
legend('Interpreter', 'none')
plot(x,MSPM_DATA(dp_index).Tgk_reg, 'DisplayName','Tgk_reg')
plot(x,MSPM_DATA(dp_index).Tgk_center, 'DisplayName','Tgk_center')
plot(x,MSPM_DATA(dp_index).Tgk_inlet, 'DisplayName','Tgk_inlet')
plot(x,MSPM_DATA(dp_index).Tgc, 'x', 'DisplayName','Tgc')
plot(x,MSPM_DATA(dp_index).TgPP, 'DisplayName','TgPP')
plot(x,MSPM_DATA(dp_index).TgPP_PPtop_test, 'DisplayName','TgPP_PPtop_test')
plot(x,MSPM_DATA(dp_index).TgCC, 'DisplayName','TgCC')
xline(0,'-',{'Expansion begins','Gas moving cold->hot'}, 'DisplayName','')
xline(90,'-',{'All Gas on hot side'})
xline(180,'-',{'Compression begins','Gas moving hot->cold'})
xline(270,'-',{'All Gas on cold side'})


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% EXPERIMENT DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Time units
% unit = ' [h]';
% secs = 3600;
% unit = ' [min]';
% secs = 60;
unit = ' [s]';
secs = 1;

%% Sample raw data plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Encoder speed raw
figure
mean_int = 1;
plot  (C_DATA.time_VC ./secs, movmean(RD_DATA.encoder_speed_raw,mean_int))

% axis tight
% ylim([150,200])
%   xlim([0,7])
%   xticks([0:7])
xlabel(['Time' unit])
ylabel('Speed [rpm]')
grid on
nicefigure('thesis_half')

%% Torque
figure
hold on
mean_int =1; % 5min
mean_torque = movmean(C_DATA.torque_sensor_transient, mean_int);
plot(C_DATA.time_VC ./secs, mean_torque)
% legend('Mov Mean window size 50','Mov Mean window size 100','Mov Mean window size 200')

title([setpoint_name ' - Measured Torque'])

% axis tight
%   ylim([0.21,0.28])
% xlim([0,5500)
xlabel(['Time' unit])
ylabel('Measured Torque [Nm]')
grid on
nicefigure('thesis_half')

%% Pressures (dynamic)
figure
time = C_DATA.time_VC /secs;
plot(time, C_DATA.p_DCH-mean(C_DATA.p_PC_static),  time, C_DATA.p_DM-mean(C_DATA.p_PC_static), time, C_DATA.p_PC-mean(C_DATA.p_PC_static), time, C_DATA.p_CC-mean(C_DATA.p_CC_static))
l=legend( '\itp_{d0}','\itp_{d1}','\itp_{d2}','\itp_{d3}');
l.ItemTokenSize(1) = 10;
   ylim([-4,5]*10^4)
 xlim([0,5])
xlabel(['Time' unit])
ylabel('Pressure [Pa]')
grid on
nicefigure('thesis_half')

%% Pressures (static)
figure
time = C_DATA.time_VC /secs;
plot(time, C_DATA.p_PC_static, time,C_DATA.p_CC_static)
l=legend( '\itp_{m0}','\itp_{m1}','Interpreter','tex');
l.ItemTokenSize(1) = 10;
   ylim([-4,5]*10^4)
 xlim([0,5])
xlabel(['Time' unit])
ylabel('Pressure [Pa]')
grid on
nicefigure('thesis_half')

%% TC and RTD mapping from data to thesis
% 'thesis name = data name'
%   RTD 0 = RTD_2 --> Heater Inlet
%   RTD 1 =  RTD_3 --> Heater Outlet
%   RTD 2 =  RTD_4 --> Cooler Inlet
%   RTD 3 =  RTD_5 --> Cooler Outlet

%   TC 0 = TC_0 --> Expansion Space
%   TC 1 =  TC_1 --> Heater/Expansion Space Interface, A Side
%   TC 2 =  TC_2 --> Heater/Expansion Space Interface, B Side
%   TC 3 =  TC_3 --> Regen/Heater Interface, A Side
%   TC 4 =  TC_4 --> Regen/Heater Interface, B Side
%   TC 5 =  TC_5 --> Cooler/Regenerator Interface, A Side
%   TC 6 =  TC_7 --> Compression Space/Cooler Interface, A Side
%   TC 7 =  TC_8 or TC_6 --> Compression Space/Cooler Interface, B Side
%   TC 8 =  TC_9 --> Power Cylinder
%   TC 9 =  TC_10 --> Crankcase


%% TCs hot
figure
time = C_DATA.time_TC /secs;
plot  (time,C_DATA.TC_5, time,C_DATA.TC_7, time,C_DATA.TC_8, time,C_DATA.TC_9, time,C_DATA.TC_10)
l=legend( 'TC 5', 'TC 6', 'TC 7', 'TC 8', 'TC 9');
l.ItemTokenSize(1) = 10;
% axis tight
   ylim([27, 35])
    yticks([27:2:35])
xlabel(['Time' unit])
ylabel('Temperature [\circC]')
grid on
nicefigure('thesis_half')

% Exp 1 (sensor A)
% Exp 2 (sensor B)
% Exp 3 (sensor C)
% Exp 4 (sensor D)
% Exp 5 (sensor A)

%% TCs cold
figure
time = C_DATA.time_TC /secs;
plot  (time,C_DATA.TC_0, time,C_DATA.TC_1, time,C_DATA.TC_2, time,C_DATA.TC_3, time,C_DATA.TC_4)
l=legend( 'TC 0', 'TC 1', 'TC 2', 'TC 3', 'TC 4');
l.ItemTokenSize(1) = 10;
% axis tight
   ylim([95, 103])
   yticks([95:2:103])
xlabel(['Time' unit])
ylabel('Temperature [\circC]')
grid on
nicefigure('thesis_half')

%% RTDs (all)
figure
hold on
time = C_DATA.time_RTD /secs;
yyaxis left
plot  (time,C_DATA.RTD_4, time,C_DATA.RTD_5)
ylabel('Cold Temperature [\circC]')
ylim([5, 20])
yyaxis right
plot  (time,C_DATA.RTD_2, time,C_DATA.RTD_3)
ylabel('Hot Temperature [\circC]')
ylim([144,153])

l=legend( 'RTD 2','RTD 3','RTD 0','RTD 1');
l.ItemTokenSize(1) = 20;
% axis tight
%    ylim([27, 35])
%     yticks([27:2:35])
xlabel(['Time' unit])
grid on
nicefigure('thesis_half')


%% Long term steady state plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Speed
figure
mean_int = 1;
plot  (C_DATA.time_VC ./secs, movmean(C_DATA.MB_speed_transient,mean_int))
title([setpoint_name ' - Speed'])

% axis tight
% ylim([150,200])
  xlim([0,7])
  xticks([0:7])
xlabel(['Time' unit])
ylabel('Speed [rpm]')
grid on
nicefigure('thesis_half')


%% Speed with deviation from final value
figure
mean_int = 600;
yyaxis left
plot  (C_DATA.time_VC ./secs, movmean(C_DATA.MB_speed_transient,mean_int))
steady_val = mean(C_DATA.MB_speed_transient(end-36000:end)); % mean of last hour
ylim([150,200])
C = get(gca,'ColorOrder');
yline(steady_val, 'Color',C(1,:), 'LineWidth',2)
ylabel('Speed [rpm]')

yyaxis right
dev_percent = abs( (movmean(C_DATA.MB_speed_transient,mean_int)./steady_val -1) ) *100;
plot  (C_DATA.time_VC ./secs, dev_percent)
ylim([0,20])
ylabel('Deviation [%]')

title([setpoint_name ' - Speed'])
% axis tight
  xlim([0,7])
  xticks([0:7])
xlabel(['Time' unit])
grid on
nicefigure('thesis_half')

%% Torque with deviation from final value
figure
mean_int = 600*5;
yyaxis left
plot  (C_DATA.time_VC ./secs, movmean(C_DATA.torque_sensor_transient,mean_int))
steady_val = mean(C_DATA.torque_sensor_transient(end-36000:end)); % mean of last hour
ylim([0.2,0.3])
C = get(gca,'ColorOrder');
yline(steady_val, 'Color',C(1,:), 'LineWidth',2)
ylabel('Torque [Nm]')

yyaxis right
dev_percent = abs( (movmean(C_DATA.torque_sensor_transient,mean_int)./steady_val -1) ) *100;
plot  (C_DATA.time_VC ./secs, dev_percent)
ylim([0,10])
ylabel('Deviation [%]')

title([setpoint_name ' - Torque'])
% axis tight
  xlim([0,7])
  xticks([0:7])
xlabel(['Time' unit])
grid on
nicefigure('thesis_half')


%% Torque
figure
hold on
mean_int =60; % 5min
mean_torque = movmean(C_DATA.torque_sensor_transient, mean_int);
plot(C_DATA.time_VC ./secs, mean_torque)
% legend('Mov Mean window size 50','Mov Mean window size 100','Mov Mean window size 200')

title([setpoint_name ' - Measured Torque'])

axis tight
%   ylim([0.21,0.28])
% xlim([0,5500)
xlabel(['Time' unit])
ylabel('Measured Torque [Nm]')
grid on

%% Shaft power with deviation from final value
figure
mean_int = 600;
yyaxis left
P_shaft = movmean(C_DATA.MB_speed_transient, mean_int)*2*pi/60 .*movmean(C_DATA.torque_sensor_transient, mean_int*5);
plot  (C_DATA.time_VC ./secs, P_shaft)
steady_val = mean(P_shaft(end-36000:end)); % mean of last hour
ylim([4,5])
C = get(gca,'ColorOrder');
yline(steady_val, 'Color',C(1,:), 'LineWidth',2)
ylabel('Shaft Power [W]')

yyaxis right
dev_percent = abs( (P_shaft./steady_val -1) ) *100;
plot  (C_DATA.time_VC ./secs, dev_percent)
ylim([0,10])
ylabel('Deviation [%]')

title([setpoint_name ' - Shaft Power'])
% axis tight
  xlim([0,7])
  xticks([0:7])
xlabel(['Time' unit])
grid on
nicefigure('thesis_half')

%% Shaft power
figure
mean_int = 600;
P_shaft = movmean(C_DATA.MB_speed_transient, mean_int)*2*pi/60 .*movmean(C_DATA.torque_sensor_transient, mean_int*5);
%avergaed after calc:
% P_shaft = movmean(C_DATA.MB_speed_transient *2*pi/60 .* C_DATA.torque_sensor_transient, mean_int);
plot  (C_DATA.time_VC ./secs, P_shaft)
title([setpoint_name ' - Shaft Power'])

% axis tight
% ylim([150,200])
% xlim([0,5500)
xlabel(['Time' unit])
ylabel('Shaft Power [W]')
grid on

%% RTDs heater
figure
mean_int = 1;
time = C_DATA.time_RTD /secs;
plot(time, movmean(C_DATA.RTD_2,mean_int),  time, movmean(C_DATA.RTD_3,mean_int))
legend('RTD 0','RTD 1')
% legend('RTD Heater In','RTD Heater Out')
title([setpoint_name ' - RTDs Heater'])

% axis tight
% ylim([142.4,143.4])
% xlim([0,5500)
  xlim([0,7])
  xticks([0:7])
xlabel(['Time' unit])
ylabel('Temp [\circC]')
grid on
nicefigure('thesis_half')

%% RTDs heater - Temp Difference
figure
mean_int = 600;
yyaxis left
dT = movmean(C_DATA.RTD_2-C_DATA.RTD_3 ,mean_int);
plot  (C_DATA.time_RTD ./secs, dT)
steady_val = mean(dT(end-36000:end)); % mean of last hour
ylim([8,10])
C = get(gca,'ColorOrder');
yline(steady_val, 'Color',C(1,:), 'LineWidth',2)
ylabel("Heater Temperature Drop"+newline+"RTD0 - RTD1 [\circC]")

yyaxis right
dev_percent = abs( (dT./steady_val -1) ) *100;
plot  (C_DATA.time_RTD ./secs, dev_percent)
ylim([0,10])
ylabel('Deviation [%]')

% axis tight
  xlim([0,7])
  xticks([0:7])
xlabel(['Time' unit])
grid on
nicefigure('thesis_half')

%% RTDs combined
figure
mean_int = 60;
time = C_DATA.time_RTD /secs;
yyaxis left
plot(time, movmean(C_DATA.RTD_2,mean_int),  time, movmean(C_DATA.RTD_3,mean_int),':')
ylabel('Temperature hot [\circC]')
% ylim([129,137])
yyaxis right
plot(time, movmean(C_DATA.RTD_4,mean_int),  time, movmean(C_DATA.RTD_5,mean_int),':')
ylabel('Temperature cold [\circC]')


l=legend('RTD 0','RTD 1','RTD 2','RTD 3')
% l.ItemTokenSize(1) = 10;

% legend('RTD Heater In','RTD Heater Out')
title([setpoint_name ' - RTDs Heater'])

% axis tight
% ylim([142.4,143.4])
% xlim([0,5500)
xlabel(['Time' unit])
grid on
nicefigure('thesis_half')

%% RTDs cooler
figure
mean_int = 1;
time = C_DATA.time_RTD /secs;
plot(time, movmean(C_DATA.RTD_4,mean_int),  time, movmean(C_DATA.RTD_5,mean_int))
legend('RTD 2','RTD 3')
% legend('RTD Cooler In','RTD Cooler Out')
title([setpoint_name ' - RTDs Cooler'])

% axis tight
% ylim([22,23])
% xlim([0,5500)
xlabel(['Time' unit])
ylabel('Temp [\circC]')
grid on
nicefigure('thesis_half')

%% RTDs cooler - Temp Difference
figure
mean_int = 600;
yyaxis left
dT = movmean(C_DATA.RTD_5-C_DATA.RTD_4 ,mean_int);
plot  (C_DATA.time_RTD ./secs, dT)
steady_val = mean(dT(end-36000:end)); % mean of last hour
ylim([10,16])
C = get(gca,'ColorOrder');
yline(steady_val, 'Color',C(1,:), 'LineWidth',2)
ylabel("Cooler Temperature Drop"+newline+"RTD5 - RTD4 [\circC]")

yyaxis right
dev_percent = abs( (dT./steady_val -1) ) *100;
plot  (C_DATA.time_RTD ./secs, dev_percent)
ylim([0,20])
ylabel('Deviation [%]')

% axis tight
  xlim([0,7])
  xticks([0:7])
xlabel(['Time' unit])
grid on
nicefigure('thesis_half')


%% TCs hot
figure
% plot moving mean to smooth curves
mean_int = 600;
time = C_DATA.time_TC /secs;
plot  (time, movmean(C_DATA.TC_0,mean_int), time, movmean(C_DATA.TC_1,mean_int), time, movmean(C_DATA.TC_2,mean_int), time, movmean(C_DATA.TC_3,mean_int), time, movmean(C_DATA.TC_4,mean_int))
l=legend( 'TC 0', 'TC 1', 'TC 2', 'TC 3', 'TC 4');
l.ItemTokenSize(1) = 10;
% legend( 'Expansion Space', 'Heater/Expansion Space Interface, Bypass Side', 'Heater/Expansion Space Interface, Connecting Pipe Side', 'Regen/Heater Interface, Bypass Side', 'Regen/Heater Interface, Connecting Pipe Side')
title([setpoint_name ' - TC Hot Side Gas Temperatures'])
% axis tight
  ylim([79, 91])
  xlim([0,7])
  xticks([0:7])
xlabel(['Time' unit])
ylabel('Temperature [\circC]')
grid on
nicefigure('thesis_half')

%% TCs cold
figure
% plot moving mean to smooth curves
mean_int = 600;
time = C_DATA.time_TC /secs;
% If TC5 diabled
plot  (time, movmean(C_DATA.TC_6,mean_int), time, movmean(C_DATA.TC_7,mean_int), time, movmean(C_DATA.TC_8,mean_int), time, movmean(C_DATA.TC_9,mean_int))
l=legend('TC 6', 'TC 7', 'TC 8', 'TC 9');
% plot  (time, movmean(C_DATA.TC_5,mean_int), time, movmean(C_DATA.TC_6,mean_int), time, movmean(C_DATA.TC_7,mean_int), time, movmean(C_DATA.TC_8,mean_int), time, movmean(C_DATA.TC_9,mean_int))
% l=legend('TC 5', 'TC 6', 'TC 7', 'TC 8', 'TC 9');

l.ItemTokenSize(1) = 10;
% legend( 'Compression Space/Cooler Interface, Connecting Pipe Side', 'Compression Space/Cooler Interface, Bypass Side', 'Compression Space/Cooler Interface, Connecting Pipe Side', 'Power Cylinder')
%     TC_5 --> Cooler/Regenerator Interface, Bypass Side
%     TC_6 --> Compression Space/Cooler Interface, Connecting Pipe Side
%     TC_7 --> Compression Space/Cooler Interface, Bypass Side
%     TC_8 --> Compression Space/Cooler Interface, Connecting Pipe Side
%     TC_9 --> Power Cylinder
%     TC_10 --> Crankcase
title([setpoint_name ' - TC Cold Side Gas Temperatures'])
% axis tight
  ylim([35,40])
  xlim([0,7])
  xticks([0:7])
xlabel(['Time' unit])
ylabel('Temperature [\circC]')
grid on
nicefigure('thesis_half')

%% Pressures
% 'calibrate.m' takes the mean of static pressure data! This is appropriate
% for regular datasets with short acquisition time (10s) where pmean is
% assumed constant, but in long time experiment we need to see the
% transient data!
figure
time = C_DATA.time_VC /secs;
plot(time, C_DATA.p_DCH,  time, C_DATA.p_DM, time, C_DATA.p_PC, time, C_DATA.p_CC)
legend( 'p_DCH','p_DM', 'p_PC','p_CC', 'Interpreter','none')
title([setpoint_name ' - Pressures'])
%   ylim([23,30])
% xlim([0,5500)
xlabel(['Time' unit])
ylabel('Pressure [Pa]')
grid on

%% Pressures static (leak test)
datapoint = 1;
mean_int = 600;

figure
time = C_DATA(datapoint).time_VC /secs;
plot(time, movmean(C_DATA(datapoint).p_PC_static,mean_int)/1000, time, movmean(C_DATA(datapoint).p_CC_static,mean_int)/1000)
% hold on
legend('p_PC_static','p_CC_static', 'Interpreter','none')
title([setpoint_name])% ' - charge to 500kPa into DM and CC, PC open to atm?'])

% axis tight
%   ylim([4.4,4.7]*10^5)
  xlim([0,7])
  xticks([0:7])
xlabel(['Time' unit])
ylabel('Mean Pressure [kPa]')
grid on
nicefigure('thesis_half')

%% Thesis plot showing data averaging of encoder speed or pressure
Ps = double.empty(0);
Xs = double.empty(0);
% Get all sample points for all angles represented in p_log into a single
% vector Ps, and corresponding angle values into Xs. i is the current
% angle.
for i = 1:length(p_log)
    Ps = [Ps; p_log{i}];
    Xs = [Xs; repelem(i,length(p_log{i}))'];
end

figure
hold on
% scatter(Xs, Ps/1000,  '.')
% plot(1:360, RD_DATA(1).p_PC_avg/1000, 'r','LineWidth',2 )
% ylabel('Pressure [kPa]')
scatter(Xs, Ps,  '.')
plot(1:360, RD_DATA(1).encoder_speed, 'r','LineWidth',2 )
ylabel('Speed [rpm]')

legend('Samples','Averaged Curve')
xlabel('Crankshaft Position [\circ]')
grid on
nicefigure('thesis')

axis tight
xlim([0,360])

%% Transient speed vs crank angle

ang_exp = 1:360;
ang_mod = linspace(0,360,201);
i_mod = 1;


for i = [3,7]%1:length(DATA_EXP.data)
figure(fig_count);
fig_count = fig_count+1;
hold on
xlabel('Crank position', 'FontWeight','bold')
ylabel('\itf\rm [rpm]')
nicefigure('thesis_small_wide');
xticks(0:90:360)
xticklabels({'Max. Volume','Heating begins','Min. Volume','Cooling begins','Max. Volume'})
xlim([0,360])

Y_exp = movmean(DATA_EXP.data(i).encoder_speed_transient, 10)';

    Y_mod = DATA_MOD(i_mod).data(i).speed_transient *60;
    Y_mod = interp1(ang_mod, Y_mod, ang_exp);
    Y_mod = circshift(Y_mod,180);
    Y_mod = Y_mod - Y_mod(1) + Y_exp(1); %adjust starting speed of model data
    dev(i) = mean(abs(Y_mod./Y_exp - 1))*100;

    plot(ang_exp, Y_exp ,'DisplayName',"Experiment")
    plot(ang_exp, Y_mod ,'DisplayName',"Model")
    
    l=legend;
 l.ItemTokenSize(1) = 20;

msg = "\itp_{set}\rm = " + DATA_EXP.data(i).pmean_setpoint/1000 + "kPa"+newline+ ...
    "\itf\rm = " + round(DATA_EXP.data(i).encoder_speed) + "rpm"+newline+...
...     "\itRe_{HX,avg}\rm = " + round(mean([ mean(DATA_MOD(i_dataset).data(i_datapoint).Re_cooler_center), mean(DATA_MOD(i_dataset).data(i_datapoint).Re_heater_center) ]));
    "\itRe_{HX,avg}\rm = " + round(Reynolds_HX_exp{1}(i)) +newline+...
    "Mean Deviation "+ round(dev(i))+" %" ;
text(0.03, 0.82, msg, 'Units','normalized', 'FontSize',10,'FontName','Arial') % bottom left
end
disp("Overall mean dev "+round(mean(dev))+" %")

%% Transient speed vs crank angle (BAK)
figure(fig_count);
fig_count = fig_count+1;
hold on
xlabel('Crank position', 'FontWeight','bold')
ylabel('\itf\rm [rpm]')
nicefigure(figure_purpose);
xticks(0:90:360)
xticklabels({'Max. Volume','Heating begins','Min. Volume','Cooling begins','Max. Volume'})
xlim([0,360])

ang_exp = 1:360;
ang_mod = linspace(0,360,201);
i_mod = 1;

for i = [3]
Y_exp = movmean(DATA_EXP.data(i).encoder_speed_transient, 10);

    Y_mod = DATA_MOD(i_mod).data(i).speed_transient *60;
    Y_mod = interp1(ang_mod, Y_mod, ang_exp);
    Y_mod = circshift(Y_mod,180);
    Y_mod = Y_mod - Y_mod(1) + Y_exp(1); %adjust starting speed of model data

    plot(ang_exp, Y_exp ,'DisplayName',"Experiment")
    plot(ang_exp, Y_mod ,'DisplayName',"Model")
    

end
l=legend;
 l.ItemTokenSize(1) = 20;

msg = "\itp_{set}\rm = " + DATA_EXP.data(i).pmean_setpoint/1000 + "kPa"+newline+ ...
    "\itf\rm = " + round(DATA_EXP.data(i).encoder_speed) + "rpm"+newline+...
...     "\itRe_{HX,avg}\rm = " + round(mean([ mean(DATA_MOD(i_dataset).data(i_datapoint).Re_cooler_center), mean(DATA_MOD(i_dataset).data(i_datapoint).Re_heater_center) ]));
    "\itRe_{HX,avg}\rm = " + round(Reynolds_HX_exp{1}(i));
text(0.03, 0.15, msg, 'Units','normalized', 'FontSize',10,'FontName','Arial') % bottom left
