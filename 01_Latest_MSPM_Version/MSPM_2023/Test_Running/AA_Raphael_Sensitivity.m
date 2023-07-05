function [RunConditions] = AA_Raphael_Sensitivity()
% Written by Steven Middleton
% Experimental data extraction added by Connor Speer, September 2021.
% Debuged and finalized by Sara Eghbali, 24 Sep 2021
% The purpose of this function is to extract the operating points from a
% set of experimental data and reconfigure it for use in MSPM. This will
% allow quick comparison plots to be made.

%% Input Parameters
% Name of experimental data files.
model = {
   'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_one_exp_body_DPseal' 
   'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_one_exp_body_DPseal_HXside_ins'
   'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_one_exp_body_DPseal_HXside_added_ins'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_hSink_-40'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_hSink_-30'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_hSink_-20'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_hSink_-10'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_hSink_+10'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_hSink_+20'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_hSink_+30'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_hSink_+40'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_hSource_-40'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_hSource_-30'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_hSource_-20'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_hSource_-10'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_hSource_+10'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_hSource_+20'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_hSource_+30'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_hSource_+40'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_HX-Ins-at-HX-Temps'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_HX-Ins-as-Source-Sink'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_NoAppGap'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_Por93'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_Por94'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_Por95'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_Por95,5'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_Por96,5'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_Por97'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_Por98'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_RegD0,2'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_RegD0,5'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_DPNodes_2x5_RegD0,05'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_Default'};
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_noBaseConduction'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_NoTopConduction'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_NoHXSideConduction'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_NoAxialHXConduction'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_NoDPConduction'
%     'Raphael_2022-05-26_FinEnhSurf_Custom_h_PlusPPCCConduction'

%      'Raphael_With_Seal_Dw0,00005'
%      'Raphael_With_Seal_Dw0,00006'
%      'Raphael_With_Seal_Dw0,00007'
%      'Raphael_With_Seal_Dw0,00008'
%      'Raphael_With_Seal_Dw0,00009'
%      'Raphael_With_Seal_Dw0,0001'
%      'Raphael_With_Seal_Dw0,00011'
%      'Raphael_With_Seal_Dw0,00012'
%      'Raphael_With_Seal_Dw0,00013'
%      'Raphael_With_Seal_Dw0,00014'
%      'Raphael_With_Seal_Dw0,00015'
%      'Raphael_With_Seal_Por94'
%      'Raphael_With_Seal_Por94,5'
%      'Raphael_With_Seal_Por95'
%      'Raphael_With_Seal_Por95,5'
%      'Raphael_With_Seal_Por96'
%      'Raphael_With_Seal_Por96,5'
%      'Raphael_With_Seal_Por97'
%      'Raphael_With_Seal_Por97,5'
%      'Raphael_With_Seal_Por98'
     
    }; % Name of MSPM model geometry.
pmean = ([300]) *1000; % [Pa]
speed = [150]; % [rpm]
TH = [150]; %[C]
TC = [5]; %[C]
p_environment = 94 *1000; % [Pa] Measured atmospheric pressure at time and location of experiment
simTime = 600; %(s) Simulation time.
minCycles = 10; % minimum number of engine cycles to complete before turning to steady state.
SS = true; % Steady state toggle.
movement_option = 'C';
max_dt = 0.1; %(s) Maximum time step.
NodeFactor = 1;
% NF = [0.2];%:0.1:0.4, 2.5:0.5:6];
% Uniform_Scale = 1;
% HX_Convection = 1;

%% Create MSPM Test Structure

RunConditions_temp = struct(... %Default values
    'Model', model{1},...
    'title','',...
    'simTime', simTime,... [s]
    'minCycles', minCycles,...
    'SS', SS,...
    'movement_option', movement_option,...
    'rpm', 60,... [rpm]
    'max_dt', max_dt,... [s]
    'SourceTemp',150 + 273.15,... [K]
    'SinkTemp',5 + 273.15,... [K]
    'EnginePressure',101325*10,...
    'NodeFactor', NodeFactor); %,...
%     'Uniform_Scale', Uniform_Scale,...
%     'HX_Convection', HX_Convection);

