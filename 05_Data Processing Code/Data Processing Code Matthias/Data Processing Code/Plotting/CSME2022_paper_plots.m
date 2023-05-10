%% Indicated Work vs speed, pressure color coded, with colors in legend
figure(fig_count);
fig_count = fig_count+1;
hold on
leg_chars = 30;
xlabel('\itf\rm [rpm]')
ylabel('\itW_{ind}\rm [J]')
title('Indicated Work')
nicefigure(figure_purpose);
plots_i = 1;

colors = {'r','k','g','b'};
% colors = repmat(colors,[1,2]);
markers = {'x','+'};
markers = repelem(markers,4);
% plot all experimental datapoints. different color for each dataset.
for i= [2,1,4,3]%1:length(DATA_EXP)
    legname = 'Experiment';
    % For pressure legend
%     legname = num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 );    
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    p = scatter([DATA_EXP(i).data.encoder_speed], [DATA_EXP(i).data.Wind], 30, colors{i}, 'o', 'DisplayName',legname);
    % For pressure legend
%     plots(plots_i) = p; plots_i = plots_i+1;
    if i==1; plots(plots_i) = p; plots_i = plots_i+1; end
end
% plot all model datapoints. different color for each dataset.
% for i=1:length(DATA_MOD)
%     legname = 'Model';
% %     legname = DATA_MOD(i).name;
%         % For pressure legend
% %     legname = num2str( DATA_MOD(i).data(1).p_mean_setpoint/1000 );    
% 
%     if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
%     p = scatter([DATA_MOD(i).data.speedRPM], [DATA_MOD(i).data.Wind], 40, colors{i}, markers{1}, 'DisplayName',legname);
%     % For pressure legend, comment this out    
%     if i==1; plots(plots_i) = p; plots_i = plots_i+1; end
% end

% for i=5:length(DATA_MOD)
%     legname = ['Mod, ' num2str( DATA_MOD(i).data(1).p_mean_setpoint/1000 ) 'kPa'];
%     if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
%     p = scatter([DATA_MOD(i).data.speedRPM], [DATA_MOD(i).data.Wind], 40, colors{2}, markers{1}, 'DisplayName',legname);
%     if i==5; plots(plots_i) = p; plots_i = plots_i+1; end
% %     if any(i==[1,5]); plots(plots_i) = p; plots_i = plots_i+1; end  
% end

% ylim([0,12])
% l=legend(plots);
% l=legend('Interpreter','None');
% l.ItemTokenSize(1) = 10;
% legend('Exp','h CFD old','Dh fix','DPseal')
l=legend('A','B','C','D')
 l.ItemTokenSize(1) = 10;


%% 3D indicated work vs. 2 variables. E.g. hSource and hSink
figure(fig_count);
fig_count = fig_count+1;
hold on
leg_chars = 30;
xlabel('hSource [W/m^2K]')
ylabel('hSink [W/m^2K]')
zlabel('Indicated Work [J]')
nicefigure(figure_purpose);
plots_i = 1;

colors = {'k','b','g','r'};
% colors = repmat(colors,[1,2]);
markers = {'o','x'};
% markers = repelem(markers,4);

% plot all model datapoints. different color for each dataset.
for i=1:length(DATA_MOD)
    legname = ['Mod, ' num2str( DATA_MOD(i).data(1).p_mean_setpoint/1000 ) 'kPa'];
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    p = scatter3([DATA_MOD(i).data.h_Source], [DATA_MOD(i).data.h_Sink], [DATA_MOD(i).data.Wind], 36, colors{i}, markers{2}, 'DisplayName',legname);
%     if i==1; plots(plots_i) = p; plots_i = plots_i+1; end
%     if any(i==[1,5]); plots(plots_i) = p; plots_i = plots_i+1; end  
end

zlim([0,11])
xlim_bak = get(gca,'xlim');
ylim_bak = get(gca,'ylim');

for i= length(DATA_EXP)
    for j = 1:length(DATA_EXP(i).data)
    legname = ['Exp, ' num2str( DATA_EXP(i).data(j).pmean_setpoint/1000 ) 'kPa'];
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    surf(xlim_bak, ylim_bak, ones(2)*DATA_EXP(i).data(j).Wind, 'EdgeColor',colors{j},'FaceColor',colors{j}, 'DisplayName',legname);
    end
end
% xlim(xlim_bak)
% ylim(ylim_bak)
l=legend();
l.ItemTokenSize(1) = 10;


%% To Add p_atmosphere to processed 'RD' files
[file,path]=uigetfile('G:\Shared drives\NOBES_GROUP\MSPM\[MATLAB_WORKING_FOLDER]\Data Processing Code\06_Post Processing_Experimental\[Experimental Data]');
load(fullfile(path,file));
for i=1:length(RD_DATA)
    RD_DATA(i).p_atm=93790;
end

save(fullfile(path,file),'RD_DATA','-v7.3')

%% Ratio of Indicated Work vs speed, pressure color coded, with colors in legend
figure(fig_count);
fig_count = fig_count+1;
hold on
leg_chars = 30;
xlabel('Speed [rpm]')
ylabel('Ind. Work Ratio Model/Experiment [%]')
title('Indicated Work Ratio')
nicefigure(figure_purpose);
plots_i = 1;

colors = {'k','b','g','r'};
colors = repmat(colors,1,2);
markers = {'x','+'};
markers = repelem(markers,4);

% plot all experimental datapoints. different color for each dataset.
for i=1:length(DATA_EXP)
%     legname = [num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 ) 'kPa'];
    legname = DATA_MOD(i).name;
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    
    range = 1:min([length(DATA_EXP(i).data), length(DATA_MOD(i).data)]);
    Wind_ratio = [DATA_MOD(i).data(range).Wind] ./ [DATA_EXP(i).data(range).Wind];
    p = scatter([DATA_EXP(i).data(range).MB_speed], Wind_ratio*100, 40, colors{i}, markers{i}, 'DisplayName',legname);
    if i==1 || i==5; plots(plots_i) = p; plots_i = plots_i+1; end
