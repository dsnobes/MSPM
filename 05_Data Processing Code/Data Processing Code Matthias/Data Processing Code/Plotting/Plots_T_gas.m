%% Temperatures %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Gas Temps vs location, scatter plot, pressure as color
figure(fig_count);
fig_count = fig_count+1;
hold on
ylabel('Gas Temperature [\circC]')
% legend('Interpreter', 'none')
title('Gas Temperatures (TC)')
colormap(jet)
c=colorbar;
ylabel(c,'Setpoint Pressure [kPa]')
nicefigure(figure_purpose);

% Change plot color order so that each color is repeated n times.
% C = get(gca,'ColorOrder');
% magenta = [1 0 1];
% black = [0 0 0];
% green = [0 1 0];
% C = [C; magenta; black; green];
% % C = repelem(C, n_color_repeat, 1);
% set(gca,'ColorOrder',C);
% 

markersMOD = {'x','>'};
for i=1:length(DATA_MOD)
    n = 0; % Position number = X values
    nd = length(DATA_MOD(i).data);
    
    scatter(repelem(n,nd) , mean([DATA_MOD(i).data.Tge]), 40, [DATA_MOD(i).data.p_mean_setpoint]/1000, markersMOD{i}, 'DisplayName','Tge'); n = n+1;
    scatter(repelem(n,nd) , mean([DATA_MOD(i).data.Tgh_inlet]), 40, [DATA_MOD(i).data.p_mean_setpoint]/1000, markersMOD{i}, 'DisplayName','Tge'); n = n+1;
    scatter(repelem(n,nd) , mean([DATA_MOD(i).data.Tgh_center]), 40, [DATA_MOD(i).data.p_mean_setpoint]/1000, markersMOD{i}, 'DisplayName','Tge'); n = n+1;
    scatter(repelem(n,nd) , mean([DATA_MOD(i).data.Tgh_reg]), 40, [DATA_MOD(i).data.p_mean_setpoint]/1000, markersMOD{i}, 'DisplayName','Tge'); n = n+1;

    scatter(repelem(n,nd) , mean([DATA_MOD(i).data.Tgr_center]), 40, [DATA_MOD(i).data.p_mean_setpoint]/1000, markersMOD{i}, 'DisplayName','Tge'); n = n+1;

    scatter(repelem(n,nd) , mean([DATA_MOD(i).data.Tgk_reg]), 40, [DATA_MOD(i).data.p_mean_setpoint]/1000, markersMOD{i}, 'DisplayName','Tge'); n = n+1;
    scatter(repelem(n,nd) , mean([DATA_MOD(i).data.Tgk_center]), 40, [DATA_MOD(i).data.p_mean_setpoint]/1000, markersMOD{i}, 'DisplayName','Tge'); n = n+1;
    scatter(repelem(n,nd) , mean([DATA_MOD(i).data.Tgk_inlet]), 40, [DATA_MOD(i).data.p_mean_setpoint]/1000, markersMOD{i}, 'DisplayName','Tge'); n = n+1;
    scatter(repelem(n,nd) , mean([DATA_MOD(i).data.Tgc]), 40, [DATA_MOD(i).data.p_mean_setpoint]/1000, markersMOD{i}, 'DisplayName','Tge'); n = n+1;

    scatter(repelem(n,nd) , mean([DATA_MOD(i).data.TgPP]), 40, [DATA_MOD(i).data.p_mean_setpoint]/1000, markersMOD{i}, 'DisplayName','Tge'); n = n+1;

%     scatter(x, mean([DATA_MOD(i).data.TgCC]), 40, C(8,:), markersMOD{i},'DisplayName','TgCC') 

end

xticklabels(["Exp","H-Inlet","H-Center","H-Reg","Reg-Center","C-Reg","C-Center","C-Inlet","Com","PP"])