n=1;
for i = 1:length(model)
    for tc = TC
            RunConditions(n) = RunConditions_temp;
            RunConditions(n).Model = model{i};
            RunConditions(n).rpm = speed;
            RunConditions(n).SourceTemp = 150 + 273.15;
            RunConditions(n).SinkTemp = tc + 273.15;
           %     RTD_0 --> Displacer Cylinder Head Inlet
            %     RTD_1 --> Displacer Cylinder Head Outlet
            %     RTD_2 --> Heater Inlet
            %     RTD_3 --> Heater Outlet
            %     RTD_4 --> Cooler Inlet
            %     RTD_5 --> Cooler Outlet
            %     RunConditions(i).SourceTemp = mean([RD_DATA(i).Tsource_in, RD_DATA(i).Tsource_out]) + 273.15; % Celsius to K
            %     RunConditions(i).SinkTemp = mean([RD_DATA(i).Tsink_in, RD_DATA(i).Tsink_out]) + 273.15;
            RunConditions(n).EnginePressure = pmean + p_environment;
%             RunConditions(n).title = [RunConditions(n).Model '_TH' num2str(RunConditions(n).SourceTemp-273.15) '_TC' num2str(RunConditions(n).SinkTemp-273.15) '_p' num2str((RunConditions(n).EnginePressure-p_environment)/1000) '_rpm' num2str(RunConditions(n).rpm)];
            RunConditions(n).title = RunConditions(n).Model;
            n = n+1;
    end
end

%     for nf = NF
%                 RunConditions(n) = RunConditions_temp;
%             RunConditions(n).Model = model{1};
%             
%             RunConditions(n).NodeFactor = nf;
%             
%             RunConditions(n).rpm = speed;
%             RunConditions(n).SourceTemp = 150 + 273.15;
%             RunConditions(n).SinkTemp = 5 + 273.15;
%            %     RTD_0 --> Displacer Cylinder Head Inlet
%             %     RTD_1 --> Displacer Cylinder Head Outlet
%             %     RTD_2 --> Heater Inlet
%             %     RTD_3 --> Heater Outlet
%             %     RTD_4 --> Cooler Inlet
%             %     RTD_5 --> Cooler Outlet
%             %     RunConditions(i).SourceTemp = mean([RD_DATA(i).Tsource_in, RD_DATA(i).Tsource_out]) + 273.15; % Celsius to K
%             %     RunConditions(i).SinkTemp = mean([RD_DATA(i).Tsink_in, RD_DATA(i).Tsink_out]) + 273.15;
%             RunConditions(n).EnginePressure = pmean + p_environment;
%             RunConditions(n).title = [RunConditions(n).Model '_TH' num2str(RunConditions(n).SourceTemp-273.15) '_TC' num2str(RunConditions(n).SinkTemp-273.15) '_p' num2str((RunConditions(n).EnginePressure-p_environment)/1000) '_rpm' num2str(RunConditions(n).rpm) '_NodeFactor' num2str(RunConditions(n).NodeFactor)];
%         n = n+1;
%     end

%     for th = TH
%             RunConditions(n) = RunConditions_temp;
%             RunConditions(n).Model = model{1};
%             %     RunConditions(i).simTime = simTime;
%             RunConditions(n).rpm = speed;
%             RunConditions(n).SourceTemp = th + 273.15;
%             RunConditions(n).SinkTemp = 5 + 273.15;
%            %     RTD_0 --> Displacer Cylinder Head Inlet
%             %     RTD_1 --> Displacer Cylinder Head Outlet
%             %     RTD_2 --> Heater Inlet
%             %     RTD_3 --> Heater Outlet
%             %     RTD_4 --> Cooler Inlet
%             %     RTD_5 --> Cooler Outlet
%             %     RunConditions(i).SourceTemp = mean([RD_DATA(i).Tsource_in, RD_DATA(i).Tsource_out]) + 273.15; % Celsius to K
%             %     RunConditions(i).SinkTemp = mean([RD_DATA(i).Tsink_in, RD_DATA(i).Tsink_out]) + 273.15;
%             RunConditions(n).EnginePressure = pmean + p_environment;
%             RunConditions(n).title = [RunConditions(n).Model '_TH' num2str(RunConditions(n).SourceTemp-273.15) '_TC' num2str(RunConditions(n).SinkTemp-273.15) '_p' num2str((RunConditions(n).EnginePressure-p_environment)/1000) '_rpm' num2str(RunConditions(n).rpm)];
%         n = n+1;
%      end


disp("Running Test Set with " + length(RunConditions) + " Cases."+newline)
end

