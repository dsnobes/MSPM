function [RunConditions] = AA_FromExpData_orPredefined()
% Written by Sara Eghbali and Connor Speer, September 2021.
% Completely redone with automated data import and new input parameters by
% Matthias Lottmann, 2022
% if USE_EXPERIMENT = 1: 
% extracts the operating points from a set of experimental data and forms
% an MSPM test set.
% if USE_EXPERIMENT = 0: 
% makes test set from models and parameters defined in section below.

%% Defines how RunConditions will be defined (below)
USE_EXPERIMENT = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Input Parameters. MAKE SURE THIS SECTION IS CORRECT, THEN RUN SCRIPT

model = {
%     'ThermoHeart_V1'
%     'ThermoHeart_V1_run2'
    'Scaling_Tube_Bank_Gamma'
%     'Scaling_Tube_Bank_Thermoheart'
%     'Scaling_Tube_Bank_Gamma_flow_improved'
%     'Scaling_Tube_Bank_Gamma_Run2'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_one_exp_body'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_one_exp_body_AppGapSplit'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_one_exp_body_DPseal'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_one_exp_body_DPseal_HXinsulated'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_one_exp_body_DPseal_HXsteel'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_one_exp_body_DPseal_HXcopper'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_one_exp_body_DPseal_DPinsulator'
    };
%Specifiy for which models the last part of the model name (after last '_') should be included in run title. 
model_in_title = [0]; 

% Default parameters
simTime = 600; %(s) Simulation time.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
minCycles = 30;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SS = true; % Steady state toggle.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
movement_option = 'C';
% movement_option = 'V';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
max_dt = 0.1; %(s) Maximum time step.
% NodeFactor = 1;
% h_custom_Source = [281.3 79.3];
% h_custom_Sink = [735.065 383.2];

% h_custom_Source = [140:20:300]; % 1st h_custom variation test
% h_custom_Sink = [600:50:1000];

% h_custom_Source = [200:40:400]; % Model 1 h variation test
% h_custom_Sink = [550:80:950];

% h_custom_Source = [80:20:280]; % Model 3 h variation test
% h_custom_Sink = [380:40:740];

% h_custom_Source = 79.3; % h_empirical
% h_custom_Sink = 383.2;
% h_custom_Source = 281.3; % h_CFD
% h_custom_Sink = 735.065;
% h_custom_Source = NaN; % no_h
% h_custom_Sink = NaN;

% h_custom_Source = [52.8 39.6]; %For Raphael Uniform_Scale test, factor [1.5 2]
% h_custom_Sink = [255.5 191.6];

% h_custom_Source = [304.35]; %Tube bank Gamma, size and HX flow rate from Raphael
% h_custom_Sink = [777.25];

% Uniform_Scale = [1.5 2];
% HX_Convection = 1;

% X_Scale = sqrt(10);
% X_Scale = sqrt([1:10, 15:5:100]);
% X_Scale = sqrt([1]);

p_environment = 0;

% Optimum p and speed for X_Scale=1
% PMEAN = (2:2:10) *1e5;
% SPEED = 210;

% For ThermoHeart
% PMEAN = (10:10:40) *1e5;
% SPEED = 250:100:650;
TH = 150;
PMEAN = 13 *1e5*(9:12);
SPEED = 210 ;
TC = 5;
TC = repelem(TC, 1, length(TH));
% h_custom_Source = NaN;
% h_custom_Sink = nan;
% Reg_dw = [30:10:100, 125:25:200, 250:50:500]*1e-6; %Micrometers
% Reg_Porosity = 0.5:0.05:0.95;
% Reg_dw = [100:25:200, 250:50:300]*1e-6; %Micrometers
% Reg_Porosity = 0.6:0.05:0.85;
% Reg_dw = [200]*1e-6; %Micrometers
% Reg_Porosity = 0.6;
% Reg_dw1 = Reg_dw(1:2:end);
% Reg_dw2 = Reg_dw(2:2:end);
% %%%%%%%%%%%%%%%%
% Reg_dw =Reg_dw2;
%%%%%%%%%%%%%%%%

% h_custom_Source = 304.35 * (0.75:0.25:2);
% h_custom_Sink = 777.25 * (0.75:0.25:2);

Gas = {'AIR','Helium Gas','H2 Gas'};



%% Create MSPM Test Structure for each selected experimental file
RunConditions_temp = struct(...
    'Model', model{1},...
    'title','',...
    'simTime', simTime,... [s]
    'SS', SS,...
    'movement_option', movement_option,...
    'rpm', 60,... [rpm]
    'max_dt', max_dt,... [s]
    'SourceTemp',150 + 273.15,... [K]
    'SinkTemp',5 + 273.15,... [K]
    'EnginePressure',101325,...
    'h_custom_Source', NaN,...
    'h_custom_Sink', NaN,... 
    'Gas', 'AIR',...
    'minCycles', minCycles);