%% Gas Temps vs location, scatter plot, Reynolds as color
figure(fig_count);
fig_count = fig_count+1;
hold on
ylabel('Gas Temperature [\circC]')
% legend('Interpreter', 'none')
title('Gas Temperatures (TC)')
colormap(jet)
c=colorbar;
ylabel(c,'Reynolds Number')
nicefigure(figure_purpose);
% ENGINE_DATA = T2_ENGINE_DATA;
% for i=1:length(DATA_MOD)
% %     if i==1
% %         A_cross = ENGINE_DATA.cooler_A_cross;
% %     else
% %         A_cross = 
%     U = (ENGINE_DATA.Vswd * 2 * [DATA_MOD(i).data.speedHz] / ENGINE_DATA.cooler_A_cross);
%     Tg_avg = mean([[DATA_MOD(i).data.Tgk_inlet]; [DATA_MOD(i).data.Tgh_inlet]]);
%     %%%% In this case DATA_EXP(1) has the correct p_atm! %%%%%%%%%%%%%%%%%%%
%     rho = (([DATA_MOD(i).data.p_mean]+[DATA_EXP(1).data.p_atm]) ./287 ./(Tg_avg+273.15));%In this case DATA_EXP(1) has the correct p_atm!
%     Re_mod{i} =  rho .* ENGINE_DATA.cooler_D_h .* U ./ Visc_air(Tg_avg);
% end

markersMOD = {'x','o','<'};
markersizeMOD = [70,70,70];
leg_plots = [];
for i=1:length(DATA_MOD)
    n = 0; % Position number = X values
    nd = length(DATA_MOD(i).data);
    Re_mod = [mean([DATA_MOD(i).data.Re_cooler_center]); mean([DATA_MOD(i).data.Re_heater_center])]; % takes mean Re of cooler and heater for each setpoitn and arranges them in 2 rows
    Re_mod = mean(Re_mod); % overall mean Re for each setpoint (1 row)
    
    leg_plots(end+1) = scatter(repelem(n,nd) , mean([DATA_MOD(i).data.Tge]), markersizeMOD(i), Re_mod, markersMOD{i}, 'DisplayName','Tge'); n = n+1;
    scatter(repelem(n,nd) , mean([DATA_MOD(i).data.Tgh_inlet]), markersizeMOD(i), Re_mod, markersMOD{i}, 'DisplayName','Tge'); n = n+1;
    scatter(repelem(n,nd) , mean([DATA_MOD(i).data.Tgh_center]), markersizeMOD(i), Re_mod, markersMOD{i}, 'DisplayName','Tge'); n = n+1;
    scatter(repelem(n,nd) , mean([DATA_MOD(i).data.Tgh_reg]), markersizeMOD(i), Re_mod, markersMOD{i}, 'DisplayName','Tge'); n = n+1;

    scatter(repelem(n,nd) , mean([DATA_MOD(i).data.Tgr_center]), markersizeMOD(i), Re_mod, markersMOD{i}, 'DisplayName','Tge'); n = n+1;

    scatter(repelem(n,nd) , mean([DATA_MOD(i).data.Tgk_reg]), markersizeMOD(i), Re_mod, markersMOD{i}, 'DisplayName','Tge'); n = n+1;
    scatter(repelem(n,nd) , mean([DATA_MOD(i).data.Tgk_center]), markersizeMOD(i), Re_mod, markersMOD{i}, 'DisplayName','Tge'); n = n+1;
    scatter(repelem(n,nd) , mean([DATA_MOD(i).data.Tgk_inlet]), markersizeMOD(i), Re_mod, markersMOD{i}, 'DisplayName','Tge'); n = n+1;
    scatter(repelem(n,nd) , mean([DATA_MOD(i).data.TgPP]), markersizeMOD(i), Re_mod, markersMOD{i}, 'DisplayName','Tge'); n = n+1;

%     scatter(x, mean([DATA_MOD(i).data.TgCC]), markersizeMOD(i), C(8,:), markersMOD{i},'DisplayName','TgCC') 
end

xticklabels(["Exp","H-Inlet","H-Center","H-Reg","Reg-Center","C-Reg","C-Center","C-Inlet","PP"])
legend(leg_plots,{'Eqn normal','Eqn corrected','Eqn normal set'})
% xlim([5,8])
% ylim([0,50])

