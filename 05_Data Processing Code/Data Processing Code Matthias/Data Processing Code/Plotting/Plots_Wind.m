%% Indicated Work %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Selected indicator diagrams (EXP)
figure(fig_count);
fig_count = fig_count+1;
hold on
leg_chars = 30;
ylabel('P - P_{mean} [kPa]')
xlabel('V / V_{max}')
title('Indicator Diagrams')
nicefigure(figure_purpose);

datasets = 1:2;
datapoints = [1, 20];
% datapoints = length(DATA_EXP(datasets).data);

% % EXP
% for i = 1:length(datasets)
%     for d = 1:length(datapoints)
%         legname = ['Exp: ' DATA_EXP(i).name];
%         if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
% 
%         V = DATA_EXP(datasets(i)).data(datapoints(d)).Vtotal_rounded;
%         V = V./max(V);
%         p = DATA_EXP(datasets(i)).data(datapoints(d)).p_PC_avg;
%         p = p-mean(p);
%         plot(V,p/1000, 'DisplayName',legname)
%     end
% end
colors = {'r','g'};
% MOD
for i = 1:length(datasets)
    for d = 1:length(datapoints)
        legname = ['Mod: ' DATA_MOD(datasets(i)).data(datapoints(d)).filename];
%         if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end

        V = DATA_MOD(datasets(i)).data(datapoints(d)).PV_PP.V;
        V = V./max(V);
        p = DATA_MOD(datasets(i)).data(datapoints(d)).PV_PP.p;
        p = p-mean(p);
        plot(V,p/1000, colors{i}, 'DisplayName',legname)
    end
end
ratio = DATA_MOD(datasets(1)).data(datapoints(1)).Wind/DATA_MOD(datasets(2)).data(datapoints(1)).Wind;
text(0.5,0.5, " Work old/new:"+newline+ratio ,'Units','normalized')
ratio = DATA_MOD(datasets(1)).data(datapoints(2)).Wind/DATA_MOD(datasets(2)).data(datapoints(2)).Wind;
text(0.1,0.8, " Work old/new:"+newline+ratio ,'Units','normalized')


legend('Interpreter', 'none')


%% Indicated Work vs speed
figure(fig_count);
fig_count = fig_count+1;
hold on
leg_chars = 30;
xlabel('\itf\rm [rpm]')
ylabel('\itW_{ind}\rm [J]')
title('Indicated Work')
nicefigure(figure_purpose);

% plot all experimental datapoints. different color for each dataset.
for i=1%:length(DATA_EXP)
    legname = ['Exp: ' DATA_EXP(i).name];
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    scatter([DATA_EXP(i).data.encoder_speed], [DATA_EXP(i).data.Wind], 30, 'o', 'DisplayName',legname);


end

% plot all model datapoints. different color for each dataset.
for i=1:length(DATA_MOD)   
    legname = ['Mod: ' DATA_MOD(i).name];
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    scatter([DATA_MOD(i).data.speedRPM], [DATA_MOD(i).data.Wind], 40, 'x', 'DisplayName',legname);
end

% % PLOT each model datapoint separately
% for i=1:length(DATA_MOD)
%     for j=1:length(DATA_MOD(i).data)
%     legname = DATA_MOD(i).data(j).filename(40:end);
%     if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
%     plot(DATA_MOD(i).data(j).speedRPM, DATA_MOD(i).data(j).Wind, 'x', 'DisplayName',legname);
%     end
% end

l=legend('Interpreter', 'none');
l.ItemTokenSize(1) = 10;

% for i=1:length(RD_DATA)
%    Wind_DM(i)=trapz(RD_DATA(i).Vtotal_rounded, RD_DATA(i).p_DM_avg); 
% end
% scatter([RD_DATA.MB_speed],Wind_DM);

%% Indicated Work vs speed, pressure color coded, with colorbar
figure(fig_count);
fig_count = fig_count+1;
hold on
leg_chars = 30;
xlabel('Speed [rpm]')
ylabel('Indicated Work [J]')
title('Indicated Work')
nicefigure(figure_purpose);
plots_i = 1;

markersMOD = {'x','+'};
markersMOD = repelem(markersMOD,4);

% plot all experimental datapoints. different color for each dataset.
for i=1:length(DATA_EXP)
    legname = ['Exp: ' DATA_EXP(i).name];
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    p = scatter([DATA_EXP(i).data.MB_speed], [DATA_EXP(i).data.Wind_exp], 30, [DATA_EXP(i).data.pmean]./1000, 'o', 'DisplayName',legname);
    if i==1; plots(plots_i) = p; plots_i = plots_i+1; end
