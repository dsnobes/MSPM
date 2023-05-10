%% Raw Pressure and Pressure Drop vs crank angle %%%%%%%%%%%%%%%%%%%%%%%%%%

%% p from ONE location vs angle (EXP), ALL sensors, ONE datapoint
figure(fig_count);
fig_count = fig_count+1;
hold on
xlabel('Crank position', 'FontWeight','bold')
ylabel('Pressure - \itp_{mean}\rm [kPa]')
nicefigure(figure_purpose);
plots = [];

colors = {'k','r','b','g'};
markers = {'-','--'};
angles = 1:360;

f_min = 1000; % to get min and max speed for the datapoint
f_max = 0;

datapoint = 1;

% plot pressures from 1 location from all sensors (DATA_EXP) for the specified datapoint.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sets = 1:length(DATA_EXP);
% sets = sets([2,1,4,3]); % (PC) change order of datasets to keep same order of sensors when plotting PC location
% sets = sets([2,1,4,3]); % (DM)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n = 1;
for i = sets
    pmean = DATA_EXP(i).data(datapoint).pmean;
    f_min = min([f_min, DATA_EXP(i).data(datapoint).encoder_speed]);
    f_max = max([f_max, DATA_EXP(i).data(datapoint).encoder_speed]);
    %%%%%%%%%%%%%%%%%%%%
%         p = plot(angles, (DATA_EXP(i).data(datapoint).p_DCH_avg - pmean)/1000, [colors{i} markers{1}]);
%          p = plot(angles, (DATA_EXP(i).data(datapoint).p_PC_avg - pmean)/1000, [colors{n} markers{1}]);
%          p = plot(angles, (DATA_EXP(i).data(datapoint).p_DM_avg - pmean)/1000, [colors{n} markers{1}]);
         p = plot(angles, (DATA_EXP(i).data(datapoint).p_CC_avg - DATA_EXP(i).data(datapoint).pmean_CC)/1000, [colors{n} markers{1}]);
    %%%%%%%%%%%%%%%%%%%%    
plots(end+1) = p;
n=n+1;
end
f_min = round(f_min);
f_max = round(f_max);
    %     if i==1; plots(plots_i) = p; plots_i = plots_i+1; end
% plot all model datapoints. different color for each dataset.
%     legname = ['Mod, ' num2str( DATA_MOD(i).data(1).p_mean_setpoint/1000 ) 'kPa'];
%     if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
%     p = scatter([DATA_MOD(i).data.speedRPM], [DATA_MOD(i).data.Wind], 40, [DATA_EXP(i).data.pmean]./1000, 'x', 'DisplayName',legname);
%     if i==1; plots(plots_i) = p; plots_i = plots_i+1; end  
xlim([0,360])
ylim([-20,20])

xticks(0:90:360)
xticklabels({'Max. Volume','Heating begins','Min. Volume','Cooling begins','Max. Volume'})
%%%%%%%%%%%%%%%%%%
msg = "Position 3"...
...%%%%%%%%%%%%%%%
+newline+"\it\tau_{set}\rm = " + DATA_EXP(1).data(datapoint).torque_setpoint + " Nm"...
    +newline+ "\itf\rm = " + f_min;
if f_min ~= f_max; msg = msg + " - " + f_max; end
msg = msg + " rpm";
text(0.03, 0.6, msg, 'Units','normalized')
 
% legend 1: color = sensor number
leg_txt = {'A','B','C','D'};
l=legend(plots,leg_txt, 'Location','northwest');
l.Title.String = 'Sensor';
l.ItemTokenSize(1) = 10;


%% p_DCH and p_DM vs angle (EXP), ALL sensors, ONE datapoint (BAK)
figure(fig_count);
fig_count = fig_count+1;
hold on
title('p-DCH (Expansion space) and p-DM (Compression space)')
xlabel('Crank angle [\circ]')
ylabel('Pressure vs \itp_{mean}\rm [Pa]')
nicefigure(figure_purpose);
plots = [];

colors = {'k','r','b','g'};
colors_PC = colors([2,1,4,3]); % color orders according to order of sensors at these locations
markers = {'-','--'};
angles = 1:360;

f_min = 1000; % to get min and max speed for the datapoint
f_max = 0;

datapoint = 1;

% plot pressures from 2 locations from all sensors (DATA_EXP) for the specified datapoint.
for i = 1:length(DATA_EXP)
    pmean = DATA_EXP(i).data(datapoint).pmean;
    f_min = min([f_min, DATA_EXP(i).data(datapoint).encoder_speed]);
    f_max = max([f_max, DATA_EXP(i).data(datapoint).encoder_speed]);
%         legname = [num2str( round(DATA_EXP(i).data(datapoint).MB_speed) ) 'rpm, p_DCH'];
%         legname = ['Exp, ' num2str( DATA_EXP(i).data(datapoints(d)).pmean_setpoint/1000 ) 'kPa, ' num2str( round(DATA_EXP(i).data(datapoints(d)).MB_speed) ) 'rpm, p_DCH'];
        p = plot(angles, [DATA_EXP(i).data(datapoint).p_DCH_avg]-pmean, [colors{i} markers{1}]);
        % legend 1: color = sensor number
        plots(end+1) = p;
        