%% Gas Temps vs location, line plot
figure(fig_count);
fig_count = fig_count+1;
hold on
ylabel('Temperature [\circC]')
% legend('Interpreter', 'none')
title('Gas Temperatures (TC)')
nicefigure(figure_purpose);

% For plot lines
markersMOD = {'-x','-->'};
colors = {'b','c','g','y','r'};
colors = repelem(colors,4);

for i=1:length(DATA_EXP)
    for j=3 %length(DATA_EXP(i).data)
        % gather all mean temps for one setpoint
        y = [... 
            DATA_EXP(i).data(j).Tge
            DATA_EXP(i).data(j).Tgh_inlet_far
            DATA_EXP(i).data(j).Tgh_inlet_pipe
            DATA_EXP(i).data(j).Tgh_reg_far
            DATA_EXP(i).data(j).Tgh_reg_pipe
            DATA_EXP(i).data(j).Tgk_reg
            DATA_EXP(i).data(j).Tgk_inlet_far
            mean([DATA_EXP(i).data(j).Tgk_inlet_pipe_1, DATA_EXP(i).data(j).Tgk_inlet_pipe_2])
            DATA_EXP(i).data(j).TgPP
            DATA_EXP(i).data(j).TgCC ...
            ];
        x = [1 1.8 2.2 2.8 3.2 4 4.8 5.2 6 7];
%         x = 1:length(y);
    
        plot(x,y, '-o')
%         plot(x,y, ['-x', colors{i}])
    end
end
xticks(x)
% xticklabels(["Exp","H-Inlet A","H-Inlet B","H-Reg A","H-Reg B","C-Reg A","C-Inlet A","C-Inlet B1","C-Inlet B2","PP","CC"])
xticklabels([0:9])
xlabel('TC position')
l=legend('Exp 1','Exp 2','Exp 3','Exp 4','Exp 5');
l.ItemTokenSize(1) = 10;

% Hot side only
xlim(x([1,5]))
ylim([93,98.5])
ylim([90,95])

% Cold side only
xlim(x([6,end]))
ylim([24,28])

for i=1:length(DATA_MOD)
    for j=length(DATA_MOD(i).data)
        % gather all mean temps for one setpoint
        y = [... 
            mean(DATA_MOD(i).data(j).Tge)
            mean(DATA_MOD(i).data(j).Tgh_inlet)
            mean(DATA_MOD(i).data(j).Tgh_center)
            mean(DATA_MOD(i).data(j).Tgh_reg)
            mean(DATA_MOD(i).data(j).Tgr_center)
            mean(DATA_MOD(i).data(j).Tgk_reg)
            mean(DATA_MOD(i).data(j).Tgk_center)
            mean(DATA_MOD(i).data(j).Tgk_inlet)
            mean(DATA_MOD(i).data(j).TgPP)...
            ];
        x = 1:length(y);
    
        plot(x,y, [markersMOD{i}, colors{j}])
    end
end

% legend('p100 rpm100 old HX','p100 rpm100 new HX','p500 rpm250 old HX','p500 rpm250 new HX')


%% Gas Temps vs location, line plot (Model Comparison)
n_sets_per_group = 4;
n_groups = ceil(length(DATA_MOD)/n_sets_per_group);
colors = {'r','b','g','m','c'};

%%%%%% SPECIFY which datapoints from which datasets to show %%%%%%%%%%%%%%%
datasets = 1:4;
datapoints = [1, 100]; % index greater than last datapoint will give last datapoint
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i_dataset = datasets
    for i_datapoint = datapoints
        
        if i_datapoint > length(DATA_MOD(i_dataset).data)
            i_datapoint = length(DATA_MOD(i_dataset).data);
        end
        
        figure(fig_count);
fig_count = fig_count+1;
hold on
ylabel('Gas Temperature [\circC]')
nicefigure(figure_purpose);

