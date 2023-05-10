function [dwork_h,dwork_r,dwork_k,pdropk,pdroph,pdropr] = worksim(ENGINE_DATA,REF_CYCLE_DATA,crank_inc)
% Evaluate the pressure drop available work loss [J]
% Israel Urieli, 7/23/2002, Modified by Connor Speer - June 2017
% Modified by Connor Speer, October 2017. No globals.

% Inputs:
% crank_inc --> crank angle step size for simulation in [degrees]

% Outputs: 
% dwork --> pressure drop available work loss [J]
% pdropk --> pressure drop across the cooler [Pa]
% pdroph --> pressure drop across the heater [Pa]
% pdropr --> pressure drop across the regenerator [Pa]

dtheta = 2*pi/(360/crank_inc);
dwork_h = 0; % initialize pumping work loss
dwork_r = 0; % initialize pumping work loss
dwork_k = 0; % initialize pumping work loss

% Preallocate space for loop variables
pdropk = zeros(1,360/crank_inc);
pdroph = zeros(1,360/crank_inc);
pdropr = zeros(1,360/crank_inc);
dp = zeros(1,360/crank_inc);
pc = zeros(1,360/crank_inc);
pe = zeros(1,360/crank_inc);
N_Re = zeros(1,360/crank_inc);

for i = 1:1:(360/crank_inc)
    % Cooler
    m_flux_k = ([REF_CYCLE_DATA(i).m_dot_ck] + [REF_CYCLE_DATA(i).m_dot_kr])*ENGINE_DATA.omega/(2*ENGINE_DATA.ak); % mass flux in [kg/s*m^2]
    [mu,kgas,N_Re(i)] = reynum(ENGINE_DATA,ENGINE_DATA.Tgk,m_flux_k,ENGINE_DATA.dk); % Reynolds number for crank angle increment
    [ht,fr] = pipefr(ENGINE_DATA,ENGINE_DATA.dk,mu,N_Re(i)); % Reynolds friction factor for each crank angle increment
    pdropk(i) = 2*fr*mu*ENGINE_DATA.Vk*m_flux_k*ENGINE_DATA.lk/(REF_CYCLE_DATA(i).mk*ENGINE_DATA.dk^2); % Pressure drop across cooler in [Pa].

    % Work Lost due to pressure drop in the cooler
    dwork_k = dwork_k + dtheta*pdropk(i)*REF_CYCLE_DATA(i).dVe; % pumping work [J]
    
    % Regenerator
    m_flux_r = (REF_CYCLE_DATA(i).m_dot_kr + REF_CYCLE_DATA(i).m_dot_rh)*ENGINE_DATA.omega/(2*ENGINE_DATA.ar);
    [mu,kgas,N_Re(i)] = reynum(ENGINE_DATA,ENGINE_DATA.Tgr,m_flux_r,ENGINE_DATA.dr);
    if(strncmp(ENGINE_DATA.regen_matrix_type,'m',1))
         [st,fr] = matrixfr(ENGINE_DATA,N_Re(i));
    elseif (strncmp(ENGINE_DATA.regen_matrix_type,'f',1))
         [st,ht,fr] = foilfr(ENGINE_DATA.dr,mu,N_Re(i));
    end
    pdropr(i) = 2*fr*mu*ENGINE_DATA.Vr*m_flux_r*ENGINE_DATA.lr/(REF_CYCLE_DATA(i).mr*ENGINE_DATA.dr^2);

    % Work Lost due to pressure drop in the regenerator
    dwork_r = dwork_r + dtheta*pdropr(i)*REF_CYCLE_DATA(i).dVe; % pumping work [J]
    
    % Heater
    m_flux_h = (REF_CYCLE_DATA(i).m_dot_rh + REF_CYCLE_DATA(i).m_dot_he)*ENGINE_DATA.omega/(2*ENGINE_DATA.ah);
    [mu,kgas,N_Re(i)] = reynum(ENGINE_DATA,ENGINE_DATA.Tgh,m_flux_h,ENGINE_DATA.dh);

    [ht,fr] = pipefr(ENGINE_DATA,ENGINE_DATA.dh,mu,N_Re(i));
    pdroph(i) = 2*fr*mu*ENGINE_DATA.Vh*m_flux_h*ENGINE_DATA.lh./(REF_CYCLE_DATA(i).mh*ENGINE_DATA.dh^2);

    % Work Lost due to pressure drop in the heater
    dwork_h = dwork_h + dtheta*pdroph(i)*[REF_CYCLE_DATA(i).dVe]; % pumping work [J]
    
    % Overall Pressure Drop
    dp(i) = pdropk(i) + pdropr(i) + pdroph(i);
   
	pc(i) = REF_CYCLE_DATA(i).p; % Baseline pressure is defined to be the compression space pressure.
	pe(i) = pc(i) + dp(i); % Expansion space pressure is the compression space pressure plus the total pressure drop.
end

%% Add one last value to the results so the length matches the other variables
pdropk((360/crank_inc)+1) = pdropk(1);
pdropr((360/crank_inc)+1) = pdropr(1);
pdroph((360/crank_inc)+1) = pdroph(1);
dp((360/crank_inc)+1) = dp(1);
pc((360/crank_inc)+1) = pc(1);
pe((360/crank_inc)+1) = pe(1);