%         legname = [num2str( round(DATA_EXP(i).data(datapoint).MB_speed) ) 'rpm, p_DM'];
        p = plot(angles, [DATA_EXP(i).data(datapoint).p_PC_avg]-pmean,  [colors_PC{i} markers{2}]);
end
f_min = round(f_min);
f_max = round(f_max);
    %     if i==1; plots(plots_i) = p; plots_i = plots_i+1; end
% plot all model datapoints. different color for each dataset.
%     legname = ['Mod, ' num2str( DATA_MOD(i).data(1).p_mean_setpoint/1000 ) 'kPa'];
%     if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
%     p = scatter([DATA_MOD(i).data.speedRPM], [DATA_MOD(i).data.Wind], 40, [DATA_EXP(i).data.pmean]./1000, 'x', 'DisplayName',legname);
%     if i==1; plots(plots_i) = p; plots_i = plots_i+1; end  
xlim([0,360])

msg = "\it\tau_{set}\rm = " + DATA_EXP(1).data(datapoint).torque_setpoint + " Nm"...
    +newline+ "\itf\rm = " + f_min;
if f_min ~= f_max; msg = msg + " - " + f_max; end
msg = msg + " rpm";
text(0.03, 0.65, msg, 'Units','normalized')%, 'FontSize',12, 'FontName','Times New Roman'
 
% legend 1: color = sensor number
leg_txt = {'A','B','C','D'};
l=legend(plots,leg_txt, 'Location','northwest');
l.Title.String = 'Sensor';
l.ItemTokenSize(1) = 10;



%% p_DCH and p_DM vs angle (EXP), several datapoints (BAK)
figure(fig_count);
fig_count = fig_count+1;
hold on
leg_chars = 30;
title('p-DCH (Expansion space) and p-DM (Compression space)')
xlabel('Crank angle [\circ]')
ylabel('Pressure vs mean [Pa]')
nicefigure(figure_purpose);
plots_i = 1;

colors = {'r','b'};
markers = {'-','--'};
% markers = repelem(markers,2);
angles = 1:360;
datasets = 5;
datapoint = [1, 5];%length(DATA_EXP(datasets).data)]; % first and last datapoint

% plot all experimental datapoints. different color for each dataset.
for i = 1:length(datasets)
    for d = 1:length(datapoint)
        legname = [num2str( round(DATA_EXP(datasets(i)).data(datapoint(d)).MB_speed) ) 'rpm, p_DCH'];
%         legname = ['Exp, ' num2str( DATA_EXP(datasets(i)).data(datapoints(d)).pmean_setpoint/1000 ) 'kPa, ' num2str( round(DATA_EXP(datasets(i)).data(datapoints(d)).MB_speed) ) 'rpm, p_DCH'];
        p = plot(angles, [DATA_EXP(datasets(i)).data(datapoint(d)).p_DCH_avg]-DATA_EXP(datasets(i)).data(datapoint(d)).pmean, [colors{d} markers{1}], 'DisplayName',legname);
        
        legname = [num2str( round(DATA_EXP(datasets(i)).data(datapoint(d)).MB_speed) ) 'rpm, p_DM'];
        p = plot(angles, [DATA_EXP(datasets(i)).data(datapoint(d)).p_DM_avg]-DATA_EXP(datasets(i)).data(datapoint(d)).pmean,  [colors{d} markers{2}], 'DisplayName',legname);
    end
end
    %     if i==1; plots(plots_i) = p; plots_i = plots_i+1; end
% plot all model datapoints. different color for each dataset.
%     legname = ['Mod, ' num2str( DATA_MOD(i).data(1).p_mean_setpoint/1000 ) 'kPa'];
%     if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
%     p = scatter([DATA_MOD(i).data.speedRPM], [DATA_MOD(i).data.Wind], 40, [DATA_EXP(i).data.pmean]./1000, 'x', 'DisplayName',legname);
%     if i==1; plots(plots_i) = p; plots_i = plots_i+1; end  
xlim([0,360])
msg = "Experiment" +newline+ "p-mean " + DATA_EXP(datasets(1)).data(datapoint(1)).pmean_setpoint/1000 + "kPa";
text(0.05, 0.7, msg, 'Units','normalized', 'FontSize',12, 'FontName','Times New Roman')
legend('Interpreter','none', 'Location','northwest')


%% p_DCH and p_DM vs angle (EXP and MOD), one datapoint
figure(fig_count);
fig_count = fig_count+1;
hold on
leg_chars = 30;
xlabel('Crank angle [\circ]')
ylabel('Pressure vs mean [Pa]')
title('p-DCH (Expansion space) and p-DM (Compression space)')
nicefigure(figure_purpose);
plots_i = 1;

colors = {'b','k','g','r'};
markers = {'-','--'};
% markers = repelem(markers,2);
angles = 1:360;
anglesMOD = linspace(1,360,199);

datasets = 1:3;
datapoint = 15;
% datapoints = length(DATA_EXP(datasets).data);

for i = 1:length(datasets)
    for d = 1:length(datapoint)
        legname = 'Exp, p_DCH';
