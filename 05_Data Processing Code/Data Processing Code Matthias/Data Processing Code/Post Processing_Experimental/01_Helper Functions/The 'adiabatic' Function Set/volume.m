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

engine_type = ENGINE_DATA.engine_type; % Letter indicating engine layout and drive mechanism

if(strncmp(engine_type,'s',1)) % Sinusoidal alpha
	[Vc,Ve,dVc,dVe] = sinevol(theta, ENGINE_DATA);
elseif(strncmp(engine_type,'y',1)) % Ross yoke mechanism alpha
	[Vc,Ve,dVc,dVe] = yokevol(theta, ENGINE_DATA);
elseif(strncmp(engine_type,'r',1)) % Ross rocker V-drive alpha
	[Vc,Ve,dVc,dVe] = rockvol(theta, ENGINE_DATA);
elseif(strncmp(engine_type,'g',1)) % Sinusoidal gamma
	[Vc,Ve,dVc,dVe] = gammasinvol(theta, ENGINE_DATA);
elseif(strncmp(engine_type,'x',1)) % Slider-crank mechanism gamma
	[Vc,Ve,dVc,dVe,V_buffer] = gammacrankvol(theta, ENGINE_DATA);
elseif(strncmp(engine_type,'a',1)) % Slider-crank mechanism alpha
	[Vc,Ve,dVc,dVe] = alphacrankvol(theta, ENGINE_DATA);
elseif(strncmp(engine_type,'d',1)) % Double bellcrank mechanism gamma
	[Vc,Ve,dVc,dVe,V_buffer] = bellcrankvol(theta, ENGINE_DATA);
end
%==============================================================

function [Vc,Ve,dVc,dVe] = sinevol(theta, ENGINE_DATA)
% sinusoidal drive volume variations and derivatives
% Israel Urieli, 7/6/2002
% Argument:  theta - current cycle angle [radians]
% Returned values: 
%   vc, ve - compression, expansion space volumes [m^3]
%   dvc, dve - compression, expansion space volume derivatives 

Vclc = ENGINE_DATA.Vclc;
Vcle = ENGINE_DATA.Vcle;
Vswc = ENGINE_DATA.Vswc;
Vswe = ENGINE_DATA.Vswe;
alpha = ENGINE_DATA.alpha;

% Vclc Vcle % compression,expansion clearence vols [m^3]
% Vswc Vswe % compression, expansion swept volumes [m^3]
% alpha % phase angle advance of expansion space [radians]

Vc = Vclc + 0.5*Vswc*(1 + cos(theta));
Ve = Vcle + 0.5*Vswe*(1 + cos(theta + alpha));
dVc = -0.5*Vswc*sin(theta);
dVe = -0.5*Vswe*sin(theta + alpha);
%==============================================================

function [Vc,Ve,dVc,dVe] = yokevol(theta, ENGINE_DATA)
% Ross yoke drive volume variations and derivatives
% Israel Urieli, 7/6/2002
% Modified by Connor Speer, October 2017.
% Argument:  theta - current cycle angle [radians]
% Returned values: 
%   Vc, Ve - compression, expansion space volumes [m^3]
%   dVc, dVe - compression, expansion space volume derivatives 

% compression,expansion clearence vols [m^3]
Vclc = ENGINE_DATA.Vclc;
Vcle = ENGINE_DATA.Vcle;

b1 = ENGINE_DATA.b1; % Ross yoke length (1/2 yoke base) [m]
b2 = ENGINE_DATA.b2; % Ross yoke height [m]
crank = ENGINE_DATA.crank; % crank radius [m]

% area of compression/expansion pistons [m^2]
acomp = ENGINE_DATA.acomp; 
aexp = ENGINE_DATA.aexp;

ymin = ENGINE_DATA.ymin; % minimum yoke vertical displacement [m]
	
sinth = sin(theta);
costh = cos(theta);
bth = (b1^2 - (crank*costh)^2)^0.5;
ye = crank*(sinth + (b2/b1)*costh) + bth;
yc = crank*(sinth - (b2/b1)*costh) + bth;

Ve = Vcle + aexp*(ye - ymin);
Vc = Vclc + acomp*(yc - ymin);
dVc = acomp*crank*(costh + (b2/b1)*sinth + crank*sinth*costh/bth);
dVe = aexp*crank*(costh - (b2/b1)*sinth + crank*sinth*costh/bth); 
%==============================================================

