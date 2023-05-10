%% MSPM Data extraction, processing and storing in struct format
% JUST RUN, INPUTS WILL POP UP.

% To extract data from a set of MSPM results folders, calculate additional
% data and store everything in a struct 'MSPM_DATA' that is saved to a .mat
% file in the same folder as the input data. Input: Path to MSPM 'Runs'
% folder containing folders of individual MSPM runs. Output: Struct
% 'MSPM_DATA' that is saved to a file '*foldername*_MSPM'. 

% 'p_environment' is the atmospheric pressure that must be subtracted from
% MSPM pressure to compare to experiment data. It can be scalar (one value
% for all datapoints) or vector (one value per datapoint)

function DataExtract(p_environment)
% clc, clear

% IMPORTANT: Environment pressure that will be subtracted from MSPM
% pressure outputs to obtain relative pressure, which is comparable to
% experiment pressure data.
% p_environment = 93.79 *1000; % Pa

% Set the names of the MSPM output files to be used. (PV outputs, sensors)
% Can contain wildcards (*)
query_enginePV = 'Engine-PV*.mat';
query_crankcasePV = 'Crankcase-PV*.mat';

% User chooses a folder to process
msg = 'Choose folder containing MSPM results folders to process.';
start_path = 'G:\Shared drives\NOBES_GROUP\MSPM\[MATLAB_WORKING_FOLDER]\MSPM\Runs';
Folder_path = uigetdir(start_path,msg);

%%
% list directories to work through
dirs = dir(Folder_path);
dirs = dirs(3:end); % remove the '.' and '..' folders
dirs = dirs([dirs.isdir]); % consider only folders, not files
n = length(dirs);


% Preallocate struct for output
MSPM_DATA(n).filename = [];
MSPM_DATA(n).speed_transient = [];
MSPM_DATA(n).speedHz = [];
MSPM_DATA(n).speedRPM = [];
MSPM_DATA(n).T_source = [];
MSPM_DATA(n).T_sink = [];
MSPM_DATA(n).h_Source = [];
MSPM_DATA(n).h_Sink = [];
MSPM_DATA(n).p_mean_setpoint = [];
MSPM_DATA(n).p_mean = [];
MSPM_DATA(n).p_mean_CC = [];

MSPM_DATA(n).PV_Com = [];
MSPM_DATA(n).PV_Exp = [];
MSPM_DATA(n).PV_PP = [];
MSPM_DATA(n).PV_CC = [];

% create structs to store PV data for each variable volume space
PV_Com.p_mean = [];
PV_Com.deltaP = [];
PV_Com.Wind = [];
PV_Com.p = [];
PV_Com.V = [];
% Same struct for each space
PV_Exp = PV_Com;
PV_PP = PV_Com;
PV_CC = PV_Com;

MSPM_DATA(n).Wind = [];


MSPM_DATA(n).FW = [];

MSPM_DATA(n).P_shaft = [];
MSPM_DATA(n).efficiency_ind = [];
MSPM_DATA(n).efficiency_shaft = [];

MSPM_DATA(n).Qdot_fromSource = [];
MSPM_DATA(n).Qdot_toSink = [];
MSPM_DATA(n).Qdot_toEnv = [];
MSPM_DATA(n).Qdot_flowloss = [];

