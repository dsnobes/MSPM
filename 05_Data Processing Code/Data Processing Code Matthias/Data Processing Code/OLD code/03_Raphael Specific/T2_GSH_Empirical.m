function P_hys = T2_GSH_Empirical(Hz,pmean_CC,Config_code)
% Written by Connor Speer - August 2017
% Updated for T2 engine by Connor Speer -  May 2019

% Calculates the gas spring hysteresis loss for the the high temperature
% gamma engine with the 85mm piston.
% Based on a surface fit that is a second degree polynomial in the x and y
% directions. 'poly22'.

% Inputs:
% Hz --> engine speed in [Hz]
% pmean --> engine mean pressure in [Pa]
% Config_code --> code specifying the buffer space configuration
% 1 --> Big CC extension
% 2 --> 

x = Hz;
y = pmean_CC;

switch Config_code
    case 1
    p00 = 1.64;
    p10 = -0.5752;
    p01 = 8.081e-06;
    p20 = 0.3882;
    p11 = -3.421e-06;
    p02 = 1.356e-11;
end
    
    
P_hys = p00 + p10.*x + p01.*y + p20.*x.^2 + p11.*x.*y + p02.*y.^2; %[W]

