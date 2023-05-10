% post_process.m - Written by Connor Speer - January 2019
% MSPM post processing added by Matthias Lottmann, January 2022
% Starting point for both experimental and MSPM data post processing.

%% IMPORTANT: For either section, need to specify environment pressure before processing.
% [Pa]
% p_environment = 93.82 *1000; % 200kpa Dec16
% p_environment = 91.03 *1000; %350kpa 23 Dec
% p_environment = 93.78 *1000; %450kpa 14-Jan
% p_environment = 93.19 *1000; %400kpa 28-Jan

% p_environment = repelem([93.82 91.03 93.78 93.19]*1000, 2); %Combination, in order of pressure - setpoint number
% p_environment = [93.82 91.03 93.78 93.19]*1000; %Combination, in order as processed
% p_environment = p_environment([1,2,4,3, 2,4,1,3]);

% p_environment = p_environment([4,4,4,4,1,1,1,1]);
% p_environment = p_environment([4,4,1,1]);
% p_environment = p_environment([4,1]);
% p_environment = p_environment([1,1,4,4,4,4,1,1]);

% p_environment = 94.12 *1000; %TH130 Reg94 16-Feb
% p_environment = 94.25 *1000; %TH130 Reg97 02-Mar
% p_environment = 93.91 *1000; %TH130 Reg97 03-Mar
% p_environment = 93.17 *1000; %TH130 Reg97 16-Mar
% p_environment = 93.20 *1000; %TH130 Reg97 29-Mar
% p_environment = 94 *1000; % Standard pressure

p_environment = 0; 

%% Run this section for MSPM data processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Environment pressure will be subtracted from MSPM
% pressure outputs to obtain relative pressure, which is comparable to
% experiment pressure data.
% Also specify engine layout so that PVs are processed correctly. In
% 'DataExtract' must adjust 'PV_order' according to oder of PV data in
% PVoutput file.
% IMPORTANT: Folder name should contain 'TH', 'TC', 'p' followed by
% setpoint parameters. These are extracted from folder name and included in
% the output.
layout = 'alpha';
% layout = 'gamma';
DataExtract(p_environment,layout);


%% Run this section for experiment data processing %%%%%%%%%%%%%%%%%%%%%%%%
% Calls calibration, data reduction, and modeling sub-functions to
% post-process data in a given list of folders. Plotting will be done
% elsewhere.

%    clear, clc, close all;

% User selects an ENGINE_DATA structure to use for model inputs
ENGINE_DATA = T2_ENGINE_DATA;

% User selects a folder to post process.
path = 'G:\Shared drives\NOBES_GROUP\MSPM\[MATLAB_WORKING_FOLDER]\Data Processing Code\06_Post Processing_Experimental\[Experimental Data]';
Raw_Data_Folder = uigetdir(path,'Choose folder to post process.');

% Call to calibrate sub-function
% NOTE: Calibration data path is specifid in 'calibrate.m'
calibrate(Raw_Data_Folder)

% Call to 'reduce' sub-function. 
% If 'short_output' is true, raw data is not included in output file.
% Environment pressure is stored in RD_DATA as 'p_atm'
short_output = true;
have_DCH_source = false;
reduce(Raw_Data_Folder, ENGINE_DATA, short_output, have_DCH_source, p_environment);