% i_dataset = 2;
% i_datapoint = 1;
% i_datapoint = length(DATA_MOD(i_dataset).data); % last datapoint

        % gather all mean temps for one setpoint
        y = [... 
            DATA_EXP(i_dataset).data(i_datapoint).Tge
            DATA_EXP(i_dataset).data(i_datapoint).Tgh_inlet
            NaN
            DATA_EXP(i_dataset).data(i_datapoint).Tgh_reg
            DATA_EXP(i_dataset).data(i_datapoint).Tgr
            DATA_EXP(i_dataset).data(i_datapoint).Tgk_reg
            NaN
            DATA_EXP(i_dataset).data(i_datapoint).Tgk_inlet
            DATA_EXP(i_dataset).data(i_datapoint).TgPP
            DATA_EXP(i_dataset).data(i_datapoint).TgCC...
            ];
        x = 1:length(y);
             
        plot(x,y, '--ok', 'MarkerFaceColor','auto','LineWidth',1.7)

        
mod_sets = i_dataset:n_sets_per_group:length(DATA_MOD); % model datasets to be used
for i = mod_sets
        % gather all mean temps for one setpoint
                    if isfield(DATA_MOD(i).data(i_datapoint),'TgPP')
                        TPP = mean(DATA_MOD(i).data(i_datapoint).TgPP);
                    else
                        TPP = mean(DATA_MOD(i).data(i_datapoint).TgPP_PPtop_test);
                    end

        y = [... 
            mean(DATA_MOD(i).data(i_datapoint).Tge)
            mean(DATA_MOD(i).data(i_datapoint).Tgh_inlet)
            mean(DATA_MOD(i).data(i_datapoint).Tgh_center)
            mean(DATA_MOD(i).data(i_datapoint).Tgh_reg)
            mean(DATA_MOD(i).data(i_datapoint).Tgr_center)
            mean(DATA_MOD(i).data(i_datapoint).Tgk_reg)
            mean(DATA_MOD(i).data(i_datapoint).Tgk_center)
            mean(DATA_MOD(i).data(i_datapoint).Tgk_inlet)
            TPP
%             mean(DATA_MOD(i).data(i_datapoint).TgPP)              
            mean(DATA_MOD(i).data(i_datapoint).TgCC)...
            ];
        x = 1:length(y);
        
        plot(x,y, ['--x' colors{mod_sets==i}], 'MarkerSize',8,'LineWidth',1)

end
xticks(x)
xticklabels(["\itT_e", "\itT_{h,inlet}", "\itT_{h,center}", "\itT_{h,reg}", "\itT_{reg}", "\itT_{k,reg}", "\itT_{k,center}", "\itT_{k,inlet}", "\itT_{PP}", "\itT_{CC}"])

% ylim([20 120])

leg_text = {'Experiment','A (No_Seal_h_analytical)','B (No_Seal_h_CFD)','C (With_Seal_h_analytical)','D (With_Seal_h_CFD)','Tube bank Gamma Oct13'};
% leg_text = {'Experiment','A (No_Seal_h_analytical)','B (No_Seal_h_CFD)','C (With_Seal_h_analytical)','D (With_Seal_h_CFD)'};
l=legend(leg_text, 'Interpreter','none');
 l.ItemTokenSize(1) = 20;
 
msg = "\itp_{set}\rm = " + DATA_EXP(i_dataset).data(i_datapoint).pmean_setpoint/1000 + "kPa"+newline+ ...
    "\itf\rm = " + round(DATA_EXP(i_dataset).data(i_datapoint).encoder_speed) + "rpm"+newline+...
...     "\itRe_{HX,avg}\rm = " + round(mean([ mean(DATA_MOD(i_dataset).data(i_datapoint).Re_cooler_center), mean(DATA_MOD(i_dataset).data(i_datapoint).Re_heater_center) ]));
    "\itRe_{HX,avg}\rm = " + round(Reynolds_HX_exp{i_dataset}(i_datapoint));
text(0.03, 0.15, msg, 'Units','normalized', 'FontSize',10,'FontName','Arial') % bottom left
% text(0.58, 0.44, msg, 'Units','normalized', 'FontSize',10,'FontName','Arial') % top right under legend
    end
