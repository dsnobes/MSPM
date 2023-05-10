%% absolute pressures and variance
pmean=[RD_DATA.pmean]+[RD_DATA.p_atm];
pmean_CC=[RD_DATA.pmean_CC]+[RD_DATA.p_atm];
WS = mean(pmean);
WS = [WS, max(pmean)-WS, min(pmean)-WS];
CC = mean(pmean_CC);
CC = [CC, max(pmean_CC)-CC, min(pmean_CC)-CC];

%% plotting to figure out variance between repeated model runs AND how h-Custom doesn't work
figure
hold on
ylabel('W_{ind}')
xlabel('p-mean (kPa)')
scatter([400,200], [DATA_EXP(1).data.Wind], 'k','o', 'DisplayName','Exp')
scatter([400,200], [DATA_MOD(1).data.Wind], 'b','x', 'DisplayName','h-empirical old')
scatter([400,200], [DATA_MOD(3).data(1:2).Wind], 'b','+', 'DisplayName','h-empirical by TestSet')
scatter([400,200], [DATA_MOD(4).data(1:2).Wind], 'b','*', 'DisplayName','h-empirical by ModelChange')

scatter([400,200], [DATA_MOD(2).data.Wind], 'g','x', 'DisplayName','h-CFD old')
scatter([400,200], [DATA_MOD(3).data(3:4).Wind], 'g','+', 'DisplayName','h-CFD by TestSet')
scatter([400,200], [DATA_MOD(4).data(3:4).Wind], 'g','*', 'DisplayName','h-CFD by ModelChange')

scatter(200, MSPM_DATA(1).Wind, 'g','<', 'DisplayName','h-CFD by TestSet FIXED')
scatter(200, MSPM_DATA(2).Wind, 'b','<', 'DisplayName','h-empirical by TestSet FIXED')

legend

%% find const temp bodies in model while debugging
for o=1:length(this.Groups.Bodies)
if strcmp(this.Groups.Bodies(o).matl.name,'Constant Temperature'); disp(o); end
end
%%
for o=1:length(ME.Model.Sensors)
if strfind(ME.Model.Sensors(o).name,'Re'); disp(o + ": "+ME.Model.Sensors(o).name); end
end
%%
xs = [];
Dhs=[];
for o=1:length(this.Groups.Bodies(1, 21).Faces  )
if isfield(this.Groups.Bodies(1, 21).Faces(o).data,'Dh')
    Dhs(end+1) = this.Groups.Bodies(1, 21).Faces(o).data.Dh;
    xs(end+1) = o;
%     xs(end+1) = this.Groups.Bodies(1, 21).Faces(o).ymin;
    disp(o + ": "+Dhs(end));
end
end
figure
plot(xs,Dhs)
%%
areas=[];
for fc=ans.Body.Faces
    if fc.Type == 'Gas'
        disp(find(ans.Body.Faces == fc))
        areas(end+1)=fc.data.Area;
    end
end

%%
for i=1:length(this.Groups.Bodies)
   if  strcmp(this.Groups.Bodies(i).name, 'App Gap')
       disp(i)
   end
end
for i=1:length(this.Groups.Bodies(1, 12).Nodes.Faces    )
   if  this.Groups.Bodies(1, 12).Nodes.Faces  (i).Type == 'Gas'
       disp(i)
   end
end
'Exp Space'
'HX Inlet top'
'App Gap'

%%
s = 0.1; %stroke
f = 1; %Hz
t = linspace(0,1/f,199);
omega = f*2*pi;
pos = s/2 * cos(omega*t);
spd = -omega*s/2 * sin(omega*t);

figure
hold on
% yyaxis left
% plot(t,pos)
% plot(t,spd)

p=101325;
T=298;
mu=1.84E-05;
R=287;
A_pis = pi*0.1^2;
A_HX = 0.039841107;
D_h = 0.0094737;

vel_HX = spd * A_pis/A_HX;
Re = (p/R/T)*abs(vel_HX)*D_h/mu;
% yyaxis right
plot(t,Re)

Re_mod = data.DependentVariable;
plot(t,Re_mod)
plot(t,Re_mod/0.454545455)

% legend('pos','spd','Re')
legend('Re theory','Re model (Re-center)','Re model corr (Re-center)','Re model corr (Re-top)')


%% plot and fit analytical Nu for rect channel
x=[1 2 3 4 6 8 100 1000]';
y=[2.98 3.39 3.96 4.44 5.14 5.6 7.535 7.54]';
f = fit(x,y,'power2');

figure
plot(x,y,'x')
hold on
plot(f)
xlim([1,20])