%         legname = ['Exp, ' num2str( DATA_EXP(datasets(i)).data(datapoints(d)).pmean_setpoint/1000 ) 'kPa, ' num2str( round(DATA_EXP(datasets(i)).data(datapoints(d)).MB_speed) ) 'rpm, p_DCH'];
        p = plot(angles, movmean(([DATA_EXP(datasets(i)).data(datapoint(d)).p_DCH_avg]-DATA_EXP(datasets(i)).data(datapoint(d)).pmean),10), [colors{i} markers{1}], 'DisplayName',legname);        
        legname = 'Exp, p_DM';
        p = plot(angles, movmean(([DATA_EXP(datasets(i)).data(datapoint(d)).p_DM_avg]-DATA_EXP(datasets(i)).data(datapoint(d)).pmean),10),  [colors{i} markers{2}], 'DisplayName',legname);
    
%         legname = 'Mod, p_Exp';
%         p = plot(anglesMOD, circshift([DATA_MOD(datasets(i)).data(datapoints(d)).PV_Exp.p]-DATA_MOD(datasets(i)).data(datapoints(d)).p_mean, 100),  [colors{2} markers{1}], 'DisplayName',legname);
%         legname = 'Mod, p_Com';
%         p = plot(anglesMOD, circshift([DATA_MOD(datasets(i)).data(datapoints(d)).PV_Com.p]-DATA_MOD(datasets(i)).data(datapoints(d)).p_mean, 100),  [colors{2} markers{2}], 'DisplayName',legname);

    end
end
for d = 1:length(datapoint)
    legname = 'Mod, p_Exp';
    p = plot(anglesMOD, circshift([DATA_MOD(datasets(i)).data(datapoint(d)).PV_Exp.p]-DATA_MOD(datasets(i)).data(datapoint(d)).p_mean, 100),  [colors{end} markers{1}], 'DisplayName',legname);
    legname = 'Mod, p_Com';
    p = plot(anglesMOD, circshift([DATA_MOD(datasets(i)).data(datapoint(d)).PV_Com.p]-DATA_MOD(datasets(i)).data(datapoint(d)).p_mean, 100),  [colors{end} markers{2}], 'DisplayName',legname);
end
        %     text(10,max([DATA_EXP(datasets(i)).data(datapoints(d)).p_DCH_avg]), "Dataset "+datasets(i)+newline+"Datapoint "+datapoints(d))
xlim([0,360])
msg = "p-mean " + DATA_EXP(datasets(1)).data(datapoint(1)).pmean_setpoint/1000 + "kPa" +newline+ round(DATA_EXP(datasets(1)).data(datapoint(1)).MB_speed) + "rpm";
text(0.05, 0.7, msg, 'Units','normalized', 'FontSize',12, 'FontName','Times New Roman')
legend('Interpreter','none', 'Location','northwest')



%% delta_P vs crank (EXP and MOD), one dataset
figure(fig_count);
fig_count = fig_count+1;
hold on
%%%%%%%%%%%%%%%%%%%%%%%%%
units = 'abs';%'abs';
exp_smoothing_interval = 20; %interval size for moving mean on exp data
%%%%%%%%%%%%%%%%%%%%%%%%%
xlabel('Crank position', 'FontWeight','bold')
switch units
    case 'abs'
        ylabel('\it\Deltap_{HX}\rm [Pa]')
    case 'rel'
        ylabel('Pressure Drop / P-mean [%]')
end
title('delta-P (Pressure drop): P-Exp - P-Com. Solid = exp, Dashed = model.')
nicefigure(figure_purpose);
plots_i = 1;
plots = [];
angles = linspace(0,360,360);
anglesMOD = linspace(0,360,199);

datasets = 1:length(DATA_EXP); % scalar

% default colororder has 7 colors
C = get(gca,'ColorOrder');
colors = {'k','g','b','r','c','m',C(2,:),C(3,:)};
    
%magenta, black, green, red   
% morecolors = [1 0 1; 0 0 0; 0 1 0; 1 0 0];
% C = repmat(C, ceil(length(datapoints)/length(C)), 1);
% C = C(1:length(datapoints),:); % to get as many colors as there are datapoints
% C = repelem(C, 2, 1); % repeat each color once for exp and mod
% set(gca,'ColorOrder',C);
markers = {'-','--'};

% plot all experimental datapoints. different color for each dataset.
for i = 1:length(datasets)
datapoint = [1, length(DATA_MOD(datasets(i)).data)];
    for d = 1:length(datapoint)
        legname = [num2str( DATA_EXP(datasets(i)).data(datapoint(d)).pmean_setpoint/1000 ) ' kPa, ' num2str( round(DATA_EXP(datasets(i)).data(datapoint(d)).encoder_speed) ) ' rpm'];
%         legname = round(DATA_EXP(datasets(i)).data(datapoints(d)).encoder_speed)+ " rpm, "+ DATA_EXP(datasets(i)).data(datapoints(d)).pmean_setpoint/1000 +" kPa";
%         legname = [num2str( round(DATA_EXP(datasets(i)).data(datapoints(d)).encoder_speed) ) 'rpm'];
        dP_exp = [DATA_EXP(datasets(i)).data(datapoint(d)).p_DCH_avg]-[DATA_EXP(datasets(i)).data(datapoint(d)).p_DM_avg];
        % extend data at start and end of vector so that movmean has full window of data around each point
        dP_exp = [dP_exp(end+1-exp_smoothing_interval/2 : end); dP_exp; dP_exp(1:exp_smoothing_interval/2)];
        dP_exp = movmean(dP_exp,exp_smoothing_interval); %smoothing the curves
        dP_exp = dP_exp(1+exp_smoothing_interval/2 : end-exp_smoothing_interval/2); % return data to original length
        dP_mod = circshift([DATA_MOD(datasets(i)).data(datapoint(d)).PV_Exp.p]-[DATA_MOD(datasets(i)).data(datapoint(d)).PV_Com.p], 100);
        if strcmp(units,'rel')
            dP_exp = dP_exp ./DATA_EXP(datasets(i)).data(datapoint(d)).pmean *100;
            dP_mod = dP_mod ./DATA_MOD(datasets(i)).data(datapoint(d)).p_mean *100;
        end
        p = plot(angles, dP_exp, markers{1}, 'Color',colors{plots_i}, 'DisplayName',legname); %
        if d==1 && i==1; plots(end+1) = p; end
