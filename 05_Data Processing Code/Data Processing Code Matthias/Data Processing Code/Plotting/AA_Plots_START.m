% SECTION 1: Data import %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RUN THIS SECTION FIRST. No inputs required.
% For Plots, open 'Plots_*' scripts.

% clear
% close all
DATA_EXP = struct([]);
DATA_MOD = struct([]);

[DATA_EXP, DATA_MOD] = Data_import(DATA_EXP, DATA_MOD); % calls subfunction
fig_count = 1; % figure counter
figure_purpose = 'thesis';

%% Duplicate DATA_EXP to match length of DATA_MOD
DATA_EXP = repmat(DATA_EXP, 1, length(DATA_MOD)/length(DATA_EXP));