%     'Reg_Porosity',0.9,...
%     'Reg_dw',1e-4);
%     'X_Scale', 1,... 
%     'NodeFactor', NodeFactor,...
%     'SpeedBounds', NaN);
%     'PressureBounds', NaN);%,...
%     'Uniform_Scale', 1);%,...
%     'HX_Convection', HX_Convection);


%% Use setpoints defined at top 
if ~USE_EXPERIMENT
n=1;
for i = 1:length(model)
for g = Gas
% for xsc = X_Scale
for pmean = PMEAN
for speed = SPEED
for it = 1:length(TH)
% for ih = 1:length(h_custom_Source)
% for dw = Reg_dw
% for Por = Reg_Porosity
        
    RunConditions(n) = RunConditions_temp;
    RunConditions(n).Model = model{i};
%     RunConditions(n).Reg_dw = dw;
%     RunConditions(n).Reg_Porosity = Por;
%     RunConditions(n).X_Scale = xsc;
    RunConditions(n).Gas = g{1};
   RunConditions(n).SourceTemp = TH(it) + 273.15;
    RunConditions(n).SinkTemp = TC(it) + 273.15;
%     RunConditions(n).h_custom_Source = h_custom_Source(ih);
%     RunConditions(n).h_custom_Sink = h_custom_Sink(ih);
%     RunConditions(n).EnginePressure = pmean*xsc^2;
    RunConditions(n).EnginePressure = pmean + p_environment;
%     RunConditions(n).rpm = speed*xsc^2; %To scale speed and number of HX tubes proportionally
    RunConditions(n).rpm = speed;
%     RunConditions(n).title = [RunConditions(n).Model '_TH' num2str(RunConditions(n).SourceTemp-273.15) '_TC' num2str(RunConditions(n).SinkTemp-273.15) '_p' num2str((RunConditions(n).EnginePressure-p_environment)/1000) '_rpm' num2str(RunConditions(n).rpm) '_RegDW' num2str(RunConditions(n).Reg_dw) '_RegPor' num2str(RunConditions(n).Reg_Porosity)];
%     RunConditions(n).title = [RunConditions(n).Model '_TH' num2str(RunConditions(n).SourceTemp-273.15) '_TC' num2str(RunConditions(n).SinkTemp-273.15) '_p' num2str((RunConditions(n).EnginePressure-p_environment)/1000) '_rpm' num2str(RunConditions(n).rpm)];
%     RunConditions(n).title = [RunConditions(n).Model '_TH' num2str(RunConditions(n).SourceTemp-273.15) '_TC' num2str(RunConditions(n).SinkTemp-273.15) '_p' num2str((RunConditions(n).EnginePressure-p_environment)/1000) '_rpm' num2str(RunConditions(n).rpm) '_hSource_' num2str(round(RunConditions(n).h_custom_Source)) '_hSink_' num2str(round(RunConditions(n).h_custom_Sink))];
%     RunConditions(n).title = [RunConditions(n).Model '_TH' num2str(RunConditions(n).SourceTemp-273.15) '_TC' num2str(RunConditions(n).SinkTemp-273.15) '_p' num2str((RunConditions(n).EnginePressure-p_environment)/1000) '_rpm' num2str(RunConditions(n).rpm) '_XScale' num2str(RunConditions(n).X_Scale) '_' replace(RunConditions(n).Gas,' ','_')];
    RunConditions(n).title = [RunConditions(n).Model '_TH' num2str(RunConditions(n).SourceTemp-273.15) '_TC' num2str(RunConditions(n).SinkTemp-273.15) '_p' num2str((RunConditions(n).EnginePressure-p_environment)/1000) '_rpm' num2str(RunConditions(n).rpm) '_' replace(RunConditions(n).Gas,' ','_')];
%     RunConditions(n).title = [RunConditions(n).Model '_TH' num2str(RunConditions(n).SourceTemp-273.15) '_TC' num2str(RunConditions(n).SinkTemp-273.15) '_p' num2str((RunConditions(n).EnginePressure-p_environment)/1000) '_rpm' num2str(RunConditions(n).rpm) '_XScale' num2str(RunConditions(n).X_Scale)];
    %             RunConditions(n).title = RunConditions(n).Model;
    n = n+1;

% end
% end
end
end
end
end
end

end

%% Make RunConditions from Experiment file
if USE_EXPERIMENT
% User chooses experimental data files to use for MSPM runs, using a dialog box
start_path_exp = 'G:\Shared drives\NOBES_GROUP\MSPM\[MATLAB_WORKING_FOLDER]\Data Processing Code\06_Post Processing_Experimental\[Experimental Data]';

FILES_EXP = struct([]);
import_done = false;

