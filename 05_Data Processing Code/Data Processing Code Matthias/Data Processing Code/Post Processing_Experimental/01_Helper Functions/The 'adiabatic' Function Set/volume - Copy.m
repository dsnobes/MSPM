function [Vc,Ve,dVc,dVe,V_buffer] = volume(theta, ENGINE_DATA)
% determine working space volume variations and derivatives
% Israel Urieli, 7/6/2002
% Modified 2/14/2010 to include rockerV (rockdrive)
% Modified by Connor Speer October 2017

% Argument:  theta - current cycle angle [radians]
% Returned values: 
%   vc, ve - compression, expansion space volumes [m^3]
%   dvc, dve - compression, expansion space volume derivatives 

% *** Note: For gamma engines, the total workspace volume is maximum at
% crank angle 0. For alpha engines, the compression space volume is maximum
% at crank angle zero.


 %% Raphael engine is slider-crank gamma 
	[Vc,Ve,dVc,dVe,V_buffer] = gammacrankvol(theta, ENGINE_DATA);
%==============================================================


 function [Vc,Ve,dVc,dVe,V_buffer] = gammacrankvol(theta, ENGINE_DATA)
% gamma crankshaft drive volume variations and derivatives
% Added by Connor Speer - February 2017
% Argument:  theta - current cycle angle [radians]
% Returned values: 
%   vc, ve - compression, expansion space volumes [m^3]
%   dvc, dve - compression, expansion space volume derivatives 

Vclp = ENGINE_DATA.Vclp;
Vcld_top = ENGINE_DATA.Vcld_top;
Vcld_bottom = ENGINE_DATA.Vcld_bottom;
Dbore = ENGINE_DATA.Dbore;
Pbore = ENGINE_DATA.Pbore;
Dr1 = ENGINE_DATA.Dr1;
Dr2 = ENGINE_DATA.Dr2;
Dr3 = ENGINE_DATA.Dr3;
Pr1 = ENGINE_DATA.Pr1;
Pr2 = ENGINE_DATA.Pr2;
Pr3 = ENGINE_DATA.Pr3;
beta = ENGINE_DATA.beta_deg*(pi/180);

% vclp vcld % piston, displacer clearence vols [m^3]
% Dbore Pbore % displacer, piston bores [m]
% Dr1 Pr1 % displacer, piston desaxe offset in [m]
% Dr2 Pr2 % displacer, piston crank length (half stroke) in [m]
% Dr3 Pr3 % displacer, piston connecting rod lengths [m]
% beta % phase angle advance of displacer motion over piston [radians]

%*** Total volume is maximum at theta = 0 for gammas.
Ptheta2 = pi - theta;
Dtheta2 = Ptheta2 - beta;

Dtheta3 = pi - asin((-Dr1+(Dr2*sin(Dtheta2)))/Dr3);
Dr4 = Dr2*cos(Dtheta2) - Dr3*cos(Dtheta3);
Dr4max = sqrt(((Dr2+Dr3)^2)-(Dr1^2));
Dr4min = sqrt(((Dr3-Dr2)^2)-(Dr1^2));
Ve = (Vcld_top) + ((pi/4)*(Dbore^2))*(Dr4max-Dr4);

V_disprod = ENGINE_DATA.V_disprod_min + Dr4*(pi/4)*((ENGINE_DATA.d_disprod)^2); % Added displacer rod.
DVc = (((pi/4)*(Dbore^2))*(Dr4max-Dr4min)) - Ve - V_disprod; % Added displacer rod.

Ptheta3 = pi - asin((-Pr1+(Pr2*sin(Ptheta2)))/Pr3);
Pr4 = Pr2*cos(Ptheta2) - Pr3*cos(Ptheta3);
Pr4max = sqrt(((Pr2+Pr3)^2)-(Pr1^2));
PVc = (((pi/4)*(Pbore^2))*(Pr4max-Pr4));
Vc = (Vcld_bottom) + Vclp + DVc + PVc;

dDtheta3 =  (Dr2.*cos(Dtheta2))./(Dr3.*sqrt(1-(((-Dr1+(Dr2.*sin(Dtheta2)))./Dr3).^2)));
dDr4 = Dr2.*sin(Dtheta2) + Dr3.*sin(Dtheta3).*dDtheta3;
dVe = -(pi/4)*(Dbore^2).*(dDr4);

dPtheta3 = (Pr2.*cos(Ptheta2))./(Pr3.*sqrt(1-(((-Pr1+(Pr2.*sin(Ptheta2)))./Pr3).^2)));
dPr4 = Pr2.*sin(Ptheta2) + Pr3.*sin(Ptheta3).*dPtheta3;
dPVc = -(pi/4)*(Pbore^2).*dPr4;

dDVc = -dVe - dDr4*(pi/4)*((ENGINE_DATA.d_disprod)^2);

dVc = dDVc + dPVc;

% Crankcase Volume Variations in (m^3) --> COULD ADD DISPLACER ROD TO THIS, BUT IT WOULD MAKE A VERY SMALL DIFFERENCE.
V_buffer = ENGINE_DATA.V_buffer_max - PVc; 
%==============================================================