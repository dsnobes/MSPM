function c_hot = SIL_180_specific_heat_calc(T_hot)

% Written by Matthias Lottmann, Jan 2022
% based on Connor's flow rate calc function
% Calculates the specific heat of SIL 180 for a given temperature.

% Data for SIL 180 only available at 20C: 
% c_hot = 1510; %(J/kgK) - for SIL 180 at 20 deg C
% Temperature dependent data available for similar oil Dow SYLTHERM 800: 
% https://www.dow.com/documents/en-us/app-tech-guide/176/176-01435-01-syltherm-800-heat-transfer-fluid.pdf
% https://www.dow.com/content/dcc/en-us/category/market/mkt-building-construction/sub-build-heating-cooling-refrigeration/heat-transfer-fluid-synthetic-calculator?ffc_type=synthetic
% https://www.dow.com/en-us/pdp.syltherm-800-stabilized-heat-transfer-fluid.39260z.html

% Inputs
% T_hot --> oil temperature in deg C

% Outputs
% c_hot --> Specific Heat Capacity in (J/kgK).

%% Inputs 
c_SIL_180_20C = 1510; %(J/kgK) - for SIL 180 at 20 deg C
c_S800_20C = 1608; %(J/kgK) - for SYLTHERM 800 at 20 deg C
temps = 70:10:160; % (deg C)
c_S800 = [1694 1711 1728 1745 1762 1779 1796 1813 1830 1847]; %(J/kgK) - for SYLTHERM 800 at temps

% Fit curve to data
[fit_c,gof] = fit(temps',c_S800','poly1');
  
%% Estimate the Heat Capacity of SIL 180
% assume that specific heat curve of SIL 180 has constant offset from curve
% of SYLTHERM 800.
c_hot = fit_c(T_hot) +c_SIL_180_20C -c_S800_20C;


 %% Plot Set-Up
% 
% figure
% hold on
% plot(temps, fit_c(temps), 'b','DisplayName','SYL800 data')%,temps,c_S800)
% plot(temps, fit_c(temps)+c_SIL_180_20C -c_S800_20C, 'r','DisplayName','Sil 180 estimate')%,temps,c_S800)
% plot(20, c_S800_20C, 'ob', 'DisplayName','SYL800, 20 \circC')
% plot(20, c_SIL_180_20C, 'or', 'DisplayName','Sil 180, 20 \circC')
% % plot(temps,c_hot,'g', 'DisplayName','SIL 180 estimate')
% 
% legend
% xlabel('Temperature (\circC)')
% ylabel('Specific Heat (J/kg K)')
% nicefigure('thesis_small_wide')
% % text(mean(temps), mean(c_S800), "R^2 = "+ gof.rsquare)