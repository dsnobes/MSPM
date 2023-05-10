function [SECOND_ORDER_DATA,REF_CYCLE_DATA,LOSSES_DATA,PARTICLE_TRAJECTORY_DATA,MECHANISM_DATA] = T2_2nd_Order(ENGINE_DATA, p_PC_avg, p_CC_avg,Tge_exp,Tgc_exp)

% Written by Connor Speer, October 2017.
% This function contains a scheme for adding decoupled losses to the
% reference cycle results.

%% Input:
% ENGINE_DATA --> Engine geometry and operating point.

%% Preamble
% A heat engine communicates with its environment in three ways: Heat
% transfer between the thermal source, and thermal sink, and work transfer 
% through the output shaft. Decoupled losses can affect any of these three
% energy transfer mechanisms.

%% Call SEA code to calculate reference cycle and decoupled losses
crank_inc = 1; % Crank angle step size for numerical integration in [deg]
Model_Code = 3; % Code specifying which model to run (3 = Simple Model).
Losses_Code = 3; % Code specifying which losses subfunction to run
part_traj_on_off = 1; % 0 = no particle trajectory calculation.
mech_calc_on_off = 1; % 0 = no mechanism dynamics calculations.
p_PC_avg = ENGINE_DATA.pmean;
p_CC_avg = ENGINE_DATA.pmean; 
Tge_exp = 130 + 273;
Tgc_exp = 30 + 273;

[REF_CYCLE_DATA, LOSSES_DATA, PARTICLE_TRAJECTORY_DATA, MECHANISM_DATA, ENGINE_DATA] = ...
    sea(ENGINE_DATA,crank_inc,Model_Code, Losses_Code,part_traj_on_off,mech_calc_on_off, p_PC_avg, p_CC_avg,Tge_exp,Tgc_exp);

%% Heat Transfer Between the Engine and the Thermal Source
SECOND_ORDER_DATA.Qh_dot = REF_CYCLE_DATA(end).Qh*ENGINE_DATA.freq + ... % Reference cycle heat input rate
    (-LOSSES_DATA.P_flow_h) + ... % Flow friction in the heater
    (-0.5*LOSSES_DATA.P_flow_r) + ... % Half of flow friction in the regenerator
    LOSSES_DATA.Q_cond + ... % Conduction loss
    LOSSES_DATA.Q_seals + ... % Seal leakage
    LOSSES_DATA.Q_app + ... % Appendix gap loss
    LOSSES_DATA.Q_insulation + ... % Heat lost through the insulation
    LOSSES_DATA.Q_qrloss;  % Regenerator enthalpy loss

%% Work Transfer Between the Engine and the Load
SECOND_ORDER_DATA.W_dot = REF_CYCLE_DATA(end).W*ENGINE_DATA.freq - ... % Reference cycle power output
    LOSSES_DATA.P_mech - ... % Mechanical friction
    LOSSES_DATA.P_flow_h - ... % Flow friction in the heater
    LOSSES_DATA.P_flow_r - ... % Flow friction in the regenerator
    LOSSES_DATA.P_flow_k - ... % Flow friction in the cooler
    LOSSES_DATA.P_GSH - ... % Gas spring hysteresis
    LOSSES_DATA.P_seals - ... % Seal leakage
    LOSSES_DATA.P_HTH - ... % Heat transfer hysteresis
    LOSSES_DATA.P_FPS - ... % Finite piston speed
    LOSSES_DATA.P_pump_cool - ... % Coolant pump
    LOSSES_DATA.P_pump_hot; % Heating system pump

    
%% Heat Transfer Between the Engine and the Thermal Sink
SECOND_ORDER_DATA.Qk_dot = -REF_CYCLE_DATA(end).Qk*ENGINE_DATA.freq + ... % Reference cycle heat rejection rate
    LOSSES_DATA.P_mech + ... % Mechanical friction
    0.5*LOSSES_DATA.P_flow_r + ... % Half of flow friction in the regenerator
    LOSSES_DATA.P_flow_k + ... % Flow friction in the cooler
    LOSSES_DATA.Q_cond + ... % Conduction loss
    LOSSES_DATA.Q_seals + ... % Seal leakage
    LOSSES_DATA.Q_app + ... % Appendix gap loss
    LOSSES_DATA.Q_qrloss; % Regenerator enthalpy loss

%% Thermal Efficiency
SECOND_ORDER_DATA.eff_thermal = SECOND_ORDER_DATA.W_dot/SECOND_ORDER_DATA.Qh_dot;

%% Overall Energy Balance
SECOND_ORDER_DATA.Energy_Imbalance = SECOND_ORDER_DATA.Qh_dot - ...
    SECOND_ORDER_DATA.W_dot - SECOND_ORDER_DATA.Qk_dot;

%% Display Results
fprintf('========== 2nd Order Model Results ============\n')
fprintf(' Heat input rate: %.2f[W]\n', SECOND_ORDER_DATA.Qh_dot);
fprintf(' Heat rejection rate: %.2f[W]\n', SECOND_ORDER_DATA.Qk_dot);
fprintf(' Power output: %.2f[W]\n', SECOND_ORDER_DATA.W_dot);
fprintf(' Thermal efficiency: %.1f[%%]\n', SECOND_ORDER_DATA.eff_thermal*100);
fprintf(' Energy Imbalance: %.1f[W]\n', SECOND_ORDER_DATA.Energy_Imbalance);
fprintf('========================================================\n')
% fprintf(' Exergy destruction at thermal source: %.1f[W]\n', LOSSES_DATA.X_dest_source);
% fprintf(' Exergy destruction at thermal sink: %.1f[W]\n', LOSSES_DATA.X_dest_sink);

fprintf('========== Summary of Losses ============\n')
fprintf(' Mechanical friction: %.2f[W]\n', LOSSES_DATA.P_mech);
fprintf(' Flow friction in the heater: %.2f[W]\n', LOSSES_DATA.P_flow_h);
fprintf(' Flow friction in the regenerator: %.2f[W]\n', LOSSES_DATA.P_flow_r);
fprintf(' Flow friction in the cooler: %.2f[W]\n', LOSSES_DATA.P_flow_k);
fprintf(' Gas spring hysteresis: %.2f[W]\n', LOSSES_DATA.P_GSH);
fprintf(' Seal leakage: %.1f[W]\n', LOSSES_DATA.P_seals);
fprintf(' Heat transfer hysteresis: %.1f[W]\n', LOSSES_DATA.P_HTH);
fprintf(' Finite piston speed: %.1f[W]\n', LOSSES_DATA.P_FPS);
fprintf(' Coolant pump: %.1f[W]\n', LOSSES_DATA.P_pump_cool);
fprintf(' Heating system pump: %.1f[W]\n', LOSSES_DATA.P_pump_hot);
fprintf(' Regenerator enthalpy loss: %.1f[W]\n', LOSSES_DATA.Q_qrloss);
fprintf(' Conduction loss: %.1f[W]\n', LOSSES_DATA.Q_cond);
fprintf(' Appendix gap loss: %.1f[W]\n', LOSSES_DATA.Q_app);
fprintf(' Heat lost through insulation: %.1f[W]\n', LOSSES_DATA.Q_insulation);
fprintf('========================================================\n')
