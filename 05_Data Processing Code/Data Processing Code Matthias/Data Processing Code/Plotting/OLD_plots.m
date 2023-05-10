%% FOR PLOTTING DIFFERENT EXP SETS IN SAME COLOR, DIFFEREND SYMBOLS
%Eff vs speed, pressure color coded, with colors in legend
figure(fig_count);
fig_count = fig_count+1;
hold on
leg_chars = 30;
xlabel('Speed [rpm]')
ylabel('Indicated Efficiency [%]')
title('Efficiency (indicated)')
nicefigure(figure_purpose);
plots_i = 1;

% plot all experimental datapoints. different color for each dataset.
for i=4:6%:length(DATA_EXP)
    legname = ['c const(old), ' num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 ) 'kPa'];
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    p = scatter([DATA_EXP(i).data.MB_speed], [DATA_EXP(i).data.efficiency_ind]*100, 30, [DATA_EXP(i).data.pmean]./1000, 'o', 'DisplayName',legname);
    if i==1; plots(plots_i) = p; plots_i = plots_i+1; end
end
for i=1:3%:length(DATA_EXP)
    legname = ['c(T)(new), ' num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 ) 'kPa'];
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    p = scatter([DATA_EXP(i).data.MB_speed], [DATA_EXP(i).data.efficiency_ind]*100, 30, [DATA_EXP(i).data.pmean]./1000, 'sq', 'DisplayName',legname);
    if i==1; plots(plots_i) = p; plots_i = plots_i+1; end
end

% plot all model datapoints. different color for each dataset.
for i=1:3%length(DATA_MOD)
    legname = ['Mod, h=5(new) ' num2str( DATA_MOD(i).data(1).p_mean_setpoint/1000 ) 'kPa'];
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    p = scatter([DATA_MOD(i).data.speedRPM], [DATA_MOD(i).data.efficiency_ind]*100, 40, [DATA_MOD(i).data.p_mean]./1000, '+', 'DisplayName',legname);
    if i==1; plots(plots_i) = p; plots_i = plots_i+1; end  
end
for i=4:6%length(DATA_MOD)
    legname = ['Mod, h=20(old) ' num2str( DATA_MOD(i).data(1).p_mean_setpoint/1000 ) 'kPa'];
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    p = scatter([DATA_MOD(i).data.speedRPM], [DATA_MOD(i).data.efficiency_ind]*100, 40, [DATA_MOD(i).data.p_mean]./1000, 'x', 'DisplayName',legname);
    if i==1; plots(plots_i) = p; plots_i = plots_i+1; end  
end

legend('Interpreter', 'none')
colormap(jet(10))




%% P shaft vs speed (Compare setpoint vs. measured torque)
figure(fig_count);
fig_count = fig_count+1;
hold on
legstr = {};
leg_chars = 25;
xlabel('Speed [rpm]')
ylabel('Shaft Power [W]')
title('Shaft Power')
nicefigure(figure_purpose);

measured_only = 1;

if ~measured_only
    % Change plot color order so that each color is repeated n times.
    n_color_repeat = 2;
    C = get(gca,'ColorOrder');
    C = repelem(C, n_color_repeat, 1);
    set(gca,'ColorOrder',C);
end

% plot all experimental datapoints. different color for each dataset.
for i=1:length(DATA_EXP)
    legname = ['Exp: ' DATA_EXP(i).name];
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    %     legstr{i} =  legname;
    
    scatter([DATA_EXP(i).data.MB_speed], [DATA_EXP(i).data.P_shaft_exp_tsensor], 40, 'x')
    
    if ~measured_only
        scatter([DATA_EXP(i).data.MB_speed], [DATA_EXP(i).data.P_shaft_exp], 30, 'o')
        legstr{2*(i-1)+1} = "(T setpoint) " + legname;
        legstr{2*(i-1)+2} = "(T measured) " + legname;
    else
        legstr{i} = legname;
    end
end
% plot all model datapoints. different color for each dataset.
% for i=1:length(DATA_MOD)
%     %     scatter([DATA_MOD(i).data.speedRPM], [DATA_MOD(i).data.Wind], 30, [DATA_MOD(i).data.p_mean]./1000)%,'x')
%     scatter([DATA_MOD(i).data.speedRPM], [DATA_MOD(i).data.Wind], 40, 'x')
%     legname = ['Mod: ' DATA_MOD(i).name];
%     if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
%     legstr{length(DATA_EXP)+i} =  legname;
%     
%     %     plot([DATA_MOD(i).data.speedRPM], [DATA_MOD(i).data.Wind])%, 30, [DATA_MOD(i).data.p_mean]./1000)%,'x')
% end
legend(legstr, 'Interpreter', 'none')



%% old plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% comparing MPSM PV plots
figure
hold on
legend
for i=1:2:length(MSPM_DATA)
   p_norm = MSPM_DATA(i).PV_PP.p - MSPM_DATA(i).p_mean;
    plot(MSPM_DATA(i).PV_PP.V, p_norm, 'DisplayName',num2str(round(MSPM_DATA(i).speedRPM)))
    x = input("");