end
% l=legend('Mod old','Mod new','Mod new, HX insulated')
% yline(100)
% legend(plots,{'FinConn(old)','FinEnh(new)'})
legend('Interpreter','None')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (TWO VARIABLES) Deviation in Indicated Work / Heat Flows  vs  Reynolds number OR speed
% calculate HX Reynolds numbers (mean speed, mean gas temp)
ENGINE_DATA = T2_ENGINE_DATA;
for i=1:length(DATA_EXP)

    Tg_avg = mean([[DATA_EXP(i).data.Tgk_inlet]; [DATA_EXP(i).data.Tgh_inlet]]);

% Re = rho * D_h * V / mu
    % rho = p/(RT)
    Reynolds_HX_exp{i} =  (([DATA_EXP(i).data.pmean]+[DATA_EXP(i).data.p_atm]) ./287 ./(Tg_avg+273.15)) .* ENGINE_DATA.cooler_D_h .* (ENGINE_DATA.Vswd * 2 * [DATA_EXP(i).data.encoder_speed]/60 / ENGINE_DATA.cooler_A_cross) ./ Visc_air(Tg_avg);
%     Massflow_HX{i} = (ENGINE_DATA.Vswd * 2 * [DATA_EXP(i).data.encoder_speed]/60) .* (([DATA_EXP(i).data.pmean]+[DATA_EXP(i).data.p_atm]) ./287 ./(Tg_avg+273.15));
% Using Model Re
    Reynolds_HX_mod{i} = mean( [mean([DATA_MOD(i).data.Re_cooler_center]); mean([DATA_MOD(i).data.Re_heater_center])] ); % takes mean Re of cooler and heater for each setpoitn and arranges them in 2 rows
end

figure(fig_count);
fig_count = fig_count+1;
hold on
nicefigure(figure_purpose);
plots_i = 1;
plots=[];

% ylabel('\itW_{ind}\rm Model Deviation [%]')
% ylabel('Indicator Diagram Overlap Ratio [%]')
% ylabel('\itQ_{Heater}\rm Model Deviation [%]')
% ylabel('\itQ_{Cooler}\rm Model Deviation [%]')
% ylabel('\itQ_{Heater / Cooler}\rm [W]')
% ylabel('\itQ_{Heater / Cooler}\rm Model Deviation [%]')
ylabel('Temperature Model Deviation [\circC]')
ylabel('Absolute Temperature (in K) Model Deviation [%]')

plot_exp = false; %Plot the experimental data separately?

%%%%%%%%%%%%%%%%%%%%
X_var = 'Re';
%%%%%%%%%%%%%%%%%%%%
switch X_var
    case 'Re'
                xlabel('\itRe_{HX,avg}\rm (experimental estimate)')
%         xlabel('\itRe_{HX,avg}\rm (model)')
        for i=1:length(DATA_EXP)
                        X{i} =  Reynolds_HX_exp{i}; % Use experimental Re
%             X{i} =  Reynolds_HX_mod{i}; % Use model Re
        end
        
    case 'speed'
        xlabel('\itf\rm [rpm]')
        for i=1:length(DATA_EXP)
            
            X{i} = [DATA_MOD(i).data.speedRPM];
        end
end

% Each Group has same symbols, different colors
n_sets_per_group = 4;
n_groups = ceil(length(DATA_MOD)/n_sets_per_group);
Y_store = [];

colors = {'k','b','g','r'};
colors = repmat(colors(1:n_sets_per_group), [1,n_groups]);
%  colors = repelem(colors, 2);
 markers = {'x','+','o','s'};
 markers = repelem(markers,n_sets_per_group);

% FIRST VARIABLE TO PLOT
for i=1:length(DATA_EXP)
%     legname = ['Exp, ' num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 ) 'kPa'];
    
    range = 1:min([length(DATA_EXP(i).data), length(DATA_MOD(i).data)]);
%     Y_plot = ([DATA_MOD(i).data(range).Wind] ./ [DATA_EXP(i).data(range).Wind] - 1)*100; % Wind deviation
%     Y_plot = PV_overlap_ratio{i}*100;
%     Y_plot = ([DATA_MOD(i).data(range).Qdot_fromSource] ./ [DATA_EXP(i).data(range).Qdot_heater] - 1)*100;
%     Y_plot = ([DATA_MOD(i).data(range).Qdot_toSink] ./ [DATA_EXP(i).data(range).Qdot_cooler] - 1)*100;
% Y_plot = mean([DATA_MOD(i).data(range).Tge]) - [DATA_EXP(i).data(range).Tge]; % T_e deviation
Y_plot = (mean([DATA_MOD(i).data(range).Tge]) - [DATA_EXP(i).data(range).Tge]) ./ ([DATA_EXP(i).data(range).Tge]+273.15) *100; % relative T_e deviation

% Y_plot = [DATA_MOD(i).data(range).Qdot_fromSource]; plot_exp = true; Y_exp = [DATA_EXP(i).data(range).Qdot_heater];
%     Y_plot = [DATA_MOD(i).data(range).Qdot_toSink]; plot_exp = true; Y_exp = [DATA_EXP(i).data(range).Qdot_cooler];

    % calculate average Y value for current dataset and display
    mean_dev = round(mean(abs(Y_plot)),1);
    legname = DATA_MOD(i).name + " (Mean dev "+mean_dev + "%)";
    disp("Dataset "+i+": Mean dev = "+mean_dev + "%")

    % calculate average Y value for group of datasets and display
    Y_store = [Y_store Y_plot];
    if ~rem(i,n_sets_per_group)
       group_dev = round(mean(abs(Y_store)),1);
       Y_store = [];
       disp("Group of "+n_sets_per_group+" Datasets: Mean dev = "+group_dev + "%")
    end
    
     % plotting 1st variable in red
    if plot_exp && i <= n_sets_per_group
        p = scatter(X{i}(range), Y_exp, 40, 'r', 'o', 'filled', 'DisplayName',legname);
        if i == 1
            plots(plots_i) = p;
            plots_i = plots_i+1;
        end
    end
    p = scatter(X{i}(range), Y_plot, 40, 'r', markers{i}, 'DisplayName',legname);

    if ~rem(i-1, n_sets_per_group) % Include every 1st plot of each group in legend
%     if i == 1  % For 2nd (color) legend: include only 1st plot
        plots(plots_i) = p; 
        plots_i = plots_i+1; 
%     end
    end
end
disp(newline)