% For each results folder, extract data and write into struct
for d = 1:n
    %% load all relevant data from MSPM result folder
    name = dirs(d).name;
    this_folderpath = fullfile(Folder_path, name);
    
    % extract setpoint parameters from name   
    T_source = FindInName(name, 'TH', '_');
    T_sink = FindInName(name, '_TC', '_');
    p_mean_setpoint = FindInName(name, '_p', '_') *1000; %Pa

    % extract h_custom values from name if present
    h_Source = FindInName(name, 'hSource_', '_'); % heat transfer coeff in W/m^2 K
    h_Sink = FindInName(name, 'hSink_', '_');  

    % load MSPM 'Statistics' output. Loads any file with name matching
    % 'query'. Sometimes this file can have a missing '.mat' extension.
    % Therefore enforce loading as 'mat'.
    %     Will load 'statistics' struct.
    query = '*_Statistics*';
    thisfile = dir(fullfile(this_folderpath, query));
    if size(thisfile, 1) ~= 1
        error("Folder:"+newline+ name +newline+"File:"+newline+...
            query +newline+"None or several found.");
    end
    load(fullfile(this_folderpath, thisfile.name), '-mat');
    
    
    % load working space PV data. Will load 'data' struct.
    query = query_enginePV;
    thisfile = dir(fullfile(this_folderpath, query));
    if size(thisfile, 1) ~= 1 % Error if not exactly one file found.
        error("Folder:"+newline+ name +newline+"File:"+newline+...
            query +newline+"None or several found.");
    end
    load(fullfile(this_folderpath, thisfile.name), '-mat');
    
    % allow p_environment to be a vector (if different between setpoints)
    if length(p_environment) > 1
        p_env = p_environment(d);
    else
        p_env = p_environment;
    end
    
    % Extract Pressure (p) and Volume (V) data.  
    p = data.DependentVariable - p_env; % see header of code file
    V = data.IndependentVariable;
    if size(p, 2) ~= 3 % Error if number of columns unexpected.
        error("Folder:"+newline+ name +newline+"File:"+newline+...
            query +newline+"Unexpected number of data columns found.");
    end
    
    % If crankcase PV output exists
    % load Crankcase PV data. Will load 'data' struct.
    query = query_crankcasePV;
    thisfile = dir(fullfile(this_folderpath, query));
    if isempty(thisfile)
        haveCC = false;
    elseif size(thisfile, 1) > 1
        error("Folder:"+newline+ name +newline+"File:"+newline+...
            query +newline+"Several found.");
    else
        haveCC = true;
        load(fullfile(this_folderpath, thisfile.name), '-mat');
        % Extract Pressure (p) and Volume (V) data.
        p_CC = data.DependentVariable - p_env; % see header of code file
        V_CC = data.IndependentVariable;
        if size(p_CC, 2) ~= 1 % Error if number of columns unexpected.
            error("Folder:"+newline+ name +newline+"File:"+newline+...
                query +newline+"Unexpected number of data columns found.");
        end
    end
    
       
    % Load sensor data for all point sensors (1D data) Does not deal with line sensors.
    % Loads files that match multiple queries, for multiple sensor types.
    query = {
        '*Temperature vs angle.mat'
        '*center - Reynolds Number vs angle.mat'...
            };
    Sfiles = struct([]);
    for q = 1:length(query)
        Sfiles = [Sfiles; dir(fullfile(this_folderpath, query{q}))];
    end
    nS = length(Sfiles);
    haveS = ~isempty(Sfiles);
%     haveS = 0;
    if haveS
        Sstruct(nS).data = []; % initialize struct for sensor data
        Sstruct(nS).name = [];
        % Get the sensor variable name from the file name. First part
        % of file name equals folder name ('name'),
        name_start_length = length(name)+2;
        % Extract data for each sensor
        for i = 1:nS
            name_flip = flip(Sfiles(i).name);
            % Sensor name ends at the dash
            name_end_length = length(flip( strtok(name_flip,'-') )) + 2;
            load(fullfile(this_folderpath, Sfiles(i).name), '-mat');
            Sstruct(i).name = Sfiles(i).name( name_start_length:(end-name_end_length) );
            if Sstruct(i).name(1) == 'T'
                adjust = -273.15; % K to CELSIUS
            else
                adjust = 0;
            end
            Sstruct(i).data = data.DependentVariable' + adjust; 
        end
        % Get crank angle from one of the sensors just for reference
        theta_rad = data.IndependentVariable;
    end

    %% Perform calculations on data
        
    % Include p and V for each volume in output struct.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % PV_order: order of Comp, Exp, PP spaces in PV output data.
    % Put indexes as follows: [Com Exp PP]
    % 1 = Compression Space, 2 = Expansion Space, 3 = Power Piston <----------------CHECK if using new MSPM model!