end
% plot all model datapoints. different color for each dataset.
for i=1:length(DATA_MOD)
    legname = ['Mod: ' DATA_MOD(i).name];
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    p = scatter([DATA_MOD(i).data.speedRPM], [DATA_MOD(i).data.Wind], 40, [DATA_MOD(i).data.p_mean]./1000, markersMOD{i}, 'DisplayName',legname);
    if any(i==[1,5]); plots(plots_i) = p; plots_i = plots_i+1; end  
end

legend(plots, 'Experiment','Model FinCon (old)','Model FinEnh custom h (new)')
cb = colorbar;
ylabel(cb,'Mean Pressure (kPa)')
colormap(jet(10))



%% Indicated Work vs speed, pressure color coded, with colors in legend
figure(fig_count);
fig_count = fig_count+1;
hold on
leg_chars = 30;
% xlabel('Speed [rpm]')
% ylabel('Indicated Work [J]')
xlabel('\itf\rm [rpm]')
ylabel('\itW_{ind}\rm [J]')
title('Indicated Work')
nicefigure(figure_purpose);
plots_i = 1;

markers = {'o','sq'};
markers = repelem(markers,2);

% plot all experimental datapoints. different color for each dataset.
for i=1:length(DATA_EXP)
    legname = ['Exp, ' num2str( DATA_EXP(i).data(1).pmean_setpoint/1000 ) 'kPa'];
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    p = scatter([DATA_EXP(i).data.MB_speed], [DATA_EXP(i).data.Wind], 30, [DATA_EXP(i).data.pmean]./1000, markers{i}, 'DisplayName',legname);
    if i==1; plots(plots_i) = p; plots_i = plots_i+1; end
end
% plot all model datapoints. different color for each dataset.
for i=1:length(DATA_MOD)
    legname = ['Mod, ' num2str( DATA_MOD(i).data(1).p_mean_setpoint/1000 ) 'kPa'];
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    p = scatter([DATA_MOD(i).data.speedRPM], [DATA_MOD(i).data.Wind], 40, [DATA_MOD(i).data.p_mean]./1000, 'x', 'DisplayName',legname);
    if i==1; plots(plots_i) = p; plots_i = plots_i+1; end  
end

legend('Interpreter', 'none')
colormap(jet(10))
% 

%% Indicated Work vs Temp ratio (varying Tsource/Tsink)
figure(fig_count);
fig_count = fig_count+1;
hold on
leg_chars = 30;
xlabel('T ratio (SOURCE)')
ylabel('\itW_{ind}\rm [J]')
title('Indicated Work')
nicefigure(figure_purpose);

% Tsource
for i=1%:length(DATA_MOD)
    for j=1:11%length(DATA_MOD(i).data)
        legname = DATA_MOD(i).data(j).filename(40:end);
        if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
        plot((DATA_MOD(i).data(j).T_source+273)/(DATA_MOD(i).data(j).T_sink+273), DATA_MOD(i).data(j).Wind/DATA_MOD(i).data(9).Wind, 'x', 'DisplayName',legname);
    
    end

end

% l=legend('Interpreter', 'none');
% l.ItemTokenSize(1) = 10;

% Tsink
figure(fig_count);
fig_count = fig_count+1;
hold on
leg_chars = 30;
xlabel('T ratio (SINK)')
ylabel('\itW_{ind}\rm [J]')
title('Indicated Work')
nicefigure(figure_purpose);

for j=12:length(DATA_MOD(i).data)
    legname = DATA_MOD(i).data(j).filename(40:end);
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
        plot((DATA_MOD(i).data(j).T_source+273)/(DATA_MOD(i).data(j).T_sink+273), DATA_MOD(i).data(j).Wind/DATA_MOD(i).data(9).Wind, 'o', 'DisplayName',legname);

end
% l=legend('Interpreter', 'none');
% l.ItemTokenSize(1) = 10;


%% General: Var Y vs Var X
% Tsource
figure(fig_count);
fig_count = fig_count+1;
hold on
leg_chars = 30;
nicefigure(figure_purpose);

for i=1%:length(DATA_MOD)
    range = 1:length(DATA_MOD(i).data);
