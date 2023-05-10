function LOSSES_DATA = parasitic_losses_T2(ENGINE_DATA,REF_CYCLE_DATA,crank_inc)
% Written by Connor Speer - January 2017
% Calculates the parasitic losses.
% Modified by Connor Speer, October 2017. No globals.

% Losses already accounted for by the "Simple" simulation:
% - Regenerator Enthalpy Loss

% Inputs:
% ENGINE_DATA --> Structure containing engine geometry and operating point
% REF_CYCLE_DATA --> Structure containing data from the reference cycle
% crank_inc --> crank angle step size in [degrees]

% Output:
% LOSSES_DATA --> Structure containing parasitic loss information

%% Imperfect Heat Transfer
TEMPORARY_ENGINE_DATA = ENGINE_DATA;

% Calculate ideal adiabatic reference cycle using thermal source and sink
% temperatures.
TEMPORARY_ENGINE_DATA.Tgh = ENGINE_DATA.Tsource;
TEMPORARY_ENGINE_DATA.Tgk = ENGINE_DATA.Tsink;
ADIABATIC_DATA = adiabatic(TEMPORARY_ENGINE_DATA,crank_inc);
Wpower_1 = ADIABATIC_DATA(end).W * TEMPORARY_ENGINE_DATA.freq; %(W)

% Calculate ideal adiabatic reference cycle using the thermal source
% temperature and the compression space gas temperature.
TEMPORARY_ENGINE_DATA.Tgh = ENGINE_DATA.Tsource;
TEMPORARY_ENGINE_DATA.Tgk = ENGINE_DATA.Tgc;
ADIABATIC_DATA = adiabatic(TEMPORARY_ENGINE_DATA,crank_inc);
Wpower_2 = ADIABATIC_DATA(end).W * TEMPORARY_ENGINE_DATA.freq; %(W)
LOSSES_DATA.P_HEX_cooler = Wpower_1 - Wpower_2; %(W)

% Calculate the ideal adiabatic reference cycle using the expansion space 
% gas temperature and the thermal sink temperature.
TEMPORARY_ENGINE_DATA.Tgh = ENGINE_DATA.Tge;
TEMPORARY_ENGINE_DATA.Tgk = ENGINE_DATA.Tsink;
ADIABATIC_DATA = adiabatic(TEMPORARY_ENGINE_DATA,crank_inc);
Wpower_3 = ADIABATIC_DATA(end).W * TEMPORARY_ENGINE_DATA.freq; %(W)
LOSSES_DATA.P_HEX_heater = Wpower_1 - Wpower_3; %(W)

% Calculate the ideal adiabatic reference cycle using the expansion and
% compression space gas temperatures.
TEMPORARY_ENGINE_DATA.Tgh = ENGINE_DATA.Tge;
TEMPORARY_ENGINE_DATA.Tgk = ENGINE_DATA.Tgc;
ADIABATIC_DATA = adiabatic(TEMPORARY_ENGINE_DATA,crank_inc);
Wpower_4 = ADIABATIC_DATA(end).W * TEMPORARY_ENGINE_DATA.freq; %(W)
LOSSES_DATA.P_HEX_total = Wpower_1 - Wpower_4; %(W)

% Is it valid to separate the heater and cooler like this? Do we get the
% same result as if we calculate them both at once?
% --> Not quite, but close. It may be a useful approximation to separate
% them if the heater and cooler performance is significantly different.