function [Vc,Ve,dVc,dVe] = rockvol(theta, ENGINE_DATA)
% Ross Rocker-V drive volume variations and derivatives
% Israel Urieli, 7/6/2002 & Martine Long 2/25/2005
% Argument:  theta - current cycle angle [radians]
% Returned values: 
%   vc, ve - compression, expansion space volumes [m^3]
%   dvc, dve - compression, expansion space volume derivatives 

global vclc vcle % compression,expansion clearence vols [m^3]
global crank % crank radius [m]
global acomp aexp % area of compression/expansion pistons [m^2]
global conrodc conrode % length of comp/exp piston connecting rods [m]
global ycmax yemax % maximum comp/exp piston vertical displacement [m]
	
sinth = sin(theta);
costh = cos(theta);
beth = (conrode^2 - (crank*costh)^2)^0.5;
bcth = (conrodc^2 - (crank*sinth)^2)^0.5;
ye = beth - crank*sinth;
yc = bcth + crank*costh;

Ve = vcle + aexp*(yemax - ye);
Vc = vclc + acomp*(ycmax - yc);
dVc = acomp*crank*sinth*(crank*costh/bcth + 1);
dVe = -aexp*crank*costh*(crank*sinth/beth - 1); 
 

 function [Vc,Ve,dVc,dVe] = gammasinvol(theta, ENGINE_DATA)
% gamma sinusoidal drive volume variations and derivatives
% Added by Connor Speer - January 2017
% Argument:  theta - current cycle angle [radians]
% Returned values: 
%   vc, ve - compression, expansion space volumes [m^3]
%   dvc, dve - compression, expansion space volume derivatives 

global vclp vcld % piston, displacer clearence vols [m^3]
global vswp vswd % compression, expansion swept volumes [m^3]
global beta % phase angle advance of displacer motion over piston [radians]

%*** Total volume is maximum at theta = 0 for gammas.
 Vc = vcld + vclp + (vswd*0.5)*(1 + ((vswp/vswd)*(1+cos(theta)) - cos(theta+beta)));
 Ve = vcld + (vswd*0.5)*(1 + cos(theta+beta));
 dVc = -(vswd*0.5)*(((vswp/vswd)*sin(theta)) - sin(theta+beta));
 dVe = -(vswd*0.5)*sin(theta+beta);
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

 function [Vc,Ve,dVc,dVe] = alphacrankvol(theta, ENGINE_DATA)
% alpha crankshaft drive volume variations and derivatives
% Added by Connor Speer - February 2017
% Argument:  theta - current cycle angle [radians]
% Returned values: 
%   vc, ve - compression, expansion space volumes [m^3]
%   dvc, dve - compression, expansion space volume derivatives 

vclc = ENGINE_DATA.Vclc;
vcle = ENGINE_DATA.Vcle;
Cbore = ENGINE_DATA.Cbore;
Ebore = ENGINE_DATA.Ebore;
Cr1 = ENGINE_DATA.Cr1;
Cr2 = ENGINE_DATA.Cr2;
Cr3 = ENGINE_DATA.Cr3;
Er1 = ENGINE_DATA.Er1;
Er2 = ENGINE_DATA.Er2;
Er3 = ENGINE_DATA.Er3;
alpha = ENGINE_DATA.alpha;

% vclc vcle % compression, expansion clearence vols [m^3]
% Cbore Ebore % compression, expansion piston bores [m]
% Cr1 Er1 % compression, expansion desaxe offset in [m]
% Cr2 Er2 % compression, expansion crank length (half stroke) in [m]
% Cr3 Er3 % compression, expansion connecting rod lengths [m]
% alpha % phase angle advance of expansion space [radians]

%*** Compression space volume is maximum at theta = 0 for alphas. Be
% careful defining crank angle 0 if using a desaxe offset.
Ctheta2 = theta - pi;
Etheta2 = Ctheta2 + alpha;

Ctheta3 = pi - asin((-Cr1+(Cr2*sin(Ctheta2)))/Cr3);
Cr4 = Cr2*cos(Ctheta2) - Cr3*cos(Ctheta3);
Cr4max = sqrt(((Cr2+Cr3)^2)-(Cr1^2));
Vc = vclc + ((pi/4)*(Cbore^2))*(Cr4max-Cr4);