% SECOND VARIABLE TO PLOT
for i=1:length(DATA_EXP)
%     legname = ['Exp, ' num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 ) 'kPa'];
    
    range = 1:min([length(DATA_EXP(i).data), length(DATA_MOD(i).data)]);
%     Y_plot = ([DATA_MOD(i).data(range).Wind] ./ [DATA_EXP(i).data(range).Wind] - 1)*100; % Wind deviation
%     Y_plot = PV_overlap_ratio{i}*100;
%     Y_plot = ([DATA_MOD(i).data(range).Qdot_fromSource] ./ [DATA_EXP(i).data(range).Qdot_heater] - 1)*100;
%     Y_plot = ([DATA_MOD(i).data(range).Qdot_toSink] ./ [DATA_EXP(i).data(range).Qdot_cooler] - 1)*100;
% Y_plot = mean([DATA_MOD(i).data(range).TgPP]) - [DATA_EXP(i).data(range).TgPP]; % T_PP deviation
Y_plot = (mean([DATA_MOD(i).data(range).TgPP]) - [DATA_EXP(i).data(range).TgPP]) ./ ([DATA_EXP(i).data(range).TgPP]+273.15) *100; % relative T_PP deviation

% Y_plot = [DATA_MOD(i).data(range).Qdot_fromSource]; plot_exp = true; Y_exp = [DATA_EXP(i).data(range).Qdot_heater];
%     Y_plot = [DATA_MOD(i).data(range).Qdot_toSink]; plot_exp = true; Y_exp = [DATA_EXP(i).data(range).Qdot_cooler];

    % calculate average Y value for current dataset and display
    mean_dev = round(mean(abs(Y_plot)),1);
    legname = DATA_MOD(i).name + " (Mean dev "+mean_dev + "%)";
    disp("Dataset "+i+": Mean dev = "+mean_dev + "%")

    % calculate average Y value for group of datasets and display
    Y_store = [Y_store Y_plot];
    if ~rem(i,n_sets_per_group)
       group_dev = round(mean(abs(Y_store)),1);
       Y_store = [];
       disp("Group of "+n_sets_per_group+" Datasets: Mean dev = "+group_dev + "%")
    end
    
    % plotting 2nd variable in blue
    %%% OPTIONAL experiment data plot
    if plot_exp && i <= n_sets_per_group
        p = scatter(X{i}(range), Y_exp, 40, 'b', 'o', 'filled', 'DisplayName',legname);
        if i == 1
            plots(plots_i) = p;
            plots_i = plots_i+1;
        end
    end
    %%% deviation plot
    p = scatter(X{i}(range), Y_plot, 40, 'b', markers{i}, 'DisplayName',legname);

    if ~rem(i-1, n_sets_per_group) % Include every 1st plot of each group in legend
%     if i == 1 % For 2nd (color) legend: include only 1st plot
        plots(plots_i) = p; 
        plots_i = plots_i+1; 
%     end
    end
end

yline(0);
% yline(100);

% LEGEND 1 (symbols)
leg_text = {'A (No_Seal_h_analytical)','B (No_Seal_h_CFD)','C (With_Seal_h_analytical)','D (With_Seal_h_CFD)'};
if plot_exp; leg_text = ['Experiment', leg_text]; end
l=legend(plots, leg_text, 'Interpreter','none');

% LEGEND 2 (colors)
% l=legend(plots, 'Heater','Cooler', 'Interpreter','none');
% l=legend(plots, '\itT_e','\itT_{PP}');


% l=legend(plots,'Interpreter','none');
% l=legend(plots, 'HX Model A','HX Model B')
% l=legend('p200','p350','p400','p450');
% l=legend('p350 h-empirical','p350 h-CFD','p350 A02 h-custom +10% to +60%')
% l=legend('Exp','Mod old','Mod new','Mod new, HX insulated','Mod new, HX insulated, 1node')
l.ItemTokenSize(1) = 20;

%% (ONE VARIABLE) Deviation in Indicated Work / Heat Flows  vs  Reynolds number OR speed
% calculate HX Reynolds numbers (mean speed, mean gas temp)
ENGINE_DATA = T2_ENGINE_DATA;
for i=1:length(DATA_EXP)

    Tg_avg = mean([[DATA_EXP(i).data.Tgk_inlet]; [DATA_EXP(i).data.Tgh_inlet]]);

% Re = rho * D_h * V / mu
    % rho = p/(RT)
    Reynolds_HX_exp{i} =  (([DATA_EXP(i).data.pmean]+[DATA_EXP(i).data.p_atm]) ./287 ./(Tg_avg+273.15)) .* ENGINE_DATA.cooler_D_h .* (ENGINE_DATA.Vswd * 2 * [DATA_EXP(i).data.encoder_speed]/60 / ENGINE_DATA.cooler_A_cross) ./ Visc_air(Tg_avg);
%     Massflow_HX{i} = (ENGINE_DATA.Vswd * 2 * [DATA_EXP(i).data.encoder_speed]/60) .* (([DATA_EXP(i).data.pmean]+[DATA_EXP(i).data.p_atm]) ./287 ./(Tg_avg+273.15));
% Using Model Re
    Reynolds_HX_mod{i} = mean( [mean([DATA_MOD(i).data.Re_cooler_center]); mean([DATA_MOD(i).data.Re_heater_center])] ); % takes mean Re of cooler and heater for each setpoitn and arranges them in 2 rows
end

figure(fig_count);
fig_count = fig_count+1;
hold on
nicefigure(figure_purpose);
plots_i = 1;
plots=[];

% ylabel('\it\eta_{shaft}\rm [%]')
% ylabel('\itP_{shaft}\rm [W]')
% ylabel('\itP_{ind}\rm [W]')
% 
ylabel('\itW_{ind}\rm [J]')
% ylabel('\itW_{ind}\rm Model Deviation [%]')
% ylabel('Indicator Diagram Overlap Ratio [%]')
% ylabel('\itQ_{Heater}\rm Model Deviation [%]')
% ylabel('\itQ_{Cooler}\rm Model Deviation [%]')
% ylabel('\itQ_{Heater}\rm [W]')
% ylabel('\itQ_{Cooler}\rm [W]')

plot_exp = false; %Plot the experimental data separately?

%%%%%%%%%%%%%%%%%%%%
X_var = 'Re';
%%%%%%%%%%%%%%%%%%%%
switch X_var
    case 'Re'
                xlabel('\itRe_{HX,avg}\rm (experimental estimate)')
