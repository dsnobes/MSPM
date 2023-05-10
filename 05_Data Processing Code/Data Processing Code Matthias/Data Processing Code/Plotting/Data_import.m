function [DATA_EXP, DATA_MOD] = Data_import(DATA_EXP, DATA_MOD)
% User chooses files to process, using a dialog box
% DATA_EXP = struct([]);
% DATA_MOD = struct([]);
import_done = false;

while ~import_done
    
    % Set up dialog text
    quest = "Add files using buttons below. Files selected so far:" +newline...
        +newline+ "Experimental:" +newline;
    for f = DATA_EXP
        quest = quest + f.name +newline;
    end
    quest = quest +newline+ "Model:" +newline;
    for f = DATA_MOD
        quest = quest + f.name +newline;
    end
    
    % display dialog box
    answer = questdlg(quest, "Choose '_RD' and '_MSPM' files to import",...
        "Add Experiment file", "Add Model file", "DONE",  "Add Experiment file");
    
    % Based on button pressed, import files using dialog, or proceed
    switch answer
        case "Add Experiment file"
            msg = "Choose experiment data file, e.g. '_RD.mat'.";
            exp_start_path = 'G:\Shared drives\NOBES_GROUP\MSPM\[MATLAB_WORKING_FOLDER]\Data Processing Code\06_Post Processing_Experimental\[Experimental Data]';
            [name, path] = uigetfile(exp_start_path, msg);
            if name
                if name(end-3:end) ~= '.mat'
                    warning("Must select a '.mat' file.")
                elseif ischar(name)
                    DATA_EXP(end+1).name = name;
                    DATA_EXP(end).path = path;
                end
            end
        case "Add Model file"
            msg = "Choose model data file, e.g. '_MSPM.mat'.";
            mod_start_path = 'G:\Shared drives\NOBES_GROUP\MSPM\[MATLAB_WORKING_FOLDER]\MSPM\Runs';
            [name, path] = uigetfile(mod_start_path, msg);
            if name
                if name(end-3:end) ~= '.mat'
                    warning("Must select a '.mat' file.")
                elseif ischar(name)
                    DATA_MOD(end+1).name = name;
                    DATA_MOD(end).path = path;
                end
            end
        case "DONE"
            import_done = true;
        otherwise
            error("User canceled file import.")
    end
    
end

% load all data from files into structs that hold all experimental / model
% datasets respectively
for i = 1:length(DATA_EXP)
    if ~isfield(DATA_EXP(i),'data') || isempty(DATA_EXP(i).data)
        load(fullfile(DATA_EXP(i).path, DATA_EXP(i).name));
        DATA_EXP(i).data = RD_DATA;
    end
end
for i = 1:length(DATA_MOD)
    if ~isfield(DATA_MOD(i),'data') || isempty(DATA_MOD(i).data)
        load(fullfile(DATA_MOD(i).path, DATA_MOD(i).name));
        DATA_MOD(i).data = MSPM_DATA;
    end
end