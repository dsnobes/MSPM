function ParallelTestSet(sel, h)

    % Prep the Test Set file
    func = str2func(sel(1:end-2)); % cut off '.m' file ending
    Test_Set = func();
    
    % Start a progress for preprocessing
    progressbar('Preprocessing')
    
    % Preprocess the test cases
    for i = 1:length(Test_Set)
        Model = Test_Set(i).Model;
        processed_model = load_sub(Model, h);
        processed_models(i) = processed_model;
        progressbar(i/length(Test_Set))
    end

    % Parfor loop progress bar
    D = parallel.pool.DataQueue;
    progressbar('Simulating');
    afterEach(D, @UpdateProgressBar);

    success = 1;

    % Run the test sets
    parfor model = 1:length(Test_Set)
        success = Run(processed_models(model),Test_Set(model))
        send(D,i)
    end

    disp("Done!!!!")

    function UpdateProgressBar(~)
        progressbar(success/length(Test_Set))
        success = success + 1;
    end
    
    
    function Model = load_sub(name, h)
        % newfile = [pwd '\Saved Files\' name];
        % File = load(newfile,'Model');
        File = load(name,'Model');
        Model = File.Model;
        Model.AxisReference = h.GUI;
    
        Model.showInterConnections = false;
        Model.showNodes = false;
        Model.RelationOn = true; set(h.RelationMode,'String','On');
        Model.showGroups = get(h.showGroups,'Value');
        Model.showBodies = get(h.showBodies,'Value');
        Model.showBodyGhosts = get(h.showBodyGhosts,'Value');
        Model.showConnections = get(h.showConnections,'Value');
        Model.showLeaks = get(h.showLeaks,'Value');
        Model.showBridges = get(h.showBridges,'Value');
        Model.showSensors = get(h.showSensors,'Value');
        Model.showRelations = get(h.showRelations,'Value');
        Model.showInterConnections = get(h.showInterConnections,'Value');
        Model.showEnvironmentConnections = get(h.showEnvironmentConnections,'Value');
        Model.showNodes = get(h.showNodes,'Value');
    
        Model.showPressureAnimation = get(h.ShowPressureAnimation,'Value');
        Model.recordPressure = get(h.RecordPressure,'Value');
        Model.showTemperatureAnimation = get(h.ShowTemperatureAnimation,'Value');
        Model.recordTemperature = get(h.RecordTemperature,'Value');
        Model.showVelocityAnimation = get(h.ShowVelocityAnimation,'Value');
        Model.recordVelocity = get(h.RecordVelocity,'Value');
        Model.showTurbulenceAnimation = get(h.ShowTurbulenceAnimation,'Value');
        Model.recordTurbulence = get(h.RecordTurbulence,'Value');
        Model.recordOnlyLastCycle = get(h.RecordOnlyLastCycle,'Value');
        Model.outputPath= get(h.OutputPath,'String');
        Model.warmUpPhaseLength = str2double(get(h.WarmUpPhaseLength,'String'));
        Model.animationFrameTime = str2double(get(h.AnimationFrameTime,'String'));
    end
end