%         xlabel('\itRe_{HX,avg}\rm (model)')
        for i=1:length(DATA_EXP)
%                         X{i} =  Reynolds_HX_exp{i}; % Use experimental Re
            X{i} =  Reynolds_HX_mod{i}; % Use model Re
        end
        
    case 'speed'
        xlabel('\itf\rm [rpm]')
        for i=1:length(DATA_EXP)
            
            X{i} = [DATA_MOD(i).data.speedRPM];
        end
        
    case 'scale'
        xlabel('Volume Scale Factor')
        X_Scale = sqrt([1:10, 20:10:100]);
        V_Scale = X_Scale.^2;
        for i=1:length(DATA_MOD)
            X{i} = V_Scale;
        end
end

% Each Group has same symbols, different colors
n_sets_per_group = 4;
n_groups = ceil(length(DATA_MOD)/n_sets_per_group);
Y_store = [];

colors = {'k','b','g','r'};
colors = repmat(colors(1:n_sets_per_group), [1,n_groups]);
%  colors = repelem(colors, 2);
 markers = {'x','+','o','s','<','^','>'};
 markers = repelem(markers,n_sets_per_group);

% plot all experimental datapoints. different color for each dataset.
for i=1:length(DATA_MOD)
%     legname = ['Exp, ' num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 ) 'kPa'];
    
    range = 1:length(DATA_MOD(i).data);
%     range = 1:min([length(DATA_EXP(i).data), length(DATA_MOD(i).data)]);
    
    Y_plot = [DATA_MOD(i).data(range).Wind]; plot_exp = true; Y_exp = [DATA_EXP(i).data(range).Wind];
%     % Indicated Power
%     Y_plot = [DATA_MOD(i).data(range).Wind].*[DATA_MOD(i).data(range).speedHz]; plot_exp = true; Y_exp = [DATA_EXP(i).data(range).Wind].*[DATA_EXP(i).data(range).encoder_speed]/60;
%     Y_plot = [DATA_MOD(i).data(range).Wind].*[DATA_MOD(i).data(range).speedHz];
    % Shaft Power
%     Y_plot = [DATA_MOD(i).data(range).P_shaft]; plot_exp = true; Y_exp = [DATA_EXP(i).data(range).P_shaft_tsensor];
    % Shaft efficiency
%     Y_plot = [DATA_MOD(i).data(range).efficiency_shaft]*100; plot_exp = true; Y_exp = [DATA_EXP(i).data(range).efficiency_shaft]*100;    
    
%     Y_plot = ([DATA_MOD(i).data(range).Wind] ./ [DATA_EXP(i).data(range).Wind] - 1)*100; % Wind deviation
%     Y_plot = PV_overlap_ratio{i}*100;
%     Y_plot = ([DATA_MOD(i).data(range).Qdot_fromSource] ./ [DATA_EXP(i).data(range).Qdot_heater] - 1)*100;
%     Y_plot = ([DATA_MOD(i).data(range).Qdot_toSink] ./ [DATA_EXP(i).data(range).Qdot_cooler] - 1)*100;

% Y_plot = [DATA_MOD(i).data(range).Qdot_fromSource]; plot_exp = true; Y_exp = [DATA_EXP(i).data(range).Qdot_heater];
%     Y_plot = [DATA_MOD(i).data(range).Qdot_toSink]; plot_exp = true; Y_exp = [DATA_EXP(i).data(range).Qdot_cooler];

    % calculate average Y value for current dataset and display
    mean_dev = round(mean(abs(Y_plot)));
    legname = DATA_MOD(i).name + " (Mean dev "+mean_dev + "%)";
    disp("Dataset "+i+": Mean dev = "+mean_dev + "%")

    % calculate average Y value for group of datasets and display
    Y_store = [Y_store Y_plot];
    if ~rem(i,n_sets_per_group)
       group_dev = round(mean(abs(Y_store)));
       Y_store = [];
       disp("Group of "+n_sets_per_group+" Datasets: Mean dev = "+group_dev + "%")
    end
    
    if plot_exp && i <= n_sets_per_group
        p = scatter(X{i}(range), Y_exp, 40, colors{i}, 'o', 'filled', 'DisplayName',legname);
        if i == 1
            plots(plots_i) = p;
            plots_i = plots_i+1;
        end
    end
    p = scatter(X{i}(range), Y_plot, 40, colors{i}, markers{i}, 'DisplayName',legname);

    % To just plot Wind
    %      p = scatter(X{i}(range), [DATA_MOD(i).data(range).Wind], 40, colors{i}, markers{i}, 'DisplayName',legname);
   
%     p = scatter(X{i}(1:2), Y_plot(1:2)*100, 40, 'k', markers{i}, 'DisplayName',legname);
%     p = scatter(X{i}(3:4), Y_plot(3:4)*100, 40, 'b', markers{i}, 'DisplayName',legname);
%     p = scatter(X{i}(5:6), Y_plot(5:6)*100, 40, 'g', markers{i}, 'DisplayName',legname);
%     p = scatter(X{i}(7:8), Y_plot(7:8)*100, 40, 'r', markers{i}, 'DisplayName',legname);

    if ~rem(i-1, n_sets_per_group) % Include every 1st plot of each group in legend
        plots(plots_i) = p; 
        plots_i = plots_i+1; 
    end
end
yline(0);
% yline(100);
% ylim([0 40])

% leg_text = {'A (No_Seal_h_analytical)','B (No_Seal_h_CFD)','C (With_Seal_h_analytical)','D (With_Seal_h_CFD)','Tube Bank Gamma Oct13','Tube Bank Gamma h_custom','Tube Bank Gamma corrected'};
leg_text = {'A (No_Seal_h_analytical)','B (No_Seal_h_CFD)','C (With_Seal_h_analytical)','D (With_Seal_h_CFD)'};


if plot_exp; leg_text = ['Experiment', leg_text]; end
l=legend(plots, leg_text, 'Interpreter','none');
l=legend(leg_text, 'Interpreter','none');
% l=legend(plots, 'Experiment','A (No_Seal_h_analytical)','B (No_Seal_h_CFD)','C (With_Seal_h_analytical)','D (With_Seal_h_CFD)', 'Interpreter','none');