%     PV_order = [1 3 2]; % For Raphael model
    PV_order = [3 2 1]; % For Scaling_tube_bundle model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    PV_Com.p = p(:,PV_order(1));
    PV_Exp.p = p(:,PV_order(2));
    PV_PP.p = p(:,PV_order(3));
    if haveCC; PV_CC.p = p_CC; end
    PV_Com.V = V(:,PV_order(1));
    PV_Exp.V = V(:,PV_order(2));
    PV_PP.V = V(:,PV_order(3));
    if haveCC; PV_CC.V = V_CC; end
    
    % Mean pressure for each volume
    PV_Com.p_mean = mean(PV_Com.p);
    PV_Exp.p_mean = mean(PV_Exp.p);
    PV_PP.p_mean = mean(PV_PP.p);
    if haveCC; PV_CC.p_mean = mean(PV_CC.p); p_mean_CC = PV_CC.p_mean; end
    % engine mean pressure for reference
    p_mean = mean([PV_Com.p_mean, PV_Exp.p_mean, PV_PP.p_mean]);
    
    % delta-P for each volume
    PV_Com.deltaP = max(PV_Com.p)-min(PV_Com.p);
    PV_Exp.deltaP = max(PV_Exp.p)-min(PV_Exp.p);
    PV_PP.deltaP = max(PV_PP.p)-min(PV_PP.p);
    if haveCC; PV_CC.deltaP = max(PV_CC.p)-min(PV_CC.p); end
    
    % Indicated work by integrating the PV loops separately. there is a
    % ~2-6% difference between separate and averaged PV work, depending on
    % the small but present pressure difference between the volume spaces.
    % Separate calculation is more accurate and also matches the PV work
    % calculated by MSPM as displayed on the PV plots.
    
    % first close the PV loops so that Wind calculations reflect the
    % entire cycle.
    p_closed = [p; p(1,:)];
    V_closed = [V; V(1,:)];
    if haveCC
        p_CC_closed = [p_CC; p_CC(1)];
        V_CC_closed = [V_CC; V_CC(1)];
    end
    
    % Integrate for PV work.
    PV_Com.Wind = trapz(V_closed(:,PV_order(1)), p_closed(:,PV_order(1)));
    PV_Exp.Wind = trapz(V_closed(:,PV_order(2)), p_closed(:,PV_order(2)));
    PV_PP.Wind = trapz(V_closed(:,PV_order(3)), p_closed(:,PV_order(3)));
    if haveCC; PV_CC.Wind = trapz(V_CC_closed, p_CC_closed); end
    
    %     % Integrating the average PV loop
    % Inaccurate, don't use!
    %     P_inst_closed = [p_inst; p_inst(1)]; V_tot_closed = [V_tot;
    %     V_tot(1)]; Wind = trapz(V_tot_closed, P_inst_closed);
    
    % Forced work
    if haveCC; FW = FW_Subfunction_v4(PV_PP.p, PV_CC.p, PV_PP.V); end
    P_shaft = mean(statistics.Power);
    
    speed_transient = statistics.Omega /(2*pi); % [Hz]
    speedHz = mean(speed_transient); % [Hz]
    speedRPM = speedHz * 60; % [rpm]
    
    % 'statistics.To_...' Contain values in unit of energy (J) for each
    % cycle increment. For energy flow, sum and multiply with speed.
    Qdot_fromSource = - sum(statistics.To_Source)*speedHz;
    Qdot_toSink = sum(statistics.To_Sink)*speedHz;
    % Sign of 'statistics.To_Environment; has been fixed in MSPM code.
    Qdot_toEnv = sum(statistics.To_Environment)*speedHz;
    Qdot_flowloss = sum(statistics.Flow_Loss)*speedHz; % should be same unit as 'To_Source' according to code analysis
    
    efficiency_ind = PV_PP.Wind *speedHz / Qdot_fromSource; % [dim.less]
    efficiency_shaft = P_shaft / Qdot_fromSource; % [dim.less]
    
    % Temperature calculations
    % Find indices of required temperatures in Sstruct
    if haveS
        for S=Sstruct
            switch S.name
                case 'Tgh_reg'
                    Tgh_reg = mean(S.data);
                case 'Tgk_reg'
                    Tgk_reg = mean(S.data);
            end
        end
        try
            Tgr_log = (Tgh_reg - Tgk_reg) / log(Tgh_reg / Tgk_reg); % C
        end
    end
    
    %% Write to struct
    MSPM_DATA(d).filename = name;
    MSPM_DATA(d).speed_transient = speed_transient;
    MSPM_DATA(d).speedHz = speedHz;
    MSPM_DATA(d).speedRPM = speedRPM;
    MSPM_DATA(d).T_source = T_source;
    MSPM_DATA(d).T_sink = T_sink;
    MSPM_DATA(d).h_Source = h_Source;
    MSPM_DATA(d).h_Sink = h_Sink;
    MSPM_DATA(d).p_mean_setpoint = p_mean_setpoint;
    MSPM_DATA(d).p_mean = p_mean;
    MSPM_DATA(d).p_mean_CC = p_mean_CC;
    
    MSPM_DATA(d).PV_Com = PV_Com;
    MSPM_DATA(d).PV_Exp = PV_Exp;
    
    MSPM_DATA(d).PV_PP = PV_PP;
    
    MSPM_DATA(d).Wind = PV_PP.Wind;
    
    
    if haveCC
        MSPM_DATA(d).PV_CC = PV_CC;
        MSPM_DATA(d).FW = FW;
    end
    
    
    
    
    MSPM_DATA(d).Qdot_fromSource = Qdot_fromSource;
    MSPM_DATA(d).Qdot_toSink = Qdot_toSink;
    MSPM_DATA(d).Qdot_toEnv = Qdot_toEnv;
    MSPM_DATA(d).Qdot_flowloss = Qdot_flowloss;
    
    MSPM_DATA(d).P_shaft = P_shaft;
    MSPM_DATA(d).efficiency_ind = efficiency_ind;
    MSPM_DATA(d).efficiency_shaft = efficiency_shaft;
    
    
    if haveS
        % Write data from each sensor into variable name
        % obtained from MSPM results file name
        for S = Sstruct
            try
                eval("MSPM_DATA(d)." + S.name + "= S.data;");
            catch
                warning("Invalid Sensor Name: "+S.name +newline+ "Will not be included in MSPM.mat output file.")
            end
        end
        
        MSPM_DATA(d).theta_rad = theta_rad;
        try
          MSPM_DATA(d).Tgr_log = Tgr_log;
        end
    end
    
    