Etheta3 = pi - asin((-Er1+(Er2*sin(Etheta2)))/Er3);
Er4 = Er2*cos(Etheta2) - Er3*cos(Etheta3);
Er4max = sqrt(((Er2+Er3)^2)-(Er1^2));
Ve = vcle + ((pi/4)*(Ebore^2))*(Er4max-Er4);

dCtheta3 = (-Cr2*cos(Ctheta2))/(Cr3*sqrt(1-(((-Cr1+(Cr2*sin(Ctheta2)))/Cr3).^2)));
dCr4 = -Cr2*sin(Ctheta2) + Cr3*sin(Ctheta3)*dCtheta3;
dVc = -(pi/4)*(Cbore^2)*(dCr4);

dEtheta3 = (-Er2*cos(Etheta2))/(Er3*sqrt(1-(((-Er1+(Er2*sin(Etheta2)))/Er3).^2)));
dEr4 = -Er2*sin(Etheta2) + Er3*sin(Etheta3)*dEtheta3;
dVe = -(pi/4)*(Ebore^2)*(dEr4);
%==============================================================

function [Vc,Ve,dVc,dVe,V_buffer] = bellcrankvol(theta, ENGINE_DATA)
% gamma double bellcrank drive volume variations and derivatives
% Added by Connor Speer - July 2019
% Argument:  theta - current cycle angle (radians)
% Returned values: 
%   Vc, Ve - compression, expansion space volumes (m^3)
%   dVc, dVe - compression, expansion space volume derivatives 

theta2 = 2*pi - theta; % Crankshaft spins CW when the engine is running.

Pbore = ENGINE_DATA.Pbore; %(m) - Piston bore diameter

b1_p = ENGINE_DATA.b1_p; %(m)
b2_p = ENGINE_DATA.b2_p; %(m)
b3_p = ENGINE_DATA.b3_p; %(m)
rG8y_p_min = ENGINE_DATA.rG8y_p_min; %(m)
r2 = ENGINE_DATA.r2; %(m)
r3_p = ENGINE_DATA.r3_p; %(m)
r4_p = ENGINE_DATA.r4_p; %(m)
r5_p = ENGINE_DATA.r5_p; %(m)
r6_p = ENGINE_DATA.r6_p; %(m)
r7_p = ENGINE_DATA.r7_p; %(m)

Vclp = ENGINE_DATA.Vclp; %(m^3)

Dbore = ENGINE_DATA.Dbore; %(m) - Displacer bore diameter

b1_d = ENGINE_DATA.b1_d; %(m)
b2_d = ENGINE_DATA.b2_d; %(m)
b3_d = ENGINE_DATA.b3_d; %(m)
rG8y_d_min = ENGINE_DATA.rG8y_d_min; %(m)
rG8y_d_max = ENGINE_DATA.rG8y_d_max; %(m)
r3_d = ENGINE_DATA.r3_d; %(m)
r4_d = ENGINE_DATA.r4_d; %(m)
r5_d = ENGINE_DATA.r5_d; %(m)
r6_d = ENGINE_DATA.r6_d; %(m)
r7_d = ENGINE_DATA.r7_d; %(m)

Vcld_top = ENGINE_DATA.Vcld_top; %(m^3)
Vcld_bottom = ENGINE_DATA.Vcld_bottom; %(m^3)

V_disprod_min = ENGINE_DATA.V_disprod_min; %(m^3)
d_disprod = ENGINE_DATA.d_disprod; %(m)

% Displacer Mechanism Constants
r1_d = sqrt(b1_d^2 + b2_d^2); %(m)
phi_d = atan(b1_d/b2_d); %(rad)

gamma_d = acos((r4_d^2 + r5_d^2 - r6_d^2)/(2*r4_d*r5_d)); %(rad)

h1_d = r1_d/r2; %(unitless)
h3_d = r1_d/r4_d; %(unitless)
h5_d = (r1_d^2 + r2^2 - r3_d^2 + r4_d^2)/(2*r2*r4_d); %(unitless)

% Piston Mechanism Constants
r1_p = sqrt(b1_p^2 + b2_p^2); %(m)
phi_p = atan(b1_p/b2_p); %(rad)

gamma_p = acos((r4_p^2 +r5_p^2 - r6_p^2)/(2*r4_p*r5_p)); %(rad)