% l=legend(plots,'Interpreter','none');
% l=legend(plots, 'HX Model A','HX Model B')
% l=legend('p200','p350','p400','p450');
% l=legend('p350 h-empirical','p350 h-CFD','p350 A02 h-custom +10% to +60%')
% l=legend('Exp','Mod old','Mod new','Mod new, HX insulated','Mod new, HX insulated, 1node')
l.ItemTokenSize(1) = 20;

%% (Re_mod vs Re_exp) deviation over Re_exp
figure
hold on
nicefigure(figure_purpose);
plots_i = 1;
plots=[];

n_sets_per_group = 4;
n_groups = ceil(length(DATA_MOD)/n_sets_per_group);

colors = {'k','b','g','r'};
colors = repmat(colors(1:n_sets_per_group), [1,n_groups]);
markers = {'x','+','o','s'};
markers = repelem(markers,n_sets_per_group);

for i = 1:length(Reynolds_HX_exp)
    Y_plot = Reynolds_HX_mod{i}./Reynolds_HX_exp{i} -1;
    p = scatter(Reynolds_HX_exp{i}, Y_plot*100, 40, colors{i}, markers{i});
    
    if ~rem(i-1, n_sets_per_group)
        plots(plots_i) = p;
        plots_i = plots_i+1;
    end
end
yline(0);
l=legend(plots, 'A (No_Seal_h_analytical)','B (No_Seal_h_CFD)','C (With_Seal_h_analytical)','D (With_Seal_h_CFD)', 'Interpreter','none');
xlabel('\itRe_{HX,avg}\rm (estimate)')
ylabel('\itRe_{HX,avg}\rm deviation, model vs. estimate [%]')
l.ItemTokenSize(1) = 20;



%% plotting Re_exp and Re_mod for comparison (OLD)
figure
hold on
colors = {'k','b','g','r'};
plots = [];
for i=1:length(Reynolds_HX_exp)
%     p1 = scatter((1:length(Reynolds_HX_exp{i})), Reynolds_HX_exp{i}, 40, colors{i}, 'o');
%     p2 = scatter((1:length(Reynolds_HX_mod{i})), Reynolds_HX_mod{i}, 40, colors{i}, 'x');
%     p3 = scatter((1:length(Reynolds_HX_mod{i})), Reynolds_HX_mod{i} /0.407, 40, colors{i}, '+'); %with porosity correction for face area in model 
    p1 = plot((1:length(Reynolds_HX_exp{i})), Reynolds_HX_exp{i}, ['-o' colors{i}]);
    p2 = plot((1:length(Reynolds_HX_mod{i})), Reynolds_HX_mod{i}, ['-x' colors{i}]);
    p3 = plot((1:length(Reynolds_HX_mod{i})), Reynolds_HX_mod{i} /0.407, ['->' colors{i}]); %with porosity correction for face area in model 
   if i == 1; plots = [plots p1 p2 p3]; end
end
legend(plots, 'exp','mod','mod corrected')
xlabel('Setpoint no. (high->low speed)')
ylabel('Re')

%% 3D Deviation of indicated work vs. 2 variables. E.g. hSource and hSink
figure(fig_count);
fig_count = fig_count+1;
hold on
xlabel('\ith_{Source}\rm [W/m^2K]')
ylabel('\ith_{Sink}\rm [W/m^2K]')
% zlabel('\itW_{ind}\rm Model Deviation [%]')
% zlabel('\itQ_{Source}\rm Model Deviation [%]')
zlabel('\itQ_{Sink}\rm Model Deviation [%]')
nicefigure(figure_purpose);

colors = {'b','r'};
% colors = repmat(colors,[1,2]);
markers = {'o','x'};
% markers = repelem(markers,4);

% plot all model datapoints. different color for each dataset.
% for i=1:length(DATA_MOD)
%     legname = [num2str( DATA_MOD(i).data(1).p_mean_setpoint/1000 ) 'kPa, ' num2str( round(DATA_MOD(i).data(1).speedRPM)) 'rpm'];
% 
%     Y_plot = ([DATA_MOD(i).data.Wind] ./ [DATA_EXP(1).data(i).Wind] - 1)*100; % Specifically for length(DATA_EXP)=1
% %     Y_plot = ([DATA_MOD(i).data.Qdot_fromSource] ./ [DATA_EXP(1).data(i).Qdot_heater] - 1)*100; % Specifically for length(DATA_EXP)=1
% %     Y_plot = ([DATA_MOD(i).data.Qdot_toSink] ./ [DATA_EXP(1).data(i).Qdot_cooler] - 1)*100; % Specifically for length(DATA_EXP)=1
%     p(i) = scatter3([DATA_MOD(i).data.h_Source], [DATA_MOD(i).data.h_Sink], Y_plot, 36, colors{i}, markers{2}, 'DisplayName',legname);
% %     if i==1; plots(plots_i) = p; plots_i = plots_i+1; end
% %     if any(i==[1,5]); plots(plots_i) = p; plots_i = plots_i+1; end  
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alternative: plot only ONE surface showing the RSS deviation from all datapoints.
legname = 'RSS deviation (';
Dev_data=[];
for i=1:length(DATA_MOD)
%     Dev_data(i,:) = ([DATA_MOD(i).data.Wind] ./ [DATA_EXP(1).data(i).Wind] - 1)*100; % Specifically for length(DATA_EXP)=1
%     Dev_data(i,:) = ([DATA_MOD(i).data.Qdot_fromSource] ./ [DATA_EXP(1).data(i).Qdot_heater] - 1)*100; 
    Dev_data(i,:) = ([DATA_MOD(i).data.Qdot_toSink] ./ [DATA_EXP(1).data(i).Qdot_cooler] - 1)*100;
    legname = [legname num2str( DATA_MOD(i).data(1).p_mean_setpoint/1000 ) 'kPa/' num2str( round(DATA_MOD(i).data(1).speedRPM)) 'rpm, '];
end
    legname = [legname(1:end-2) ')'];
    legname = 'RSS deviation (2 setpoints)';

    setpoint_diff = abs(Dev_data(1,:)-Dev_data(2,:)); %difference in deviation between setpoints as second variable to plot
    Y_plot = rssq(Dev_data);