end

%% Save Data
reversed_file_path = reverse(Folder_path);
reversed_folder_name = strtok(reversed_file_path,'\');
folder_name = reverse(reversed_folder_name);
Processed_Data_Filename = strcat(Folder_path,'\',folder_name,'_MSPM.mat');

% Processed_Data_Filename = 'G:\Shared drives\NOBES_GROUP\MSPM\[MATLAB_WORKING_FOLDER]\MSPM\Runs\22-02-xx-Fin_Enhanced_Surface\B - HX insulated\[]22-02-18_p450_FinEnh_HXisolated_EqualThickness';
% Processed_Data_Filename = [Processed_Data_Filename '\new.mat'];
% Processed_Data_Filename = ['new.mat'];
save(Processed_Data_Filename,'MSPM_DATA','-v7.3')
disp('Success')
end

% Function that returns parameters from string 'name' that it finds after
% 'tok' until next delimiter 'delim'
function output = FindInName(name, tok, delim)
    i_start = strfind(name, tok) + length(tok);
    output = str2double( strtok(name(i_start:end), delim) );
end

% %% reverse 'Sine' and 'Crank' (ONLY NEEDED WHEN RESULT NAMES WERE INCORRECT DUE TO TEST SET CONFIGURATION ERROR)
% t1 = 'Crank';
% t2 = 'Sine';
% for i = 1:length(MSPM_DATA)
%     if contains(MSPM_DATA(i).filename, t1)
%         MSPM_DATA(i).filename = strrep(MSPM_DATA(i).filename, t1, t2);
%     elseif contains(MSPM_DATA(i).filename, t2)
%         MSPM_DATA(i).filename = strrep(MSPM_DATA(i).filename, t2, t1);
%     end
% end