while ~import_done
    
    % Set up dialog text
    quest = "Add Experiment files to create MSPM runs using buttons below. Files selected so far:" +newline;
    for f = FILES_EXP
        quest = quest + f.name +newline;% "     p_env: " + f.p_env + " kPa" +newline;
    end
    
    % display dialog box
    answer = questdlg(quest, "Choose Experiment data files '_RD.mat' to import",...
        "Add Experiment file", "DONE (Start Solving)",  "Add Experiment file");
    
    % Based on button pressed, import files using dialog, or proceed
    switch answer
        case "Add Experiment file"
            msg = "Choose experiment data file, e.g. '_RD.mat'.";
            [name, path] = uigetfile(start_path_exp, msg);
            if name
                if name(end-3:end) ~= '.mat'
                    warning("Must select a '.mat' file.")
                elseif ischar(name)
                    
%                     prompt = "Input measured atmospheric pressure for experiment " + name + " [kPa]:";
%                     p_env_str = inputdlg(prompt);
%                     p_env = str2num(p_env_str{1});
%                     if length(p_env) == 1
                        FILES_EXP(end+1).name = name;
                        FILES_EXP(end).path = path;
%                         FILES_EXP(end).p_env = p_env;
%                     end
                    
                end
            end
        case "DONE (Start Solving)"
            import_done = true;
        otherwise
            error("User canceled file import.")
    end
    
end

n = 1;
% for i_h_so = 1:length(h_custom_Source)

    for f = 1:length(FILES_EXP)
        
    load(fullfile(FILES_EXP(f).path, FILES_EXP(f).name)); % loads RD_DATA
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i_mod = 1:length(model)
    for i_X_Scale = 1:length(X_Scale)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
                  
            
        for i_RD = 1:size(RD_DATA,2)
            
%             for i_h_si = 1:length(h_custom_Sink)
                
                RunConditions(n) = RunConditions_temp;
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 i_mod = i_h_so;
                RunConditions(n).Model = model{i_mod};

%                 RunConditions(n).Uniform_Scale = Uniform_Scale(i_mod);
                RunConditions(n).X_Scale = X_Scale(i_X_Scale);
                
%                 RunConditions(n).PressureBounds = PressureBounds;
%                 RunConditions(n).SpeedBounds = SpeedBounds;              

                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                 
                RunConditions(n).h_custom_Source = h_custom_Source(i_mod);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                RunConditions(n).h_custom_Sink = h_custom_Sink(i_mod);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                RunConditions(n).rpm = RD_DATA(i_RD).encoder_speed;
                RunConditions(n).SourceTemp = mean([RD_DATA(i_RD).Tsource_in, RD_DATA(i_RD).Tsource_out]) + 273.15; % Celsius to K
                RunConditions(n).SinkTemp = mean([RD_DATA(i_RD).Tsink_in, RD_DATA(i_RD).Tsink_out]) + 273.15;
                RunConditions(n).EnginePressure = RD_DATA(i_RD).pmean + RD_DATA(i_RD).p_atm; % Adding environment pressure here to get absolute pressure for MSPM
%                 RunConditions(n).title = [RD_DATA(i_RD).filename, RunConditions(n).Model(end-7:end)];
%                 RunConditions(n).title = [RD_DATA(i_RD).filename '_hSource_' num2str(RunConditions(n).h_custom_Source) '_hSink_' num2str(RunConditions(n).h_custom_Sink) '_Model_' num2str(i_mod)];
%                 RunConditions(n).title = [RD_DATA(i_RD).filename '_hSource_' num2str(RunConditions(n).h_custom_Source) '_hSink_' num2str(RunConditions(n).h_custom_Sink)];
                RunConditions(n).title = ['V_Scale_' num2str(X_Scale(i_X_Scale)^2)];
%                 RunConditions(n).title = [RD_DATA(i_RD).filename '_V_Scale_' num2str(X_Scale(i_X_Scale)^2)];
%                 RunConditions(n).title = RD_DATA(i_RD).filename;
                
                if model_in_title(i_mod)
                    mod_tit = flip(RunConditions(n).Model);
                    mod_tit = flip(strtok(mod_tit,'_'));
                    RunConditions(n).title = [RunConditions(n).title '_' mod_tit];
                end
                n = n+1;
%             end
        end
    end
    end
    end
% end
end

%%
% Remove empty rows.
todelete = [];
for i = 1:length(RunConditions)
    if isempty(RunConditions(i).title)
        todelete(end+1) = i;
    end
end
RunConditions(todelete) = [];

% Ask for confirmation before starting to solve.
quest = "Running Test Set with " + length(RunConditions) + " Cases." +newline+ "Good to go?";
answer = questdlg(quest);
if ~strcmp(answer, 'Yes'); error("Test set canceled."); end