%                 legname = ['Mod, ' num2str( DATA_MOD(datasets(i)).data(datapoints(d)).p_mean_setpoint/1000 ) 'kPa, ' num2str( round(DATA_MOD(datasets(i)).data(datapoints(d)).speedRPM) ) 'rpm'];
        p = plot(anglesMOD, dP_mod,  markers{2}, 'Color',colors{plots_i}, 'DisplayName',legname);
        if d==1 && i==1; plots(end+1) = p; end

        %         plot(anglesMOD, dP_mod,  markers{2}, 'Color',colors{plots_i}, 'DisplayName',legname);
        plots_i = plots_i+1;
    end
end
l=legend(plots);
%  l.ItemTokenSize(1) = 20;
l.Title.String = '\itp_{set} , f';

xlim([0,360])
xticks(0:90:360)
xticklabels({'Max. Volume','Heating begins','Min. Volume','Cooling begins','Max. Volume'})


%% Pressure drop vs Speed/Re %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% pre-calcs
clear dP_*
% clear dP_mean_positive_exp dP_mean_negative_exp dP_max_exp dP_min_exp dP_zeros_exp dP_mean_positive_mod dP_mean_negative_mod dP_max_mod dP_min_mod dP_zeros_mod
exp_smoothing_interval = 20; %interval size for moving mean on exp data
% Requires DATA_EXP and DATA_MOD to have same number of datasets with equal
% number of datatpoints
for i = 1:length(DATA_EXP)
    for d = 1:length(DATA_EXP(i).data)
        dP_exp = [DATA_EXP(i).data(d).p_DCH_avg]-[DATA_EXP(i).data(d).p_DM_avg];
                % extend data at start and end of vector so that movmean has full window of data around each point
        dP_exp = [dP_exp(end+1-exp_smoothing_interval/2 : end); dP_exp; dP_exp(1:exp_smoothing_interval/2)];
        dP_exp = movmean(dP_exp,exp_smoothing_interval); %smoothing the exp data
        dP_exp = dP_exp(1+exp_smoothing_interval/2 : end-exp_smoothing_interval/2); % return data to original length
        dP_mean_positive_exp{i}(d) = mean(dP_exp(dP_exp>0));
        dP_mean_negative_exp{i}(d) = mean(dP_exp(dP_exp<0));
        dP_mean_abs_exp{i}(d) = mean(abs(dP_exp));
        dP_max_exp{i}(d) = max(dP_exp);
        dP_min_exp{i}(d) = min(dP_exp);
        % 'close' the pressure curve so that zero crossing at first or last element will be found
        dP_zeros_exp{i,d} = find(diff(sign([dP_exp; dP_exp(1)])));
%                 [dP_max_exp{i}(d), dP_max_angle_exp{i}(d)] = max(dP_exp);
%         [dP_min_exp{i}(d), dP_min_angle_exp{i}(d)] = min(dP_exp);
    end
end
for i = 1:length(DATA_MOD)
    for d = 1:length(DATA_MOD(i).data)
        dP_mod = circshift([DATA_MOD(i).data(d).PV_Exp.p]-[DATA_MOD(i).data(d).PV_Com.p], 100);
        dP_mean_positive_mod{i}(d) = mean(dP_mod(dP_mod>0));
        dP_mean_negative_mod{i}(d) = mean(dP_mod(dP_mod<0));
        dP_mean_abs_mod{i}(d) = mean(abs(dP_mod));
        dP_max_mod{i}(d) = max(dP_mod);
        dP_min_mod{i}(d) = min(dP_mod);
        dP_zeros_mod{i,d} = find(diff(sign([dP_mod; dP_mod(1)]))) /length(dP_mod)*length(dP_exp); % to degrees;
%         [dP_max_mod{i}(d), dP_max_angle_mod{i}(d)] = max(dP_mod);
%         [dP_min_mod{i}(d), ind] = min(dP_mod);
%         dP_min_angle_mod{i}(d) = ind/length(dP_mod)*360; % to degrees

    end
end

%% delta_P Maximum and Minimum vs Reynolds OR speed
figure(fig_count);
fig_count = fig_count+1;
hold on
%%%%%%%%%%%%%%
units = 'abs'; %'rel'
X_var = 'speed'; %'speed'
%%%%%%%%%%%%%%
switch units
    case 'abs'
        ylabel('Pressure Drop [Pa]')
    case 'rel'
        ylabel('Pressure Drop / P-mean [%]')
end
title('MAXIMUM delta-P (Pressure drop): P-Exp - P-Com.')
nicefigure(figure_purpose);
plots_i = 1;
clear plots