end
% legend(num2str(round([MSPM_DATA.speedRPM]')))

%% Pmean over speed
figure
hold on
plot([RD_DATA.MB_speed], [RD_DATA.pmean], 'ok')
plot([MSPM_DATA.speedRPM], [MSPM_DATA.p_mean], 'xr')
xlabel('Speed [rpm]')
ylabel('Pressure [Pa]')
legend('Experiment','MSPM')
title('Mean Cycle Pressure, for mean pressures between 350kPa, 480kPa')

%% dP over speed
figure
hold on
plot([RD_DATA.MB_speed], max([RD_DATA.p_PC_avg])-min([RD_DATA.p_PC_avg]), 'ok')
PV_PP = [MSPM_DATA.PV_PP];
plot([MSPM_DATA.speedRPM], [PV_PP.deltaP], 'xr')
xlabel('Speed [rpm]')
ylabel('Pressure [Pa]')
legend('Experiment','MSPM')
title('delta-P, pmean 350...480kPa')





%% For comparing Sine and Crank $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
% Split MSPM_DATA into sine and crank
MSPM_SINE = MSPM_DATA(1:45);
MSPM_CRANK = MSPM_DATA(46:end);

%% Indicated Work vs speed, pressure as color
figure
hold on
% plot([RD_DATA.MB_speed], [RD_DATA.Wind_exp], 'ok')
% plot([MSPM_DATA.speedRPM], [MSPM_DATA.Wind], 'xr')
scatter([RD_DATA.MB_speed], [RD_DATA.Wind_exp], 30, [RD_DATA.pmean]./1000,'o')
scatter([RD_DATA.MB_speed], [MSPM_SINE.Wind], 30, [MSPM_SINE.p_mean]./1000,'x')
scatter([RD_DATA.MB_speed], [MSPM_CRANK.Wind], 20, [MSPM_CRANK.p_mean]./1000,'+')
% plot([RD_DATA.MB_speed], p_dev_mean*100, 'ok', [RD_DATA.MB_speed], p_dev_max*100, 'xr')
cb = colorbar;
ylabel(cb,'Mean Pressure (kPa)')
colormap(jet)
xlabel('Speed [rpm]')
ylabel('Indicated Work [J]')
legend('Experiment','MSPM-sine','MSPM-crank')
title('Indicated Work, for mean pressures between 350kPa, 480kPa')

%% Eff vs speed, pressure as color
eff_ind = [RD_DATA.Wind_exp].*[RD_DATA.MB_speed]./60 ./([RD_DATA.Qdot_heater_exp]+[RD_DATA.Qdot_DCH_exp]);

figure
hold on
% this is shaft efficiency
% scatter([RD_DATA.MB_speed], [RD_DATA.efficiency_exp], 30, [RD_DATA.pmean]./1000,'o')
scatter([RD_DATA.MB_speed], eff_ind, 30, [RD_DATA.pmean]./1000,'o')
scatter([RD_DATA.MB_speed], [MSPM_SINE.efficiency_ind]*100, 30, [MSPM_SINE.p_mean]./1000,'x')
scatter([RD_DATA.MB_speed], [MSPM_CRANK.efficiency_ind]*100, 20, [MSPM_CRANK.p_mean]./1000,'+')
cb = colorbar;
ylabel(cb,'Mean Pressure (kPa)')
colormap(jet)
xlabel('Speed [rpm]')
ylabel('Indicated Efficiency [%]')
legend('Experiment','MSPM-sine','MSPM-crank')
title('Efficiency, for mean pressures between 350kPa, 480kPa')

%% Avg and max deviation in pressure between exp and mod, vs speed, pressure as color
figure
hold on
scatter([RD_DATA.MB_speed], p_dev_mean(1:45)*100, 40, [RD_DATA.pmean]./1000,'x')
scatter([RD_DATA.MB_speed], p_dev_max(1:45)*100, 40, [RD_DATA.pmean]./1000,'x','LineWidth',1)
scatter([RD_DATA.MB_speed], p_dev_mean(46:end)*100, 30, [RD_DATA.pmean]./1000,'o')
scatter([RD_DATA.MB_speed], p_dev_max(46:end)*100, 30, [RD_DATA.pmean]./1000,'o','LineWidth',1)
% plot([RD_DATA.MB_speed], p_dev_mean*100, 'ok', [RD_DATA.MB_speed], p_dev_max*100, 'xr')
cb = colorbar;
ylabel(cb,'Mean Pressure (kPa)')
colormap(jet)
xlabel('Speed [rpm]')
ylabel('Pressure Relative Deviation [%]')
legend('Mean-sine','Max-sine','Mean-crank','Max-crank')
title('Deviation in pressure, pmean 350...480kPa')

%% PV overlap between exp and mod, vs speed, pressure as color
figure
hold on
% plot([RD_DATA.MB_speed], PV_overlap_ratio*100, 'xk')
scatter([RD_DATA.MB_speed], PV_overlap_ratio(1:45)*100, 40, [RD_DATA.pmean]./1000,'x')
scatter([RD_DATA.MB_speed], PV_overlap_ratio(46:end)*100, 30, [RD_DATA.pmean]./1000,'o')
cb = colorbar;
ylabel(cb,'Mean Pressure (kPa)')
colormap(jet)
xlabel('Speed [rpm]')
ylabel('PV overlap ratio [%]')
legend('sine','crank')
title('PV overlap, pmean 350...480kPa')