end

%% Gas Temps vs location, line plot (Model Comparison) (BAK 19 july)
figure(fig_count);
fig_count = fig_count+1;
hold on
ylabel('Gas Temperature [\circC]')
% legend('Interpreter', 'none')
title('Gas Temperatures (TC)')
nicefigure(figure_purpose);

% Colors indicate datapoint %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
markersMOD = {'--x','-->'};
colors = {'b','c','g','y','r'};
% colors = repelem(colors,4);

% Alternative: colors indicate dataset %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lines = {'-','--'};
colors = {'r','k'};
markers = {'o','x'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

range = [1,2];

for i=1
    c = 1;
    for j = 1:length(range) % length(DATA_EXP(i).data)]
        % gather all mean temps for one setpoint
        y = [... 
            DATA_EXP(i).data(range(j)).Tge
            DATA_EXP(i).data(range(j)).Tgh_inlet
            NaN
            DATA_EXP(i).data(range(j)).Tgh_reg
            DATA_EXP(i).data(range(j)).Tgr
            DATA_EXP(i).data(range(j)).Tgk_reg
            NaN
            DATA_EXP(i).data(range(j)).Tgk_inlet
            DATA_EXP(i).data(range(j)).TgPP
            DATA_EXP(i).data(range(j)).TgCC...
%             mean(DATA_EXP(i).data(j).Tge)
%             mean(DATA_EXP(i).data(j).Tgh_inlet_far)
%             mean(DATA_EXP(i).data(j).Tgh_inlet_pipe)
%             mean(DATA_EXP(i).data(j).Tgh_reg_far)
%             mean(DATA_EXP(i).data(j).Tgh_reg_pipe)
%             mean(DATA_EXP(i).data(j).Tgk_reg)
%             mean(DATA_EXP(i).data(j).Tgk_inlet_far)
%             mean(DATA_EXP(i).data(j).Tgk_inlet_pipe_1)
%             mean(DATA_EXP(i).data(j).Tgk_inlet_pipe_2)
%             mean(DATA_EXP(i).data(j).TgPP)
%             mean(DATA_EXP(i).data(j).TgCC)...
            ];
%         x = [1 1.8 2.2 2.8 3.2 4 4.7 4.9 5.2 6 7];
        x = 1:length(y);
        
        legname = "Exp DP" + range(j);
%         legname = ['Exp ' DATA_EXP(i).data(range(j)).filename(1:3)];
        
%         plot(x,y, ['-o', colors{c}], 'DisplayName',legname)
        % Alternative %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        plot(x,y, [lines{1}, markers{1}, colors{j}], 'DisplayName',legname)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        c = c+1;
    end
end

for i=1:length(DATA_MOD)
    c = 1;
    for j = 1:length(range)
        % gather all mean temps for one setpoint
        y = [... 
            mean(DATA_MOD(i).data(range(j)).Tge)
            mean(DATA_MOD(i).data(range(j)).Tgh_inlet)
            mean(DATA_MOD(i).data(range(j)).Tgh_center)
            mean(DATA_MOD(i).data(range(j)).Tgh_reg)
            mean(DATA_MOD(i).data(range(j)).Tgr_center)
            mean(DATA_MOD(i).data(range(j)).Tgk_reg)
            mean(DATA_MOD(i).data(range(j)).Tgk_center)
            mean(DATA_MOD(i).data(range(j)).Tgk_inlet)
            mean(DATA_MOD(i).data(range(j)).TgPP)
            mean(DATA_MOD(i).data(range(j)).TgCC)...
            ];
        x = 1:length(y);
        
        % Adding 2nd Tge sensor for comparison
%         if i==1
%             y = [mean(DATA_MOD(i).data(range(j)).Tge_top); y];
%             x = [x(1)-1, x];
%         end
    
%         legname = DATA_MOD(i).data(range(j)).filename(40:end);
%         legname = ['Mod' num2str(i) ' ' DATA_MOD(i).data(range(j)).filename(2:4)];
        legname = "Mod"+ i + " DP" + range(j);
        