markers = {'o','sq','x','+'};
colors = {'k','b','g','r'};

switch X_var % determine data for X axis
    case 'Re'
        xlabel('Reynolds Number')
        ENGINE_DATA = T2_ENGINE_DATA;
        for i=1:length(DATA_EXP)
            Tg_avg = mean([[DATA_EXP(i).data.Tgk_inlet]; [DATA_EXP(i).data.Tgh_inlet]]);
            % Re = rho * D_h * V / mu
            % rho = p/(RT)
            X{i} =  (([DATA_EXP(i).data.pmean]+[DATA_EXP(i).data.p_atm]) ./287 ./(Tg_avg+273.15)) .* ENGINE_DATA.cooler_D_h .* (ENGINE_DATA.Vswd * 2 * [DATA_EXP(i).data.MB_speed]/60 / ENGINE_DATA.cooler_A_cross) ./ Visc_air(Tg_avg);
        end
    case 'speed'
        xlabel('Speed [rpm]')
        for i=1:length(DATA_EXP)
            Xexp{i} = [DATA_EXP(i).data.MB_speed];

        end
        for i=1:length(DATA_MOD)
            Xmod{i} = [DATA_MOD(i).data.speedRPM];

        end
end

% plot all experimental datapoints. different color for each dataset.
for i = 1:length(DATA_EXP)   
    Y_plot = dP_max_exp{i};
    if strcmp(units,'rel')
        Y_plot = Y_plot ./[DATA_EXP(i).data.pmean] *100;
    end
    legname = ['Exp, ' num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 ) 'kPa, max'];
    p = scatter(Xexp{i}, Y_plot, 30, colors{i}, markers{1}, 'DisplayName',legname);
    plots(plots_i) = p;
    plots_i = plots_i+1;
    
    Y_plot = -dP_min_exp{i};
    if strcmp(units,'rel')
        Y_plot = Y_plot ./[DATA_EXP(i).data.pmean] *100;
    end
    legname = ['Exp, ' num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 ) 'kPa, min'];
    p = scatter(Xexp{i}, Y_plot, 30, colors{i}, markers{2}, 'DisplayName',legname);
    plots(plots_i) = p;
    plots_i = plots_i+1;
    
end
for i = 1:length(DATA_MOD)
    Y_plot = dP_max_mod{i};
    if strcmp(units,'rel')
        Y_plot = Y_plot ./[DATA_MOD(i).data.p_mean] *100;
    end
    legname = ['Mod, ' num2str( DATA_MOD(i).data(1).p_mean_setpoint/1000 ) 'kPa, max'];
    p = scatter(Xmod{i}, Y_plot, 40, colors{i}, markers{3}, 'DisplayName',legname);
    plots(plots_i) = p;
    plots_i = plots_i+1;
    
    Y_plot = -dP_min_mod{i};
    if strcmp(units,'rel')
        Y_plot = Y_plot ./[DATA_MOD(i).data.p_mean] *100;
    end
    legname = ['Mod, ' num2str( DATA_MOD(i).data(1).p_mean_setpoint/1000 ) 'kPa, min'];
    p = scatter(Xmod{i}, Y_plot, 40, colors{i}, markers{4}, 'DisplayName',legname);
    plots(plots_i) = p;
    plots_i = plots_i+1;
end
legend(plots([1, 2, length(DATA_EXP)*2+1, length(DATA_EXP)*2+2]), 'Interpreter','none')
legend(plots)


%% delta_P Mean (positive and negative) vs Reynolds OR speed, incl. analytical values
figure(fig_count);
fig_count = fig_count+1;
hold on
%%%%%%%%%%%%%%
units = 'abs'; %'rel'
X_var = 'Re'; %'speed'
%%%%%%%%%%%%%%
switch units
    case 'abs'
        ylabel('\it\Deltap_{HX}\rm [Pa]')
    case 'rel'
        ylabel('Pressure Drop / P-mean [%]')
end
title('MEAN delta-P (Pressure drop): P-Exp - P-Com.')
nicefigure(figure_purpose);
plots_i = 1;
plots = [];

markers = {'o','sq','x','+','^','>'};
colors = {'k','b','g','r'};

