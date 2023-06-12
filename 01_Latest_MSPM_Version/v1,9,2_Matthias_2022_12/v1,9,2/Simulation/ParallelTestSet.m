function ParallelTestSet(sel, h)
    % Surpress the recursion limit warning
    warning('off', 'MATLAB:loadsave:saveRecursionLimit')

    % Prep the Test Set file
    func = str2func(sel(1:end-2)); % cut off '.m' file ending
    Test_Set = func();
    
    % Start a progress for preprocessing
    progressbar('Preprocessing for Parallel Execution')

    % Start timer
    tic

    % Create parallel processing pool
    parpool("Processes", [4,16]);
    
    % Preprocess the test cases
    for i = 1:length(Test_Set)
        processed_models(i)  = load_sub(Test_Set(i).Model, h);
        progressbar(i/length(Test_Set));
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

    % Delete the parallel processing pool
    delete(gcp('nocreate'))

    disp("Done!!!!")

    fprintf(['Elapsed time: ' sec2timestr(runtime) '\n']);

    % Turn on the recursion limit warning
    warning('on', 'MATLAB:loadsave:saveRecursionLimit')


    function UpdateProgressBar(~)
        progressbar(success/length(Test_Set))
        success = success + 1;
    end
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


function timestr = sec2timestr(sec)
    % Convert a time measurement from seconds into a human readable string.
    % Convert seconds to other units
    w = floor(sec/604800); % Weeks
    sec = sec - w*604800;
    d = floor(sec/86400); % Days
    sec = sec - d*86400;
    h = floor(sec/3600); % Hours
    sec = sec - h*3600;
    m = floor(sec/60); % Minutes
    sec = sec - m*60;
    s = floor(sec); % Seconds
    % Create time string
    if w > 0
        if w > 9
            timestr = sprintf('%d week', w);
        else
            timestr = sprintf('%d week, %d day', w, d);
        end
    elseif d > 0
        if d > 9
            timestr = sprintf('%d day', d);
        else
            timestr = sprintf('%d day, %d hr', d, h);
        end
    elseif h > 0
        if h > 9
            timestr = sprintf('%d hr', h);
        else
            timestr = sprintf('%d hr, %d min', h, m);
        end
    elseif m > 0
        if m > 9
            timestr = sprintf('%d min', m);
        else
            timestr = sprintf('%d min, %d sec', m, s);
        end
    else
        timestr = sprintf('%d sec', s);
    end
end
