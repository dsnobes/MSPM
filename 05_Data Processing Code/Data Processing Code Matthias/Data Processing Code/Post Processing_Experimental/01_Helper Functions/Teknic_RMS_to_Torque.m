function [Teknic_Nm] = Teknic_RMS_to_Torque(Teknic_RMS, Teknic_RPM)

%% Written by Connor Speer, May 2019

% Takes the RMS percentage readings from the MSP software and converts them
% to torque using the torque speed curve provided by Teknic.

% Inputs:
%--> Teknic_RMS (%), vector of RMS values read off the MSP screen.
%--> Teknic_RPM (RPM), vector of setpoints of the Teknic, can also be read off of MSP

% Outputs:
%--> Teknic_Nm (Nm), vector of torque applied by the Teknic


%% Import data from spreadsheet
opts = spreadsheetImportOptions("NumVariables", 2);
opts.Sheet = "Sheet1";
opts.DataRange = "A3:B60";
opts.VariableNames = ["dig_speed", "dig_Nm"];
opts.SelectedVariableNames = ["dig_speed", "dig_Nm"];
opts.VariableTypes = ["double", "double"];
tbl = readtable("T:\01_Engineering\00_Stirling Engine Development\10_Lab Equipment\Teknic Motor\Digitized Teknic Torque Curve.xlsx", opts, "UseExcel", false);
dig_speed = tbl.dig_speed;
dig_Nm = tbl.dig_Nm;
clear opts tbl

%% Fit curve to digitized data
X = dig_speed; %(Hz)
Y = dig_Nm; %(Pa)
[max_torque_fit,~] = fit(X,Y,'cubicinterp');

% figure
% plot(f,X,Y)
% xlabel('Motor Speed (RPM)')
% ylabel('Torque (Nm)')

%% Use fitted curve equation to calculate max torques from speed input
max_torques = max_torque_fit(Teknic_RPM); %(Nm)

%% Use the RMS input to calculate to calculate the actual torques
Teknic_Nm = 0.01.*Teknic_RMS.*max_torques; %(Nm)