%% START HERE for PV curve comparison %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET INPUTS BELOW BEFORE RUNNING
% Run this section if you want to compute and plot the PV diagram
% comparison parameters for experimental and model datasets.

% INPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Whether to plot the PVs for each data point.
% 0 for no plots
% 1 to show each plot
% any number n > 1 to show every n'th plot
% > 0 always shows plots for 1st and last data point)
plotPVs = 30;

% SPECIFY the indices (in DATA_EXP and DATA_MOD) of the datasets that
% should be used for comparing PV shapes. Datasets will be compared in the
% order they appear in iPV_mod and iPV_exp. Experimental and model datasets
% being compared must have same number and order of datapoints.
% Can specify any number of pairs of datasets to be compared.

iPV_exp = 1:length(DATA_EXP); % indices of experimental datasets for comparison

iPV_mod = 1;%:length(DATA_MOD); % indices of model datasets for comparison

% END INPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Outputs: p_dev_max, p_dev_mean, PV_overlap_ratio
% Plots:
% (1) raw PV curves
% (2) Volume over crank angle, incl max volume deviation
% (3) Overlaid PV curves with overlap curve and percentage
[p_dev_max, p_dev_mean, PV_overlap_ratio] = Data_PVcompare(plotPVs,figure_purpose,iPV_exp,iPV_mod, DATA_EXP,DATA_MOD);

close all


%% Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Avg and max deviation in pressure between exp and mod, vs speed
figure(fig_count);
fig_count = fig_count+1;
hold on
legstr = "";
leg_chars = 30;
xlabel('Speed [rpm]')
ylabel('Pressure Relative Deviation [%]')
title('Deviation in pressure')
nicefigure(figure_purpose);

% Change plot color order so that each color is repeated n times.
n_color_repeat = 2;
C = get(gca,'ColorOrder');
C = repelem(C, n_color_repeat, 1);
set(gca,'ColorOrder',C);

% plot all model datapoints. different color for each dataset.
for i=1:size(p_dev_mean, 1)
    scatter([DATA_MOD(i).data.speedRPM], p_dev_mean{i}*100, 40, 'x')
    scatter([DATA_MOD(i).data.speedRPM], p_dev_max{i}*100, 40, '+')
    legname = DATA_MOD(i).name;
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    legstr(2*(i-1)+1) = "Mean: " + legname;
    legstr(2*(i-1)+2) = "Max: " + legname;
end
legend(legstr, 'Interpreter', 'none')


%% PV overlap between exp and mod, vs speed
figure(fig_count);
fig_count = fig_count+1;
hold on
legstr = {};
leg_chars = 30;
xlabel('Speed [rpm]')
ylabel('PV overlap ratio [%]')
title('PV overlap')
nicefigure(figure_purpose);

% plot all model datapoints. different color for each dataset.
for i=1:size(PV_overlap_ratio, 1)
    scatter([DATA_MOD(i).data.speedRPM], PV_overlap_ratio{i}*100, 40, colors{i},'x')
    legname = DATA_MOD(i).name;
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    legstr{i} = legname;

end
% legend(legstr, 'Interpreter', 'none')
l=legend('200 kPa','350 kPa','400 kPa','450 kPa', 'Location','northoutside');
l.ItemTokenSize(1) = 10;
% scatter([RD_DATA.MB_speed], PV_overlap_ratio*100, 30, [RD_DATA.pmean]./1000,'x')
