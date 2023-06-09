function ParallelTestSet(sel, h)

    % Prep the Test Set file
    func = str2func(sel(1:end-2)); % cut off '.m' file ending
    Test_Set = func();
    
    % Start a progress for preprocessing
    progressbar('Preprocessing for Parallel Execution')

    % Start timer
    tic

    % Create temp cell output to store variables
    temp_out(1:length(Test_Set)) = parallel.FevalFuture;


    % Parfor loop progress bar
    D = parallel.pool.DataQueue;
    progressbar('Preprocessing Test Data');
    afterEach(D, @UpdateProgressBar);

    success = 1;

    % Create parallel processing pool
    pool = parpool("Processes", [4,16]);

    % Preprocess the test cases
    for i = 1:length(Test_Set)
        temp_out(i) = parfeval(@load_sub, 1, Test_Set(i).Model, h);
        send(D,i)
    end

    % Extract the values
    processed_out = fetchOutputs(temp_out);
    delete temp_out

    % Reset progressbar
    success = 1;
    progressbar('Simulating')

    % Run the test sets
    parfor model = 1:length(processed_out)
        success = Run(processed_models(model),processed_out(model))
        send(D,i)
    end

    % Delete the parallel processing pool
    delete(gcp('nocreate'))

    disp("Done!!!!")

    disp(toc)

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


