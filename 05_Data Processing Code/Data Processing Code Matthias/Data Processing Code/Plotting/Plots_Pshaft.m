%% Shaft Power %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 3D plot of Power vs pmean, speed
figure(fig_count);
fig_count = fig_count+1;
hold on
nicefigure(figure_purpose);
% legend('Interpreter', 'none')

markers = {'o','sq'};
markers = repelem(markers,2);
colors = {'b','r'};
colors = repmat(colors,1,2);

ps = [MSPM_DATA.p_mean_setpoint].*1e-5;
ps = round(ps,1);
Xdata = unique(ps);
xlabel('\itp_{mean}\rm [bar]')

rpms = [MSPM_DATA.speedRPM];
rpms = round(rpms);
Ydata = unique(rpms);
ylabel('\itf\rm [rpm]')

Zs = [MSPM_DATA.P_shaft];
% Zs = [MSPM_DATA.FW];
% Zs = [MSPM_DATA.efficiency_shaft]*100;
% Zs = [MSPM_DATA.efficiency_ind]*100;

% Zs = mean( [mean([MSPM_DATA.Re_cooler_center]); mean([MSPM_DATA.Re_heater_center])] );

Zdata = reshape(Zs, length(Ydata),length(Xdata));
zlabel('\itP_{shaft}\rm [W]')
% zlabel('\itW_f\rm [J]')
% zlabel('\it\eta_{shaft}\rm [%]')
% zlabel('\itRe_{HX,avg}\rm (model)')


% Pind = [MSPM_DATA.Wind].*[MSPM_DATA.speedHz];
% Pind = reshape(Pind, length(Ydata),length(Xdata));
% 
% for i=1:length(MSPM_DATA)
%     Wexp(i)=MSPM_DATA(i).PV_Exp.Wind;
%     Wcom(i)=MSPM_DATA(i).PV_Com.Wind;
%     Wcc(i)=MSPM_DATA(i).PV_CC.Wind;
% end
% Pnet = ([MSPM_DATA.Wind]+Wexp+Wcom+Wcc).*[MSPM_DATA.speedHz];

surf(Xdata,Ydata,Zdata)
% surf(Xdata,Ydata,Pind)
% plot3(Xdata,Ydata,Pnet)

% [m,i] = max([MSPM_DATA.P_shaft]);
[~,i] = max(Zs);
scatter3(ps(i),rpms(i),Zs(i), 45,'b', 'LineWidth',1)
txt = "Max: "+Zs(i)+newline +ps(i)+" bar"+newline +rpms(i)+" rpm";
% text(ps(i),rpms(i)+0,Zs(i)+0.8,txt, 'Color','b','FontWeight','bold')
annotation('textbox','String',txt,'BackgroundColor','w','EdgeColor','b','Color','b');

