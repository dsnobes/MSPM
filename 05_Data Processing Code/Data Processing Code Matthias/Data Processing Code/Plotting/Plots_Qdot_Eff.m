%% Efficiency %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

markers = {'o','sq'};
markers = repelem(markers,2);

% plot all experimental datapoints. different color for each dataset.
for i=1:length(DATA_EXP)
    legname = ['Exp, ' num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 ) 'kPa'];
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    p = scatter([DATA_EXP(i).data.MB_speed], [DATA_EXP(i).data.efficiency_ind]*100, 30, [DATA_EXP(i).data.pmean]./1000, markers{i}, 'DisplayName',legname);
    if i==1; plots(plots_i) = p; plots_i = plots_i+1; end
end

% plot all model datapoints. different color for each dataset.
for i=1:length(DATA_MOD)
    legname = ['Mod, ' num2str( DATA_MOD(i).data(1).p_mean_setpoint/1000 ) 'kPa'];
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    p = scatter([DATA_MOD(i).data.speedRPM], [DATA_MOD(i).data.efficiency_ind]*100, 40, [DATA_MOD(i).data.p_mean]./1000, 'x', 'DisplayName',legname);
    if i==1; plots(plots_i) = p; plots_i = plots_i+1; end  
end

legend('Interpreter', 'none')
colormap(jet(10))



%% Eff vs speed
figure(fig_count);
fig_count = fig_count+1;
hold on
leg_chars = 40;
xlabel('Speed [rpm]')
ylabel('Indicated Efficiency [%]')
title('Efficiency (indicated)')
nicefigure(figure_purpose);
plots_i = 1;

for i=1:length(DATA_EXP)
    % MB_speed in rpm
    %eff_ind = [DATA_EXP(i).data.Wind_exp].*[DATA_EXP(i).data.MB_speed]./60 ./([DATA_EXP(i).data.Qdot_heater_exp]+[DATA_EXP(i).data.Qdot_DCH_exp]) *100; % [%]
    legname = ['Exp: ' DATA_EXP(i).name];
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    p = scatter([DATA_EXP(i).data.MB_speed], [DATA_EXP(i).data.efficiency_ind]*100, 30, 'o', 'DisplayName',legname);
    if i==1; plots(plots_i) = p; plots_i = plots_i+1; end
end
% plot all model datapoints. different color for each dataset.
% for i=1:length(DATA_MOD)
%     legname = ['Mod: ' DATA_MOD(i).name];
%     if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
%     p = scatter([DATA_MOD(i).data.speedRPM], [DATA_MOD(i).data.efficiency_ind]*100, 40, 'x', 'DisplayName',legname);
%     if i==1; plots(plots_i) = p; plots_i = plots_i+1; end  
% end

% Different models in one dataset
for i=1:length(DATA_MOD)
    for j=1:length(DATA_MOD(i).data)
    legname = DATA_MOD(i).data(j).filename(40:end);
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    plot(DATA_MOD(i).data(j).speedRPM, DATA_MOD(i).data(j).efficiency_ind*100, 'x', 'DisplayName',legname);
    end
end

legend('Interpreter', 'none')

%% Heat Flow Rates vs speed
figure(fig_count);
fig_count = fig_count+1;
hold on
leg_chars = 30;
xlabel('Speed [rpm]')
ylabel('Heat Flow [W]')
title('Heat Flow Rates')
nicefigure(figure_purpose);
plots_i = 1;