%% Mechanical Friction (Forced Work Method, See Senft's Book)
vtot = ([REF_CYCLE_DATA.Vc] + ENGINE_DATA.Vk + ENGINE_DATA.Vr + ...
    ENGINE_DATA.Vh + [REF_CYCLE_DATA.Ve]); % cubic meters

p_engine = [REF_CYCLE_DATA.p]; % Pascals

% Crankcase Pressure Models %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% p0 = mean([REF_CYCLE_DATA.p]); % Mean crankcase pressure in (Pa).
p0 = ENGINE_DATA.p_buffer_exp; % Measured mean crankcase pressure in (Pa).

% Mean crankcase volume in (m^3).
V0 = ENGINE_DATA.V_buffer_max - 0.5*0.075*(((pi/4)*(ENGINE_DATA.Pbore^2))); 

% % Constant Buffer Pressure Equal to the Mean Pressure
% p_buff_const = mean([REF_CYCLE_DATA.p]); % Pascals
% p_buffer = repelem(p_buff_const,length(vtot));

% % Buffer Pressure Assuming Isothermal Compression and Expansion
% T_crankcase = ENGINE_DATA.Tgc; % Mean crankcase temperature in [K].
% % Mass of gas in the crankcase in [kg].
% m_crankcase = (p0*V0)/(ENGINE_DATA.rgas*T_crankcase);
% p_buffer = (m_crankcase*R*T_crankcase)./V_buffer;

% Buffer Pressure Assuming Adiabatic Compression and Expansion in (Pa).
p_buffer = p0.*((V0./[REF_CYCLE_DATA.V_buffer]).^ENGINE_DATA.gamma);

% % Buffer Pressure Determined By Shahzeb's Empirical Ellipse Function
% p_buffer = getBufferPressure(ENGINE_DATA.pmean,crank_inc);

LOSSES_DATA.p_buffer = p_buffer; %(Pa)

% Run Forced Work Subfunction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[W_ind, FW, W_shaft] = ...
    FW_Subfunction_v3(1,p_engine,p_buffer,vtot,ENGINE_DATA.effect,0);

% Store forced work in LOSSES_DATA structure
LOSSES_DATA.FW = FW; %(J)

% Net output shaft power (W) (Senft's formula)
P_shaft = W_shaft*ENGINE_DATA.freq;

% Power lost to mechanical friction in [W]
LOSSES_DATA.P_mech = (W_ind*ENGINE_DATA.freq) - P_shaft;


%% Flow Friction
regen_corr_factor = 1;

% Calculate pressure drops
[~,~,~,pdropk,pdroph,pdropr] = ...
    worksim(ENGINE_DATA,REF_CYCLE_DATA,crank_inc);

LOSSES_DATA.pdropk = pdropk; % Pressure drop across the cooler in (Pa)
LOSSES_DATA.pdroph = pdroph; % Pressure drop across the heater in (Pa)
LOSSES_DATA.pdropr = pdropr; % Pressure drop across the regenerator in (Pa)

dwork_h = sum(crank_inc*(pi/180).*pdroph(1:360).*[REF_CYCLE_DATA(1:360).dVe]); % pumping work [J]
dwork_r = sum(crank_inc*(pi/180).*regen_corr_factor.*pdropr(1:360).*[REF_CYCLE_DATA(1:360).dVe]); % pumping work [J]
dwork_k = sum(crank_inc*(pi/180).*pdropk(1:360).*[REF_CYCLE_DATA(1:360).dVe]); % pumping work [J]

% Pressure drop power loss in the heater
LOSSES_DATA.P_flow_h = dwork_h*ENGINE_DATA.freq; %(W)

% Pressure drop power loss in the regenerator
LOSSES_DATA.P_flow_r = dwork_r*ENGINE_DATA.freq; %(W)

% Pressure drop power loss in the cooler
LOSSES_DATA.P_flow_k = dwork_k*ENGINE_DATA.freq; %(W)

%% Regenerator Enthalpy Loss
A = isfield(REF_CYCLE_DATA, 'qrloss');
if A == 1
    % Convert regenerator enthalpy loss per cycle in (J) to a rate in (W)
    LOSSES_DATA.Q_qrloss = REF_CYCLE_DATA(1).qrloss*ENGINE_DATA.freq; %(W)
else
    LOSSES_DATA.Q_qrloss = 0;
end

%% Conduction Loss (1-D Fourier Law)
% Input parameters needed:
% A_wall --> Average cross-sectional area of the wall conduction path [m^2]
% k_wall --> Average thermal conductivity of the wall conduction material
% [W/mK]
% L_wall --> Length of the wall conduction path [m]
% A_regen --> Regenerator free flow area [m^2]
% kgas --> Thermal conductivity of the working gas [W/mK]
% L_regen --> Length of the regenerator [m]
% A_displacer --> Cross-sectional area of the displacer [m^2]
% k_displacer --> Effective thermal conductivity of the displacer [W/m^2]
% L_displacer --> Length of the displacer [m]

% % Inputs for Terrapin Engine 2.0
A_wall = 0.25*pi*((0.274^2)-(0.247^2)+(0.207^2)-(0.200^2)); % [m^2]
k_wall = 0.216; % PEI/Ultem plastic [W/m^2K]
L_wall = 0.0254; %[m] Length of regenerator cavity in this case
A_regen = 0.25*pi*((0.247^2)-(0.207^2)); %[m^2] Area of regenerator
k_regen = 0.96*ENGINE_DATA.kgas + 0.04*(0.05); % Porosity weighted working gas + Polyester.
L_regen = 0.0254; %[m]
A_displacer = 0.25*pi*(0.200^2); %[m^2]
k_displacer = 0.033; %[W/mK]
L_displacer = 0.1405; %[m]
A_rods = 8*0.25*pi*(0.012^2); %(m^2)
k_rods = 54; %(W/mK) Low carbon steel
L_rods = 0.24139; %(m)

% Conduction through the engine walls
Q_wall = (A_wall*k_wall*(ENGINE_DATA.Twh-ENGINE_DATA.Twk))/L_wall; %[W]

% Conduction through the regenerator
Q_regen = (A_regen*k_regen*(ENGINE_DATA.Twh-ENGINE_DATA.Twk))/L_regen; %[W]

% Conduction through the displacer
Q_displacer = (A_displacer*k_displacer*(mean([REF_CYCLE_DATA.Tge])...
    -mean([REF_CYCLE_DATA.Tgc])))/L_displacer; %[W]

% Conduction through displacer cylinder tie rods
Q_rods = (A_rods*k_rods*(ENGINE_DATA.Twh-ENGINE_DATA.Twk))/L_rods; %[W]

% Total Conduction Loss [W]
LOSSES_DATA.Q_cond = Q_wall + Q_regen + Q_displacer + Q_rods;

% % Plot relative conduction loss components
% figure
% wall_label = strcat('Walls (',num2str(round((Q_wall/LOSSES_DATA.Q_cond)*100),2),'%)');
% regen_label = strcat('Regenerator (',num2str(round((Q_regen/LOSSES_DATA.Q_cond)*100),2),'%)');
% displacer_label = strcat('Displacer (',num2str(round((Q_displacer/LOSSES_DATA.Q_cond)*100),2),'%)');
% rods_label = strcat('Tie Rods (',num2str(round((Q_rods/LOSSES_DATA.Q_cond)*100),2),'%)');
% labels = {wall_label regen_label displacer_label rods_label};
% pie([Q_wall Q_regen Q_displacer Q_rods],labels)
% title('Conduction Loss Model')

%% Gas Spring Hysteresis Losses
% Input parameters needed:
% Tw --> gas spring wall temperature [K]
% delV --> volume amplitude of the spring cavity [m^3]
% VB --> mean volume of the gas spring cavity [m^3]
% Aw --> mean wetted area of the gas spring [m^2]
% delA --> wetted area amplitude [m^2]

% % Inputs for Original ST05G-CNC Stirling Engine
% Tw = ENGINE_DATA.Tgk; %[K] (assumed to be equal to the cooler temperature)
% delV = 0.25*pi*(0.085^2)*0.075; %[m^3]
% VB = 0.5*delV + 0.002488647 + 0.000091248 + 0.000419874 + 0.000186558 + ...
%     0.000182367 - 0.000229935 - 0.000061378 - 0.000059277 - ...
%     0.000007376 - 0.000021882 - 0.000013195 - 0.000009817 - ...
%     0.000009173 - 0.000231607; %[m^3]
% delA = pi*0.085*0.075; %[m^2]
% Aw = 0.5*delA + 0.05853681 + 0.00804849 + 0.01866106 + 0.01030158 + ...
%     0.02145481 + 0.03279471 + 0.01778246 + 0.02301812 + 0.00211262 + ...
%     0.007294024 + 0.00026389 + 0.00045239 + 0.02173007; %[m^2]
% 
% % Calculation of the gas spring hysteresis loss
% F1 = sqrt(0.125*ENGINE_DATA.omega*ENGINE_DATA.gamma*...
% (ENGINE_DATA.gamma-1)*Tw*ENGINE_DATA.pmean*ENGINE_DATA.kgas);
% F2 = (delV/VB)*((0.5*ENGINE_DATA.gamma*(delV/VB)*Aw) - delA);
% 
% P_hys = F1*F2*ENGINE_DATA.freq; % Power lost to gas spring hysteresis in [W].

% Empirical Formula Based on Experimental Data
LOSSES_DATA.P_GSH = T2_GSH_Empirical(ENGINE_DATA.freq,ENGINE_DATA.p_buffer_exp,ENGINE_DATA.GSH_config); %[W]


%% Seal Leakage Losses
% Input parameters needed:
% mloss_outside --> Working fluid loss rate due to leakage to the outside [Pa/s]
% isentropic_eff_comp --> Isentropic efficiency of the compressor
% h_ambient --> Enthalpy of the air entering the compressor in [J/kg] 
% h2_isentropic --> Discharge enthalpy of the compressor in [J/kg] 

% Inputs for HTG Stirling Engine
mloss_outside = 0; % [kg/s]
isentropic_eff_comp = 0.75; % [unitless]
h_ambient = 298180; % [J/kg]
h2_isentropic = 575590; % [J/kg]

% Piston Leakage

% Displacer Leakage

% Leakage to the outside (adds compressor work for a pressurized engine)
% *** This will not affect the measured engine output if the engine is not
% driving the compressor.
% Power consumed by the compressor to maintain engine pressure
P_compressor = (mloss_outside*(h2_isentropic-h_ambient))/isentropic_eff_comp; %[W]

% Total leakage loss effects
LOSSES_DATA.P_seals = 0; % Power lost due to seal leakage in [W].
LOSSES_DATA.Q_seals = 0; % Heat lost due to seal leakage in [W].


%% Appendix Gap Losses (Pg 140 of Urieli and Berchowitz)
% Input parameters needed:
% D --> diameter of the displacer cylinder ??? [m]
% kgas --> thermal conductivity of the working fluid [W/mK]
% Xd --> displacer motion amplitude (displacer stroke) [m]
% upsilon --> linear axial temperature gradient (bad assumption in this case since cooler is a different material) [K/m]
% h --> appendix gap width(distance b/w displacer wall and cylinder wall) [m]
% omega --> engine angular frequency [rad/s]
% phi --> phase angle b/w displacer motion and pressure variation [rad]
% alpha_solid --> thermal diffusivity of the displacer and cylinder material in [m^2/s]
% k_solid --> thermal conductivity of the displacer and cylinder material in [W/m.K]

% Inputs for HTG Stirling Engine
D = 0.200; %[m] 
Xd = 0.075; %[m]
upsilon = (ENGINE_DATA.Tgh-ENGINE_DATA.Tgk)/0.242; %[K/m] (Divided by length of displacer cylinder)
h = 0.001; %[m]
alpha_solid = 1.172e-05; %[m^2/s] (Steel from Wikipedia)
k_solid = 47; %[W/m.K] (AISI 1020 Steel from Solidworks - Displacer is Stainless so this should be refined)

% Crank angle at which minimum workspace pressure occurs
[~,pmax_index] = max([REF_CYCLE_DATA.p]); 
pmaxAngle = pmax_index*crank_inc - crank_inc; %[degrees]

% Crank angle at which expansion space volume is minimum
[~,Vemin_index] = min([REF_CYCLE_DATA.Ve]); 
DispTDCAngle = Vemin_index*crank_inc - crank_inc; %[degrees]

% Crank angle by which pressure variation leads the displacer motion
phi = (pmaxAngle-DispTDCAngle)*(pi/180); %[rad]

pressure = [REF_CYCLE_DATA.p];
delp = max(pressure) - min(pressure); %[Pa]

w = sqrt(ENGINE_DATA.omega/(2*alpha_solid));

shuttle_loss = (pi*0.5*D*ENGINE_DATA.kgas*(Xd^2)*upsilon)/h;
net_enthalpy_transport = (ENGINE_DATA.gamma/(ENGINE_DATA.gamma-1))*pi*D*delp*Xd*ENGINE_DATA.omega*log(ENGINE_DATA.Tgh/ENGINE_DATA.Tgk)*sin(phi)*(0.5-(ENGINE_DATA.kgas/(w*h*k_solid)))*h;
pV_work_on_seal_face = (0.5*pi*D*delp*Xd*ENGINE_DATA.omega*sin(phi))*h;

LOSSES_DATA.Q_app = shuttle_loss + net_enthalpy_transport - pV_work_on_seal_face; % Heat lost due to appendix gap in [W].


%% Heat Transfer Hysteresis
LOSSES_DATA.P_HTH = 0; % Power lost to heat transfer hysteresis in [W].


%% Finite Piston Speed Loss
% % Equations come from Petrescu 2002 and quasi-steady approach was inspired
% % by Hosseinzade 2015
% 
% % Calculate the constant quantity "a"
% a = sqrt(3*ENGINE_DATA.gamma);
% 
% % Calculate vectors of average molecular speeds corresponding to the 
% % vector of crank angle increments in (m/s)
% cc = sqrt(3*ENGINE_DATA.R.*[REF_CYCLE_DATA.Tgc]); % Compression space
% ce = sqrt(3*ENGINE_DATA.R.*[REF_CYCLE_DATA.Tge]); % Expansion space
% 
% % Calculate vectors of piston speeds in (m/s)
% Dr1 = ENGINE_DATA.Dr1;
% Dr2 = ENGINE_DATA.Dr2;
% Dr3 = ENGINE_DATA.Dr3;
% Dbore = ENGINE_DATA.Dbore;
% 
% Pr1 = ENGINE_DATA.Pr1;
% Pr2 = ENGINE_DATA.Pr2;
% Pr3 = ENGINE_DATA.Pr3;
% Pbore = ENGINE_DATA.Pbore;
% 
% Ptheta2 = pi - [REF_CYCLE_DATA.theta]; %(rad)
% Dtheta2 = Ptheta2 - ENGINE_DATA.beta; %(rad)
% 
% Ptheta2_dot = -ENGINE_DATA.omega; %(rad/s)
% Dtheta2_dot = -ENGINE_DATA.omega; %(rad/s)
% 
% Ptheta3 = pi - asin((-Pr1+(Pr2.*sin(Ptheta2)))./Pr3); %(rad)
% Dtheta3 = pi - asin((-Dr1+(Dr2.*sin(Dtheta2)))./Dr3); %(rad)
% 
% wp = (Pr2*Ptheta2_dot.*sin(Ptheta3-Ptheta2))./cos(Ptheta3); %(m/s)
% wd = (Dr2*Dtheta2_dot.*sin(Dtheta3-Dtheta2))./cos(Dtheta3); %(m/s)
% 
% % Calculate incremental volume changes caused by the piston and displacer
% dPtheta3 = (Pr2.*cos(Ptheta2))./(Pr3.*sqrt(1-(((-Pr1+(Pr2.*sin(Ptheta2)))./Pr3).^2)));
% dPr4 = Pr2.*sin(Ptheta2) + Pr3.*sin(Ptheta3).*dPtheta3;
% dVp = -(pi/4)*(Pbore^2).*dPr4;
% 
% dDtheta3 =  (Dr2.*cos(Dtheta2))./(Dr3.*sqrt(1-(((-Dr1+(Dr2.*sin(Dtheta2)))./Dr3).^2)));
% dDr4 = Dr2.*sin(Dtheta2) + Dr3.*sin(Dtheta3).*dDtheta3;
% dVe = -(pi/4)*(Dbore^2).*(dDr4);
% 
% % Calculate vectors of lost work
% dWp = [REF_CYCLE_DATA.p].*(-a*wp./cc).*dVp;
% 
% % Calculate total work lost to finite piston speed
% W_FPS = sum(dWp);
% 
% % Calculate total power lost to finite piston speed
% LOSSES_DATA.P_FPS = W_FPS*ENGINE_DATA.freq; %(W)
LOSSES_DATA.P_FPS = 0; % Power loss due to relative motion between piston and gas molecules in [W].


%% Cooling/Heating System Pumping Power
% Some of the power produced by the engine must be used to drive the
% coolant pump (unless a heat pipe or other passive cooling method is used).
% A fuel pump or hot side water pump may also be needed.

% Inputs:
% rho_cool --> density of coolant in (kg/m^3)
% g --> gravitational acceleration in (m/s^2)
% V_dot_cool --> volume flow rate of coolant in (m^3/s)
% H_cool --> coolant pump net head in (m)
% eff_pump_cool --> coolant pump efficiency

% P_pump_cool = (rho_cool*g*V_dot_cool*H_cool)/eff_pump; %(W)

LOSSES_DATA.P_pump_cool = 0; % Power required to drive the coolant pump in (W).

LOSSES_DATA.P_pump_hot = 0; % Power required to drive fuel pump or hot water pump in [W].


%% Exergy Destruction due to Heat Conduction at the Thermal Source/Sink Interfaces
% The temperature drop between the heater/cooler gas temperature and the
% thermal source/sink causes exergy destruction.

% Calculations follow an example on Pg 446 of Cengel Thermodynamics
% Assumptions:
% 1. Steady state conduction process.
% 2. 1-dimensional heat conduction.
% 3. The exergy of the wall itself is constant, since it does not change
% state.

% Average heat transfer rates in the heater and cooler in (W)
Qh_dot_avg = mean([REF_CYCLE_DATA.Qh]*ENGINE_DATA.freq); 
Qk_dot_avg = mean([REF_CYCLE_DATA.Qk]*ENGINE_DATA.freq);

% Average gas temperatures in the heater and cooler in (K)
Tgh_avg = mean([ENGINE_DATA.Tgh]);
Tgk_avg = mean([ENGINE_DATA.Tgk]);

% Temperatures of the thermal source and sink in (K)
Tsource = ENGINE_DATA.Tsource;
Tsink = ENGINE_DATA.Tsink;

T0 = 21 + 273.15; % Temperature of the environment in (K)

% Calculate exergy destruction in the heater and cooler in (W)
LOSSES_DATA.X_dest_source = Qh_dot_avg*(1-(T0/Tsource)) - Qh_dot_avg*(1-(T0/Tgh_avg));

LOSSES_DATA.X_dest_sink = Qk_dot_avg*(1-(T0/Tsink)) - Qk_dot_avg*(1-(T0/Tgk_avg));


%% Heat lost through the heating cap insulation
% LOSSES_DATA.Q_insulation = 135; % Measured at 300 deg C Cap Temperature (W)
% LOSSES_DATA.Q_insulation = 90; % Measured at 200 deg C Cap Temperature (W)
LOSSES_DATA.Q_insulation = 0;