%     Y_plot = ([DATA_MOD(i).data.Qdot_fromSource] ./ [DATA_EXP(1).data(i).Qdot_heater] - 1)*100; % Specifically for length(DATA_EXP)=1
%     Y_plot = ([DATA_MOD(i).data.Qdot_toSink] ./ [DATA_EXP(1).data(i).Qdot_cooler] - 1)*100; % Specifically for length(DATA_EXP)=1
    p(1) = scatter3([DATA_MOD(i).data.h_Source], [DATA_MOD(i).data.h_Sink], Y_plot, 55, 'b', 'x', 'DisplayName',legname);
    p(2) = scatter3([DATA_MOD(i).data.h_Source], [DATA_MOD(i).data.h_Sink], setpoint_diff, 36, 'r', 'o', 'DisplayName','Difference in Deviation (DD)');
    
    % highlight the h's of the model variants
    % h_analytical %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     source_highlight = 80;
%     sink_highlight = 380;
%     i_highlight = find([DATA_MOD(i).data.h_Source]==source_highlight & [DATA_MOD(i).data.h_Sink]==sink_highlight);
% %     p(3) = scatter3(source_highlight, sink_highlight, Y_plot(i_highlight), 55,'m','x', 'LineWidth',1,'DisplayName','\ith_{analytical}');
% %     scatter3(source_highlight, sink_highlight, setpoint_diff(i_highlight), 36,'m','o', 'filled','LineWidth',1,'DisplayName','\ith_{analytical}');
%     p(3) = scatter3([1 1]*source_highlight, [1 1]*sink_highlight, [Y_plot(i_highlight), setpoint_diff(i_highlight)], 36,'o', 'MarkerEdgeColor','k','MarkerFaceColor','m','DisplayName','\ith_{analytical}\rm estimate');
     % h_CFD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    source_highlight = 280;
    sink_highlight = 710;
    i_highlight = find([DATA_MOD(i).data.h_Source]==source_highlight & [DATA_MOD(i).data.h_Sink]==sink_highlight);
%     p(4) = scatter3(source_highlight, sink_highlight, Y_plot(i_highlight), 55,'g','x', 'LineWidth',1,'DisplayName','\ith_{CFD}');
%     scatter3(source_highlight, sink_highlight, setpoint_diff(i_highlight), 36,'g','o', 'filled','LineWidth',1,'DisplayName','\ith_{CFD}');
    p(3) = scatter3([1 1]*source_highlight, [1 1]*sink_highlight, [Y_plot(i_highlight), setpoint_diff(i_highlight)], 36,'o', 'MarkerEdgeColor','k','MarkerFaceColor','g', 'DisplayName','\ith_{CFD}\rm estimate');
   %     if i==1; plots(plots_i) = p; plots_i = plots_i+1; end
%     if any(i==[1,5]); plots(plots_i) = p; plots_i = plots_i+1; end  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% lines of constant h_sink to view when looking at deviation vs. h_source
for i=1%:length(DATA_MOD) % For RSS plot, i=1
    
    % OPTION 1: Plot lines of constant h_Sink, over hSource
    constant_var = [DATA_MOD(i).data.h_Sink];
    varying_var = [DATA_MOD(i).data.h_Source];
    varying_ax = 'X';
    
%     % OPTION 2: Plot lines of constant h_Source, over hSink
%     varying_var = [DATA_MOD(i).data.h_Sink];
%     constant_var = [DATA_MOD(i).data.h_Source];
%     varying_ax = 'Y';

%     Z_var = ([DATA_MOD(i).data.Wind] ./ [DATA_EXP(1).data(i).Wind] - 1)*100;
%     Z_var = ([DATA_MOD(i).data.Qdot_fromSource] ./ [DATA_EXP(1).data(i).Qdot_heater] - 1)*100;
%     Z_var = ([DATA_MOD(i).data.Qdot_toSink] ./ [DATA_EXP(1).data(i).Qdot_cooler] - 1)*100;
    Z_var{1} = Y_plot; % For RSS plot
    Z_var{2} = setpoint_diff;
    %%%%%%%%%%%%%%%%%%%%%%
    text_left_side = [0,1]; % whether text will be shown left of line (instead of right), for each z vaiable
    %%%%%%%%%%%%%%%%%%%%%%
    
    vals = unique(constant_var);
    for j=1:length(vals)
        inds = find(constant_var == vals(j));
        [varying_var_plot, i_sort] = sort(varying_var(inds));
        
        for z=1:length(Z_var) % plot lines for each z variable
        Z_var_plot = Z_var{z}(inds);
        Z_var_plot = Z_var_plot(i_sort);
        
        text_var = constant_var(inds(1));
        if text_left_side(z)
                text_Z = Z_var_plot(1);
            else
                text_Z = Z_var_plot(end);
        end
        % Enter amounts to shift individual text fields in Z direction so
        % they don't overlap
        switch text_var
%             case 280
%                 text_Z = text_Z +0.5;               
        end
        % Enter amount by which to extend the right side plot limit to have
        % space for the text
        extra_space_Y = 0;
        
        switch varying_ax
            case 'X'
                plot3(varying_var_plot, constant_var(inds), Z_var_plot, colors{z});
                if text_left_side(z)
                    text(varying_var_plot(1)-5, text_var, text_Z, num2str(text_var) ,'Color',colors{z}, 'HorizontalAlignment','right');
                else
                    text(varying_var_plot(end)+5, text_var, text_Z, num2str(text_var) ,'Color',colors{z});
                end
                if j==1; xlim(get(gca,'xlim')+[0, extra_space_Y]); end
            case 'Y'
                plot3(constant_var(inds), varying_var_plot, Z_var_plot, colors{z});
                if text_left_side(z)
                    text(text_var, varying_var_plot(1)-5, text_Z, num2str(text_var) ,'Color',colors{z}, 'HorizontalAlignment','right');
                else
                    text(text_var, varying_var_plot(end)+5, text_Z, num2str(text_var) ,'Color',colors{z});
                end
                if j==1; ylim(get(gca,'ylim')+[0, extra_space_Y]); end
        end
        end
    end
end
% zlim([0,20])

% black surface at z=0
% xlim_bak = get(gca,'xlim');
% ylim_bak = get(gca,'ylim');
% surf(xlim_bak, ylim_bak, zeros(2), 'EdgeColor','k','FaceColor','k');