%         plot(x,y, [markersMOD{i}, colors{c}], 'DisplayName',legname)
        % Alternative %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        plot(x,y, [lines{i} markers{2}, colors{j}], 'DisplayName',legname)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        c = c+1;
    end
end
xticks(x)
xticklabels(["Exp","H-Inlet","H-Center","H-Reg","Reg-Center","C-Reg","C-Center","C-Inlet","PP","CC"])
        % Adding 2nd Tge sensor for comparison
% xticks([x(1)-1, x])
% xticklabels(["Exp (top node)","Exp","H-Inlet","H-Center","H-Reg","Reg-Center","C-Reg","C-Center","C-Inlet","PP","CC"])

l=legend('Interpreter', 'none');
% l.ItemTokenSize(1) = 10;


%% Gas Temps vs location, line plot (BAK old)
figure(fig_count);
fig_count = fig_count+1;
hold on
ylabel('Gas Temperature [\circC]')
% legend('Interpreter', 'none')
title('Gas Temperatures (TC)')
nicefigure(figure_purpose);

% For plot lines
markersMOD = {'-x','-->'};
colors = {'b','c','g','y','r'};
colors = repelem(colors,4);

for i=1:length(DATA_EXP)
    for j=length(DATA_EXP(i).data)
        % gather all mean temps for one setpoint
        y = [... 
            mean(DATA_EXP(i).data(j).Tge)
            mean(DATA_EXP(i).data(j).Tgh_inlet_far)
            mean(DATA_EXP(i).data(j).Tgh_inlet_pipe)
            mean(DATA_EXP(i).data(j).Tgh_reg_far)
            mean(DATA_EXP(i).data(j).Tgh_reg_pipe)
            mean(DATA_EXP(i).data(j).Tgk_reg)
            mean(DATA_EXP(i).data(j).Tgk_inlet_far)
            mean(DATA_EXP(i).data(j).Tgk_inlet_pipe_1)
            mean(DATA_EXP(i).data(j).Tgk_inlet_pipe_2)
            mean(DATA_EXP(i).data(j).TgPP)
            mean(DATA_EXP(i).data(j).TgCC)...
            ];
        x = [1 1.8 2.2 2.8 3.2 4 4.7 4.9 5.2 6 7];
%         x = 1:length(y);
    
        plot(x,y, [markersMOD{i}, colors{j}])
    end
end
% xticks(x)

for i=1:length(DATA_MOD)
    for j=length(DATA_MOD(i).data)
        % gather all mean temps for one setpoint
        y = [... 
            mean(DATA_MOD(i).data(j).Tge)
            mean(DATA_MOD(i).data(j).Tgh_inlet)
            mean(DATA_MOD(i).data(j).Tgh_center)
            mean(DATA_MOD(i).data(j).Tgh_reg)
            mean(DATA_MOD(i).data(j).Tgr_center)
            mean(DATA_MOD(i).data(j).Tgk_reg)
            mean(DATA_MOD(i).data(j).Tgk_center)
            mean(DATA_MOD(i).data(j).Tgk_inlet)
            mean(DATA_MOD(i).data(j).TgPP)...
            ];
        x = 1:length(y);
    
        plot(x,y, [markersMOD{i}, colors{j}])
    end
end
xticklabels(["Exp","H-Inlet","H-Center","H-Reg","Reg-Center","C-Reg","C-Center","C-Inlet","PP"])

% legend('p100 rpm100 old HX','p100 rpm100 new HX','p500 rpm250 old HX','p500 rpm250 new HX')



%% (OLD) Gas Temperatures (Avg) vs speed

% Hot Side %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(fig_count);
fig_count = fig_count+1;
hold on
xlabel('Speed [rpm]')
ylabel('Gas Temperature [\circC]')
legend('Interpreter', 'none')
title('Gas Temperatures (TC), hot side. x - model, o - experiment (inc torque), sq - experiment (dec torque)')
nicefigure(figure_purpose);