% EXP data
for i=1 
    legname = ['Heater'];
    p = scatter([DATA_EXP(i).data.MB_speed], [DATA_EXP(i).data.Qdot_heater], 30, 'g', '+', 'DisplayName',legname);
        if i==1; plots(plots_i) = p; plots_i = plots_i+1; end

    legname = ['Cooler'];
    p = scatter([DATA_EXP(i).data.MB_speed], [DATA_EXP(i).data.Qdot_cooler], 30, 'g', 'o', 'DisplayName',legname);
        if i==1; plots(plots_i) = p; plots_i = plots_i+1; end

    legname = ['Shaft Power'];
    p = scatter([DATA_EXP(i).data.MB_speed], [DATA_EXP(i).data.P_shaft_tsensor], 30, 'g', 'x', 'DisplayName',legname);
        if i==1; plots(plots_i) = p; plots_i = plots_i+1; end

    legname = ['Lost(exp) / Environment(mod)'];
    Qlost = [DATA_EXP(i).data.Qdot_heater]-[DATA_EXP(i).data.P_shaft_tsensor]-[DATA_EXP(i).data.Qdot_cooler];
    p = scatter([DATA_EXP(i).data.MB_speed], Qlost, 30, 'g', '>', 'DisplayName',legname);
    if i==1; plots(plots_i) = p; plots_i = plots_i+1; end
end

n_color_repeat = 4;
C = get(gca,'ColorOrder');
C = repelem(C, n_color_repeat, 1);
set(gca,'ColorOrder',C);
% MOD data
markers = {'+','o','x','>'};
legs = {'FinConn (old) ','FinEnh insulated','FinEnh custom h'};
for i=1
    for j=1:length(DATA_MOD(i).data)
    legname = DATA_MOD(i).data(j).filename(40:end);
    p = plot(DATA_MOD(i).data(j).speedRPM, DATA_MOD(i).data(j).Qdot_fromSource,  markers{1}, 'DisplayName',legname);
    legname = DATA_MOD(i).data(j).filename(40:end);
    plot(DATA_MOD(i).data(j).speedRPM, DATA_MOD(i).data(j).Qdot_toSink, markers{2}, 'DisplayName',legname);
    legname = DATA_MOD(i).data(j).filename(40:end);
    plot(DATA_MOD(i).data(j).speedRPM, DATA_MOD(i).data(j).P_shaft, markers{3}, 'DisplayName',legname);
    legname = DATA_MOD(i).data(j).filename(40:end);
    plot(DATA_MOD(i).data(j).speedRPM, DATA_MOD(i).data(j).Qdot_toEnv, markers{4}, 'DisplayName',legname);
%     plots(plots_i) = p; plots_i = plots_i+1;  

    end
end


% markers = {'x','+','*'};
% legs = {'FinConn (old) ','FinEnh insulated','FinEnh custom h'};
% for i=1:3 
%     legname = [legs{i} 'Source' ];
%     p = scatter([DATA_MOD(i).data.speedRPM], [DATA_MOD(i).data.Qdot_fromSource], 40, 'r', markers{i}, 'DisplayName',legname);
%     legname = [legs{i} 'Sink' ];
%     p = scatter([DATA_MOD(i).data.speedRPM], [DATA_MOD(i).data.Qdot_toSink], 40, 'b', markers{i}, 'DisplayName',legname);
%     legname = [legs{i} 'Shaft Power' ];
%     p = scatter([DATA_MOD(i).data.speedRPM], [DATA_MOD(i).data.P_shaft], 40, 'g', markers{i}, 'DisplayName',legname);
%     legname = [legs{i} 'Environment' ];
%     p = scatter([DATA_MOD(i).data.speedRPM], [DATA_MOD(i).data.Qdot_toEnv], 40, 'k', markers{i}, 'DisplayName',legname);
%     legname = [legs{i} 'Other Loss' ];
%     loss = [DATA_MOD(i).data.Qdot_fromSource]-[DATA_MOD(i).data.Qdot_toSink]-[DATA_MOD(i).data.P_shaft]-[DATA_MOD(i).data.Qdot_toEnv];
%     p = scatter([DATA_MOD(i).data.speedRPM], loss, 40, [0.5 0.5 0.5], markers{i}, 'DisplayName',legname);
% %     if i==1; plots(plots_i) = p; plots_i = plots_i+1; end  
% end

legend(plots, 'Interpreter', 'none')