% Calculate analytical pressure drop
ENGINE_DATA = T2_ENGINE_DATA;
HX_AR = ENGINE_DATA.cooler_slot_width/ENGINE_DATA.cooler_slot_height;
HX_AR = min([HX_AR, 1/HX_AR]);
%%%% Insert Porosity here!!!!! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Reg_beta = 0.97; 
Reg_Area = Reg_beta* pi/4*(ENGINE_DATA.regen_housing_ID^2-ENGINE_DATA.regen_matrix_ID^2);
Reg_D_h = ENGINE_DATA.regen_wire_diameter /(1-Reg_beta);
Reg_c = Reg_beta/(1-Reg_beta);
for i=1:length(DATA_EXP)
    U = (ENGINE_DATA.Vswd * 2 * [DATA_EXP(i).data.encoder_speed]/60 / ENGINE_DATA.cooler_A_cross);
    Tg_avg = mean([[DATA_EXP(i).data.Tgk_inlet]; [DATA_EXP(i).data.Tgh_inlet]]);
    rho = (([DATA_EXP(i).data.pmean]+[DATA_EXP(i).data.p_atm]) ./287 ./(Tg_avg+273.15));
    % Re = rho * D_h * V / mu
    % rho = p/(RT)
    Re_exp{i} =  rho .* ENGINE_DATA.cooler_D_h .* U ./ Visc_air(Tg_avg);
    Nf = (-43.94*HX_AR^3 +123.2*HX_AR^2 -118.31*HX_AR +96) ./ Re_exp{i}; % Friction factor, As used in MSPM, rectangular channels
    dP_HXs{i} = 2* Nf*ENGINE_DATA.cooler_length/ENGINE_DATA.cooler_D_h .*rho.*U.^2 /2; % for 2 HXs

    U_reg = (ENGINE_DATA.Vswd * 2 * [DATA_EXP(i).data.MB_speed]/60 /Reg_Area);
    Re_reg{i} = rho .* Reg_D_h .* U_reg ./ Visc_air(Tg_avg);
    Nf_reg = (25.7*Reg_c+79.8)./Re_reg{i} + (0.146*Reg_c+3.76)./(Re_reg{i}.^(0.00283*Reg_c+0.0748)); % Friction factor, As used in MSPM, random fibre
    dP_Reg{i} = Nf_reg*ENGINE_DATA.regen_length/Reg_D_h .*rho.*U_reg.^2 /2;
end
for i=1:length(DATA_MOD)
    U = (ENGINE_DATA.Vswd * 2 * [DATA_MOD(i).data.speedHz] / ENGINE_DATA.cooler_A_cross);
    Tg_avg = mean([[DATA_MOD(i).data.Tgk_inlet]; [DATA_MOD(i).data.Tgh_inlet]]);
    %%%% In this case DATA_EXP(1) has the correct p_atm! %%%%%%%%%%%%%%%%%%%
    rho = (([DATA_MOD(i).data.p_mean]+[DATA_EXP(i).data.p_atm]) ./287 ./(Tg_avg+273.15));
    Re_mod{i} =  rho .* ENGINE_DATA.cooler_D_h .* U ./ Visc_air(Tg_avg);
end

switch X_var
    case 'Re'
                xlabel('\itRe_{HX,avg}\rm (experimental estimate)')
            Xexp = Re_exp;
            Xmod = Re_exp; % changed so both match Re_exp
%              Xmod = Re_mod;
   case 'speed'
        xlabel('Speed [rpm]')
        for i=1:length(DATA_EXP)
            Xexp{i} = [DATA_EXP(i).data.MB_speed];
        end
        for i=1:length(DATA_MOD)
            Xmod{i} = [DATA_MOD(i).data.speedRPM];
        end
end

% plot all experimental datapoints. different color for each dataset.
for i = 1:length(DATA_EXP)
    %Exp absolute
    Y_plot = dP_mean_abs_exp{i};
    if strcmp(units,'rel')
        Y_plot = Y_plot ./[DATA_EXP(i).data.pmean] *100;
    end
%     legname = ['Exp, ' num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 ) 'kPa'];
    legname = 'Experiment';
    p = scatter(Xexp{i}, Y_plot, 30, colors{i}, markers{1}, 'DisplayName',legname);
%     if i==1
        plots(end+1) = p; 
%     end

%     %Exp positive
%     Y_plot = dP_mean_positive_exp{i};
%     if strcmp(units,'rel')
%         Y_plot = Y_plot ./[DATA_EXP(i).data.pmean] *100;
%     end
%     legname = ['Exp, ' num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 ) 'kPa, pos'];
%     p = scatter(Xexp{i}, Y_plot, 30, colors{i}, markers{1}, 'DisplayName',legname);
%     plots(plots_i) = p;
%     plots_i = plots_i+1;
%     
%     %Exp negative
%     Y_plot = -dP_mean_negative_exp{i};
%     if strcmp(units,'rel')
%         Y_plot = Y_plot ./[DATA_EXP(i).data.pmean] *100;
%     end
%     legname = ['Exp, ' num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 ) 'kPa, neg'];
%     p = scatter(Xexp{i}, Y_plot, 30, colors{i}, markers{2}, 'DisplayName',legname);
%     plots(plots_i) = p;
%     plots_i = plots_i+1;
    
    % Analytical HXs+Reg
    Y_plot = dP_HXs{i}+dP_Reg{i};
    if strcmp(units,'rel')
        Y_plot = Y_plot ./[DATA_EXP(i).data.pmean] *100;
    end
    legname = 'Analytical, Heat Exchangers + Regenerator';
%     legname = ['Theory, HXs+Reg, ' num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 ) 'kPa'];
    p = scatter(Xexp{i}, Y_plot, 40, colors{i}, markers{5}, 'DisplayName',legname);
%     if i==1; plots(end+1) = p; end
    
