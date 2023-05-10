function [m_dot_DCH, m_dot_heater] = SIL_180_flow_rate_calc(hot_bath_setpoint)

% Written by Connor Speer, May 2019
% Calculates the mass flow rate of SIL 180 for the given hot bath setpoint
% using results of a  bucket test calibration.

% Inputs
% hot_bath_setpoint --> hot bath setpoint in deg C

% Outputs
% m_dot_DCH --> Displacer Cylinder Head SIL 180 mass flow rate in (kg/s).
% m_dot_heater --> Heater SIL 180 mass flow rate in (kg/s).

%% Input Calibration Results
% Connor's values
% temps = [60 80 100 120 150]; % Hot bath setpoints in deg C for calibration test.
% mfrate_DCH = [0.03165 0.03580 0.03885 0.04185 0.04460]; % DCH mass flow rates in (kg/s).
% mfrate_heater = [0.03175 0.03505 0.03830 0.04075 0.04280]; % Heater mass flow rates in (kg/s).

% Matthias, 2021 Dec 08 (measured Toan and Nico)
temps = 70:20:150; % Hot bath setpoints in deg C for calibration test.
% DCH heat exchanger disabled!!!!!!!!!!!!!!!
% mfrate_DCH = [0.03165 0.03580 0.03885 0.04185 0.04460]; % DCH mass flow rates in (kg/s).
mfrate_heater = [0.047050568 0.05155111 0.053543139 0.054037953 0.054598534]; % Heater mass flow rates in (kg/s).

% Fit curves to calibration data
% [fit_DCH,gof_DCH] = fit(temps',mfrate_DCH','poly2');
[fit_heater,gof_heater] = fit(temps',mfrate_heater','poly3');
  
%% Calculate the Flow Rate of SIL 180
% m_dot_DCH = p1_DCH*hot_bath_setpoint^2 + p2_DCH*hot_bath_setpoint + p3_DCH;
m_dot_DCH = 0;

m_dot_heater = fit_heater(hot_bath_setpoint);

%% Plot Set-Up
% 
% % % Plot results to characterize curves
% % figure('Position', [x y width height])
% % plot(fit_DCH,temps,mfrate_DCH)
% % xlabel('Hot Bath Setpoint (\circC)')
% % ylabel('SIL 180 Mass Flow Rate (kg/s)')
% % title('Displacer Cylinder Head')
% % set(gca,'fontsize',font_size)
% % set(gca,'FontName',font)
% 
% figure
% plot(fit_heater,temps,mfrate_heater)
% xlabel('Bath Setpoint (\circC)')
% ylabel('Mass Flow Rate (kg/s)')
% cv = coeffvalues(fit_heater);
% txt = "y = " +cv(1)+"*x^3 + " + cv(2)+"*x^2 + " + cv(3)+"*x + " + cv(4)...
%     +newline+ "R^2 = "+ gof_heater.rsquare;
%  text(mean(temps), mean(mfrate_heater), txt)
% nicefigure('thesis_small_wide')

% % Cooler flowrate
% hold on
% plot(5, 0.0235576, 'DisplayName','Cooler')