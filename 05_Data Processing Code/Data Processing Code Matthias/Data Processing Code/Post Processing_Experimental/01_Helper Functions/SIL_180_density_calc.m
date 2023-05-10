function density = SIL_180_density_calc(hot_bath_setpoint)

% Written by Connor Speer, May 2019
% Calculates the mass flow rate of SIL 180 for the given hot bath setpoint
% using results of a  bucket test calibration.

% Inputs
% hot_bath_setpoint --> hot bath setpoint in deg C

% Outputs
% density -->  SIL 180 density in (kg/m3).

%% Input Calibration Results

% Matthias, 2021 Dec 08 (measured Toan and Nico)
temps = [49.5 61.5 72.3 80.1 89.8 100.1 112 120 130 141 152 160 170]; % Hot bath setpoints in deg C for calibration test.
measured_dens = [902 894.12 889.8 886.6 874.75 862.75 860.42 855.1 845.36 836.73 828.57 816.33 813.86]; % Heater mass flow rates in (kg/s).
% temps = [21.5 30.1 49.5 61.5 72.3 80.1 89.8 100.1 112 120 130 141 152 160 170]; % Hot bath setpoints in deg C for calibration test.
% measured_dens = [932.32 904 902 894.12 889.8 886.6 874.75 862.75 860.42 855.1 845.36 836.73 828.57 816.33 813.86]; % Heater mass flow rates in (kg/s).

% Fit curves to calibration data
[fit_dens,gof] = fit(temps',measured_dens','poly2');

% Extract the fit coefficients
fit_coefficients = coeffvalues(fit_dens);
    
%% Calculate the density of SIL 180
p1 = fit_coefficients(1);
p2 = fit_coefficients(2);
p3 = fit_coefficients(3);
density = p1*hot_bath_setpoint^2 + p2*hot_bath_setpoint + p3;

%% Plot Set-Up
% set(0,'defaultfigurecolor',[1 1 1])
% 
% % Location of Figures
% x = 500;
% y = 500;
% 
% % Size of Figures
% width = 550;
% height = 400;
% 
% % Font For Figures
% font = 'Arial';
% font_size = 11;
% 
% %% Plot results to characterize curves
%  
% figure('Position', [x y width height])
% plot(fit_dens,temps,measured_dens)
% xlabel('Hot Bath Setpoint (\circC)')
% ylabel('SIL 180 Density')
% set(gca,'fontsize',font_size)
% set(gca,'FontName',font)
% text(mean(temps), mean(measured_dens), "R^2 = "+ gof.rsquare)