%     Y_plot = dP_HXs{i};
%     if strcmp(units,'rel')
%         Y_plot = Y_plot ./[DATA_EXP(i).data.pmean] *100;
%     end
%     legname = ['Theory, HXs, ' num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 ) 'kPa'];
%     p = scatter(X{i}, Y_plot, 40, colors{i}, markers{5}, 'DisplayName',legname);
%     plots(plots_i) = p;
%     plots_i = plots_i+1;
%     
%     Y_plot = dP_Reg{i};
%     if strcmp(units,'rel')
%         Y_plot = Y_plot ./[DATA_EXP(i).data.pmean] *100;
%     end
%     legname = ['Theory, reg, ' num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 ) 'kPa'];
%     p = scatter(X{i}, Y_plot, 40, colors{i}, markers{6}, 'DisplayName',legname);
%     plots(plots_i) = p;
%     plots_i = plots_i+1;
end
for i = 1:length(DATA_MOD)
    
    % Mod absolute
    Y_plot = dP_mean_abs_mod{i};
    if strcmp(units,'rel')
        Y_plot = Y_plot ./[DATA_MOD(i).data.p_mean] *100;
    end
    legname = 'Model';
%     legname = ['Mod, ' num2str( DATA_MOD(i).data(1).p_mean_setpoint/1000 ) 'kPa, pos'];
    p = scatter(Xmod{i}, Y_plot, 40, colors{i}, markers{3}, 'DisplayName',legname);
%     if i==1; plots(end+1) = p; end

%     % Mod positive
%     Y_plot = dP_mean_positive_mod{i};
%     if strcmp(units,'rel')
%         Y_plot = Y_plot ./[DATA_MOD(i).data.p_mean] *100;
%     end
%     legname = ['Mod, ' num2str( DATA_MOD(i).data(1).p_mean_setpoint/1000 ) 'kPa, pos'];
%     p = scatter(Xmod{i}, Y_plot, 40, colors{i}, markers{3}, 'DisplayName',legname);
%     plots(plots_i) = p;
%     plots_i = plots_i+1;
%     
%     % Mod negative
%     Y_plot = -dP_mean_negative_mod{i};
%     if strcmp(units,'rel')
%         Y_plot = Y_plot ./[DATA_MOD(i).data.p_mean] *100;
%     end
%     legname = ['Mod, ' num2str( DATA_MOD(i).data(1).p_mean_setpoint/1000 ) 'kPa, neg'];
%     p = scatter(Xmod{i}, Y_plot, 40, colors{i}, markers{4}, 'DisplayName',legname);
%     plots(plots_i) = p;
%     plots_i = plots_i+1;
end
% legend(plots([1:3, length(DATA_EXP)*3+1, length(DATA_EXP)*3+2]), 'Interpreter','none')

% LEGEND 1: symbols
% l=legend(plots);
% l.ItemTokenSize(1) = 20;

% LEGEND 2: colors
l=legend(plots, '100','200','350','450');
l.Title.String = '\itp_{set}';
l.ItemTokenSize(1) = 10;



%% delta_P Mean (positive and negative) vs Reynolds OR speed
figure(fig_count);
fig_count = fig_count+1;
hold on
%%%%%%%%%%%%%%
units = 'abs'; %'rel'
X_var = 'speed'; %'speed'
%%%%%%%%%%%%%%
switch units
    case 'abs'
        ylabel('Pressure Drop [Pa]')
    case 'rel'
        ylabel('Pressure Drop / P-mean [%]')
end
title('MEAN delta-P (Pressure drop): P-Exp - P-Com.')
nicefigure(figure_purpose);
plots_i = 1;
clear plots

markers = {'o','sq','x','+'};
colors = {'k','b','g','r'};

for i=1:length(DATA_EXP)
    U = (ENGINE_DATA.Vswd * 2 * [DATA_EXP(i).data.MB_speed]/60 / ENGINE_DATA.cooler_A_cross);
    Tg_avg = mean([[DATA_EXP(i).data.Tgk_inlet]; [DATA_EXP(i).data.Tgh_inlet]]);
    rho = (([DATA_EXP(i).data.pmean]+[DATA_EXP(i).data.p_atm]) ./287 ./(Tg_avg+273.15));
    % Re = rho * D_h * V / mu
    % rho = p/(RT)
    Re_exp{i} =  rho .* ENGINE_DATA.cooler_D_h .* U ./ Visc_air(Tg_avg);
end
for i=1:length(DATA_MOD)
    U = (ENGINE_DATA.Vswd * 2 * [DATA_MOD(i).data.speedHz] / ENGINE_DATA.cooler_A_cross);
    Tg_avg = mean([[DATA_MOD(i).data.Tgk_inlet]; [DATA_MOD(i).data.Tgh_inlet]]);
    %%%% In this case DATA_EXP(1) has the correct p_atm! %%%%%%%%%%%%%%%%%%%
    rho = (([DATA_MOD(i).data.p_mean]+[DATA_EXP(1).data.p_atm]) ./287 ./(Tg_avg+273.15));
    Re_mod{i} =  rho .* ENGINE_DATA.cooler_D_h .* U ./ Visc_air(Tg_avg);
end

switch X_var
    case 'Re'
        xlabel('\itRe_{HX,avg}\rm (experimental estimate)')
        Xexp = Re_exp;
        Xmod = Re_mod;
    case 'speed'
        xlabel('Speed [rpm]')
        for i=1:length(DATA_EXP)
            Xexp{i} = [DATA_EXP(i).data.MB_speed];
        end
        for i=1:length(DATA_MOD)
            Xmod{i} = [DATA_MOD(i).data.speedRPM];
        end
end

