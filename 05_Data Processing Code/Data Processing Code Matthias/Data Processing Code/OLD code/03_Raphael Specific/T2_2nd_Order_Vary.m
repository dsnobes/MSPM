function DATA_STRUCTURE = T2_2nd_Order_Vary(varName,Min,Max,Increment,ENGINE_DATA)

% Written by Connor Speer - April 2017
% Editted by Shahzeb Mirza - October 2017 

% The purpose of this script is to run the SEA code repeatedly for a
% variety of any given variable, and return results.

% Inputs:
% varName --> String with the exact variable name

% Min --> Lower bound of the variable range being considered [any unit]
% Max --> Upper bound of the variable range being considered [any unit]
% Increment --> Increment size for variable range [any unit

% ENGINE_DATA --> Structure which defines engine geometry and operating conditions

% Crank_Angle_Increment --> Crank angle step size for numerical integration in [degrees]

% Model_Code --> Code specifying which model to run.
% 1 = Ideal Isothermal Model
% 2 = Ideal Adiabatic Model
% 3 = Simple Model
% Losses_Code --> Code specifying which losses subfunction to run
% 1 = parasitic_losses_GEN.m
% 2 = parasitic_losses_HTG.m


range = Min:Increment:Max;

% Preallocate space
DATA_STRUCTURE(length(range)).Qh_dot = [];
DATA_STRUCTURE(length(range)).Qk_dot = [];
DATA_STRUCTURE(length(range)).W_dot = [];
DATA_STRUCTURE(length(range)).eff_thermal = [];

counter = 1; % Initialize counter variable
counter_max = length(range);
h = waitbar(0,'Running 2nd order model...');

for i = range
    command = strcat('ENGINE_DATA.',varName,' = i;');
    eval(command);
    
    % Call the second order model subfunction
    [SECOND_ORDER_DATA,REF_CYCLE_DATA,LOSSES_DATA] = T2_2nd_Order(ENGINE_DATA);
    
    % Store outputs from the model
    DATA_STRUCTURE(counter).Qh_dot = SECOND_ORDER_DATA.Qh_dot;
    DATA_STRUCTURE(counter).Qk_dot = SECOND_ORDER_DATA.Qk_dot;
    DATA_STRUCTURE(counter).W_dot = SECOND_ORDER_DATA.W_dot;
    DATA_STRUCTURE(counter).eff_thermal = SECOND_ORDER_DATA.eff_thermal;
    
    DATA_STRUCTURE(counter).ref_cycle_power = REF_CYCLE_DATA(1).W_dot_ref;
    DATA_STRUCTURE(counter).ref_cycle_heat_in = REF_CYCLE_DATA(end).Qh*ENGINE_DATA.freq;
    DATA_STRUCTURE(counter).ref_cycle_heat_out = REF_CYCLE_DATA(end).Qk*ENGINE_DATA.freq;
    
    DATA_STRUCTURE(counter).FW = LOSSES_DATA.FW;
    DATA_STRUCTURE(counter).P_HEX = REF_CYCLE_DATA(1).W_dot_ref-(REF_CYCLE_DATA(end).W*ENGINE_DATA.freq);
    DATA_STRUCTURE(counter).P_mech = LOSSES_DATA.P_mech;
    DATA_STRUCTURE(counter).pdroph = LOSSES_DATA.pdroph;
    DATA_STRUCTURE(counter).pdropr = LOSSES_DATA.pdropr;
    DATA_STRUCTURE(counter).pdropk = LOSSES_DATA.pdropk;
    DATA_STRUCTURE(counter).P_flow_h = LOSSES_DATA.P_flow_h;
    DATA_STRUCTURE(counter).P_flow_r = LOSSES_DATA.P_flow_r;
    DATA_STRUCTURE(counter).P_flow_k = LOSSES_DATA.P_flow_k;
    DATA_STRUCTURE(counter).P_GSH = LOSSES_DATA.P_GSH;
    DATA_STRUCTURE(counter).Q_qrloss = LOSSES_DATA.Q_qrloss;
    DATA_STRUCTURE(counter).Q_cond = LOSSES_DATA.Q_cond;
    DATA_STRUCTURE(counter).Q_app = LOSSES_DATA.Q_app;
    DATA_STRUCTURE(counter).P_seals = LOSSES_DATA.P_seals;
    DATA_STRUCTURE(counter).Q_seals = LOSSES_DATA.Q_seals;
    DATA_STRUCTURE(counter).P_HTH = LOSSES_DATA.P_HTH;
    DATA_STRUCTURE(counter).P_FPS = LOSSES_DATA.P_FPS;
    DATA_STRUCTURE(counter).P_pump_cool = LOSSES_DATA.P_pump_cool;
    DATA_STRUCTURE(counter).P_pump_hot = LOSSES_DATA.P_pump_hot;
    DATA_STRUCTURE(counter).X_dest_source = LOSSES_DATA.X_dest_source;
    DATA_STRUCTURE(counter).X_dest_sink = LOSSES_DATA.X_dest_sink;
    DATA_STRUCTURE(counter).Q_insulation = LOSSES_DATA.Q_insulation;
    
    % Close the temporary data file to prevent Matlab errors
    fclose('all');
    
    counter = counter + 1;
    
    waitbar(counter/ counter_max)
end

close(h) 