h1_p = r1_p/r2; %(unitless)
h3_p = r1_p/r4_p; %(unitless)
h5_p = (r1_p^2 + r2^2 - r3_p^2 + r4_p^2)/(2*r2*r4_p); %(unitless)

b_d = -2*sin(theta2 - phi_d); %(unitless)
d_d = -h1_d + (1 - h3_d)*cos(theta2 - phi_d) + h5_d; %(unitless)
e_d = h1_d - (1 + h3_d)*cos(theta2 - phi_d) + h5_d; %(unitless)

theta4_d = (2*atan((-b_d - (b_d^2 - 4*d_d*e_d)^0.5)/(2*d_d)) + phi_d); %(rad)

theta5_d = theta4_d + gamma_d; %(rad)

theta7_d = pi - asin((-b1_d - b3_d - r5_d*sin(theta5_d))/(r7_d)); %(rad)

rG8y_d = b2_d + r5_d*cos(theta5_d) + r7_d*cos(theta7_d);

dtheta5_d = -(2*((2*cos(phi_d - theta2) + (8*cos(phi_d - theta2)*sin(phi_d - theta2) ...
    + sin(phi_d - theta2)*(h3_d + 1)*(4*h1_d - 4*h5_d + 4*cos(phi_d - theta2)*(h3_d - 1)) ...
    - 4*sin(phi_d - theta2)*(h3_d - 1)*(h1_d + h5_d - cos(phi_d - theta2)*(h3_d + 1))) ...
    /(2*(4*sin(phi_d - theta2)^2 + (4*h1_d - 4*h5_d + 4*cos(phi_d - theta2)*(h3_d - 1)) ...
    *(h1_d + h5_d - cos(phi_d - theta2)*(h3_d + 1)))^(1/2)))/(2*h1_d - 2*h5_d ...
    + 2*cos(phi_d - theta2)*(h3_d - 1)) + (2*sin(phi_d - theta2)*(2*sin(phi_d - theta2) ...
    + (4*sin(phi_d - theta2)^2 + (4*h1_d - 4*h5_d + 4*cos(phi_d - theta2)*(h3_d - 1)) ...
    *(h1_d + h5_d - cos(phi_d - theta2)*(h3_d + 1)))^(1/2))*(h3_d - 1)) ...
    /(2*h1_d - 2*h5_d + 2*cos(phi_d - theta2)*(h3_d - 1))^2))/((2*sin(phi_d - theta2) ...
    + (4*sin(phi_d - theta2)^2 + (4*h1_d - 4*h5_d + 4*cos(phi_d - theta2)*(h3_d - 1)) ...
    *(h1_d + h5_d - cos(phi_d - theta2)*(h3_d + 1)))^(1/2))^2/(2*h1_d - 2*h5_d + 2*cos(phi_d - theta2)*(h3_d - 1))^2 + 1);