zlim_bak = get(gca,'zlim');
zlim([0,zlim_bak(2)])

grid on
l=legend(p);
l.ItemTokenSize(1) = 10;

%% Ratio of Indicated Work vs Reynolds number, pressure color coded, with colors in legend
% calculate HX Reynolds numbers (mean speed, mean gas temp)
ENGINE_DATA = T2_ENGINE_DATA;
for i=1:length(DATA_EXP)
    Tg_avg = mean([[DATA_EXP(i).data.Tgk_inlet]; [DATA_EXP(i).data.Tgh_inlet]]);

% Re = rho * D_h * V / mu
    % rho = p/(RT)
    Reynolds_HX{i} =  (([DATA_EXP(i).data.pmean]+[DATA_EXP(i).data.p_atm]) ./287 ./(Tg_avg+273.15)) .* ENGINE_DATA.cooler_D_h .* (ENGINE_DATA.Vswd * 2 * [DATA_EXP(i).data.MB_speed]/60 / ENGINE_DATA.cooler_A_cross) ./ Visc_air(Tg_avg);
    Massflow_HX{i} = (ENGINE_DATA.Vswd * 2 * [DATA_EXP(i).data.MB_speed]/60) .* (([DATA_EXP(i).data.pmean]+[DATA_EXP(i).data.p_atm]) ./287 ./(Tg_avg+273.15));
end

figure(fig_count);
fig_count = fig_count+1;
hold on
leg_chars = 30;
xlabel('Reynolds Number (HX Avg)')
ylabel('Ind. Work Ratio Model/Experiment [%]')
title('Indicated Work')
nicefigure(figure_purpose);
plots_i = 1;

% colors = {'k','b','g','r'};
% plot all experimental datapoints. different color for each dataset.
for i=1:length(DATA_EXP)
    legname = ['Exp, ' num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 ) 'kPa'];
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    
    range = 1:min([length(DATA_EXP(i).data), length(DATA_MOD(i).data)]);
    Wind_ratio = [DATA_MOD(i).data(range).Wind] ./ [DATA_EXP(i).data(range).Wind_exp];
    p = scatter(Reynolds_HX{i}(range), Wind_ratio*100, 40, colors{i}, markers{i}, 'DisplayName',legname);
    if i==1; plots(plots_i) = p; plots_i = plots_i+1; end
end

yline(100);
l=legend
% l=legend('Exp','Mod old','Mod new','Mod new, HX insulated','Mod new, HX insulated, 1node')
l.ItemTokenSize(1) = 10;


% % Looks same when plotted over Mass flow rate, since (Re = const * mdot) if
% % mu=const.
% figure(fig_count);
% fig_count = fig_count+1;
% hold on
% leg_chars = 30;
% xlabel('Avg. Mass Flow Rate [kg/s]')
% ylabel('Ind. Work Ratio Model/Experiment [%]')
% title('Indicated Work')
% nicefigure(figure_purpose);
% plots_i = 1;
% 
% colors = {'k','b','g','r'};
% % plot all experimental datapoints. different color for each dataset.
% for i=1:length(DATA_EXP)
%     legname = ['Exp, ' num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 ) 'kPa'];
%     if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
%     
%     Wind_ratio = [DATA_MOD(i).data.Wind] ./ [DATA_EXP(i).data.Wind_exp];
%     p = scatter(Massflow_HX{i}, Wind_ratio*100, 40, colors{i}, 'x', 'DisplayName',legname);
%     if i==1; plots(plots_i) = p; plots_i = plots_i+1; end
% end
% yline(100);

%% Eff vs speed, pressure color coded, with colors in legend
figure(fig_count);
fig_count = fig_count+1;
hold on
leg_chars = 30;
xlabel('Speed [rpm]')
ylabel('Indicated Efficiency [%]')
title('Efficiency (indicated)')
nicefigure(figure_purpose);
plots_i = 1;

colors = {'r','b'};
% colors = repmat(colors,[1,2]);
colors = repelem(colors,4);
markers = {'x','+'};
markers = repelem(markers,4);

% plot all experimental datapoints. different color for each dataset.
for i=1:4%length(DATA_EXP)
    legname = ['Exp, ' num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 ) 'kPa'];
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    p = scatter([DATA_EXP(i).data.MB_speed], [DATA_EXP(i).data.efficiency_ind]*100, 30, 'k', 'o', 'DisplayName',legname);
    if i==1; plots(plots_i) = p; plots_i = plots_i+1; end
end

% plot all model datapoints. different color for each dataset.
for i=1:length(DATA_MOD)
    legname = ['Mod, ' num2str( DATA_MOD(i).data(1).p_mean_setpoint/1000 ) 'kPa'];
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    p = scatter([DATA_MOD(i).data.speedRPM], [DATA_MOD(i).data.efficiency_ind]*100, 40, colors{i}, 'x', 'DisplayName',legname);
    if i==1 || i==5; plots(plots_i) = p; plots_i = plots_i+1; end  
end

% legend('Interpreter', 'none')
% colormap(jet(10))
% axis tight
l=legend(plots, 'Experiment','Model, HX A','Model, HX B')
l.ItemTokenSize(1) = 10;

xlim([110,250])
xticks(110:20:250)
ylim([0,4])


%% Source Heat Flow Rate vs speed, pressure color coded, with colors in legend
figure(fig_count);
fig_count = fig_count+1;
hold on
leg_chars = 30;
xlabel('Speed [rpm]')
ylabel('Source Heat Flow [W]')
nicefigure(figure_purpose);
plots_i = 1;

colors = {'r','b'};
% colors = repmat(colors,[1,2]);
colors = repelem(colors,4);
markers = {'x','+'};
markers = repelem(markers,4);

% plot all experimental datapoints. different color for each dataset.
for i=1:4%length(DATA_EXP)
    legname = ['Exp, ' num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 ) 'kPa'];
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    p = scatter([DATA_EXP(i).data.MB_speed], [DATA_EXP(i).data.Qdot_heater], 30, 'k', 'o', 'DisplayName',legname);
    if i==1; plots(plots_i) = p; plots_i = plots_i+1; end
end