% plot all experimental datapoints. different color for each dataset.
for i = 1:length(DATA_EXP)   
    Y_plot = dP_mean_positive_exp{i};
    if strcmp(units,'rel')
        Y_plot = Y_plot ./[DATA_EXP(i).data.pmean] *100;
    end
    legname = ['Exp, ' num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 ) 'kPa, pos'];
    p = scatter(Xexp{i}, Y_plot, 30, colors{i}, markers{1}, 'DisplayName',legname);
    plots(plots_i) = p;
    plots_i = plots_i+1;
    
    Y_plot = -dP_mean_negative_exp{i};
    if strcmp(units,'rel')
        Y_plot = Y_plot ./[DATA_EXP(i).data.pmean] *100;
    end
    legname = ['Exp, ' num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 ) 'kPa, neg'];
    p = scatter(Xexp{i}, Y_plot, 30, colors{i}, markers{2}, 'DisplayName',legname);
    plots(plots_i) = p;
    plots_i = plots_i+1;
    
end
for i = 1%:length(DATA_MOD)
    Y_plot = dP_mean_positive_mod{i};
    if strcmp(units,'rel')
        Y_plot = Y_plot ./[DATA_MOD(i).data.p_mean] *100;
    end
    legname = ['Mod, ' num2str( DATA_MOD(i).data(1).p_mean_setpoint/1000 ) 'kPa, pos'];
    p = scatter(Xmod{i}, Y_plot, 40, colors{i}, markers{3}, 'DisplayName',legname);
    plots(plots_i) = p;
    plots_i = plots_i+1;
    
    Y_plot = -dP_mean_negative_mod{i};
    if strcmp(units,'rel')
        Y_plot = Y_plot ./[DATA_MOD(i).data.p_mean] *100;
    end
    legname = ['Mod, ' num2str( DATA_MOD(i).data(1).p_mean_setpoint/1000 ) 'kPa, neg'];
    p = scatter(Xmod{i}, Y_plot, 40, colors{i}, markers{4}, 'DisplayName',legname);
    plots(plots_i) = p;
    plots_i = plots_i+1;
end
% legend(plots([1,2, length(DATA_EXP)*2 + [1,2]]), 'Interpreter','none') % legend 1: symbols
legend(plots(1:2:end), 'Interpreter','none') % legend 2: colors


%% Crank positions with delta_P = 0, vs Reynolds OR speed
figure(fig_count);
fig_count = fig_count+1;
hold on
%%%%%%%%%%%%%%
X_var = 'Re'; %'speed'
%%%%%%%%%%%%%%
ylabel('Crank position where \it\Deltap_{HX}\rm = 0', 'FontWeight','bold')
title('Crank positions with Zero Pressure Drop')
nicefigure(figure_purpose);
plots = [];

markers = {'o','sq','x','+'};
colors = {'k','b','g','r'};

switch X_var
    case 'Re'
                xlabel('\itRe_{HX,avg}\rm (experimental estimate)')
        ENGINE_DATA = T2_ENGINE_DATA;
        for i=1:length(DATA_EXP)
            Tg_avg = mean([[DATA_EXP(i).data.Tgk_inlet]; [DATA_EXP(i).data.Tgh_inlet]]);
            % Re = rho * D_h * V / mu
            % rho = p/(RT)
            Xexp{i} =  (([DATA_EXP(i).data.pmean]+[DATA_EXP(i).data.p_atm]) ./287 ./(Tg_avg+273.15)) .* ENGINE_DATA.cooler_D_h .* (ENGINE_DATA.Vswd * 2 * [DATA_EXP(i).data.encoder_speed]/60 / ENGINE_DATA.cooler_A_cross) ./ Visc_air(Tg_avg);
        end
        Xmod = Xexp;
    case 'speed'
        xlabel('Speed [rpm]')
        for i=1:length(DATA_EXP)
            Xexp{i} = [DATA_EXP(i).data.MB_speed];
        end
        for i=1:length(DATA_MOD)
            Xmod{i} = [DATA_MOD(i).data.speedRPM];
        end
end

for i = 1:length(DATA_EXP)
    for d = 1:length(DATA_EXP(i).data)
        Y_plot = dP_zeros_exp{i,d};
        X_plot = repelem(Xexp{i}(d), length(Y_plot));
        legname = ['Exp, ' num2str( DATA_EXP(i).data(d).pmean_setpoint/1000 ) 'kPa'];
        p = scatter(X_plot, Y_plot, 30, colors{i}, markers{1}, 'DisplayName',legname);
        if d == 1 && i==1
            plots(end+1) = p;
        end
    end
end
for i = 1:length(DATA_MOD)
    for d = 1:length(DATA_MOD(i).data)
        Y_plot = dP_zeros_mod{i,d};
        X_plot = repelem(Xmod{i}(d), length(Y_plot));
        legname = ['Mod, ' num2str( DATA_MOD(i).data(1).p_mean_setpoint/1000 ) 'kPa'];
        p = scatter(X_plot, Y_plot, 40, colors{i}, markers{3}, 'DisplayName',legname);
        if d == 1 && i==1
            plots(end+1) = p;
        end
    end
end
ylim([0,360])
yticks(0:90:360)
yticklabels({'Max. Volume','Heating begins','Min. Volume','Cooling begins','Max. Volume'})
yline(90); yline(270);
% legend(plots([1, length(DATA_EXP)+1]), 'Interpreter','none')
l=legend(plots,'Experiment','Model');
l.ItemTokenSize(1) = 10;