dtheta7_d = -(2*r5_d*cos(gamma_d + phi_d + 2*atan((2*sin(phi_d - theta2) ...
    + (4*sin(phi_d - theta2)^2 + (4*h1_d - 4*h5_d + 4*cos(phi_d - theta2) ...
    *(h3_d - 1))*(h1_d + h5_d - cos(phi_d - theta2)*(h3_d + 1)))^(1/2)) ...
    /(2*h1_d - 2*h5_d + 2*cos(phi_d - theta2)*(h3_d - 1))))*((2*cos(phi_d - theta2) ...
    + (8*cos(phi_d - theta2)*sin(phi_d - theta2) + sin(phi_d - theta2)*(h3_d + 1) ...
    *(4*h1_d - 4*h5_d + 4*cos(phi_d - theta2)*(h3_d - 1)) - 4*sin(phi_d - theta2) ...
    *(h3_d - 1)*(h1_d + h5_d - cos(phi_d - theta2)*(h3_d + 1)))/(2*(4*sin(phi_d - theta2)^2 ...
    + (4*h1_d - 4*h5_d + 4*cos(phi_d - theta2)*(h3_d - 1))*(h1_d + h5_d - cos(phi_d - theta2) ...
    *(h3_d + 1)))^(1/2)))/(2*h1_d - 2*h5_d + 2*cos(phi_d - theta2)*(h3_d - 1)) ...
    + (2*sin(phi_d - theta2)*(2*sin(phi_d - theta2) + (4*sin(phi_d - theta2)^2 ...
    + (4*h1_d - 4*h5_d + 4*cos(phi_d - theta2)*(h3_d - 1))*(h1_d + h5_d - cos(phi_d - theta2) ...
    *(h3_d + 1)))^(1/2))*(h3_d - 1))/(2*h1_d - 2*h5_d + 2*cos(phi_d - theta2) ...
    *(h3_d - 1))^2))/(r7_d*(1 - (b1_d + b3_d + r5_d*sin(gamma_d + phi_d + 2*atan((2*sin(phi_d - theta2) ...
    + (4*sin(phi_d - theta2)^2 + (4*h1_d - 4*h5_d + 4*cos(phi_d - theta2)*(h3_d - 1)) ...
    *(h1_d + h5_d - cos(phi_d - theta2)*(h3_d + 1)))^(1/2))/(2*h1_d - 2*h5_d + ...
    2*cos(phi_d - theta2)*(h3_d - 1)))))^2/r7_d^2)^(1/2)*((2*sin(phi_d - theta2) ...
    + (4*sin(phi_d - theta2)^2 + (4*h1_d - 4*h5_d + 4*cos(phi_d - theta2) ...
    *(h3_d - 1))*(h1_d + h5_d - cos(phi_d - theta2)*(h3_d + 1)))^(1/2))^2/ ...
    (2*h1_d - 2*h5_d + 2*cos(phi_d - theta2)*(h3_d - 1))^2 + 1));

drG8y_d = -r5_d*sin(theta5_d)*dtheta5_d - r7_d*sin(theta7_d)*dtheta7_d;

% Compression Space
b_p = -2*sin(theta2 + phi_p); %(unitless)
d_p = -h1_p + (1 - h3_p)*cos(theta2 + phi_p) + h5_p; %(unitless)
e_p = h1_p - (1 + h3_p)*cos(theta2 + phi_p) + h5_p; %(unitless)

theta4_p = (2*pi) + (2*atan((-b_p + (b_p^2-4*d_p*e_p)^0.5)/(2*d_p)) - phi_p); %(rad)

theta5_p = theta4_p - gamma_p; %(rad)

theta7_p = pi - asin((b1_p + b3_p - r5_p*sin(theta5_p))/(r7_p)); %(rad)

rG8y_p = b2_p + r5_p*cos(theta5_p) + r7_p*cos(theta7_p);

V_disprod = V_disprod_min + (rG8y_d_max - rG8y_d)*(pi/4)*(d_disprod^2); %(m^3)
dV_disprod = (pi/4)*(d_disprod^2)*drG8y_d;

dtheta5_p = -(2*((2*cos(phi_p + theta2) + (8*cos(phi_p + theta2)*sin(phi_p + theta2) ...
    + sin(phi_p + theta2)*(h3_p + 1)*(4*h1_p - 4*h5_p + 4*cos(phi_p + theta2)*(h3_p - 1)) ...
    - 4*sin(phi_p + theta2)*(h3_p - 1)*(h1_p + h5_p - cos(phi_p + theta2)*(h3_p + 1))) ...
    /(2*(4*sin(phi_p + theta2)^2 + (4*h1_p - 4*h5_p + 4*cos(phi_p + theta2)*(h3_p - 1)) ...
    *(h1_p + h5_p - cos(phi_p + theta2)*(h3_p + 1)))^(1/2)))/(2*h1_p - 2*h5_p ...
    + 2*cos(phi_p + theta2)*(h3_p - 1)) + (2*sin(phi_p + theta2)*(2*sin(phi_p + theta2) ...
    + (4*sin(phi_p + theta2)^2 + (4*h1_p - 4*h5_p + 4*cos(phi_p + theta2)*(h3_p - 1)) ...
    *(h1_p + h5_p - cos(phi_p + theta2)*(h3_p + 1)))^(1/2))*(h3_p - 1)) ...
    /(2*h1_p - 2*h5_p + 2*cos(phi_p + theta2)*(h3_p - 1))^2))/((2*sin(phi_p + theta2) ...
    + (4*sin(phi_p + theta2)^2 + (4*h1_p - 4*h5_p + 4*cos(phi_p + theta2)*(h3_p - 1)) ...
    *(h1_p + h5_p - cos(phi_p + theta2)*(h3_p + 1)))^(1/2))^2/(2*h1_p - 2*h5_p + 2*cos(phi_p + theta2)*(h3_p - 1))^2 + 1);