i = find(ps==9 & rpms==100);
scatter3(ps(i),rpms(i),Zs(i), 45,'r', 'LineWidth',1')
txt = "Value: "+Zs(i)+newline +ps(i)+" bar"+newline +rpms(i)+" rpm";
% text(ps(i),rpms(i)+0,Zs(i)+0.8,txt, 'Color','r','FontWeight','bold')
annotation('textbox','String',txt,'BackgroundColor','w');

colormap jet
% legend('\itP_{shaft}','Maximum')

high = Zs>0.95*max(Zs);
xobj = scatter3(ps(high),rpms(high),Zs(high), 36,'g','x');
legend(xobj, 'Within 5 % of Max')

%%
figure(fig_count);
fig_count = fig_count+1;
hold on
nicefigure(figure_purpose);

Re_mean = mean( [mean([MSPM_DATA.Re_cooler_center]); mean([MSPM_DATA.Re_heater_center])] );
% scatter(Re_mean, [MSPM_DATA.P_shaft], 36,[MSPM_DATA.speedRPM])
% legend('Color = Speed')

scatter(Re_mean, [MSPM_DATA.P_shaft], 36,[MSPM_DATA.p_mean_setpoint])
legend('Color = Pressure')

colormap jet

%% Shaft power vs Scaling factor
figure(fig_count);
fig_count = fig_count+1;
hold on
nicefigure(figure_purpose);

Scale = [1:10, 15:5:100];
scatter(Scale,[MSPM_DATA.P_shaft],'k')
scatter(Scale,[MSPM_DATA.P_shaft]./1.41,'k','sq')
scatter(Scale,[MSPM_DATA_p.P_shaft],45,'k','x')
scatter(Scale(1:4),[MSPM_DATA_rpm.P_shaft],'k','+')
l=legend('Volume','Volume (realistic estimate)','Pressure','Speed');
% l=legend('Volume','Volume (realistic estimate)');
title(l,'Scaled Variable')
ylabel('\itP_{shaft}\rm [W]')

 xlim([1 10])
 xticks(1:10)
ylim([-500 1500])

% xlim([0 100])
% xticks(0:20:100)
% ylim([0 16000])

xlabel('Scaling Factor')
% xlabel('Volume Scaling Factor')

l.ItemTokenSize(1) = 10;

%% Shaft power vs scaling for different Gases
figure(fig_count);
fig_count = fig_count+1;
hold on
nicefigure(figure_purpose);

% Scale = [1:10, 15:5:100];
Scale = 200:200:1000;
xlabel('Volume Scaling Factor')

scatter(Scale,[MSPM_DATA.P_shaft]./1.41,'k')
% scatter(Scale,[MSPM_DATA.P_shaft]./1.41,'k','sq')
% scatter(Scale,[MSPM_DATA_N2.P_shaft]./1.41,'b')
scatter(Scale,[MSPM_DATA_He.P_shaft]./1.41,'g')
scatter(Scale,[MSPM_DATA_H2.P_shaft]./1.41,'r')

l=legend('Air','Helium','Hydrogen');
% l=legend('Air','Nitrogen','Helium','Hydrogen');
% title(l,'Scaled Variable')
ylabel('\itP_{shaft}\rm [W]')

%  xlim([1 10])
%  xticks(1:10)
% ylim([-500 1500])

% xlim([0 100])
% xticks(0:20:100)
% ylim([0 35000])
% f=fit(Scale', [MSPM_DATA_H2.P_shaft]','poly1')

l.ItemTokenSize(1) = 10;


%% P shaft vs speed
figure(fig_count);
fig_count = fig_count+1;
hold on
leg_chars = 25;
xlabel('Speed [rpm]')
ylabel('Shaft Power [W]')
title('Shaft Power')
nicefigure(figure_purpose);
legend('Interpreter', 'none')

markers = {'o','sq'};
markers = repelem(markers,2);
colors = {'b','r'};
colors = repmat(colors,1,2);

% plot all experimental datapoints. different color for each dataset.
for i=1:length(DATA_EXP)
    legname = ['Exp: ' DATA_EXP(i).name];
%     if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end   
    scatter([DATA_EXP(i).data.MB_speed], [DATA_EXP(i).data.P_shaft_exp_tsensor], 40, colors{i}, markers{i}, 'DisplayName',legname)
end
% plot all model datapoints. different color for each dataset.
for i=1:length(DATA_MOD)
    legname = ['Mod: ' DATA_MOD(i).name];
    scatter([DATA_MOD(i).data.speedRPM], [DATA_MOD(i).data.P_shaft], 30, 'x', 'DisplayName',legname)
end

%% P shaft vs speed, comparing measures of shaft power
figure(fig_count);
fig_count = fig_count+1;
hold on
leg_chars = 25;
xlabel('Speed [rpm]')
ylabel('Shaft Power [W]')
title('Shaft Power')
nicefigure(figure_purpose);
legend('Interpreter', 'none')


% plot all experimental datapoints. different color for each dataset.
for i=1%:length(DATA_EXP)
    legname = ['Exp: ' 'Measured'];
%     if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end   
    scatter([DATA_EXP(i).data.MB_speed], [DATA_EXP(i).data.P_shaft_exp_tsensor], 40, 'g', 'sq', 'DisplayName',legname)
    legname = ['Exp: ' 'Setpoint'];
    scatter([DATA_EXP(i).data.MB_speed], [DATA_EXP(i).data.P_shaft_exp], 30, 'b', 'o', 'DisplayName',legname)


end
% plot all model datapoints. different color for each dataset.
for i=2%:length(DATA_MOD)
    legname = ['Mod: ' 'MSPM Power'];
    scatter([DATA_MOD(i).data.speedRPM], [DATA_MOD(i).data.P_shaft], 30, 'k', 'x', 'DisplayName',legname)
    for j = 1:length(DATA_MOD(i).data)
        P_calc(j) = (DATA_MOD(i).data(j).PV_PP.Wind + DATA_MOD(i).data(j).PV_Exp.Wind + DATA_MOD(i).data(j).PV_Com.Wind) * DATA_MOD(i).data(j).speedHz;
        P_calc_flowloss(j) = P_calc(j) - DATA_MOD(i).data(j).Qdot_flowloss;
    end
    legname = ['Mod: ' 'from PV data'];
    scatter([DATA_MOD(i).data.speedRPM], P_calc, 40, 'r', 'x', 'DisplayName',legname)
    legname = ['Mod: ' 'from PV data, flowloss'];
    scatter([DATA_MOD(i).data.speedRPM], P_calc_flowloss, 40, 'r', '+', 'DisplayName',legname)
 
    %     if length(legname)>leg_chars; legname = legname(1:leg_chars) + "..."; end
    
    %     plot([DATA_MOD(i).data.speedRPM], [DATA_MOD(i).data.Wind])%, 30, [DATA_MOD(i).data.p_mean]./1000)%,'x')
end