% plot all model datapoints. different color for each dataset.
for i=1:length(DATA_MOD)
    legname = ['Mod, ' num2str( DATA_MOD(i).data(1).p_mean_setpoint/1000 ) 'kPa'];
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    p = scatter([DATA_MOD(i).data.speedRPM], [DATA_MOD(i).data.Qdot_fromSource], 40, colors{i}, 'x', 'DisplayName',legname);
    if i==1 || i==5; plots(plots_i) = p; plots_i = plots_i+1; end  
end

% legend('Interpreter', 'none')
% colormap(jet(10))
% axis tight
l=legend(plots, 'Experiment','Model, HX A','Model, HX B');
l.ItemTokenSize(1) = 10;

xlim([110,250])
xticks(110:20:250)
% ylim([0,4])

%% New Eff Plots, not in CSME paper %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Eff vs Reynolds Number, pressure color coded, with colors in legend
% calculate HX Reynolds numbers (mean speed, mean gas temp)
ENGINE_DATA = T2_ENGINE_DATA;
for i=1:length(DATA_EXP)
    Tg_avg = mean([[DATA_EXP(i).data.Tgk_inlet]; [DATA_EXP(i).data.Tgh_inlet]]);

% Re = rho * D_h * V / mu
    % rho = p/(RT)
    Reynolds_HX{i} =  (([DATA_EXP(i).data.pmean]+[DATA_EXP(i).data.p_atm]) ./287 ./(Tg_avg+273.15)) .* ENGINE_DATA.cooler_D_h .* (ENGINE_DATA.Vswd * 2 * [DATA_EXP(i).data.MB_speed]/60 / ENGINE_DATA.cooler_A_cross) ./ Visc_air(Tg_avg);
    Massflow_HX{i} = (ENGINE_DATA.Vswd * 2 * [DATA_EXP(i).data.MB_speed]/60) .* (([DATA_EXP(i).data.pmean]+[DATA_EXP(i).data.p_atm]) ./287 ./(Tg_avg+273.15));
end

figure(fig_count);
fig_count = fig_count+1;
hold on
leg_chars = 30;
xlabel('Reynolds Number (HX Avg)')
ylabel('Indicated Efficiency [%]')
title('Efficiency (indicated)')
nicefigure(figure_purpose);
plots_i = 1;

% plot all experimental datapoints. different color for each dataset.
for i=1:length(DATA_EXP)
    legname = ['Exp, ' num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 ) 'kPa'];
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    p = scatter(Reynolds_HX{i}, [DATA_EXP(i).data.efficiency_ind]*100, 30, colors{i}, 'o', 'DisplayName',legname);
    if i==1; plots(plots_i) = p; plots_i = plots_i+1; end
end

% plot all model datapoints. different color for each dataset.
for i=1:length(DATA_MOD)
    legname = ['Mod, ' num2str( DATA_MOD(i).data(1).p_mean_setpoint/1000 ) 'kPa'];
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    p = scatter(Reynolds_HX{i}, [DATA_MOD(i).data.efficiency_ind]*100, 40, colors{i}, 'x', 'DisplayName',legname);
    if i==1; plots(plots_i) = p; plots_i = plots_i+1; end  
end

% legend('Interpreter', 'none')
% colormap(jet(10))
% axis tight
l=legend(plots);
l.ItemTokenSize(1) = 10;


%% Deviation in Efficiency vs Reynolds Number, pressure color coded, with colors in legend
% calculate HX Reynolds numbers (mean speed, mean gas temp)
ENGINE_DATA = T2_ENGINE_DATA;
for i=1:length(DATA_EXP)
    Tg_avg = mean([[DATA_EXP(i).data.Tgk_inlet]; [DATA_EXP(i).data.Tgh_inlet]]);

% Re = rho * D_h * V / mu
    % rho = p/(RT)
    Reynolds_HX{i} =  (([DATA_EXP(i).data.pmean]+[DATA_EXP(i).data.p_atm]) ./287 ./(Tg_avg+273.15)) .* ENGINE_DATA.cooler_D_h .* (ENGINE_DATA.Vswd * 2 * [DATA_EXP(i).data.MB_speed]/60 / ENGINE_DATA.cooler_A_cross) ./ Visc_air(Tg_avg);
    Massflow_HX{i} = (ENGINE_DATA.Vswd * 2 * [DATA_EXP(i).data.MB_speed]/60) .* (([DATA_EXP(i).data.pmean]+[DATA_EXP(i).data.p_atm]) ./287 ./(Tg_avg+273.15));
end

figure(fig_count);
fig_count = fig_count+1;
hold on
leg_chars = 30;
xlabel('Reynolds Number (Heat Exchanger average)')
ylabel('Efficiency - Model Deviation [%]')
title('Efficiency (indicated)')
nicefigure(figure_purpose);
plots_i = 1;

 colors = {'k','b','g','r'};
 colors = repmat(colors, [1,2]);
 markers = {'x','+'};
 markers = repelem(markers,4);

% plot all experimental datapoints. different color for each dataset.
for i=1:length(DATA_EXP)
    legname = ['Exp, ' num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 ) 'kPa'];
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    
    range = 1:min([length(DATA_EXP(i).data), length(DATA_MOD(i).data)]);
    Eff_ratio = [DATA_MOD(i).data(range).efficiency_ind] ./ [DATA_EXP(i).data(range).efficiency_ind] - 1;
    p = scatter(Reynolds_HX{i}, Eff_ratio*100, 40, colors{i}, markers{i}, 'DisplayName',legname);
    if i==1 || i==5; plots(plots_i) = p; plots_i = plots_i+1; end
end

yline(0);
l=legend(plots, 'HX Model A','HX Model B')
%  axis tight
l.ItemTokenSize(1) = 10;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

markers = {'x','+'};
markers = repelem(markers,3);

% plot all model datapoints. different color for each dataset.
for i=1:size(PV_overlap_ratio, 1)
    scatter([DATA_MOD(i).data.speedRPM], PV_overlap_ratio{i}*100, 40, colors{i},markers{1})
    legname = DATA_MOD(i).name;
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    legstr{i} = legname;

end
% legend(legstr, 'Interpreter', 'none')
l=legend('200 kPa','350 kPa','400 kPa','450 kPa', 'Location','northoutside');
l.ItemTokenSize(1) = 10;
% scatter([RD_DATA.MB_speed], PV_overlap_ratio*100, 30, [RD_DATA.pmean]./1000,'x')