%     Xdata = 0.4 + (1:length(DATA_MOD(i).data))*0.1;
Xdata = 94:0.5:98; % Porosity
% Xdata = 0.05:0.01:0.15;
% Xdata = [TestSetStatistics.GN]+[TestSetStatistics.SN];
    Ydata = [DATA_MOD(i).data(range).Wind];
%     Ydata = [DATA_MOD(i).data(range).Qdot_fromSource];
%     Ydata = [DATA_MOD(i).data(range).Qdot_toSink];
%     Ydata = [DATA_MOD(i).data(range).Qdot_toEnv];

Ydata = Ydata./Ydata(5)-1;

      legname = DATA_MOD(i).name;
    if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    scatter(Xdata, Ydata, 50, 'x', 'DisplayName',legname);
    scatter(Xdata(6), Ydata(6), 50,'x','r')
end
% f=fit(Xdata', Ydata','poly1')
% plot(f)
% l=legend({'Wind','Qsource','Qsink','Qenv','Eff'}, 'Interpreter', 'none');
% l.ItemTokenSize(1) = 10;

xlabel('\itD_{W,Reg}\rm [mm]')
% xlabel('\it\beta\rm [%]')
% xlabel('h sink change from default [%]')
% xlabel('h source change from default [%]')

ylabel('\itW_{ind}\rm [J]')
% ylabel('Qdot fromSource [W]')
% ylabel('Qdot toSink [W]')
% ylabel('Qdot toEnv [W]')
% ylabel('Efficiency indicated [%]')

% xline(0.07);
% xline(0.13);


%% Tsource / Tsink sensitivity
figure(fig_count);
fig_count = fig_count+1;
hold on
nicefigure(figure_purpose);
Ydata = [];

for i=3%:length(DATA_MOD)
    range = 1:length(DATA_MOD(i).data);
%     range = 12:24; %length(DATA_MOD(i).data);   
    
Xdata = [DATA_MOD(i).data(range).T_source];
% Xdata = [DATA_MOD(i).data(range).T_sink];
    
default_index = 1;
    Ydata(1,:) = [DATA_MOD(i).data(range).Wind] / DATA_MOD(i).data(default_index).Wind -1;
    Ydata(2,:) = [DATA_MOD(i).data(range).Qdot_fromSource] / DATA_MOD(i).data(default_index).Qdot_fromSource -1;
    Ydata(3,:) = [DATA_MOD(i).data(range).Qdot_toSink] / DATA_MOD(i).data(default_index).Qdot_toSink -1;
    Ydata(4,:) = [DATA_MOD(i).data(range).Qdot_toEnv] / DATA_MOD(i).data(default_index).Qdot_toEnv -1;
%     Ydata(5,:) = [DATA_MOD(i).data(range).efficiency_ind] / DATA_MOD(i).data(default_index).efficiency_ind -1;
  
    for p = 1:size(Ydata,1)
    plot(Xdata, Ydata(p,:)*100, '-x');
    end
end
l=legend({'\itW_{ind}','\itQ_{Source}','\itQ_{Sink}','\itQ_{Env}'});
l.ItemTokenSize(1) = 20;

xlabel('Tsource')
% xlabel('Tsink')

ylabel('Deviation from default [%]')


%% Convergence of mesh plot
figure(fig_count);
fig_count = fig_count+1;
hold on
nicefigure(figure_purpose);
Ydata = [];

for i=1%:length(DATA_MOD)
    range = 1:length(DATA_MOD(i).data);
    Xdata = [0.2:0.1:2, 2.5:0.5:6]; %NodeFactor
% Xdata = [TestSetStatistics.GN]+[TestSetStatistics.SN]; % Nodes
% Xdata = [TestSetStatistics.GF]+[TestSetStatistics.SF]+[TestSetStatistics.MF]; % Faces

default_index = 9;
    Ydata(1,:) = [DATA_MOD(i).data(range).Wind] / DATA_MOD(i).data(default_index).Wind -1;
    Ydata(2,:) = [DATA_MOD(i).data(range).Qdot_fromSource] / DATA_MOD(i).data(default_index).Qdot_fromSource -1;
    Ydata(3,:) = [DATA_MOD(i).data(range).Qdot_toSink] / DATA_MOD(i).data(default_index).Qdot_toSink -1;
    Ydata(4,:) = [DATA_MOD(i).data(range).Qdot_toEnv] / DATA_MOD(i).data(default_index).Qdot_toEnv -1;