% Change plot color order so that each color is repeated n times.
C = get(gca,'ColorOrder');
magenta = [1 0 1];
black = [0 0 0];
green = [0 1 0];
C = [C; magenta; black; green];
% C = repelem(C, n_color_repeat, 1);
set(gca,'ColorOrder',C);

% plot all experimental datapoints. different color for each dataset.
markers = {'o','sq'};
for i=1:length(DATA_EXP)
    x = [DATA_EXP(i).data.MB_speed];
    scatter(x, [DATA_EXP(i).data.Tge_exp], 30, markers{i}, 'DisplayName','Tge_exp (TC0)')
    scatter(x, [DATA_EXP(i).data.Tgh_inlet_far], 30, markers{i}, 'DisplayName','Tgh_inlet_far (TC1)')
    scatter(x, [DATA_EXP(i).data.Tgh_inlet_pipe], 30, markers{i}, 'DisplayName','Tgh_inlet_pipe (TC2)')
    scatter(x, [DATA_EXP(i).data.Tgh_inlet], 30, markers{i}, 'DisplayName','Tgh_inlet (avg)')
    scatter(x, [DATA_EXP(i).data.Tgh_reg_far], 30, markers{i}, 'DisplayName','Tgh_reg_far (TC3)')
    scatter(x, [DATA_EXP(i).data.Tgh_reg_pipe], 30, markers{i}, 'DisplayName','Tgh_reg_pipe (TC4)')
    scatter(x, [DATA_EXP(i).data.Tgh_reg], 30, markers{i}, 'DisplayName','Tgh_reg (avg)')
    scatter(x, [DATA_EXP(i).data.Tgh_exp_far], 30, markers{i}, 'DisplayName','Tgh_exp_far (avg)')
    scatter(x, [DATA_EXP(i).data.Tgh_exp_pipe], 30, markers{i}, 'DisplayName','Tgh_exp_pipe (avg)')
    scatter(x, [DATA_EXP(i).data.Tgh_exp], 30, markers{i}, 'DisplayName','Tgh_exp (avg)')
end
% plot all model datapoints. different color for each dataset.
markersMOD = {'x','>'};
for i=1:length(DATA_MOD)
    x = [DATA_MOD(i).data.speedRPM];
    % plot mean of each setpoint
    scatter(x, mean([DATA_MOD(i).data.Tge]), 40, C(1,:), markersMOD{i}, 'DisplayName','Tge')
    scatter(x, mean([DATA_MOD(i).data.Tgh_inlet]), 40, C(4,:), markersMOD{i},'DisplayName','Tgh_inlet') 
    scatter(x, mean([DATA_MOD(i).data.Tgh_reg]), 40, C(7,:), markersMOD{i},'DisplayName','Tgh_reg') 
    scatter(x, mean([DATA_MOD(i).data.Tgh_reg_TopOfReg_test]), 40, C(7,:), '+','DisplayName','Tgh_reg_TopOfReg_test') 
    scatter(x, mean([DATA_MOD(i).data.Tgh_center]), 40, C(10,:), markersMOD{i},'DisplayName','Tgh_center') 
end

% regenerator %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(fig_count);
fig_count = fig_count+1;
hold on
xlabel('Speed [rpm]')
ylabel('Gas Temperature [\circC]')
legend('Interpreter', 'none')
title('Gas Temperatures (TC), Regenerator. x - model, o - experiment (inc torque), sq - experiment (dec torque)')
nicefigure(figure_purpose);

markers = {'o','sq'};
for i=1:length(DATA_EXP)
    x = [DATA_EXP(i).data.MB_speed];
%     scatter(x, [DATA_EXP(i).data.Tgh_reg_far], 30, markers{i}, 'DisplayName','Tgh_reg_far')
%     scatter(x, [DATA_EXP(i).data.Tgh_reg_pipe], 30, markers{i}, 'DisplayName','Tgh_reg_pipe')
%     scatter(x, [DATA_EXP(i).data.Tgh_reg], 30, markers{i}, 'DisplayName','Tgh_reg')
    scatter(x, [DATA_EXP(i).data.Tgr_exp], 30, markers{i}, 'DisplayName','Tgr_exp (log mean Tgh_reg, Tgk_reg)')