dtheta7_p = -(2*r5_p*cos(gamma_p + phi_p + 2*atan((2*sin(phi_p + theta2) ...
    + (4*sin(phi_p + theta2)^2 + (4*h1_p - 4*h5_p + 4*cos(phi_p + theta2) ...
    *(h3_p - 1))*(h1_p + h5_p - cos(phi_p + theta2)*(h3_p + 1)))^(1/2)) ...
    /(2*h1_p - 2*h5_p + 2*cos(phi_p + theta2)*(h3_p - 1))))*((2*cos(phi_p + theta2) ...
    + (8*cos(phi_p + theta2)*sin(phi_p + theta2) + sin(phi_p + theta2)*(h3_p + 1) ...
    *(4*h1_p - 4*h5_p + 4*cos(phi_p + theta2)*(h3_p - 1)) - 4*sin(phi_p + theta2) ...
    *(h3_p - 1)*(h1_p + h5_p - cos(phi_p + theta2)*(h3_p + 1)))/(2*(4*sin(phi_p + theta2)^2 ...
    + (4*h1_p - 4*h5_p + 4*cos(phi_p + theta2)*(h3_p - 1))*(h1_p + h5_p - cos(phi_p + theta2) ...
    *(h3_p + 1)))^(1/2)))/(2*h1_p - 2*h5_p + 2*cos(phi_p + theta2)*(h3_p - 1)) ...
    + (2*sin(phi_p + theta2)*(2*sin(phi_p + theta2) + (4*sin(phi_p + theta2)^2 ...
    + (4*h1_p - 4*h5_p + 4*cos(phi_p + theta2)*(h3_p - 1))*(h1_p + h5_p - cos(phi_p + theta2) ...
    *(h3_p + 1)))^(1/2))*(h3_p - 1))/(2*h1_p - 2*h5_p + 2*cos(phi_p + theta2) ...
    *(h3_p - 1))^2))/(r7_p*((2*sin(phi_p + theta2) + (4*sin(phi_p + theta2)^2 ...
    + (4*h1_p - 4*h5_p + 4*cos(phi_p + theta2)*(h3_p - 1))*(h1_p + h5_p ...
    - cos(phi_p + theta2)*(h3_p + 1)))^(1/2))^2/(2*h1_p - 2*h5_p ...
    + 2*cos(phi_p + theta2)*(h3_p - 1))^2 + 1)*(1 - (b1_p + b3_p + r5_p ...
    *sin(gamma_p + phi_p + 2*atan((2*sin(phi_p + theta2) + (4*sin(phi_p + theta2)^2 ...
    + (4*h1_p - 4*h5_p + 4*cos(phi_p + theta2)*(h3_p - 1))*(h1_p + h5_p -  ...
    cos(phi_p + theta2)*(h3_p + 1)))^(1/2))/(2*h1_p - 2*h5_p + 2*cos(phi_p + theta2)*(h3_p - 1)))))^2/r7_p^2)^(1/2));

drG8y_p = -r5_p*sin(theta5_p)*dtheta5_p - r7_p*sin(theta7_p)*dtheta7_p;

DVe = Vcld_top + (pi/4)*(Dbore^2)*(rG8y_d - rG8y_d_min);
PVe = Vclp + (pi/4)*(Pbore^2)*(rG8y_p - rG8y_p_min);
dDVe = -(pi/4)*(Dbore^2)*drG8y_d;
dPVe = -(pi/4)*(Pbore^2)*drG8y_p;

% Derivatives above have a negative sign in front to allow for the CW
% crankshaft direction.
Ve = DVe + PVe; %(m^3)
dVe = dDVe + dPVe;
Vc = Vcld_bottom + (pi/4)*(Dbore^2)*(rG8y_d_max - rG8y_d_min) - DVe - V_disprod; %(m^3)
dVc = -dDVe - dV_disprod;

% Crankcase Volume Variations in (m^3) --> COULD ADD DISPLACER ROD TO THIS, BUT IT WOULD MAKE A VERY SMALL DIFFERENCE.
V_buffer = ENGINE_DATA.V_buffer_max - PVe; 
%==========================================================================