%     Ydata(5,:) = [DATA_MOD(i).data(range).efficiency_ind] / DATA_MOD(i).data(default_index).efficiency_ind -1;
  
    for p = 1:size(Ydata,1)
    plot(Xdata, Ydata(p,:)*100, '-x');
    end
end
l=legend({'\itW_{ind}','\itQ_{Source}','\itQ_{Sink}','\itQ_{Env}'});
l.ItemTokenSize(1) = 20;

% xlabel('# of Nodes')
xlabel('Node Factor')

ylabel('Deviation from default mesh [%]')


%% Plot Node Counts
figure(fig_count);
fig_count = fig_count+1;
hold on
nicefigure(figure_purpose);
Ydata = [];
markers = {':o','-o',':x','-x','-.x','-*'};
% markers = {'o','o','x','x','x','-*'};

for i=1%:length(DATA_MOD)
    Xdata = [0.2:0.1:2, 2.5:0.5:6]; %NodeFactor
    default_index = 9;
    
    Ydata(1,:) = [TestSetStatistics.GN];% / DATA_MOD(i).data(default_index).Wind -1;
    Ydata(2,:) = [TestSetStatistics.SN];
    Ydata(3,:) = [TestSetStatistics.GF];
    Ydata(4,:) = [TestSetStatistics.SF];
    Ydata(5,:) = [TestSetStatistics.MF];
    Ydata(6,:) = [TestSetStatistics.Runtime]/60;
    
    yyaxis left
    ylabel('Count')
    for p = 1:5%size(Ydata,1)
        if strfind(markers{p},'x')
    plot(Xdata, Ydata(p,:), markers{p}, 'MarkerSize',10);
        else
    plot(Xdata, Ydata(p,:), markers{p});
        end
%         plot(fit(Xdata', Ydata(p,:)','poly1'))
    end
    yyaxis right
    ylabel('Runtime [min]')
    plot(Xdata, Ydata(6,:), markers{6});
    

end
l=legend({'Gas Nodes','Solid Nodes','Gas Faces','Solid Faces','Mixed Faces','Runtime'});
% l.ItemTokenSize(1) = 20;

% xlabel('# of Nodes')
xlabel('Node Factor')

% ylabel('Deviation from default mesh [%]')




%% From Scratch vs. from snapshot comparison
figure;
hold on
nicefigure(figure_purpose);
plots = [];
log = [];

yyaxis left
n1 = length(MSPM_DATA_snap_1);
n3 = length(MSPM_DATA_snap_3);
plots(end+1) = scatter( 1:n1, [MSPM_DATA_snap_1.Wind], 50,  'x');
plots(end+1) = scatter( 1:n1, [MSPM_DATA_scratch_1.Wind], 40,  '+');
scatter( n1+1:n1+n3, [MSPM_DATA_snap_3.Wind], 50,  'x');
scatter( n1+1:n1+n3, [MSPM_DATA_scratch_3.Wind], 40,  '+');
ylabel('\itW_{ind}\rm [J]')
ylim([0,16])

yyaxis right
dev1 = ([MSPM_DATA_snap_1.Wind]./[MSPM_DATA_scratch_1.Wind]-1)*100;
dev3 = ([MSPM_DATA_snap_3.Wind]./[MSPM_DATA_scratch_3.Wind]-1)*100;
log = [dev1 dev3];
disp("Avg deviation (%) "+mean(log))
plots(end+1) = scatter( 1:n1, dev1, 40,  'o');
scatter( n1+1:n1+n3, dev3, 40,  'o');
ylabel('Deviation [%]')
xlabel('Datapoint no.')
xline(18.5);

legend(plots, 'from Snapshot','from Scratch','Deviation')

%% Indicated work over datapoint number
figure;
hold on
nicefigure(figure_purpose);
plots = [];

yyaxis left
n1 = length(MSPM_DATA);
scatter( 1:n1, [MSPM_DATA.Wind], 50,  'x');
ylabel('\itW_{ind}\rm [J]')
ylim([0,6])

mean_Wind = mean([MSPM_DATA.Wind]);
C = get(gca,'ColorOrder');
plots(end+1) = yline(mean_Wind,'Color',C(1,:));

yyaxis right
mean_Wind = mean([MSPM_DATA.Wind]);
dev1 = ([MSPM_DATA.Wind]/mean_Wind-1)*100;
disp("Avg deviation (%) "+mean(abs(dev1)))
scatter( 1:n1, dev1, 40,  'o');
ylabel('Deviation from Mean [%]')
xlabel('Datapoint no.')
legend(plots,'Mean')