%     scatter(x, [DATA_EXP(i).data.Tgk_reg], 30, markers{i}, 'DisplayName','Tgk_reg')
end
markersMOD = {'x','>'};
for i=1:length(DATA_MOD)
    x = [DATA_MOD(i).data.speedRPM];
    scatter(x, mean([DATA_MOD(i).data.Tgr_center]), 40, markersMOD{i},'DisplayName','Tgr_center') 
    scatter(x, [DATA_MOD(i).data.Tgr_log], 40, markersMOD{i},'DisplayName','Tgr_log (log mean Tgh_reg, Tgk_reg)') 
end

% Cold Side %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(fig_count);
fig_count = fig_count+1;
hold on
xlabel('Speed [rpm]')
ylabel('Gas Temperature [\circC]')
legend('Interpreter', 'none')
title('Gas Temperatures (TC), cold side. x - model, o - experiment (inc torque), sq - experiment (dec torque)')
nicefigure(figure_purpose);

% Change plot color order so that each color is repeated n times.
n_color_repeat = 2;
C = get(gca,'ColorOrder');
magenta = [1 0 1];
black = [0 0 0];
green = [0 1 0];
C = [C; magenta];%; black; green];
% C = repelem(C, n_color_repeat, 1);
set(gca,'ColorOrder',C);

% plot all experimental datapoints. different color for each dataset.
markers = {'o','sq'};
for i=1:length(DATA_EXP)
    x = [DATA_EXP(i).data.MB_speed];
    scatter(x, [DATA_EXP(i).data.Tgk_reg], 30, markers{i}, 'DisplayName','Tgk_reg (TC5)')
    scatter(x, [DATA_EXP(i).data.Tgk_inlet_far], 30, markers{i}, 'DisplayName','Tgk_inlet_far (TC7)')
    scatter(x, [DATA_EXP(i).data.Tgk_inlet_pipe_1], 30, markers{i}, 'DisplayName','Tgk_inlet_pipe_1 (TC8)')
    scatter(x, [DATA_EXP(i).data.Tgk_inlet_pipe_2], 30, markers{i}, 'DisplayName','Tgk_inlet_pipe_2 (TC6)')
    scatter(x, [DATA_EXP(i).data.Tgk_inlet], 30, markers{i}, 'DisplayName','Tgk_inlet (avg)')
    scatter(x, [DATA_EXP(i).data.Tgk_exp], 30, markers{i}, 'DisplayName','Tgk_exp (avg)')
    scatter(x, [DATA_EXP(i).data.TgPP], 30, markers{i}, 'DisplayName','TgPP (TC9)')
    scatter(x, [DATA_EXP(i).data.TgCC_exp], 30, markers{i}, 'DisplayName','TgCC_exp (TC10)')
end
% plot all model datapoints. different color for each dataset.
markersMOD = {'x','>'};
for i=1:length(DATA_MOD)
    x = [DATA_MOD(i).data.speedRPM];
    % plot mean of each setpoint
    scatter(x, mean([DATA_MOD(i).data.Tgk_reg]), 40, C(1,:), markersMOD{i}, 'DisplayName','Tgk_reg')
    scatter(x, mean([DATA_MOD(i).data.Tgk_inlet]), 40, C(5,:), markersMOD{i},'DisplayName','Tgk_inlet') 
    scatter(x, mean([DATA_MOD(i).data.Tgk_center]), 40, C(6,:), markersMOD{i},'DisplayName','Tgk_center') 
    scatter(x, mean([DATA_MOD(i).data.TgPP]), 40, C(7,:), markersMOD{i},'DisplayName','TgPP') 
    scatter(x, mean([DATA_MOD(i).data.TgPP_PPtop_test]), 40, C(7,:), '+','DisplayName','TgPP_PPtop_test') 
    scatter(x, mean([DATA_MOD(i).data.TgCC]), 40, C(8,:), markersMOD{i},'DisplayName','TgCC') 
end
