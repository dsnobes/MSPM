function [History] = GradientAscent(...
    Model, ...
    OptimizationSchemeID)
    History = [];
    % Find the Folder "Test_Running" and allow the user to select a test set
    % ... which generates the appropriate structure.
    % OCT 2022: updated by Matthias to use uigetfile for convenience
    sel = uigetfile('Test_Running\*.m');
    if sel
        func = str2func(sel(1:end-2)); % cut off '.m' file ending
        RunConditions = func();
    
        % files = dir('Test_Running');
        % names = {files.name};
        % names(1:2) = [];
        % if ~iscell(names); names = {names}; end
        % for index = size(names,1):-1:1; names{index} = names{index}(1:end-2); end
        % index = listdlg('PromptString','Pick the test running conditions',...
        %     'ListString',names,...
        %     'SelectionMode','single',...
        %     'InitialValue',index,...
        %     'ListSize',[300 300]); % [W H] Default: [160 300]
        % if ~isempty(index)
        %     if strfind(names{index},'.m')
        %       func = str2func(names{index}(1:end-2));
        %     else
        %       func = str2func(names{index});
        %     end
        %     RunConditions = func();
    else
        msgbox('A run condition struct is required to run the model.');
        return;
    end
    
    % Pick Optimizing Variable -> output: options
    options = struct('OptimizedProperty','');
    names = {
        'Max Power';
        'Max Thermo Power Per Unit Engine Volume';
        'Max Efficiency';
        'Max West Number'};
    index = listdlg('ListString',names,...
        'SelectionMode','single',...
        'InitialValue',1);
    if ~isempty(index)
        options.OptimizedProperty = names{index};
    else
        msgbox('You must select a parameter to be optimized');
        return;
    end
    % RunConditions = struct that lays out the test conditions in the style of
    % ... test set running.
    % if isfield(RunConditions,'PressureBounds')
    %     mod_pressure = ~isempty(RunConditions.PressureBounds);
    %     if length(RunConditions.PressureBounds) == 1
    %         options.MinPressure = 101325;
    %         options.MaxPressure = RunConditions.PressureBounds(2);
    %     elseif mod_pressure
    %         options.MinPressure = RunConditions.PressureBounds(1);
    %         options.MaxPressure = RunConditions.PressureBounds(2);
    %     end
    % else
    %   mod_pressure = false;
    % end
    % if isfield(RunConditions,'SpeedBounds')
    %     mod_speed = ~isempty(RunConditions.SpeedBounds);
    %     if length(RunConditions.SpeedBounds) == 1
    %         options.MinSpeed = 0.2;
    %         options.MaxSpeed = RunConditions.SpeedBounds(2);
    %     elseif mod_speed
    %         options.MinSpeed = RunConditions.SpeedBounds(1);
    %         options.MaxSpeed = RunConditions.SpeedBounds(2);
    %     end
    % else
    %   mod_speed = false;
    % end
    originalname = replace(Model.name,' - Optimized','');
    
    sets = RunConditions;
    for optrial = 1:length(sets)
        RunConditions = sets(optrial);
    
        %Matthias: Moved this from before the loop into the loop
        % Load pressure and speed bounds for current trial
        if isfield(RunConditions,'PressureBounds')
            mod_pressure = ~isempty(RunConditions.PressureBounds);
            if length(RunConditions.PressureBounds) == 1
                options.MinPressure = 101325;
                options.MaxPressure = RunConditions.PressureBounds(2);
            elseif mod_pressure
                options.MinPressure = RunConditions.PressureBounds(1);
                options.MaxPressure = RunConditions.PressureBounds(2);
            end
        else
            mod_pressure = false;
        end
        if isfield(RunConditions,'SpeedBounds')
            mod_speed = ~isempty(RunConditions.SpeedBounds);
            if length(RunConditions.SpeedBounds) == 1
                options.MinSpeed = 0.2;
                options.MaxSpeed = RunConditions.SpeedBounds(2);
            elseif mod_speed
                options.MinSpeed = RunConditions.SpeedBounds(1);
                options.MaxSpeed = RunConditions.SpeedBounds(2);
            end
        else
            mod_speed = false;
        end
    
        % Load the specificied model
        if isempty(RunConditions.title)
            Model.name = originalname;
            NewModel = [Model.name ' - Optimized'];
        else
            Model.name = RunConditions.title;
            NewModel = RunConditions.title;
        end
    
        RunConditions.title = NewModel;
        RunConditions.Model = NewModel;
        addpath('..\runs\'); % Weird vs code sytax highliting, code runs as expected #32
        addpath(cd);
    
        found = false;
        for optimization_scheme = Model.OptimizationSchemes
            if optimization_scheme.ID == OptimizationSchemeID
                Study = optimization_scheme;
                Names = cell(1,length(optimization_scheme.IDs));
                Objects = cell(1,length(optimization_scheme.IDs));
                found = true;
                for k = 1:length(optimization_scheme.IDs)
                    Names{k} = optimization_scheme.Names{k};
                    switch optimization_scheme.Classes{k}
                        case 'Connection'
                            for iGroup = Model.Groups
                                for iCon = iGroup.Connections
                                    if iCon.ID == optimization_scheme.IDs{k}
                                        Objects{k} = iCon;
                                        break;
                                    end
                                end
                                if Objects{k} == iCon; break; end
                            end
                        case 'LinRotMechanism'
                            for iLRM = Model.Converters
                                if iLRM.ID == optimization_scheme.IDs{k}
                                    Objects{k} = iLRM;
                                    break;
                                end
                            end
                    end
                end
                Fields = optimization_scheme.Fields;
                break;
            end
        end
    
        if mod_pressure
            pressure_ind = length(Objects) + 1;
        end
        if mod_speed
            speed_ind = length(Objects) + mod_pressure + 1;
        end
    
        if ~found
            fprintf('XXX Model or Optimization Scheme is not found. XXX\b');
            return;
        end
    
        % Process the model
        Model.name = NewModel;
        % Open up memory, keeping only the last SnapShot
        Model.SnapShots(1:end-1) = [];
        % Recording Options
        Model.showLivePV = false;
        Model.showPressureAnimation = false;
        Model.recordPressure = true;
        Model.showTemperatureAnimation = false;
        Model.recordTemperature = true;
        Model.showVelocityAnimation = false;
        Model.recordVelocity = false;
        Model.showTurbulenceAnimation = false;
        Model.recordTurbulence = true;
        Model.showConductionAnimation = false;
        Model.recordConductionFlux = false;
        Model.showPressureDropAnimation = false;
        Model.recordPressureDrop = false;
        Model.recordOnlyLastCycle = true;
        Model.recordStatistics = true;
        Model.warmUpPhaseLength = 0;
        Model.deRefinementFactorInput = 1;
        Model.RelationOn = true;
        save(Model.name,'Model');
    
        % Initialize Recording
        % ... Struct that provides the class-field names and value, as well as goal
        h1 = figure();
        h2 = figure();
    
        % Adadelta parameters
        extra = mod_pressure + mod_speed;
        shifts = zeros(length(Objects) + extra,1);
        take_a_break = false(length(shifts),1);
        gradient = shifts;
        % gamma = 0.6;
        tol = 1e-6;
        optimizing = true;
        maxiterations = 30;
        iteration = 1;
        L = 0.001; % Length scale for shifts in location of connections
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % General Scale of variable shifts during optimization. Should be
        % increased when optimizing speed or pressure.
        Scale = 1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        local_scale = 1;
        %EPara2 = ones(size(shifts))*0.01;
        %EGrad2 = ones(size(shifts));
    
        % Define History
        History = struct();
        fprintf('\nRunning first test to get baseline result\n')
        [History.Score, success, ~, ~] = RunSubFunction(Model,RunConditions,options);
        if ~success
            fprintf('XXX Failed to run the first test, corrupted snapshot or unsolveable geometry XXX\n');
            return;
        end
        History.Names = cell(size(Objects));
        History.IDs = zeros(size(Objects));
        for i = 1:length(Objects)
            History.Names{i} = Names{i};
            History.IDs(i) = Objects{i}.ID;
        end
        if mod_pressure
            History.Names{pressure_ind} = 'Pressure (Atm)';
        end
        if mod_speed
            History.Names{speed_ind} = 'Speed (Hz)';
        end
        History.data = zeros(length(Objects) + mod_pressure + mod_speed,0);
        if ~isempty(Study.History)
            iteration = iteration + 1;
            maxiterations = maxiterations + 1;
            for i = 1:length(History.Names)
                for j = 1:length(Study.History.Names)
                    if strcmp(History.Names{i},Study.History.Names{j}) % two for loops and if that do nothing? #33
                        %         EPara2(i) = Study.History.EPara2(j);
                        %         EGrad2(i) = Study.History.EGrad2(j);
                        %         gradient(i) = Study.History.gradient(j);
                        break;
                    end
                end
            end
            Scale = Study.History.Scale;
        end
        count = 1;
        for i = 1:length(Objects)
            History.data(i,count) = Objects{i}.get(Fields{i});
        end
        if mod_pressure
            History.data(pressure_ind,count) = RunConditions.EnginePressure/101325;
        end
        if mod_speed
            History.data(speed_ind,count) = RunConditions.rpm/60;
        end
    
    
        while optimizing && iteration < maxiterations
            iteration = iteration + 1;
            % Calculate local gradient - output shifts - using Adadelta
            for i = 1:length(Objects)
                if ~take_a_break(i)
                    [gradient(i), History] = ...
                        getShiftObject(gradient(i),Objects{i},Fields{i},History,...
                        Model,RunConditions,options);
                end
            end
            if mod_pressure
                ind = pressure_ind;
                if ~take_a_break(ind)
                    [gradient(ind), History, RunConditions] = getShiftRunCon(...
                        gradient(ind),History,Model,RunConditions,...
                        'EnginePressure',options.MinPressure,options.MaxPressure,options);
                end
            end
            if mod_speed
                ind = speed_ind;
                if ~take_a_break(ind)
                    [gradient(ind), History, RunConditions] = getShiftRunCon(...
                        gradient(ind),History,Model,RunConditions,...
                        'rpm',options.MinSpeed,options.MaxSpeed,options);
                end
            end
    
            if max(abs(gradient)) < tol
                optimizing = false;
            end
    
            % Adadelta algorithm - Shifts
            for i = 1:length(Objects)
                %     shifts(i) = sqrt((EPara2(i) + 1e-8) / ...
                %       (EGrad2(i) + 1e-8)) * gradient(i);
                shifts(i) = L*gradient(i);%/sqrt(EGrad2(i) + 1e-8);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Matthias: 'getShiftRunCon' above calculates the gradient of the Score
            % (e.g. Power) vs the variable (speed / pressure). Here below, this gradient becomes the shift
            % and is then tested (ca. line 372).
            if mod_pressure
                %     shifts(i) = sqrt((EPara2(pressure_ind) + 1e-8) / ...
                %       (EGrad2(pressure_ind) + 1e-8)) * gradient(pressure_ind);
                shifts(pressure_ind) = gradient(pressure_ind);%/sqrt(EGrad2(pressure_ind) + 1e-8);
            end
            if mod_speed
                %     shifts(speed_ind) = sqrt((EPara2(speed_ind) + 1e-8) / ...
                %       (EGrad2(speed_ind) + 1e-8)) * gradient(speed_ind);
                shifts(speed_ind) = gradient(speed_ind);%/sqrt(EGrad2(speed_ind) + 1e-8);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Matthias: the lines below limit the shifts in size based on 'Scale'.
            % With Scale=1, a shift in a single variable is limited to 0.005m or rpm or
            % Pa. This makes sense for locations in (m) but is way too small for
            % optimizing speed or pressure! --> Vary 'Scale'
            if max(abs(shifts)) > Scale*0.005
                shifts = Scale*shifts*0.005/max(abs(shifts));
            elseif max(abs(shifts)) < Scale*0.0002
                %         elseif max(abs(shifts)) < Scale*0.002
                shifts = Scale*shifts*0.002/max(abs(shifts));
            end
    
            fprintf('\nShifts: ')
            for i = 1:length(shifts)
                fprintf([num2str(shifts(i)) ', ']);
                if i == length(shifts)
                    fprintf('\n');
                end
            end
    
            power_backup = History.Score(end);
            increasing = true;
            stepcount = 1;
            trial = 1;
            fprintf('Starting Uphill Climb \n');
            while increasing
                % Make a step
                backup = zeros(1,length(Objects)+mod_pressure+mod_speed);
                for i = 1:length(Objects)
                    fprintf(['Shifting Object: ' num2str(i) '\n']);
                    backup(i) = Objects{i}.get(Fields{i});
                    if ~take_a_break(i)
                        newValue = Objects{i}.get(Fields{i}) + shifts(i);
                        if isa(Objects{i},'Connection')
                            for iBody = Objects{i}.Bodies
                                for iCon = iBody.Connections
                                    if iCon.Orient == Objects{i}.Orient && iCon ~= Objects{i}
                                        if sign(iCon.x - Objects{i}.x) == sign(shifts(i))
                                            if ~iCon.IsFixedTo(Objects{i})
                                                shifts(i) = sign(shifts(i)).*min(abs(shifts(i)), ...
                                                    abs(0.33*(iCon.x - Objects{i}.x)));
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        try_ = 0;
                        while Objects{i}.get(Fields{i}) ~= newValue
                            Objects{i}.set(Fields{i},newValue);
                            if Objects{i}.get(Fields{i}) ~= newValue
                                shifts(i) = shifts(i) / 2;
                                newValue = Objects{i}.get(Fields{i}) + local_scale * shifts(i);
                                try_ = try_ + 1;
                                if try_ > 3; shifts(i) = 0; break; end
                            else; break;
                            end
                        end
                        take_a_break(i) = (~take_a_break(i) && abs(local_scale * shifts(i)) < tol);
                    end
                end
                if mod_pressure
                    backup(pressure_ind) = RunConditions.EnginePressure;
                    RunConditions.EnginePressure = min(options.MaxPressure,...
                        max(options.MinPressure,RunConditions.EnginePressure + local_scale * shifts(pressure_ind)));
                    fprintf(['Shifting Pressure by ' num2str(RunConditions.EnginePressure-backup(pressure_ind)) ' Pa\n']);
                end
                if mod_speed
                    backup(speed_ind) = RunConditions.rpm;
                    RunConditions.rpm = min(options.MaxSpeed,...
                        max(options.MinSpeed,RunConditions.rpm + local_scale * shifts(speed_ind)));
                    fprintf(['Shifting Speed by ' num2str(RunConditions.rpm-backup(speed_ind)) ' rpm\n']);
                end
    
                % Discretize & Run using a single run
                [Power, success, ShaftPower, statistics] = RunSubFunction(Model,RunConditions,options);
    
                if ~success || isnan(Power)
                    fprintf('Simulation Failed\n');
                    for i = 1:length(Objects); Objects{i}.set(Fields{i},backup(i)); end
                    if mod_pressure; RunConditions.EnginePressure = backup(pressure_ind); end
                    if mod_speed; RunConditions.rpm = backup(speed_ind); end
                    Power = power_backup;
                    break;
                end
                %           if all(take_a_break(i))
                if all(take_a_break) %Matthias: fixed
                    fprintf('Simulation Stalled (from "take_a_break", shift in objects too small.\n');
                    break;
                end
    
                % Test the step
                fprintf('Testing the Next Step \n');
                increasing = Power > power_backup*1.002;
                if increasing
                    if local_scale == 1
                        % Continue stepping
                        power_backup = Power;
                        stepcount = stepcount + 1;
                    else
                        increasing = false;
                        local_scale = 1;
                    end
                else
                    % Undo the shift
                    for i = 1:length(Objects); Objects{i}.set(Fields{i},backup(i)); end
                    if mod_pressure; RunConditions.EnginePressure = backup(pressure_ind); end
                    if mod_speed; RunConditions.rpm = backup(speed_ind); end
                    Power = power_backup;
                    save(Model.name,'Model');
                    if stepcount == 1 && trial < 3
                        % We overstepped this point, but the gradient is still valid
                        % shifts = shifts;
                        trial = trial + 1;
                        increasing = true;
                        local_scale = local_scale / 2;
                    else
                        local_scale = 1;
                        stepcount = 1;
                        increasing = false;
                    end
                end
            end
    
            if ~isfield(History,'Score'); History.Score = []; end
            count = length(History.Score) + 1;
    
            History.Score(count) = Power;
    
            figure(h1);
            plot(History.Score);
            xlabel('Trial');
            switch options.OptimizedProperty
                case 'Max Power'
                    ylabel('Power [W]');
                    title('Trend in Power during gradient ascent');
                case 'Max Thermo Power Per Unit Engine Volume'
                    ylabel('Thermo Power [W] per m^3');
                    title('Trend in Power Density during gradient ascent');
                case 'Max Efficiency'
                    ylabel('Efficiency [%]');
                    title('Trend in Efficiency during gradient ascent');
                case 'Max West Number'
                    ylabel('West Number');
                    title('Trend in West Number during gradient ascent');
            end
    
    
            for i = 1:length(Objects)
                History.data(i,count) = Objects{i}.get(Fields{i});
            end
            if mod_pressure
                History.data(pressure_ind,count) = RunConditions.EnginePressure/101325;
            end
            if mod_speed
                History.data(speed_ind,count) = RunConditions.rpm/60;
            end
    
            figure(h2);
            xlabel('Trial');
            ylabel('Value');
            hold on;
            for i = 1:size(History.data,1)
                plot(History.data(i,:));
            end
            legend(History.Names,'Location','northwest')
            hold off;
            if count > 1
                if History.Score(count) - History.Score(count-1) < 1e-2
                    fprintf('Simulation Stalled. Score changed by less than 0.01 during last step.\n');
                    break;
                end
            end
        end
        % History.EPara2 = EPara2;
        % History.EGrad2 = EGrad2;
        History.Scale = Scale;
        History.gradient = gradient;
        Study.History = History;
        save(Model.name,'Model');
    
        % Record Matrix of Body Sizes
        for iGroup = Model.Groups
            for iBody = iGroup.Bodies
                if iBody.matl.Phase == enumMaterial.Gas
                    if isempty(iBody.customname); field = ['Body_' num2str(iBody.ID)];
                    else
                        % Matthias: added this function to make sure any body name is converted to a valid field name
                        field = matlab.lang.makeValidName(iBody.customname);
                    end
                    [~,~,x1,x2] = iBody.limits(enumOrient.Vertical);
                    [~,~,y1,y2] = iBody.limits(enumOrient.Horizontal);
                    % For each gas body, axial frontal area and y-length are saved
                    sets(optrial).(field) = [pi*(x2^2-x1^2) y2(1)-y1(1)];
                    sets(optrial).Score = Power;
                end
            end
        end
        sets(optrial).Score = Power;
        sets(optrial).Converged = success;
        sets(optrial).statistics = statistics;
        sets(optrial).HistoryScore = History.Score;
        sets(optrial).HistoryDOF = History.data;
        sets(optrial).HistoryNames = History.Names;
        save(['..\Runs\Optimization_set_' replace(replace(date,' ','_'),':','-')], 'sets');
    end
end

function [Parameter, success, ShaftPower, statistics] = RunSubFunction(Model, RunConditions, options)
    [success] = Model.Run(RunConditions);
    addpath(['..\runs\' RunConditions.title]); % Weird vs code sytax highliting, code runs as expected #32
    try
        load([RunConditions.title '_Statistics'],'statistics');
    catch
        load([RunConditions.title '_Statistics.mat'],'statistics');
    end
    ShaftPower = mean(statistics.Power);
    switch options.OptimizedProperty
        case 'Max Power'
            Parameter = ShaftPower;
        case 'Max Thermo Power Per Unit Engine Volume'
            ThermoPower = 0;
            for iPV = Model.PVoutputs
                ThermoPower = ThermoPower + iPV.Power;
            end
            Vol = mean(statistics.VMax);
            if ThermoPower < 0 % To prevent convergence on an incorrect sense of optimal
                Parameter = ThermoPower;
            else
                Parameter = ThermoPower/Vol;
            end
            statistics.Power = ThermoPower;
        case 'Max Efficiency'
            Q = -sum(statistics.To_Source);
            Parameter = ShaftPower/Q;
        case 'Max West Number'
            Wo = ShaftPower;
            P = RunConditions.EnginePressure;
            dV = statistics.VMax - statistics.VMin;
            V = mean(dV(dV~=0));
            f = RunConditions.rpm/60;
            TH = RunConditions.SourceTemp;
            TK = RunConditions.SinkTemp;
            Parameter = Wo/(P*V*f)*(TH + TK)/(TH - TK);
    end
    statistics.Power = mean(statistics.Power);
    statistics.Time = [];
    statistics.Angle = [];
    statistics.Omega = [];
    statistics.TotalPower = [];
    statistics.To_Environment = sum(statistics.To_Environment);
    statistics.To_Source = sum(statistics.To_Source);
    statistics.To_Sink = sum(statistics.To_Sink);
    statistics.Flow_Loss = sum(statistics.Flow_Loss);
    %{
        Power = 0;
        for PV = Model.PVoutputs
          str = [PV.name '_' Model.name];
          str = replace(str,':',' -');
          load(['..\runs\' RunConditions.title '\' str '.mat'], 'data');
          pV = zeros(size(data.DependentVariable,1)+1,1); pP = pV;
          for i = 1:size(data.DependentVariable,2)
            pV(1:end-1) = data.IndependentVariable(:,i);
            pV(end) = data.IndependentVariable(1,i);
            pP(1:end-1) = data.DependentVariable(:,i);
            pP(end) = data.DependentVariable(1,i);
            Power = Power + PowerFromPV(pP,pV);
          end
        end
    %}
end

function [grad, History] = getShiftObject(grad,obj,fld,History,...
    Model,RunConditions,options)
    if grad < 0
        modshift = -0.001;
    else
        modshift = 0.001;
    end
    grad = 0;
    backup = obj.get(fld);
    newValue = backup + modshift;
    try_ = 0;
    while obj.get(fld) ~= newValue
        obj.set(fld,newValue);
        if obj.get(fld) == newValue
            fprintf(['\nRunning test to get gradient for object'  '\n'])
            [Power, success, ~, ~] = RunSubFunction(Model,RunConditions,options);
            % Undo
            obj.set(fld,backup);
            if ~success
                modshift = -modshift / 2;
                newValue = backup + modshift;
                obj.set(fld,newValue);
                try_ = try_ + 1;
                if try_ > 8; break; end
            else
                grad = (Power - History.Score(end))/modshift;
                return;
            end
        else
            modshift = -modshift / 2;
            newValue = backup + modshift;
            obj.set(fld,newValue);
            try_ = try_ + 1;
            if try_ > 8; break; end
        end
    end
    if grad == 0
        fprintf('err');
    end
end

function [grad, History, RunCon] = getShiftRunCon(grad,History,...
    Model,RunCon,Field,MinVal,MaxVal,options)
    success = false;
    backup = RunCon.(Field);
    while ~success
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Modify amount of shift in pressure and speed
        % Might want to increase these since the change in power resulting from
        % these miniscule changes in speed/pressure may be smaller than the
        % solver uncertainty from its convergence tolerance.
        if strcmp(Field,'EnginePressure')
            modshift = 100;
        elseif strcmp(Field,'rpm')
            modshift = 0.1;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        RunCon.(Field) = min(MaxVal,max(MinVal,backup + modshift));
        fprintf(['\nRunning test to get gradient for ' Field '\n'])
        [Power, success, ~, ~] = RunSubFunction(Model,RunCon,options);
        if ~success
            modshift = modshift/2;
            RunCon.(Field) = backup;
        end
    end
    grad = (Power - History.Score(end))/modshift;
    % if sign(grad) == sign(modshift)
    %     % Take advantage of it
    %     History.Score(end) = statistics.TotalPower(end);
    % else
    %     % Undo the small change
    %     RunCon.(Field) = RunCon.(Field) - modshift;
    % end
end

