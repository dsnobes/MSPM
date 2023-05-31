classdef Model < handle
    %MODEL Summary of this class goes here
    %   Detailed explanation goes here
    properties (Constant)
        ProportionTolerance = 0.02; % 2% error is pretty reasonable
        dt = 0.01;          % Seconds              ???
        NTheta = 400;       % Number of divisions  400 intervals
        dOmega2 = pi^2/2;   % (Radians/second)^2   32 intervals between 0->2 Hz
        dAppliedForce = 1;  % Newtons              ???
        %%%%%%%%%%%%%%%%%%%%%%% Changed %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        AnimationLength_s = 12;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        AnimationSpeed_rads = pi;
        MaxFourierNumber = 0.25;
    end

    properties (Dependent)
        ActiveGroup;
        isDefaultModel;
        isDiscretized;
    end

    properties
        isChanged logical = true;
        Selection = cell(0); % Various Objects
        name = '';
        Groups Group; % A container of Group
        Mesher Mesher; % A container for meshing options
        Bridges Bridge;
        LeakConnections LeakConnection;
        RefFrames Frame;
        Sensors Sensor;
        PVoutputs PVoutput;
        SnapShots cell;
        NonConnections NonConnection;
        CustomMinorLosses CustomMinorLoss;
        OptimizationSchemes OptimizationScheme;
        CurrentSim Simulation; % Simulations are stored in a named file folder
        Converters LinRotMechanism;
        AxisReference;
        setConditions Environment;
        MechanicalSystem MechanicalSystem;
        initConditions Environment;
        surroundings Environment;
        roughness double = 0.000045; % 0.045 mm - Commercial or welded steel

        Faces Face;
        Nodes Node;

        Simulations Simulation;

        PressureContacts PressureContact;
        ShearContacts ShearContact;

        Results Result;
        engineTemperature double = 298;
        enginePressure double = 101325;
        engineSpeed double = 1;

        RelationOn = true;
    end

    properties (Hidden)
        StaticGUIObjects = [];
        DynamicGUIObjects = [];
        GhostGUIObjects = [];
        BodyIDIndex = 1;
        ConIDIndex = 1;
        OptIDIndex = 1;
        LRMIDIndex = 1;
        % GUI Options
        showGroups = true;
        showBodies = true;
        showBodyGhosts = true;
        showConnections = true;
        showLeaks = true;
        showBridges = true;
        showSensors = true;
        showEnvironmentConnections = false;
        showRelations = false;

        % Matthias: Advanced Node Display Options
        showInterConnections = false;
        showFacesGas = true;
        showFacesSolid = true;
        showFacesMix = true;
        showFacesLeak = false;
        showFacesMatrixTransition = false;
        showFacesEnvironment = false;

        showNodes = false;
        showNodeBounds = false;
        showNodesSVGN = true;
        showNodesVVGN = true;
        showNodesSAGN = true;
        showNodesSN = true;
        showNodesEN = false;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Simulation Options
        showLivePV = true;
        showPressureAnimation = true;
        recordPressure = true;
        showTemperatureAnimation = true;
        recordTemperature = true;
        showVelocityAnimation = true;
        recordVelocity = true;
        showTurbulenceAnimation = true;
        recordTurbulence = true;
        showConductionAnimation = true;
        recordConductionFlux = true;
        showPressureDropAnimation = true;
        recordPressureDrop = true;
        %new
        showReynoldsAnimation = true;
        recordReynolds = true;

        recordOnlyLastCycle = true;
        recordStatistics = true;
        outputPath = '';
        warmUpPhaseLength = 0;
        animationFrameTime = 0.05;
        deRefinementFactorInput = 1;

        MaxCourantFinal = 0.025;
        MaxFourierFinal = 0.025;
        MaxCourantConverging = 0.025;
        MaxFourierConverging = 0.025;

        % RunTime Options
        stopSimulation = false;

        isStateDiscretized logical;
        isAnimating logical;
    end

    methods
        %% Creating, Reseting, Debugging
        function this = Model(AxisReference)
            this.initConditions = Environment();
            this.surroundings = Environment();
            this.Mesher = Mesher();
            this.MechanicalSystem = MechanicalSystem(this,LinRotMechanism.empty,[],1,function_handle.empty);
            switch nargin
                case 0
                    this.Groups = Group(this,Position(0,0,pi/2)); % The first Group
                case 1
                    this.Groups = Group(this,Position(0,0,pi/2)); % The first Group
                    this.AxisReference = AxisReference;
            end
            this.isChanged = true;
        end
        function ID = getBodyID(this)
            % Creates a unique id when called
            this.BodyIDIndex = this.BodyIDIndex + 1;
            ID = this.BodyIDIndex;
        end
        function ID = getConID(this)
            % Creates a unique id when called
            this.ConIDIndex = this.ConIDIndex + 1;
            ID = this.ConIDIndex;
        end
        function ID = getOptimizationStudyID(this)
            % Creates a unique id when called
            this.OptIDIndex = this.OptIDIndex + 1;
            ID = this.OptIDIndex;
        end
        function ID = getLRMID(this)
            % Creates a unique id when called
            this.LRMIDIndex = this.LRMIDIndex + 1;
            ID = this.LRMIDIndex;
        end
        function Bodies = BodyList(this)
            % Makes a list of all bodies in the Model, spanning multiple groups
            n = 0;
            for iGroup = this.Groups
                Bodies(n+1:n+length(iGroup.Bodies)) = iGroup.Bodies;
                n = n + length(iGroup.Bodies);
            end
        end
        function resetDiscretization(this)
            % Reset the discretization of the entire model, removing all faces
            % ... and nodes
            for iLRM = this.Converters
                iLRM.Model = this;
                if isempty(iLRM.ID)
                    iLRM.ID = this.getLRMID();
                end
            end
            for iGroup = this.Groups
                iGroup.resetDiscretization();
            end
            for iBridge = this.Bridges
                iBridge.resetDiscretization();
            end
            for iLeak = this.LeakConnections
                iLeak.resetDiscretization();
            end
            this.Nodes(:) = [];
            this.Faces(:) = [];
            this.PressureContacts(:) = [];
            this.ShearContacts(:) = [];
            this.CurrentSim(:) = [];
            this.surroundings.resetDiscretization();
            this.change();
        end
        function dispNodeIndexes(this)
            % Prints to screen the index associated with a node its display
            % ... position
            for iNd = this.Nodes
                pnt = iNd.minCenterCoords;
                text(pnt.x,pnt.y,num2str(iNd.index));
            end
        end

        %% GET/SET Interface
        function Item = get(this,PropertyName)
            switch PropertyName
                case 'Name'
                    Item = this.name;
                case 'Groups'
                    Item = this.Groups;
                case 'Bridges'
                    Item = this.Bridges;
                case 'Leaks'
                    Item = this.LeakConnections;
                case 'Sensors'
                    Item = this.Sensors;
                case 'PVoutputs'
                    Item = this.PVoutputs;
                case 'Lin. to Rot. Mechanisms'
                    Item = this.Converters;
                case 'Optimization Studies'
                    Item = this.OptimizationSchemes;
                case 'Initial Internal Conditions'
                    Item = this.initConditions;
                case 'External Conditions'
                    Item = this.surroundings;
                case 'Engine Temperature'
                    Item = this.engineTemperature;
                case 'Engine Pressure'
                    Item = this.enginePressure;
                case 'Minimum Speed'
                    Item = this.engineSpeed;
                case 'SnapShots'
                    Item = cell(length(this.SnapShots),1);
                    for i = 1:length(this.SnapShots)
                        Item{i} = this.SnapShots{i}.Name;
                    end
                case 'NonConnections'
                    Item = cell(length(this.NonConnections),1);
                    for i = 1:length(this.NonConnections)
                        Item{i} = this.NonConnections(i).name;
                    end
                case 'Custom Minor Losses'
                    Item = cell(length(this.CustomMinorLosses),1);
                    for i = 1:length(this.CustomMinorLosses)
                        Item{i} = this.CustomMinorLosses(i).name;
                    end
                case 'Mesher'
                    Item = this.Mesher;
                case 'Mechanical System'
                    % why does this GETTER modify this??????
                    if isempty(this.MechanicalSystem)
                        this.MechanicalSystem = MechanicalSystem(this,...
                            LinRotMechanism.empty,[],1,function_handle.empty);
                    end
                    Item = this.MechanicalSystem;
                case 'Max Courant Final'
                    Item = this.MaxCourantFinal;
                case 'Max Fourier Final'
                    Item = this.MaxFourierFinal;
                case 'Max Courant Converging'
                    Item = this.MaxCourantConverging;
                case 'Max Fourier Converging'
                    Item = this.MaxFourierConverging;
                otherwise
                    fprintf(['XXX Model GET Inteface for ' PropertyName ' is not found XXX\n']);
                    return;
            end
            this.change();
        end
        function set(this,PropertyName,Item)
            % these are public properties??? why is there a setter? (it is basically unused as far as I can tell)
            switch PropertyName
                case 'Name'
                    this.name = Item;
                case 'Engine Temperature'
                    this.engineTemperature = Item;
                case 'Engine Pressure'
                    this.enginePressure = Item;
                case 'Minimum Speed'
                    this.engineSpeed = Item;
                case 'SnapShots'
                    for i = length(Item):-1:1
                        if Item(i); this.SnapShots(i) = []; end
                    end
                case 'NonConnections'
                    for i = length(Item):-1:1
                        if Item(i); this.NonConnections(i) = []; end
                    end
                case 'Custom Minor Losses'
                    for i = length(Item):-1:1
                        if Item(i); this.CustomMinorLosses(i) = []; end
                    end
                case 'Max Courant Final'
                    this.MaxCourantFinal = Item;
                case 'Max Fourier Final'
                    this.MaxFourierFinal = Item;
                case 'Max Courant Converging'
                    this.MaxCourantConverging = Item;
                case 'Max Fourier Converging'
                    this.MaxFourierConverging = Item;
                otherwise
                    fprintf(['XXX Model SET Inteface for ' PropertyName ' is not found XXX\n']);
            end
        end

        %% Adding Elements
        function addGroup(this,GroupToAdd)
            if isrow(GroupToAdd)
                this.Groups = [this.Groups GroupToAdd];
            else
                this.Groups = [this.Groups GroupToAdd'];
            end
        end
        function addBridge(this,BridgeToAdd)
            if isrow(BridgeToAdd)
                this.Bridges = [this.Bridges BridgeToAdd];
            else
                this.Bridges = [this.Bridges BridgeToAdd'];
            end
        end
        function addLeakConnection(this,LeakToAdd)
            if isrow(LeakToAdd)
                this.LeakConnections = [this.LeakConnections LeakToAdd];
            else
                this.LeakConnections = [this.LeakConnections LeakToAdd'];
            end
        end
        function addConverter(this,ConverterToAdd)
            LEN = length(this.Converters);
            for i = length(ConverterToAdd):-1:1
                this.Converters(LEN+i) = ConverterToAdd(i);
                this.addFrame(ConverterToAdd(i).Frames);
            end
        end
        function addFrame(this,FrameToAdd)
            LEN = length(this.RefFrames);
            for i = length(FrameToAdd):-1:1
                this.RefFrames(LEN+i) = FrameToAdd(i);
            end
        end
        function addSensor(this,SensorToAdd)
            LEN = length(this.Sensors);
            for i = length(SensorToAdd):-1:1
                this.Sensors(LEN+i) = SensorToAdd(i);
                if this.isDiscretized
                    this.Sensors(LEN+1).update();
                end
            end
            this.Sensors = unique(this.Sensors);
        end
        function addPVoutput(this,PVoutputToAdd)
            LEN = length(this.PVoutputs);
            for i = length(PVoutputToAdd):-1:1
                this.PVoutputs(LEN+i) = PVoutputToAdd(i);
            end
            this.PVoutputs = unique(this.PVoutputs);
        end
        function addSnapShot(this,SnapShotToAdd)
            this.SnapShots{end+1} = SnapShotToAdd;
        end
        function addNonConnection(this,NonConnectionToAdd)
            LEN = length(this.NonConnections);
            for i = length(NonConnectionToAdd):-1:1
                this.NonConnections(LEN+i) = NonConnectionToAdd(i);
                this.resetDiscretization();
            end
            keep = true(size(this.NonConnections));
            for i = 1:length(this.NonConnections)
                if keep(i)
                    for j = i+1:length(this.NonConnections)
                        if keep(j)
                            if this.NonConnections(i).Body1 == ...
                                    this.NonConnections(j).Body1
                                if this.NonConnections(i).Body2 == ...
                                        this.NonConnections(j).Body2
                                    keep(j) = false;
                                end
                            elseif this.NonConnections(i).Body1 == ...
                                    this.NonConnections(j).Body2
                                if this.NonConnections(i).Body2 == ...
                                        this.NonConnections(j).Body1
                                    keep(j) = false;
                                end
                            end
                        end
                    end
                end
            end
            this.NonConnections = this.NonConnections(keep);
        end
        function addCustomMinorLoss(this,CustomMinorLossToAdd)
            LEN = length(this.CustomMinorLosses);
            for i = length(CustomMinorLossToAdd):-1:1
                this.CustomMinorLosses(LEN+i) = CustomMinorLossToAdd(i);
                this.resetDiscretization();
            end
            this.CustomMinorLosses = unique(this.CustomMinorLosses);
        end

        %% Update on Demand
        function update(this)
            this.isStateDiscretized = true;
            if any(~isvalid(this.Bridges))
                this.Bridges = this.Bridges(isvalid(this.Bridges));
            end
            keep = true(size(this.Bridges));
            for i = 1:length(this.Bridges)
                for j = i+1:length(this.Bridges)
                    if (this.Bridges(i).Body1 == this.Bridges(j).Body1 && ...
                            this.Bridges(i).Body2 == this.Bridges(j).Body2) ...
                            || (this.Bridges(i).Body2 == this.Bridges(j).Body1 && ...
                            this.Bridges(i).Body1 == this.Bridges(j).Body2)
                        keep(j) = false;
                    end
                end
            end
            for i = length(keep):-1:1
                if ~keep(i)
                    this.Bridges(i).deReference();
                end
            end
            if any(~isvalid(this.Groups))
                this.Groups = this.Groups(isvalid(this.Groups));
            end
            if any(~isvalid(this.LeakConnections))
                this.LeakConnections = this.LeakConnections(isvalid(this.LeakConnections));
            end
            if any(~isvalid(this.Converters))
                this.Converters = this.Converters(isvalid(this.Converters));
            end
            for iConverter = this.Converters
                if isempty(iConverter.Model); iConverter.Model = this; end
            end
            if any(~isvalid(this.RefFrames))
                this.RefFrames = this.RefFrames(isvalid(this.RefFrames));
            end
            if any(~isvalid(this.Sensors))
                this.Sensors = this.Sensors(isvalid(this.Sensors));
            end
            if any(~isvalid(this.PVoutputs))
                this.PVoutputs = this.PVoutputs(isvalid(this.PVoutputs));
            end
            for i = length(this.Selection):-1:1
                if ~isvalid(this.Selection{i})
                    this.Selection(i) = [];
                end
            end
            for iGroup = this.Groups
                if ~iGroup.isDiscretized
                    this.isStateDiscretized = false;
                    break;
                end
            end
            this.isChanged = false;
        end
        function change(this)
            % Records that the model is changed and should be updated when
            % ... required
            this.isChanged = true;
            this.Faces(:) = [];
            this.Nodes(:) = [];
            this.CurrentSim(:) = [];
            this.isStateDiscretized = false;
        end

        %% Process nodes and faces
        function isit = get.isDiscretized(this)
            if this.isChanged; this.update(); end
            isit = this.isStateDiscretized;
        end
        function MeshCounts = discretize(this, run)
            this.resetDiscretization();
            for iLinRot = this.Converters
                iLinRot.Populate(iLinRot.Type,iLinRot.originalInput);
            end
            if this.isChanged; this.update(); end

            %% Initializing Meshing
            progressbar('Calculating Surroundings');

            % Test if everything is discretized
            this.surroundings.discretize();

            % Matthias: In this initial section of 'discretize' function
            % there are many expressions like "isfield('XXX',run)" which
            % are wrong (should be "isfield(run,'XXX')"). They always give
            % 'false' because of wrong order of the input arguments.
            % BUT they don't matter because the code conditioned by them is
            % redundant. It applies the run parameters from the 'run'
            % struct to the model ('this'), but later in 'Model.Run' the
            % 'crun' struct is directly passed to the Simulation object
            % which then aplies the parameters from 'crun'. The parameters
            % applied here from 'run' are never used.
            % Matthias: Fixed the wrong uses of 'isfield'. marked by %FIXED

            if nargin > 1 && isfield(run,'rpm') %FIXED
                % This line causes mesh in solid bodies discretized by the
                % 'Wall_Smart_Discretize' function to vary depending on
                % engine speed! (Temperature oscillation depth based on
                % speed)
                % this.engineSpeed = run.rpm;
            end

            if nargin > 1 && isfield(run,'NodeFactor') && run.NodeFactor ~= 1 %FIXED
                backup_ODN = this.Mesher.oscillation_depth_N;
                backup_MXT = this.Mesher.maximum_thickness;
                backup_HEFD = this.Mesher.HeatExchangerFinDivisions;
                backup_gas_entrance = this.Mesher.Gas_Entrance_Exit_N;
                backup_gas_maximum_size = this.Mesher.Gas_Maximum_Size;
                backup_gas_minimum_size = this.Mesher.Gas_Minimum_Size;
                %% IMPORTANT for 'NodeFactor'
                % This section defines which meshing settings are modified
                % by 'NodeFactor'. The settings are then used by the
                % 'Wall_Smart_Discretize' function on all the bodies that
                % have the function enabled. By default (Steven), only
                % this.Mesher.Gas_Entrance_Exit_N
                % this.Mesher.Gas_Maximum_Size
                % this.Mesher.Gas_Minimum_Size
                % are changed by 'NodeFactor'.
                % Matthias May 31: uncommented
                this.Mesher.oscillation_depth_N = ...
                    ceil(sqrt(double(run.NodeFactor))*double(backup_ODN));
                this.Mesher.maximum_thickness = ...
                    backup_MXT/sqrt(double(run.NodeFactor));
                %
                this.Mesher.Gas_Entrance_Exit_N = ...
                    double(run.NodeFactor)*double(backup_gas_entrance);
                this.Mesher.Gas_Maximum_Size = ...
                    double(backup_gas_maximum_size)/double(run.NodeFactor);
                this.Mesher.Gas_Minimum_Size = ...
                    double(backup_gas_minimum_size)/double(run.NodeFactor);
                %%
            end

            % Matthias: Added code to apply "h_custom_Source/Sink" from test set here.
            % Criterium for body being a source/sink is it being 'Constant
            % Temperature' and its temperature being higher/lower than the
            % default engine temperature.
            run_so_si = isfield(run,{'h_custom_Source','h_custom_Sink'}); %1=source, 2=sink
            if any(run_so_si)
                % if isfield(run,'h_custom_Source') || isfield(run,'h_custom_Sink')
                for iGroup = this.Groups
                    for iBody = iGroup.Bodies
                        if strcmp(iBody.matl.name, 'Constant Temperature') %Sources in form of constant temperature bodies
                            % && ~isnan(iBody.h_custom)
                            % Any constant temp body, independent of its
                            % h_custom value, will be considered a
                            % source/sink.
                            if iBody.Temperature > this.engineTemperature
                                if run_so_si(1); iBody.h_custom = run.h_custom_Source; end
                                % if isfield(run,'h_custom_Source'); iBody.h_custom = run.h_custom_Source; end
                            elseif iBody.Temperature < this.engineTemperature
                                if run_so_si(2); iBody.h_custom = run.h_custom_Sink; end
                                % if isfield(run,'h_custom_Sink'); iBody.h_custom = run.h_custom_Sink; end
                            else
                                fprintf(['XXX When applying "h_custom_Source/Sink", a body could not be determined as Source or Sink because its temperature is equal to the engine temperature:\n' iBody.name ' XXX\n']);
                            end
                        end
                        if ~isempty(iBody.Matrix) && iBody.Matrix.data.hasSource  %Sources inside of Matrixes
                            if iBody.Matrix.data.SourceTemperature > this.engineTemperature
                                if run_so_si(1); iBody.h_custom = run.h_custom_Source; end
                            elseif iBody.Matrix.data.SourceTemperature < this.engineTemperature
                                if run_so_si(2); iBody.h_custom = run.h_custom_Sink; end
                            else
                                fprintf(['XXX When applying "h_custom_Source/Sink", a body could not be determined as Source or Sink because its temperature is equal to the engine temperature:\n' iBody.name ' XXX\n']);
                            end
                        end

                    end
                end
            end

            % Matthias: Calculation of conductances for faces begins in this step of
            % discretization! --> all modifications to conductance (e.g. 'h_custom')
            % must be applied prior.

            progressbar('Discretizing Bridges');
            % Test and Discretize Bridges
            for iBridge = this.Bridges
                if ~iBridge.isDiscretized
                    iBridge.discretize();
                    if ~iBridge.isDiscretized
                        fprintf(['XXX Exited Discretization at Bridge Connection: ' ...
                            iBridge.name '. XXX\n']);
                        if nargin > 1 && isfield(run,'NodeFactor') && run.NodeFactor ~= 1 %FIXED
                            this.Mesher.oscillation_depth_N = backup_ODN;
                            this.Mesher.maximum_thickness = backup_MXT;
                            this.Mesher.HeatExchangerFinDivisions = backup_HEFD;
                            this.Mesher.maximum_growth = backup_growth;
                            this.Mesher.Gas_Entrance_Exit_N = backup_gas_entrance;
                            this.Mesher.Gas_Maximum_Size = backup_gas_maximum_size;
                            this.Mesher.Gas_Minimum_Size = backup_gas_minimum_size;
                            clear backup_ODN;
                            clear backup_MXT;
                            clear backup_HEFD;
                            clear backup_growth;
                        end
                        return;
                    end
                end
            end

            progressbar('Discretizing Groups');
            % Test and Discretize Groups
            for iGroup = this.Groups
                if ~iGroup.isDiscretized
                    % Matthias: Fixed below so that 'run' does not need to contain NodeFactor
                    %                     if nargin > 1
                    if nargin > 1
                        if isfield(run,'NodeFactor') && run.NodeFactor ~= 1
                            iGroup.discretize(run.NodeFactor);
                        else
                            iGroup.discretize;
                        end
                    end
                    if ~iGroup.isDiscretized
                        fprintf(['XXX Exited Discretization at Group: ' iGroup.name '. XXX\n']);
                        if nargin > 1 && isfield(run,'NodeFactor') && run.NodeFactor ~= 1 %FIXED
                            this.Mesher.oscillation_depth_N = backup_ODN;
                            this.Mesher.maximum_thickness = backup_MXT;
                            this.Mesher.HeatExchangerFinDivisions = backup_HEFD;
                            this.Mesher.Gas_Entrance_Exit_N = backup_gas_entrance;
                            this.Mesher.Gas_Maximum_Size = backup_gas_maximum_size;
                            this.Mesher.Gas_Minimum_Size = backup_gas_minimum_size;
                            clear backup_ODN;
                            clear backup_MXT;
                            clear backup_HEFD;
                            clear backup_growth;
                        end
                        return;
                    end
                end
            end

            progressbar('Discretizing Leaks');
            LeakFaces = struct('Node1',Node(),'Node2',Node(),'LeakFunc',@CollapseVector);
            LeakFaces(:) = [];
            % Test and Discretize LeakConnections
            for iLeak = this.LeakConnections
                TempLeakFaces = iLeak.getleakface();
                LeakFaces(end+1:end+length(TempLeakFaces)) = TempLeakFaces;
            end
            if nargin > 1 && isfield(run,'NodeFactor') && run.NodeFactor ~= 1 %FIXED
                this.Mesher.oscillation_depth_N = backup_ODN;
                this.Mesher.maximum_thickness = backup_MXT;
                this.Mesher.HeatExchangerFinDivisions = backup_HEFD;
                this.Mesher.Gas_Entrance_Exit_N = backup_gas_entrance;
                this.Mesher.Gas_Maximum_Size = backup_gas_maximum_size;
                this.Mesher.Gas_Minimum_Size = backup_gas_minimum_size;
                clear backup_ODN;
                clear backup_MXT;
                clear backup_HEFD;
                clear backup_growth;
            end

            progressbar('Counting Elements');
            % Count the Nodes and Faces
            ndequ = 1; % <-- Environment Node
            fcequ = 0;
            %             for iLeak = this.LeakConnections
            %                 fcequ = fcequ + length(iLeak.Faces);
            %             end
            for iBridge = this.Bridges
                fcequ = fcequ + length(iBridge.Faces);
            end
            for iGroup = this.Groups
                fcequ = fcequ + length(iGroup.Faces);
                ndequ = ndequ + length(iGroup.Nodes);
            end

            % Start Simulation Definition
            this.CurrentSim = Simulation();
            Sim = this.CurrentSim;
            Sim.Model = this;

            %% Acquiring Nodes and Faces
            progressbar('Acquiring Nodes and Faces');

            % Collect Nodes and Faces
            % Environment
            this.Nodes(ndequ) = this.surroundings.Node;
            ndequ = ndequ - 1;
            % LeakConnections
            %             for iLeak = this.LeakConnections
            %                 len = length(iLeak.Faces);
            %                 this.Faces(fcequ - len + 1:fcequ) = iLeak.Faces;
            %                 fcequ = fcequ - len;
            %             end
            % Bridges
            for iBridge = this.Bridges
                len = length(iBridge.Faces);
                this.Faces(fcequ - len + 1:fcequ) = iBridge.Faces;
                fcequ = fcequ - len;
            end
            % Groups
            for iGroup = this.Groups
                this.Faces(fcequ - length(iGroup.Faces) + 1:fcequ) = iGroup.Faces;
                fcequ = fcequ - length(iGroup.Faces);
                this.Nodes(ndequ - length(iGroup.Nodes) + 1:ndequ) = iGroup.Nodes;
                ndequ = ndequ - length(iGroup.Nodes);
            end

            % Exclude invalid nodes
            keep = true(size(this.Nodes));
            for i = 1:length(this.Nodes)
                if ~isvalid(this.Nodes(i))
                    keep(i) = false;
                end
            end
            this.Nodes = this.Nodes(keep);

            % Exclude Faces with invalid nodes
            keep = true(size(this.Faces));
            for i = 1:length(this.Faces)
                Fc = this.Faces(i);
                if ~isvalid(Fc) || ...
                        ~isvalid(Fc.Nodes(1)) || ...
                        ~isvalid(Fc.Nodes(2))
                    keep(i) = false;
                end
            end
            this.Faces = this.Faces(keep);

            % Assign Faces/Node Connections to Nodes
            for Nd = this.Nodes
                Nd.Faces = Face.empty;
                Nd.Nodes = Node.empty;
            end
            for Fc = this.Faces
                % Add to each Node
                Fc.Nodes(1).addFace(Fc);
                Fc.Nodes(2).addFace(Fc);
            end

            % Remove faces that are not allowed
            keep2 = true(size(this.NonConnections));
            i = 1;
            for nonCon = this.NonConnections
                iBody = nonCon.Body1;
                if ~isvalid(iBody)
                    keep2(i) = false;
                else
                    if isa(nonCon.Body2,'Environment')
                        for nd = iBody.Nodes
                            keep = true(size(nd.Faces));
                            i = 1;
                            for fc = nd.Faces
                                if (fc.Nodes(1).Body == iBody && ...
                                        (isa(fc.Nodes(2).Body,'Environment') && ...
                                        fc.Nodes(2).Body == nonCon.Body2)) || ...
                                        ((isa(fc.Nodes(1).Body,'Environment') && ...
                                        fc.Nodes(1).Body == nonCon.Body2) && ...
                                        fc.Nodes(2).Body == iBody)
                                    keep(i) = false;
                                end
                                i = i + 1;
                            end

                            if any(~keep)
                                for i = 1:length(keep)
                                    if ~keep(i)
                                        this.Faces(this.Faces==nd.Faces(i)) = [];
                                    end
                                end
                                nd.Faces = nd.Faces(keep);
                            end
                        end
                    else
                        for nd = iBody.Nodes
                            keep = true(size(nd.Faces));
                            i = 1;
                            for fc = nd.Faces
                                if (fc.Nodes(1).Body == iBody && ...
                                        fc.Nodes(2).Body == nonCon.Body2) || ...
                                        (fc.Nodes(1).Body == nonCon.Body2 && ...
                                        fc.Nodes(2).Body == iBody)
                                    keep(i) = false;
                                end
                                i = i + 1;
                            end

                            if any(~keep)
                                for i = 1:length(keep)
                                    if ~keep(i)
                                        this.Faces(this.Faces==nd.Faces(i)) = [];
                                    end
                                end
                                nd.Faces = nd.Faces(keep);
                            end
                        end
                    end
                end
                i = i + 1;
            end
            if any(~keep2)
                this.NonConnections = this.NonConnections(keep2);
            end

            %% Cleaning up solid connections that are too small
            progressbar('Cleaning up solid connections that are too small');

            % Clean up small nodes near bigger nodes
            keep = true(size(this.Faces));
            nds2del = Node.empty;
            count = 0;
            if nargin > 1 && isfield(run,'NodeFactor') && run.NodeFactor ~= 1 %FIXED
                for i = 1:length(this.Faces)
                    fc = this.Faces(i);
                    [should_remove, nd2del, ~] = fc.Nodes(1).combineSolid(fc.Nodes(2),run.NodeFactor);
                    if should_remove
                        count = count + 1;
                        keep(i) = false;
                        nds2del(end+1) = nd2del;
                    end
                end
            else
                for i = 1:length(this.Faces)
                    fc = this.Faces(i);
                    [should_remove, nd2del, ~] = fc.Nodes(1).combineSolid(fc.Nodes(2),1);
                    if should_remove
                        count = count + 1;
                        keep(i) = false;
                        nds2del(end+1) = nd2del;
                    end
                end
            end
            fprintf([num2str(count) ' Node pairs collapsed\n']);
            this.Faces = this.Faces(keep);

            % Remove these nodes from were they came
            for nd = nds2del
                if ~isempty(nd.Body) && isa(nd.Body,'Body')
                    keep2 = true(size(nd.Body.Nodes));
                    for i = 1:length(nd.Body.Nodes)
                        if nd.Body.Nodes(i) == nd
                            keep2(i) = false;
                        end
                    end
                    nd.Body.Nodes = nd.Body.Nodes(keep2);
                end
            end

            % Remove the nodes from the bulk list
            keep = true(size(this.Nodes));
            for nd = nds2del
                keep(this.Nodes==nd) = false;
            end
            this.Nodes = this.Nodes(keep);
            clear nds2del;

            %% Assigning Node and Face Indexes
            progressbar('Assigning Node and Face Indexes');

            % Assign Face/Node indexs to Faces and Nodes
            % Determine the amount of Solid, Wall, Environment and Gas Nodes
            S_count = 0;
            E_count = 0;
            for Nd = this.Nodes
                if Nd.Type == enumNType.SN
                    S_count = S_count + 1;
                elseif Nd.Type == enumNType.EN
                    E_count = E_count + 1;
                end
            end
            % Arrange, GN, EN, SN
            G_count = length(this.Nodes) - E_count - S_count;
            fprintf(['Found: ' num2str(G_count) ' Gas Nodes, ' ...
                num2str(E_count) ' Environment Nodes, ' ...
                num2str(S_count) ' Solid Nodes\n']);

            % Matthias: Record Node counts to include in TestSetStatictics
            % output
            MeshCounts.SN = S_count;
            MeshCounts.EN = E_count;
            MeshCounts.GN = G_count;

            E_count = G_count + E_count;
            S_count = length(this.Nodes);

            S_count_backup = S_count;
            E_count_backup = E_count;
            G_count_backup = G_count;

            for Nd = this.Nodes
                if Nd.Type == enumNType.SN
                    Nd.index = S_count;
                    S_count = S_count - 1;
                elseif Nd.Type == enumNType.EN
                    Nd.index = E_count;
                    E_count = E_count - 1;
                else
                    Nd.index = G_count;
                    G_count = G_count - 1;
                end
            end

            % Exclude faces with nodes with no index
            keep = true(size(this.Faces));
            for i = 1:length(this.Faces)
                Fc = this.Faces(i);
                if isempty(Fc.Nodes(1).index) || isempty(Fc.Nodes(2).index) || ...
                        Fc.Nodes(1).index < 1 || Fc.Nodes(2).index < 1
                    keep(i) = false;
                end
            end
            this.Faces = this.Faces(keep);


            %% Assessing Connections
            progressbar('Assessing Connections');

            % Orient them such that the node closer to 0,0 is
            % ... listed first
            for Fc = this.Faces
                if Fc.Type == enumFType.Gas || Fc.Type == enumFType.MatrixTransition
                    if isempty(Fc.Connection)
                        O = Fc.Orient;
                    else
                        O = Fc.Connection.Orient;
                    end
                    switch O
                        case enumOrient.Vertical
                            if Fc.Nodes(1).xmin(1) > Fc.Nodes(2).xmin(1)
                                % Swap Nodes
                                TempNode = Fc.Nodes(1);
                                Fc.Nodes(1) = Fc.Nodes(2);
                                Fc.Nodes(2) = TempNode;
                            end
                        case enumOrient.Horizontal
                            if Fc.Nodes(1).ymin(1) > Fc.Nodes(2).ymin(1)
                                % Swap Nodes
                                TempNode = Fc.Nodes(1);
                                Fc.Nodes(1) = Fc.Nodes(2);
                                Fc.Nodes(2) = TempNode;
                            end
                    end
                end
            end

            % For Gas-Gas Faces that have a connection (from node contacts), determine K
            % Determine if applicable
            isSubject = false(length(this.Faces),1);
            for fcequ = 1:length(this.Faces)
                % Gather all Gas-Gas faces that are on possible discontinuities
                isSubject(fcequ) = ...
                    ((this.Faces(fcequ).Type == enumFType.Gas || ...
                    this.Faces(fcequ).Type == enumFType.MatrixTransition) && ...
                    ~isempty(this.Faces(fcequ).Connection)) && ...
                    ~isfield(this.Faces(fcequ).data,'K12');
            end

            % Group based on common connection & body
            subSet = this.Faces(isSubject);
            isExcluded = false(length(subSet),1);
            n = 1;
            for i = 1:length(subSet)
                if ~isExcluded(i)
                    isSubject = false(length(subSet),1);
                    isSubject(i) = true;
                    for j = 1:length(subSet)
                        if ~isExcluded(j) && ...
                                subSet(i).Connection == subSet(j).Connection
                            % The two Faces are very likely somehow adjacent
                            isSubject(j) = true;
                        end
                    end
                    % should have acquired a subSet with a common connection
                    % Mark off Exclusion
                    isExcluded(isSubject) = true;
                    subsubSet = subSet(isSubject);

                    % So we have grabbed a subset of the select nodes that share a
                    % ... connection with element i
                    index = zeros(length(subsubSet),1);

                    % Determine if they are part of some adjacent chain by going
                    % ... through each combination and passing a index between
                    % ... connected elements.
                    for k = 1:length(subsubSet)
                        for x = k+1:length(subsubSet)
                            % Test if they link to the same nodes or the linked nodes are
                            % touching, for both sides of the face.
                            if ((subsubSet(k).Nodes(1) == subsubSet(x).Nodes(1) || ...
                                    subsubSet(k).Nodes(1).isTouching(subsubSet(x).Nodes(1))) && ...
                                    (subsubSet(k).Nodes(2) == subsubSet(x).Nodes(2) || ...
                                    subsubSet(k).Nodes(2).isTouching(subsubSet(x).Nodes(2))))
                                if index(k) == 0
                                    if index(x) == 0
                                        index(k) = n;
                                        index(x) = n;
                                    else
                                        index(k) = index(x);
                                    end
                                else
                                    if index(x) == 0
                                        index(x) = index(k);
                                    else
                                        index(index==index(x)) = index(k);
                                    end
                                end
                            else
                                if index(k) == 0
                                    index(k) = n;
                                    n = n + 1;
                                end
                            end
                        end
                    end

                    % Pick out groups that have the same index (i.e. part of the same
                    % ... chain)
                    issubExcluded = false(length(subsubSet),1);
                    for k = 1:length(subsubSet)
                        if ~issubExcluded(k)
                            issubExcluded(index==index(k)) = true;
                            neighbourhood = subsubSet(index==index(k));
                            isDynamic = false;
                            for Fc = neighbourhood
                                if Fc.isDynamic
                                    isDynamic = true;
                                    break;
                                end
                            end
                            if isDynamic
                                % For each moment in time, get the total area as a vector
                                Area1 = zeros(1,Frame.NTheta);
                                Area2 = zeros(1,Frame.NTheta);
                                for x = 1:length(neighbourhood)
                                    for ind = 0:Frame.NTheta-1
                                        Area1(ind+1) = Area1(ind+1) + ...
                                            neighbourhood(x).Nodes(1).getArea(ind,neighbourhood(x).Connection);
                                        Area2(ind+1) = Area2(ind+1) + ...
                                            neighbourhood(x).Nodes(2).getArea(ind,neighbourhood(x).Connection);
                                    end
                                end
                                Area1 = CollapseVector(Area1);
                                Area2 = CollapseVector(Area2);
                                ratio = Area1./Area2;
                                if ~all(ratio == 1)
                                    ratio(ratio>1)=1./ratio(ratio>1);
                                    firstformula = ratio>0.76;
                                    K12 = zeros(size(firstformula));
                                    K12(firstformula) = (1-ratio(firstformula).^2).^2;
                                    K12(~firstformula) = 0.42*(1-ratio(~firstformula).^2);
                                    K12 = CollapseVector(K12);
                                    K21 = K12;
                                    Entrance = Area1 > Area2;
                                    if length(Entrance) > 1
                                        for b = 1:length(Entrance)
                                            x12 = min(b,length(K12));
                                            x21 = min(b,length(K21));
                                            if Entrance(b)
                                                if K12(x12) > 0.5; K12(x12) = 0.5; end
                                            else
                                                if K21(x21) > 0.5; K21(x21) = 0.5; end
                                            end
                                        end
                                    elseif Entrance
                                        K12(K12>0.5) = 0.5;
                                    elseif ~Entrance
                                        K21(K21>0.5) = 0.5;
                                    end
                                else
                                    K12 = 0;
                                    K21 = 0;
                                end
                            else
                                % Get the area as a static scalar
                                Area1 = 0; Area2 = 0;
                                for x = 1:length(neighbourhood)
                                    Area1 = Area1 + neighbourhood(x).Nodes(1).getArea(0,neighbourhood(x).Connection);
                                    Area2 = Area2 + neighbourhood(x).Nodes(2).getArea(0,neighbourhood(x).Connection);
                                end
                                ratio = Area1/Area2;
                                if ratio ~= 1
                                    if ratio > 1; ratio = 1/ratio; end
                                    if ratio > 0.76; K12 = (1-ratio.^2).^2;
                                    else; K12 =  0.42*(1-ratio.^2);
                                    end
                                    K21 = K12;
                                    if Area1 > Area2
                                        if K12 > 0.5
                                            K12 = 0.5;
                                        end
                                    else
                                        if K21 > 0.5
                                            K21 = 0.5;
                                        end
                                    end
                                else
                                    K12 = 0;
                                    K21 = 0;
                                end
                            end
                            if all(K12 == 0)
                                % It is straight, this is simply a pipe
                                for Fc = neighbourhood
                                    if Fc.Orient == enumOrient.Vertical
                                        if Fc.Nodes(1).xmin == 0
                                            % Cylindrical
                                            C = 64;
                                        else
                                            % Annuluar
                                            C = 96;
                                        end
                                    else % Horizontal
                                        C = 96;
                                    end
                                    Fc.data.fFunc_l = @(Re) C./Re;
                                    Fc.data.fFunc_t = @(Re) 0.11*(this.roughness/Fc.data.Dh+68./Re).^0.25;

                                    % Streamwise conduction enhancement
                                    Fc.data.NkFunc_l = @(Re) 1;
                                    Fc.data.NkFunc_t = @(Re,Pr) 0.022*(Re.^0.75).*(Pr);
                                end
                            else
                                for Fc = neighbourhood
                                    Fc.data.K12 = K12;
                                    Fc.data.K21 = K21;
                                end
                            end
                        end
                    end
                end
            end

            % Overwrite K of Custom Minor Losses
            for CustomK = this.CustomMinorLosses
                if this.CustomMinorLosses.isValid()
                    for Fc = this.Faces
                        if isa(Fc.Nodes(1).Body,'Body') && ...
                                isa(Fc.Nodes(2).Body,'Body')
                            if (Fc.Nodes(1).Body == CustomK.Body1 && ...
                                    Fc.Nodes(2).Body == CustomK.Body2)
                                Fc.data.K12 = CustomK.K12;
                                Fc.data.K21 = CustomK.K21;
                            elseif (Fc.Nodes(2).Body == CustomK.Body1 && ...
                                    Fc.Nodes(1).Body == CustomK.Body2)
                                Fc.data.K12 = CustomK.K21;
                                Fc.data.K21 = CustomK.K12;
                            end
                        end
                    end
                end
            end

            %% Decimating Loops
            progressbar('Decimating Extra Loops');
            % debug_loopPlot(this,false);
            % Decimate extra loops
            Triads = cell(0,0);
            for Nd = this.Nodes
                if Nd.Type ~= enumNType.SN && Nd.Type ~= enumNType.EN
                    visited = GetTriad(Nd);
                    for set = visited
                        fcs = set{1};
                        % Prevent duplicate loops from showing up
                        found = false;
                        for i = 1:length(Triads)
                            if any(Triads{i}(1) == fcs) && any(Triads{i}(2) == fcs) && ...
                                    any(Triads{i}(3) == fcs)
                                found = true; break;
                            end
                        end
                        if ~found; Triads{end+1} = fcs; end
                    end
                end
            end

            % Look at Triads
            Scores = cell(size(Triads));
            Tri_Nodes = Scores;
            for i = 1:length(Scores)
                Scores{i} = zeros(1,3);
                Tri_Nodes{i} = Node.empty;
            end
            % Score All the Triads
            for k = 1:length(Triads)
                Tri = Triads{k};
                Tri_Node_i = 3;
                backup = [0 0];
                % Get nodes for the Tri
                for fc = Tri
                    for nd = fc.Nodes
                        if isempty(Tri_Nodes{k}) || ...
                                all(Tri_Nodes{k} ~= nd)
                            Tri_Nodes{k}(Tri_Node_i) = nd; Tri_Node_i = Tri_Node_i - 1;
                        end
                    end
                end
                % Assign a score based on the area that enters than node
                for fc = Tri
                    score = mean(fc.data.Area);
                    for nd = fc.Nodes
                        index = find(Tri_Nodes{k}==nd);
                        Scores{k}(index) = Scores{k}(index) + score;
                    end
                end
                % Normalize the Scores According to the other Options
                backup(1) = Scores{k}(1); backup(2) = Scores{k}(2);
                Scores{k}(1) = backup(1) / (backup(2) + Scores{k}(3));
                Scores{k}(2) = backup(2) / (backup(1) + Scores{k}(3));
                Scores{k}(3) = Scores{k}(3) / (backup(1) + backup(2));
                Scores{k}(isnan(Scores{k})) = 0;
                % Ensure that faces that can't be closed will not be looked at
                % ... As the number of faces that can't will only increase
                Backup_Tri = Tri;
                for i = 1:3
                    for j = 1:length(Backup_Tri)
                        fc = Backup_Tri(j);
                        if ~any(fc.Nodes == Tri_Nodes{k}(i))
                            Tri(i) = fc;
                            if ~canClose(fc)
                                Scores{k}(i) = 0;
                            end
                            break;
                        end
                    end
                end
                % Rearrange the Tri so that the faces correspond to the correct
                % ... score

            end

            while ~isempty(Triads)
                Best_Tri = 0;
                Open_Triads = true(length(Triads),1);
                Best_Score = 0;
                Best_Index = 0;

                % Find Best Possible Face to close
                finding_best = true;
                while finding_best
                    for k = 1:length(Triads)
                        % Get the best
                        finding_best = true;
                        for i = 1:3
                            if Scores{k}(i) > Best_Score
                                Best_Score = Scores{k}(i);
                                Best_Index = i;
                                Best_Tri = k;
                            end
                        end
                    end
                    if Best_Score == 0; break; end
                    closing_face = Triads{Best_Tri}(Best_Index);
                    if canClose(closing_face)
                        finding_best = false;
                    else
                        Scores{Best_Tri}(Best_Index) = 0;
                        Best_Score = 0;
                    end
                end

                % Collapse the face, closing the triad
                if Best_Score > 0

                    % Adjust the area and minor loss coefficients of the other two faces
                    for fc = Triads{Best_Tri}
                        if fc ~= closing_face
                            if isfield(fc.data,'K12')
                                if isfield(closing_face.data,'K12')
                                    fc.data.K12 = (fc.data.K12.*fc.data.Area + ...
                                        closing_face.data.K12.*closing_face.data.Area)./ ...
                                        (fc.data.Area + closing_face.data.Area);
                                    fc.data.K21 = (fc.data.K21.*fc.data.Area + ...
                                        closing_face.data.K21.*closing_face.data.Area)./ ...
                                        (fc.data.Area + closing_face.data.Area);
                                end
                            end
                            fc.data.Area = fc.data.Area + closing_face.data.Area;
                        end
                    end

                    % Delete the face from the list
                    closing_face.data.Area = 0;
                    for nd = closing_face.Nodes
                        nd.Faces(nd.Faces == closing_face) = [];
                    end
                    this.Faces(this.Faces == closing_face) = [];

                    for k = 1:length(Triads)
                        if any(Triads{k} == closing_face)
                            Open_Triads(k) = false;
                        end
                    end
                    Open_Triads(Best_Tri) = false;
                    Triads = Triads(Open_Triads);
                    Scores = Scores(Open_Triads);
                    fprintf(['Decimated a Triad with ' num2str(length(Open_Triads) - sum(Open_Triads) - 1) ' others.\n']);
                else
                    Triads = cell(0);
                end
            end
            %{
            for Tri = Triads
                Tri_Nodes = Node.empty;
                Scores = {0,0,0};
                for fc = Tri{1}
                for nd = fc.Nodes
                    if isempty(Tri_Nodes) || all(Tri_Nodes ~= nd)
                    Tri_Nodes = [Tri_Nodes nd];
                    index = length(Tri_Nodes);
                    else
                    index = find(Tri_Nodes==nd);
                    end
                    Scores{index} = Scores{index} + fc.data.Area;
                end
                end
            %}

            % Starting at the node with maximum area, test if the opposite face
            % can be closed
            %{
                bestrecord = 0;
                bestindex = 0;
                for i = 1:3
                if mean(Scores{i}) > bestrecord
                    for fc = Tri{1}
                    if ~any(fc.Nodes == Tri_Nodes(i))
                        if canClose(fc)
                        bestindex = i;
                        bestrecord = mean(Scores{i});
                        end
                        break;
                    end
                    end
                end
                end
                
                % Collapse the triad
                if bestindex > 0 && bestrecord > 0
                fprintf('Decimated a Triad\n');
                % Find closing face
                for fc = Tri{1}
                    if ~any(fc.Nodes == Tri_Nodes(i))
                    closing_face = fc;
                    break;
                    end
                end
                
                % Adjust the area and minor loss coefficients of the other two faces
                for fc = Tri{1}
                    if fc ~= closing_face
                    if isfield(fc.data,'K12')
                        if isfield(closing_face.data,'K12')
                        fc.data.K12 = (fc.data.K12.*fc.data.Area + ...
                            closing_face.data.K12.*closing_face.data.Area)./ ...
                            (fc.data.Area + closing_face.data.Area);
                        fc.data.K21 = (fc.data.K21.*fc.data.Area + ...
                            closing_face.data.K21.*closing_face.data.Area)./ ...
                            (fc.data.Area + closing_face.data.Area);
                        end
                    end
                    fc.data.Area = fc.data.Area + closing_face.data.Area;
                    end
                end
                
                % Delete the face from the list
                closing_face.data.Area = 0;
                for nd = closing_face.Nodes
                    nd.Faces(nd.Faces == closing_face) = [];
                end
                this.Faces(this.Faces == closing_face) = [];
                end
            %}

            % Faces
            % Determine the amount of Solid, Environment, Mix and Gas Faces
            S_count = 0;
            E_count = 0;
            M_count = 0;
            for Fc = this.Faces
                switch Fc.Type
                    case enumFType.Solid
                        S_count = S_count + 1;
                    case enumFType.Mix
                        M_count = M_count + 1;
                    case enumFType.Environment
                        E_count = E_count + 1;
                end
            end
            G_count = length(this.Faces) - S_count - E_count - M_count;
            fprintf(['Found: ' num2str(G_count) ' Gas Faces, ' ...
                num2str(E_count) ' Environment Faces, ' ...
                num2str(M_count) ' Mixed Faces, ' ...
                num2str(S_count) ' Solid Faces\n']);

            % Matthias: Record Face counts to include in TestSetStatictics
            % output
            MeshCounts.SF = S_count;
            MeshCounts.EF = E_count;
            MeshCounts.GF = G_count;
            MeshCounts.MF = M_count;

            M_count = G_count + M_count;
            E_count = M_count + E_count;
            S_count = length(this.Faces);
            G_count_backup_faces = G_count;
            E_count_backup_faces = E_count;
            M_count_backup_faces = M_count;
            for Fc = this.Faces
                switch Fc.Type
                    case enumFType.Solid
                        Fc.index = S_count;
                        S_count = S_count - 1;
                    case enumFType.Mix
                        Fc.index = M_count;
                        M_count = M_count - 1;
                    case enumFType.Environment
                        Fc.index = E_count;
                        E_count = E_count - 1;
                        %                     case enumFType.Leak

                    otherwise % Gas
                        Fc.index = G_count;
                        G_count = G_count - 1;
                end
            end

            % Remove Nodal Faces that have been deleted
            for iNd = this.Nodes
                keep = true(size(iNd.Faces));
                j = 1;
                for Fc = iNd.Faces
                    if isempty(Fc.index) || Fc.index < 1
                        keep(j) = false;
                    end
                    j = j + 1;
                end
                iNd.Faces = iNd.Faces(keep);
            end

            % Deal with input options
            % 1. NodeFactor -> Already handled in initial discretization
            % 2. HX Convection ->
            if isfield(run,'HX_Convection') && run.HX_Convection ~= 1
                % Find all bodies which are gases, but contain source nodes
                for iGroup = this.Groups
                    for iBody = iGroup.Bodies
                        if iBody.matl.Phase == enumMaterial.Gas
                            if ~isempty(iBody.Matrix) && ...
                                    isfield(iBody.Matrix.data,'SourceTemperature')
                                for nd = iBody.Nodes
                                    if nd.Type ~= enumNType.SN
                                        if isfield(nd.data,'NuFunc_l')
                                            func = nd.data.NuFunc_l;
                                            if nargin(func) == 2
                                                nd.data.NuFunc_l = @(Re,Pr) run.HX_Convection.*func(Re,Pr);
                                            else
                                                nd.data.NuFunc_l = @(Re) run.HX_Convection.*func(Re);
                                            end
                                        end
                                        if isfield(nd.data,'NuFunc_t')
                                            func = nd.data.NuFunc_t;
                                            if nargin(func) == 2
                                                nd.data.NuFunc_t = @(Re,Pr) run.HX_Convection.*func(Re,Pr);
                                            else
                                                nd.data.NuFunc_t = @(Re) run.HX_Convection.*func(Re);
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            % 3. Regen_Convection ->
            if isfield(run,'Regen_Convection') && run.Regen_Convection ~= 1
                % Find all bodies which are gases but contain solids nodes without
                % ... source nodes
                for iGroup = this.Groups
                    for iBody = iGroup.Bodies
                        if iBody.matl.Phase == enumMaterial.Gas
                            if ~isempty(iBody.Matrix) && ...
                                    ~isfield(iBody.Matrix.data,'SourceTemperature')
                                for nd = iBody.Nodes
                                    if nd.Type ~= enumNType.SN
                                        if isfield(nd.data,'NuFunc_l')
                                            func = nd.data.NuFunc_l;
                                            if nargin(func) == 2
                                                nd.data.NuFunc_l = @(Re,Pr) run.Regen_Convection.*func(Re,Pr);
                                            else
                                                nd.data.NuFunc_l = @(Re) run.Regen_Convection.*func(Re);
                                            end
                                        end
                                        if isfield(nd.data,'NuFunc_t')
                                            func = nd.data.NuFunc_t;
                                            if nargin(func) == 2
                                                nd.data.NuFunc_t = @(Re,Pr) run.Regen_Convection.*func(Re,Pr);
                                            else
                                                nd.data.NuFunc_t = @(Re) run.Regen_Convection.*func(Re);
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            % 4. Outside Matrix Convection ->
            if isfield(run,'Outside_Matrix_Convection') && run.Outside_Matrix_Convection ~= 1
                % Find all bodies which contain only gas nodes
                for iGroup = this.Groups
                    for iBody = iGroup.Bodies
                        if iBody.matl.Phase == enumMaterial.Gas
                            if isempty(iBody.Matrix)
                                for nd = iBody.Nodes
                                    if nd.Type ~= enumNType.SN
                                        if isfield(nd.data,'NuoFunc_l')
                                            func = nd.data.NuoFunc_l;
                                            if nargin(func) == 2
                                                nd.data.NuoFunc_l = @(Re,Pr) run.HX_Convection.*func(Re,Pr);
                                            else
                                                nd.data.NuoFunc_l = @(Re) run.HX_Convection.*func(Re);
                                            end
                                        end
                                        if isfield(nd.data,'NuFunc_l')
                                            func = nd.data.NuFunc_l;
                                            if nargin(nd.data.NuFunc_l) == 2
                                                nd.data.NuFunc_l = @(Re,Pr) run.HX_Convection.*func(Re,Pr);
                                            else
                                                nd.data.NuFunc_l = @(Re) run.HX_Convection.*func(Re);
                                            end
                                        end
                                        if isfield(nd.data,'NuFunc_t')
                                            func = nd.data.NuFunc_t;
                                            if nargin(func) == 2
                                                nd.data.NuFunc_t = @(Re,Pr) run.HX_Convection.*func(Re,Pr);
                                            else
                                                nd.data.NuFunc_t = @(Re) run.HX_Convection.*func(Re);
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            % 5. Friction ->
            if isfield(run,'Friction') && run.Friction ~= 1
                % Find all gas faces
                for Fc = this.Faces
                    if Fc.Type == enumFType.Gas || Fc.Type == enumFType.MatrixTransition
                        if isfield(Fc.data,'fFunc_l')
                            func = Fc.data.fFunc_l;
                            Fc.data.fFunc_l = @(Re) run.Friction*func(Re);
                        end
                        if isfield(Fc.data,'fFunc_t')
                            func = Fc.data.fFunc_t;
                            Fc.data.fFunc_t = @(Re) run.Friction*func(Re);
                        end
                    end
                end
            end
            % 6. Solid_Conduction ->
            if isfield(run,'Solid_Conduction') && run.Solid_Conduction ~= 1
                % Find all solid and mixed faces
                for Fc = this.Faces
                    if Fc.Type == enumFType.Solid
                        if isfield(Fc.data,'U')
                            Fc.data.U = Fc.data.U.*run.Solid_Conduction;
                        end
                    elseif Fc.Type == enumFType.Mix
                        if isfield(Fc.data,'R')
                            if run.Solid_Conduction == 0
                                Fc.data.R = 1e8;
                            else
                                Fc.data.R = Fc.data.R./run.Solid_Conduction;
                            end
                        end
                    end
                end
            end
            % 7. Axial_Mixing_Coefficient ->
            if isfield(run,'Axial_Mixing_Coefficient') && run.Axial_Mixing_Coefficient ~= 1
                % Find all gas faces
                for Fc = this.Faces
                    if Fc.Type == enumFType.Gas || Fc.Type == enumFType.MatrixTransition
                        if isfield(Fc.data,'NkFunc_l')
                            func = Fc.data.NkFunc_l;
                            if nargin(Fc.data.NkFunc_l) == 2
                                Fc.data.NkFunc_l = @(Re,Pr) run.Axial_Mixing_Coefficient.*func(Re,Pr);
                            else
                                Fc.data.NkFunc_l = @(Re) run.Axial_Mixing_Coefficient.*func(Re);
                            end
                        end
                        if isfield(Fc.data,'NkFunc_t')
                            func = Fc.data.NkFunc_t;
                            if nargin(Fc.data.NkFunc_t) == 2
                                Fc.data.NkFunc_t = @(Re,Pr) run.Axial_Mixing_Coefficient.*func(Re,Pr);
                            else
                                Fc.data.NkFunc_t = @(Re) run.Axial_Mixing_Coefficient.*func(Re);
                            end
                        end
                    end
                end
            end
            % 8. Custom HX Coefficients ->
            for iGroup = this.Groups
                for iBody = iGroup.Bodies
                    if ~isempty(iBody.Matrix) && ...
                            iBody.Matrix.Geometry == enumMatrix.HeatExchanger && ...
                            strcmp(iBody.Matrix.data.Classification,'Custom HX')
                        if isfield(run,'HX_C1')
                            iBody.Matrix.data.C1 = run.HX_C1;
                        end
                        if isfield(run,'HX_C2')
                            iBody.Matrix.data.C2 = run.HX_C2;
                        end
                        if isfield(run,'HX_C3')
                            iBody.Matrix.data.C3 = run.HX_C3;
                        end
                        if isfield(run,'HX_C4')
                            iBody.Matrix.data.C4 = run.HX_C4;
                        end
                        if isfield(run,'HX_SA_V')
                            iBody.Matrix.data.SA_V = run.HX_SA_V;
                        end
                    end
                    if ~isempty(iBody.Matrix) && ...
                            iBody.Matrix.Geometry == enumMatrix.CustomRegen
                        if isfield(run,'Regen_C1')
                            iBody.Matrix.data.C1 = run.Regen_C1;
                        end
                        if isfield(run,'Regen_C2')
                            iBody.Matrix.data.C2 = run.Regen_C2;
                        end
                        if isfield(run,'Regen_C3')
                            iBody.Matrix.data.C3 = run.Regen_C3;
                        end
                        if isfield(run,'Regen_C4')
                            iBody.Matrix.data.C4 = run.Regen_C4;
                        end
                        if isfield(run,'Regen_Porosity')
                            iBody.Matrix.data.Porosity = run.Regen_Porosity;
                        end
                        if isfield(run,'Regen_SA_V')
                            iBody.Matrix.data.SA_V = run.Regen_SA_V;
                        end
                    end
                end
            end


            %% Vectorizing Nodes
            progressbar('Vectorizing Nodes');
            % Generic Properties
            Sim.dT_dU = zeros(S_count_backup,1);
            Sim.u = Sim.dT_dU;
            Sim.T = Sim.dT_dU;
            Sim.CondFlux = Sim.dT_dU;

            % Environment Additional Properties
            Sim.P = zeros(E_count_backup,1);
            Sim.dP = Sim.P;
            Sim.dh_dT = Sim.P;
            Sim.rho = Sim.P;
            Sim.m = Sim.dT_dU;
            Sim.vol = Sim.T;
            Sim.dV_dt = Sim.P;

            % Gas Node Additional Properties
            Sim.k = Sim.P;
            Sim.mu = Sim.P;
            Sim.Dh = zeros(G_count_backup,1);
            Sim.Nu = Sim.Dh;
            Sim.NuFunc_l = cell(G_count_backup,1);
            Sim.NuFunc_t = Sim.NuFunc_l;
            Sim.isDynVol = Sim.P;
            Sim.DynVol = zeros(6,0);
            % Interpolated from Faces
            Sim.RE = Sim.Dh;
            Sim.U = Sim.Dh;
            Sim.f = Sim.Dh;
            % Turbulence
            Sim.useTurbulenceNd = false(length(Sim.P)-1,1);
            Sim.turb = Sim.P;
            Sim.dturb = Sim.P;
            Sim.Area = zeros(2,length(Sim.Dh));
            Sim.Va = Sim.Dh;
            Sim.to = Sim.Dh;

            % Gas Regions
            % Growth algorithm propegating through gas faces that are always open
            region = zeros(length(Sim.P),1);
            region_count = 0;
            for Nd = this.Nodes
                if Nd.index <= length(region) && region(Nd.index) == 0
                    region_count = region_count + 1;
                    region = PropegateRegion(Nd,region,region_count);
                    if all(region > 0); break; end
                end
            end

            % Define Functions
            DynVol_n = 1;
            DynDh_n = 1;
            Rs = Sim.P;
            for Nd = this.Nodes
                if isfield(Nd.data,'matl')
                    if Nd.data.matl.Phase ~= enumMaterial.Solid
                        matl = Material(Nd.data.matl.name);
                    else
                        matl = Nd.data.matl;
                    end
                else
                    if Nd.Body.matl.Phase ~= enumMaterial.Solid
                        matl = Material(Nd.Body.matl.name);
                    else
                        matl = Nd.Body.matl;
                    end
                end
                switch Nd.Type
                    case enumNType.SN
                        % Sim.dU(Nd.index) = 0; - Needs to be zeroed
                        Sim.m(Nd.index) = Nd.vol()*matl.Density;
                        if matl.dT_du <= 0
                            Sim.dT_dU(Nd.index) = 0;
                        else
                            Sim.dT_dU(Nd.index) = matl.dT_du;
                        end
                        Sim.T(Nd.index) = Nd.data.T;
                        Sim.u(Nd.index) = matl.initialInternalEnergy(Nd.data.T);
                        Sim.vol(Nd.index) = Nd.vol();

                        % Static Volume Gas Node %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    case {enumNType.SVGN, enumNType.VVGN, enumNType.SAGN}
                        V = Nd.vol();
                        Nd.recalc_Dh();
                        if isempty(Nd.Body.Matrix)
                            if ~isscalar(V)
                                Sim.useTurbulenceNd(Nd.index) = true;
                            else
                                Sim.useTurbulenceNd(Nd.index) = false;
                            end
                        else
                            Sim.useTurbulenceNd(Nd.index) = true;
                        end

                        if isscalar(V)
                            Sim.vol(Nd.index) = V;
                        else
                            Sim.vol(Nd.index) = V(1);
                            Sim.isDynVol(Nd.index) = DynVol_n;
                            Sim.DynVol(1,DynVol_n) = Nd.index;
                            Sim.DynVol(2,DynVol_n) = Sim.Dyn;
                            DynVol_n = DynVol_n + 1;
                            Sim.Dynamic(Sim.Dyn,:) = V;
                            Sim.Dyn = Sim.Dyn + 1;
                        end
                        if isscalar(Nd.data.Dh)
                            Sim.Dh(Nd.index) = Nd.data.Dh;
                        else
                            Sim.DynDh(1,DynDh_n) = Nd.index;
                            Sim.DynDh(2,DynDh_n) = Sim.Dyn;
                            DynDh_n = DynDh_n + 1;
                            Sim.Dynamic(Sim.Dyn,:) = Nd.data.Dh;
                            Sim.Dyn = Sim.Dyn + 1;
                        end
                        Sim.dT_dU(Nd.index) = 1;
                        Sim.dT_duFunc{region(Nd.index)} = matl.dT_duFunc;
                        try
                            Sim.dh_dTFunc{region(Nd.index)} = matl.dh_dTFunc; % Additions
                        catch
                            matl.Configure(matl.name);
                            Sim.dh_dTFunc{region(Nd.index)} = matl.dh_dTFunc; % Additions
                        end
                        Sim.u2T{region(Nd.index)} = matl.u2T;
                        Sim.T(Nd.index) = Nd.data.T;

                        Sim.P(Nd.index) = Nd.data.P;
                        Sim.rho(Nd.index) = Nd.data.P/(matl.R*Nd.data.T);
                        Sim.u(Nd.index) = matl.initialInternalEnergy(Nd.data.T);% + Nd.data.P/Sim.rho(Nd.index);
                        Sim.m(Nd.index) = Sim.rho(Nd.index)*Sim.vol(Nd.index);

                        Sim.kFunc{region(Nd.index)} = matl.kFunc;
                        Sim.muFunc{region(Nd.index)} = matl.muFunc;
                        Rs(Nd.index) = matl.R;

                        if isfield(Nd.data,'NuoFunc_l')
                            Sim.NuFunc_l{Nd.index} = Nd.data.NuoFunc_l;
                        else
                            Sim.NuFunc_l{Nd.index} = Nd.data.NuFunc_l;
                        end
                        Sim.NuFunc_t{Nd.index} = Nd.data.NuFunc_t;
                        % Environment Node (Static Properties Node) %%%%%%%%%%%%%%%%%%%
                    case enumNType.EN
                        Sim.dT_dU(Nd.index) = 0;
                        Sim.T(Nd.index) = Nd.Body.Temperature;
                        Sim.u2T{region(Nd.index)} = matl.u2T;
                        Sim.kFunc{region(Nd.index)} = matl.kFunc;
                        Sim.muFunc{region(Nd.index)} = matl.muFunc;
                        Sim.dT_duFunc{region(Nd.index)} = matl.dT_duFunc;
                        try
                            Sim.dh_dTFunc{region(Nd.index)} = matl.dh_dTFunc; % Additions
                        catch
                            matl.Configure(matl.name);
                            Sim.dh_dTFunc{region(Nd.index)} = matl.dh_dTFunc; % Additions
                        end
                        Rs(Nd.index) = matl.R;
                        Sim.k(Nd.index) = matl.kFunc(Nd.data.T);
                        Sim.mu(Nd.index) = matl.muFunc(Nd.data.T);
                        Sim.u(Nd.index) = matl.initialInternalEnergy(Nd.data.T);% + Nd.data.P/Nd.data.rho;
                        Sim.P(Nd.index) = Nd.data.P;
                        Sim.rho(Nd.index) = Nd.data.rho;
                        Sim.vol(Nd.index) = Inf;
                        Sim.m(Nd.index) = Inf;
                        Sim.turb(Nd.index) = 0;
                end
            end

            %% Vectorizing Faces
            progressbar('Vectorizing Faces');

            Sim.Fc_Nd = zeros(length(this.Faces),2);
            Sim.Fc_U = zeros(G_count_backup_faces,1);
            Sim.Fc_PR = Sim.Fc_U;
            Sim.Fc_dx = Sim.Fc_U;
            Sim.Fc_RE = Sim.Fc_U;
            Sim.Fc_f = Sim.Fc_U;
            Sim.Fc_R = zeros(1,M_count_backup_faces);
            Sim.Fc_fFunc_l = cell(G_count_backup_faces,1);
            Sim.Fc_fFunc_t = Sim.Fc_fFunc_l;
            Sim.Fc_NkFunc_l = Sim.Fc_fFunc_l;
            Sim.Fc_NkFunc_t = Sim.Fc_fFunc_l;
            Sim.Fc_Dist = Sim.Fc_U;
            Sim.Fc_Cond_Dist = Sim.Fc_U;
            Sim.Fc_K12 = Sim.Fc_U;
            Sim.Fc_K21 = Sim.Fc_U;
            Sim.Fc_u = Sim.Fc_U;
            %      Sim.dL_dt = Sim.Fc_U;
            %      Sim.dD_dt = Sim.Fc_U;
            Sim.KpU_2A = Sim.Fc_U;
            Sim.Fc_V = Sim.Fc_U;
            Sim.Fc_dP = Sim.Fc_U;
            Sim.Fc_V_backup = Sim.Fc_U;
            Sim.Fc_W = Sim.Fc_U;

            % For gas-gas, mix and environment faces
            Sim.Fc_Area = zeros(E_count_backup_faces,1);
            Sim.Fc_Dh = Sim.Fc_U;
            Sim.Fc_Cond = Sim.Fc_Area;
            Sim.Fc_T = Sim.Fc_U;
            Sim.Fc_k = Sim.Fc_U;
            Sim.Fc_mu = Sim.Fc_U;
            Sim.Fc_rho = Sim.Fc_U;
            Sim.Fc_Vel_Factor = Sim.Fc_U;
            Sim.Fc_Shear_Factor = Sim.Fc_U;

            % Turbulence
            Sim.Fc_turb = Sim.Fc_U;
            Sim.Fc_to = Sim.Fc_U;
            Sim.useTurbulenceFc = true(G_count_backup_faces,1);

            % Flux Limiters
            Sim.Fc_Nd03 = Sim.Fc_Nd;
            Sim.Fc_A = Sim.Fc_U;
            Sim.Fc_B = Sim.Fc_U;
            Sim.Fc_C = Sim.Fc_U;
            Sim.Fc_D = Sim.Fc_U;

            % Find V and S for the faces
            for Fc = this.Faces
                [V, S, SContact] = FaceMotion(Fc);
                if ~isempty(V); Fc.data.V = V; end
                if ~isempty(S)
                    Fc.data.S = S;
                    if ~isempty(SContact)
                        this.ShearContacts = [this.ShearContacts SContact];
                    end
                end
            end

            %% Creating Shear/Pressure Contacts
            progressbar('Creating Shear/Pressure Contacts');

            % For all Faces, attempt to make a PressureContact
            for Fc = this.Faces
                if Fc.Type == enumFType.Mix
                    PContact = Fc.getPressureContact();
                    if ~isempty(PContact)
                        this.PressureContacts = [this.PressureContacts PContact];
                    end
                elseif (Fc.Nodes(1).Type == enumNType.SN && ...
                        Fc.Nodes(2).Type == enumNType.EN) || ...
                        (Fc.Nodes(1).Type == enumNType.EN && ...
                        Fc.Nodes(2).Type == enumNType.SN)
                    PContact = Fc.getPressureContact();
                    if ~isempty(PContact)
                        this.PressureContacts = [this.PressureContacts PContact];
                    end
                end
            end

            % For all Faces, distribute the friction length to neighbours if
            % ... K enabled.
            for Fc = this.Faces
                if isfield(Fc.data,'Dist')
                    Fc.data.Cond_Dist = Fc.data.Dist;
                    if isfield(Fc.data,'dx') && isfield(Fc.data, 'K12')
                        if any(Fc.data.K12 > 0) || any(Fc.data.K21 > 0)
                            % Will only run this code if:
                            % ... It is a gas face
                            % ... It has a minor loss coefficient

                            % This face will not utilize the value of Dist
                            Fc.data.Dist = 0;

                            % Get the location of the center of this face
                            x = getCenterOfOverlapRegion(...
                                Fc.Nodes(1).xmin, Fc.Nodes(2).xmin,...
                                Fc.Nodes(1).xmax, Fc.Nodes(2).xmax);
                            y = getCenterOfOverlapRegion(...
                                Fc.Nodes(1).ymin, Fc.Nodes(2).ymin,...
                                Fc.Nodes(1).ymax, Fc.Nodes(2).ymax);

                            % Find all neighbours
                            for nd = Fc.Nodes
                                ndx = (nd.xmin + nd.xmax)/2;
                                ndy = (nd.ymin + nd.ymax)/2;
                                count = 0;
                                for fci = nd.Faces
                                    if fci ~= Fc
                                        if isfield(fci.data,'Dist') && (...
                                                (isfield(Fc.data, 'K12') && all(Fc.data.K12 == 0)) || ...
                                                ~isfield(Fc.data, 'K12'))
                                            count = count + 1;
                                        end
                                    end
                                end
                                if count < 2
                                    % Will only run if this node has only one other gas face
                                    for fci = nd.Faces
                                        if fci ~= Fc
                                            if isfield(fci.data,'Dist') && (...
                                                    (isfield(Fc.data, 'K12') && all(Fc.data.K12 == 0)) || ...
                                                    ~isfield(Fc.data, 'K12'))
                                                % Will only run if this face can use it
                                                % Determine orientation of fci
                                                if fci.Nodes(1).xmin == fci.Nodes(2).xmax
                                                    dDist = abs(ndx - x);
                                                    % If the connection is actually closer than
                                                    % ... assumed then the distance is negative
                                                    if abs(fci.Nodes(1).xmin - x) < ...
                                                            abs(fci.Nodes(1).xmin - ndx)
                                                        dDist = -dDist;
                                                    end
                                                elseif fci.Nodes(1).xmax == fci.Nodes(2).xmin
                                                    dDist = abs(ndx - x);
                                                    % If the connection is actually closer than
                                                    % ... assumed then the distance is negative
                                                    if abs(fci.Nodes(2).xmin - x) < ...
                                                            abs(fci.Nodes(2).xmin - ndx)
                                                        dDist = -dDist;
                                                    end
                                                elseif all(fci.Nodes(1).ymin == fci.Nodes(2).ymax)
                                                    dDist = abs(ndy - y);
                                                    % If the connection is actually closer than
                                                    % ... assumed then the distance is negative
                                                    if abs(fci.Nodes(1).ymin - y) < ...
                                                            abs(fci.Nodes(1).ymin - ndy)
                                                        dDist = -dDist;
                                                    end
                                                else
                                                    dDist = abs(ndy - y);
                                                    % If the connection is actually closer than
                                                    % ... assumed then the distance is negative
                                                    if abs(fci.Nodes(2).ymin - y) < ...
                                                            abs(fci.Nodes(2).ymin - ndy)
                                                        dDist = -dDist;
                                                    end
                                                end
                                                fci.data.Dist = CollapseVector(fci.data.Dist + dDist);
                                                if any(fci.data.Dist <= 0)
                                                    fprintf('XXX Negative Distance Detected. \n');
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            % Vectorize all Faces
            MF_n = 1;
            Fc_DynCond_n = 1;
            Fc_DynArea_n = 1;
            Fc_DynDist_n = 1;
            Fc_DynCond_Dist_n = 1;
            Fc_Dyndx_n = 1;
            Fc_DynDh_n = 1;
            Fc_DynK12_n = 1;
            Fc_DynK21_n = 1;
            Fc_DynVel_Factor_n = 1;
            Fc_DynShear_Factor_n = 1;
            Fc_DynA_n = 1; Fc_DynB_n = 1; Fc_DynC_n = 1; Fc_DynD_n = 1;
            IsApprox = false(length(this.Faces),1);
            ApproxCount = 1;
            for Fc = this.Faces
                N1 = Fc.Nodes(1);
                N2 = Fc.Nodes(2);
                Sim.Fc_Nd(Fc.index,1) = N1.index;
                Sim.Fc_Nd(Fc.index,2) = N2.index;

                % Solid Faces
                switch Fc.Type
                    case enumFType.Solid % Solid and Solid-Environment Faces
                        % Conductance
                        if isscalar(Fc.data.U)
                            Sim.Fc_Cond(Fc.index) = Fc.data.U;
                        else
                            Sim.Dynamic(Sim.Dyn,:) = Fc.data.U;
                            Sim.Fc_DynCond(1,Fc_DynCond_n) = Fc.index;
                            Sim.Fc_DynCond(2,Fc_DynCond_n) = Sim.Dyn;
                            Fc_DynCond_n = Fc_DynCond_n + 1;
                            Sim.Dyn = Sim.Dyn + 1;
                        end
                    case enumFType.Mix % Gas-Solid Faces
                        Sim.Mix_Fc(MF_n) = Fc.index; % A list of Fc_indexes
                        if N2.Type ~= enumNType.SN
                            % Switch direction, Gas First, Solid Second
                            Sim.Fc_Nd(Fc.index,1) = N2.index;
                            Sim.Fc_Nd(Fc.index,2) = N1.index;
                            temp = N1;
                            N1 = N2;
                            N2 = temp;
                        end
                        if isscalar(Fc.data.Area) && isscalar(Fc.data.R)
                            % Solid Resistance
                            Sim.Fc_R(Fc.index) = Fc.data.R;
                            % Surface Area
                            Sim.Fc_Area(Fc.index) = Fc.data.Area;
                        elseif ~isscalar(Fc.data.Area)
                            % Solid Resistance
                            temp = Fc.data.R;
                            temp = temp(~isnan(temp));
                            Sim.Fc_R(Fc.index) = temp(1);
                            % Surface Area
                            Sim.Dynamic(Sim.Dyn,:) = Fc.data.Area;
                            Sim.Fc_DynArea(1,Fc_DynArea_n) = Fc.index;
                            Sim.Fc_DynArea(2,Fc_DynArea_n) = Sim.Dyn;
                            Fc_DynArea_n = Fc_DynArea_n + 1;
                            Sim.Dyn = Sim.Dyn + 1;
                        else
                            Fc.data.R = Fc.data.R(~isnan(Fc.data.R));
                            Fc.data.R = Fc.data.R(1);
                            Sim.Fc_R(Fc.index) = Fc.data.R;
                            Sim.Fc_Area(Fc.index) = Fc.data.Area;
                        end
                        % Look at the mixed face and determine if it can be
                        % ... approximated
                        %{
                        if isfield(N2.data,'matl')
                        if N2.data.matl.Phase ~= enumMaterial.Solid
                            matl = Material(N2.data.matl.name);
                        else
                            matl = N2.data.matl;
                        end
                        else
                        if N2.Body.matl.Phase ~= enumMaterial.Solid
                            matl = Material(N2.Body.matl.name);
                        else
                            matl = N2.Body.matl;
                        end
                        end
                        if matl.dT_du < 0; matl.dT_du = 1e-8; end
                        if length(N2.Faces) == 1
                        % True for most regenerators and heat exchangers
                        if any((Fc.data.Area./Fc.data.R)./(N2.vol().*matl.Density./matl.dT_du)*1.e-4 > 0.25)
                            IsApprox(Fc.index) = true;
                            Sim.FcApprox(ApproxCount) = Fc.index;
                            ApproxCount = ApproxCount + 1;
                        end
                        else
                        CU = 0;
                        Cother = 0;
                        for fc = N2.Faces
                            if fc == Fc
                            CU = fc.data.Area./fc.data.R;
                            if double(sum(CU < Cother))/...
                                double(max(length(CU),length(Cother))) > 0.5
                                CU = 0;
                                break;
                            end
                            else
                            if fc.Type == enumFType.Mix
                                Cother = Cother + fc.data.Area./fc.data.R;
                                if any(CU ~= 0) && ...
                                    double(sum(CU < Cother))/...
                                    double(max(length(CU),length(Cother))) > 0.5
                                CU = 0;
                                break;
                                end
                            end
                            end
                        end
                        if CU ~= 0
                            if any((Fc.data.Area./Fc.data.R)./(N2.vol().*matl.Density./matl.dT_du)*1.e-4 > 0.25)
                            IsApprox(Fc.index) = true;
                            Sim.FcApprox(ApproxCount) = Fc.index;
                            ApproxCount = ApproxCount + 1;
                            end
                        end
                        end
                        
                        %}
                        MF_n = MF_n + 1;
                    case {enumFType.Gas, enumFType.MatrixTransition} % Gas-Gas, Gas-Environment Faces
                        Fc.recalc_Area_Dh();
                        % Create Fc_Fcs array
                        [A,B,C,D] = populate_Fc_ABCD(Sim, Fc);

                        % Create Fc_A array
                        if isscalar(A)
                            Sim.Fc_A(Fc.index) = A;
                        else
                            Sim.Dynamic(Sim.Dyn,:) = A;
                            Sim.Fc_DynA(1,Fc_DynA_n) = Fc.index;
                            Sim.Fc_DynA(2,Fc_DynA_n) = Sim.Dyn;
                            Fc_DynA_n = Fc_DynA_n + 1;
                            Sim.Dyn = Sim.Dyn + 1;
                        end
                        % Create Fc_B array
                        if isscalar(B)
                            Sim.Fc_B(Fc.index) = B;
                        else
                            Sim.Dynamic(Sim.Dyn,:) = B;
                            Sim.Fc_DynB(1,Fc_DynB_n) = Fc.index;
                            Sim.Fc_DynB(2,Fc_DynB_n) = Sim.Dyn;
                            Fc_DynB_n = Fc_DynB_n + 1;
                            Sim.Dyn = Sim.Dyn + 1;
                        end
                        % Create Fc_C array
                        if isscalar(C)
                            Sim.Fc_C(Fc.index) = C;
                        else
                            Sim.Dynamic(Sim.Dyn,:) = C;
                            Sim.Fc_DynC(1,Fc_DynC_n) = Fc.index;
                            Sim.Fc_DynC(2,Fc_DynC_n) = Sim.Dyn;
                            Fc_DynC_n = Fc_DynC_n + 1;
                            Sim.Dyn = Sim.Dyn + 1;
                        end
                        % Create Fc_B array
                        if isscalar(D)
                            Sim.Fc_D(Fc.index) = D;
                        else
                            Sim.Dynamic(Sim.Dyn,:) = D;
                            Sim.Fc_DynD(1,Fc_DynD_n) = Fc.index;
                            Sim.Fc_DynD(2,Fc_DynD_n) = Sim.Dyn;
                            Fc_DynD_n = Fc_DynD_n + 1;
                            Sim.Dyn = Sim.Dyn + 1;
                        end

                        % Area
                        if isscalar(Fc.data.Area)
                            Sim.Fc_Area(Fc.index) = Fc.data.Area;
                        else
                            Sim.Dynamic(Sim.Dyn,:) = Fc.data.Area;
                            Sim.Fc_DynArea(1,Fc_DynArea_n) = Fc.index;
                            Sim.Fc_DynArea(2,Fc_DynArea_n) = Sim.Dyn;
                            Fc_DynArea_n = Fc_DynArea_n + 1;
                            Sim.Dyn = Sim.Dyn + 1;
                        end
                        % Length / Friction Length
                        if isscalar(Fc.data.Dist)
                            Sim.Fc_Dist(Fc.index) = Fc.data.Dist;
                        else
                            Sim.Dynamic(Sim.Dyn,:) = Fc.data.Dist;
                            Sim.Fc_DynDist(1,Fc_DynDist_n) = Fc.index;
                            Sim.Fc_DynDist(2,Fc_DynDist_n) = Sim.Dyn;
                            Fc_DynDist_n = Fc_DynDist_n + 1;
                            Sim.Dyn = Sim.Dyn + 1;
                        end
                        if isscalar(Fc.data.Cond_Dist)
                            Sim.Fc_Cond_Dist(Fc.index) = Fc.data.Cond_Dist;
                        else
                            Sim.Dynamic(Sim.Dyn,:) = Fc.data.Cond_Dist;
                            Sim.Fc_DynCond_Dist(1,Fc_DynCond_Dist_n) = Fc.index;
                            Sim.Fc_DynCond_Dist(2,Fc_DynCond_Dist_n) = Sim.Dyn;
                            Fc_DynCond_Dist_n = Fc_DynCond_Dist_n + 1;
                            Sim.Dyn = Sim.Dyn + 1;
                        end
                        if isscalar(Fc.data.dx)
                            Sim.Fc_dx(Fc.index) = Fc.data.dx;
                        else
                            Sim.Dynamic(Sim.Dyn,:) = Fc.data.dx;
                            Sim.Fc_Dyndx(1,Fc_Dyndx_n) = Fc.index;
                            Sim.Fc_Dyndx(2,Fc_Dyndx_n) = Sim.Dyn;
                            Fc_Dyndx_n = Fc_Dyndx_n + 1;
                            Sim.Dyn = Sim.Dyn + 1;
                        end
                        % Hydraulic Diameter
                        if isscalar(Fc.data.Dh)
                            Sim.Fc_Dh(Fc.index) = Fc.data.Dh;
                        else
                            Sim.Dynamic(Sim.Dyn,:) = Fc.data.Dh;
                            Sim.Fc_DynDh(1,Fc_DynDh_n) = Fc.index;
                            Sim.Fc_DynDh(2,Fc_DynDh_n) = Sim.Dyn;
                            Fc_DynDh_n = Fc_DynDh_n + 1;
                            Sim.Dyn = Sim.Dyn + 1;
                        end
                        % Friction Function
                        if isfield(Fc.data,'K12') && any(Fc.data.K12 > 0) && any(Fc.data.K21 > 0)
                            if isscalar(Fc.data.K12)
                                Sim.Fc_K12(Fc.index) = Fc.data.K12;
                            else
                                Sim.Dynamic(Sim.Dyn,:) = Fc.data.K12;
                                Sim.Fc_DynK12(1,Fc_DynK12_n) = Fc.index;
                                Sim.Fc_DynK12(2,Fc_DynK12_n) = Sim.Dyn;
                                Fc_DynK12_n = Fc_DynK12_n + 1;
                                Sim.Dyn = Sim.Dyn + 1;
                            end
                            if isscalar(Fc.data.K21)
                                Sim.Fc_K21(Fc.index) = Fc.data.K21;
                            else
                                Sim.Dynamic(Sim.Dyn,:) = Fc.data.K21;
                                Sim.Fc_DynK21(1,Fc_DynK21_n) = Fc.index;
                                Sim.Fc_DynK21(2,Fc_DynK21_n) = Sim.Dyn;
                                Fc_DynK21_n = Fc_DynK21_n + 1;
                                Sim.Dyn = Sim.Dyn + 1;
                            end
                        else
                            Sim.Fc_fFunc_l{Fc.index} = Fc.data.fFunc_l;
                            Sim.Fc_fFunc_t{Fc.index} = Fc.data.fFunc_t;
                        end
                        % Mixing Function
                        Sim.Fc_NkFunc_l{Fc.index} = Fc.data.NkFunc_l;
                        Sim.Fc_NkFunc_t{Fc.index} = Fc.data.NkFunc_t;
                        % Shear Speed Factor
                        if isfield(Fc.data,'S')
                            Sim.Dynamic(Sim.Dyn,:) = Fc.data.S;
                            Sim.Fc_DynShear_Factor(1,Fc_DynShear_Factor_n) = Fc.index;
                            Sim.Fc_DynShear_Factor(2,Fc_DynShear_Factor_n) = Sim.Dyn;
                            Fc_DynShear_Factor_n = Fc_DynShear_Factor_n + 1;
                            Sim.Dyn = Sim.Dyn + 1;
                        end
                        % Face Speed Factor
                        if isfield(Fc.data,'V')
                            Sim.Dynamic(Sim.Dyn,:) = Fc.data.V;
                            Sim.Fc_DynVel_Factor(1,Fc_DynVel_Factor_n) = Fc.index;
                            Sim.Fc_DynVel_Factor(2,Fc_DynVel_Factor_n) = Sim.Dyn;
                            Fc_DynVel_Factor_n = Fc_DynVel_Factor_n + 1;
                            Sim.Dyn = Sim.Dyn + 1;
                        end
                        %                     case enumFType.Leak % Gas-Gas Leaks
                        % Do nothing, this is handled elsewhere
                end
            end

            Sim.Dynamic = Sim.Dynamic';

            %% Creating Face - Use Turbulence
            progressbar('Creating Face - Use Turbulence');

            L = G_count_backup_faces + 1;
            for Fc = this.Faces
                if Fc.index < L
                    % Don't use turbulence if
                    % Matrix exist in either connected node
                    % Either Node is variable volume
                    for Nd = Fc.Nodes
                        if ~Sim.Fc_K12(Fc.index)
                            if Sim.isDynVol(Nd.index)
                                Sim.useTurbulenceFc(Fc.index) = false;
                                break;
                            end
                            if isa(Nd.Body,'Body')
                                if ~isempty(Nd.Body.Matrix)
                                    Sim.useTurbulenceFc(Fc.index) = false;
                                    break;
                                end
                            else
                                Sim.useTurbulenceFc(Fc.index) = false;
                                break;
                            end
                        end
                    end
                end
            end

            %% Defining Max Time Step
            progressbar('Defining Max Time Step');

            BoundaryNodes = [];
            NGas = length(Sim.P);
            NGas = NGas - 1;
            NSolid = length(Sim.T) - NGas;
            MixFcs = cell(NSolid,1);
            ACond = zeros(NSolid,NSolid);
            bCond = zeros(NSolid,1);

            for nd = this.Nodes
                if nd.Type == enumNType.SN
                    if (isfield(nd.data,'matl') && nd.data.matl.dT_du < 0) || ...
                            nd.Body.matl.dT_du < 0
                        % Do not give these any sort of special privileges as they are
                        % ... no different than an environment node.
                        continue;
                    end
                    added = false;
                    for fc = nd.Faces
                        if fc.Type == enumFType.Mix
                            if ~added
                                added = true;
                                BoundaryNodes(length(BoundaryNodes)+1,1) = nd.index - NGas;
                            end
                            MixFcs{nd.index - NGas} = [MixFcs{nd.index - NGas} fc.index];
                        end
                    end
                end
            end

            fprintf(['Number of Solid Nodes + 1 Env node: ' num2str(NSolid) '\n']);

            for nd = this.Nodes
                if nd.index > NGas
                    row = nd.index-NGas;
                    if nd.Type == enumNType.SN
                        if (isfield(nd.data,'matl') && nd.data.matl.dT_du < 0) || ...
                                nd.Body.matl.dT_du < 0
                            ACond(row,row) = 1;
                            bCond(row) = nd.data.T;
                        else
                            for fc = nd.Faces
                                if fc.Type ~= enumFType.Mix
                                    avgCond = mean(fc.data.U);
                                    if fc.Nodes(1) == nd
                                        col = fc.Nodes(2).index - NGas;
                                    else
                                        col = fc.Nodes(1).index - NGas;
                                    end
                                    ACond(row, row) = ACond(row, row) + avgCond;
                                    ACond(row, col) = ACond(row, col) - avgCond;
                                end
                            end
                        end
                    else
                        if nd.Type == enumNType.EN
                            ACond(row,row) = 1;
                            bCond(row) = nd.Body.Temperature;
                        else
                            fprintf(['XXX Undefined node type during ACond and bCond ' ...
                                'pre-calculation XXX/n']);
                        end
                    end
                end
            end

            Sim.ACond = ACond;
            Sim.bCond = bCond;
            Sim.CondEff = zeros(M_count_backup_faces,1);
            Sim.CondTempEff = zeros(M_count_backup_faces,1);
            Sim.BoundaryNodes = BoundaryNodes';
            Sim.MixFcs = MixFcs;
            Sim.CycleTime = 0;

            a = 1000;
            Sim.Solid_dt_max = a(ones(1,Frame.NTheta));
            Sim.Nd_Solid_dt = a(ones(size(Sim.T)));
            for fc = this.Faces
                if ~IsApprox(fc.index)
                    if fc.Type == enumFType.Solid
                        for nd = fc.Nodes
                            if isfield(nd.data,'matl'); matl = nd.data.matl;
                            else; matl = nd.Body.matl;
                            end
                            if isa(nd.Body,'Body')
                                if matl.dT_du > 0
                                    timesteps = (this.MaxFourierNumber*nd.vol()*matl.Density/...
                                        matl.dT_du)./fc.data.U;
                                    if length(timesteps) == 1
                                        Sim.Solid_dt_max(Sim.Solid_dt_max > timesteps) = timesteps;
                                    else
                                        if iscolumn(timesteps)
                                            timesteps = timesteps';
                                        end
                                        Sim.Solid_dt_max = min([Sim.Solid_dt_max; timesteps]);
                                    end
                                    Sim.Nd_Solid_dt(nd.index) = min(Sim.Nd_Solid_dt(nd.index), min(timesteps));
                                end
                            end
                        end
                    end
                end
            end

            %% Defining Conduction/Transport Network
            progressbar('Defining Conduction/Transport Network');

            % SolidNds
            % Sim.Cond_Nds = all nodes except the environment, which is
            % ... automatically excluded
            Sim.Cond_Nds = [1:G_count_backup E_count_backup+1:S_count_backup];
            %Sim.Cond_Fcs = Sim.Solid_Fc;
            Sim.Cond_Fcs = 1:length(this.Faces);
            Sim.Cond_Fcs(IsApprox) = []; % Remove faces that are approximated by a different method.
            Nds1 = Sim.Fc_Nd(Sim.Cond_Fcs,1);
            Nds2 = Sim.Fc_Nd(Sim.Cond_Fcs,2);
            Sim.Cond_Nds1 = Nds1;
            Sim.Cond_Nds2 = Nds2;
            Nds1(Sim.dT_dU(Nds1)<0) = 0;
            Nds2(Sim.dT_dU(Nds2)<0) = 0;
            % Determine set of element sets with sign
            i = 1;
            % Node 1's
            if any(Nds1~=0); N1 = mode(Nds1(Nds1~=0)); N1 = sum(Nds1(:)==N1);
            else; N1 = 0; end
            if any(Nds2~=0); N2 = mode(Nds2(Nds2~=0)); N2 = sum(Nds2(:)==N2);
            else; N2 = 0; end
            Temp = cell(1,3*(N1+N2));
            if N1 ~= 0
                % First element = sign
                % Second element = nodes
                % Third element = faces
                for k = 1:N1
                    % Q is flow into Node 1
                    N = length(unique(Nds1(Nds1>0)));
                    Temp{i} = -1;
                    Temp{i+1} = zeros(1,N);
                    Temp{i+2} = zeros(1,N);
                    el = 1;
                    for x = 1:length(Nds1)
                        if Nds1(x) > 0
                            if ~any(Temp{i+1}(1:el-1) == Nds1(x))
                                Temp{i+1}(el) = Nds1(x);
                                Temp{i+2}(el) = x; % index with respect to Fc_Cond
                                Nds1(x) = 0;
                                el = el + 1;
                            end
                        end
                    end
                    i = i + 3;
                end
            end
            % Node 2's
            if N2 ~= 0
                % First element = sign
                % Second element = nodes
                % Third element = faces
                for k = 1:N2
                    % Q is flow into Node 1
                    N = length(unique(Nds2(Nds2>0)));
                    Temp{i} = 1;
                    Temp{i+1} = zeros(1,N);
                    Temp{i+2} = zeros(1,N);
                    el = 1;
                    for x = 1:length(Nds2)
                        if Nds2(x) > 0
                            if ~any(Temp{i+1}(1:el-1) == Nds2(x))
                                Temp{i+1}(el) = Nds2(x);
                                Temp{i+2}(el) = x; % index with respect to Fc_Cond
                                Nds2(x) = 0;
                                el = el + 1;
                            end
                        end
                    end
                    i = i + 3;
                end
            end
            Sim.CondNet = Temp;

            % GasNds
            Sim.Trans_Fcs = 1:length(Sim.Fc_U);
            Nds1 = Sim.Fc_Nd(Sim.Trans_Fcs,1);
            Nds2 = Sim.Fc_Nd(Sim.Trans_Fcs,2);
            Nds1(Sim.dT_dU(Nds1)==0) = 0;
            Nds2(Sim.dT_dU(Nds2)==0) = 0;
            % Determine the set of element sets with sign
            i = 1;
            % Node 1's
            if any(Nds1~=0); N1 = mode(Nds1(Nds1~=0)); N1 = sum(Nds1(:)==N1);
            else; N1 = 0; end
            if any(Nds2~=0); N2 = mode(Nds2(Nds2~=0)); N2 = sum(Nds2(:)==N2);
            else; N2 = 0; end
            Temp = cell(1,3*(N1+N2));
            if N1 ~= 0
                Excluded = false(1,length(Nds1)); Excluded(Nds1==0) = true;
                % First element = sign
                % Second element = nodes
                % Third element = faces
                for k = 1:N1
                    % Q is flow into Node 1
                    N = length(unique(Nds1(~Excluded)));
                    Temp{i} = -1;
                    Temp{i+1} = zeros(1,N);
                    Temp{i+2} = zeros(1,N);
                    el = 1;
                    for x = 1:length(Nds1)
                        if ~Excluded(x) && ~any(Temp{i+1}(1:el-1) == Nds1(x))
                            Temp{i+1}(el) = Nds1(x); % Target Node
                            Temp{i+2}(el) = x; % index with respect to Fc_Cond
                            Excluded(x) = true;
                            el = el + 1;
                        end
                    end
                    i = i + 3;
                end
            end
            % Node 2's
            if N2 ~= 0
                Excluded = false(1,length(Nds2)); Excluded(Nds2==0) = true;
                % First element = sign
                % Second element = nodes
                % Third element = faces
                for k = 1:N2
                    % Q is flow into Node 1
                    N = length(unique(Nds2(~Excluded)));
                    Temp{i} = 1;
                    Temp{i+1} = zeros(1,N);
                    Temp{i+2} = zeros(1,N);
                    el = 1;
                    for x = 1:length(Nds2)
                        if ~Excluded(x) && ~any(Temp{i+1}(1:el-1) == Nds2(x))
                            Temp{i+1}(el) = Nds2(x);
                            Temp{i+2}(el) = x; % index with respect to Fc_Cond
                            Excluded(x) = true;
                            el = el + 1;
                        end
                    end
                    i = i + 3;
                end
            end
            Sim.TransNet = Temp;

            %% Creating Lookup Tables, Regions and Loops For Solver
            progressbar('Creating Regions and Loops For Solver');

            %% Group functions
            % Laminar Nusselt
            novel = true(size(Sim.P));
            novel(end) = [];
            nodes = zeros(size(Sim.P));
            Sim.NuFunc_l_el = cell(0);
            x = 1;
            for i = 1:length(Sim.P)-2
                if novel(i)
                    func = Sim.NuFunc_l{i}; k = 1; nodes(k) = i;
                    for j = i+1:length(Sim.P)-1
                        if novel(j)
                            if nargin(func) == nargin(Sim.NuFunc_l{j})
                                if nargin(func) == 1
                                    x1 = rand(1);
                                    if func(x1) == Sim.NuFunc_l{j}(x1)
                                        k = k + 1; nodes(k) = j; novel(j) = false;
                                    end
                                else
                                    x1 = rand(1); x2 = rand(1);
                                    if func(x1,x2) == Sim.NuFunc_l{j}(x1,x2)
                                        k = k + 1; nodes(k) = j; novel(j) = false;
                                    end
                                end
                            end
                        end
                    end
                    Sim.NuFunc_l_el{x} = nodes(1:k);
                    x = x + 1;
                end
            end
            if novel(end); Sim.NuFunc_l_el{x} = length(novel); end
            Sim.NuFunc_l(~novel) = [];

            % Turbulent Nusselt
            novel(:) = true;
            nodes = zeros(size(Sim.P));
            Sim.NuFunc_t_el = cell(0);
            x = 1;
            for i = 1:length(Sim.P)-2
                if novel(i)
                    func = Sim.NuFunc_t{i}; k = 1; nodes(k) = i;
                    for j = i+1:length(Sim.P)-1
                        if novel(j)
                            if nargin(func) == nargin(Sim.NuFunc_t{j})
                                if nargin(func) == 1
                                    x1 = rand(1);
                                    if func(x1) == Sim.NuFunc_t{j}(x1)
                                        k = k + 1; nodes(k) = j; novel(j) = false;
                                    end
                                else
                                    x1 = rand(1); x2 = rand(1);
                                    if func(x1,x2) == Sim.NuFunc_t{j}(x1,x2)
                                        k = k + 1; nodes(k) = j; novel(j) = false;
                                    end
                                end
                            end
                        end
                    end
                    Sim.NuFunc_t_el{x} = nodes(1:k);
                    x = x + 1;
                end
            end
            if novel(end); Sim.NuFunc_t_el{x} = length(novel); end
            Sim.NuFunc_t(~novel) = [];

            % Laminar Conduction
            novel = true(size(Sim.Fc_U));
            nodes = zeros(size(Sim.Fc_U));
            Sim.Fc_NkFunc_l_el = cell(0);
            x = 1;
            if ~isempty(novel)
                for i = 1:length(Sim.Fc_U)-1
                    if novel(i)
                        func = Sim.Fc_NkFunc_l{i}; k = 1; nodes(k) = i;
                        for j = i+1:length(Sim.Fc_U)
                            if novel(j)
                                if nargin(func) == nargin(Sim.Fc_NkFunc_l{j})
                                    if nargin(func) == 1
                                        x1 = rand(1);
                                        if func(x1) == Sim.Fc_NkFunc_l{j}(x1)
                                            k = k + 1; nodes(k) = j; novel(j) = false;
                                        end
                                    else
                                        x1 = rand(1); x2 = rand(1);
                                        if func(x1,x2) == Sim.Fc_NkFunc_l{j}(x1,x2)
                                            k = k + 1; nodes(k) = j; novel(j) = false;
                                        end
                                    end
                                end
                            end
                        end
                        Sim.Fc_NkFunc_l_el{x} = nodes(1:k);
                        x = x + 1;
                    end
                end
                if novel(end); Sim.Fc_NkFunc_l_el{x} = length(novel); end
                Sim.Fc_NkFunc_l(~novel) = [];
            end

            % Turbulent Conduction
            novel(:) = true;
            nodes = zeros(size(Sim.Fc_U));
            Sim.Fc_NkFunc_t_el = cell(0);
            x = 1;
            if ~isempty(novel)
                for i = 1:length(Sim.Fc_U)-1
                    if novel(i)
                        func = Sim.Fc_NkFunc_t{i}; k = 1; nodes(k) = i;
                        for j = i+1:length(Sim.Fc_U)
                            if novel(j)
                                if nargin(func) == nargin(Sim.Fc_NkFunc_t{j})
                                    if nargin(func) == 1
                                        x1 = rand(1);
                                        if func(x1) == Sim.Fc_NkFunc_t{j}(x1)
                                            k = k + 1; nodes(k) = j; novel(j) = false;
                                        end
                                    else
                                        x1 = rand(1); x2 = rand(1);
                                        if func(x1,x2) == Sim.Fc_NkFunc_t{j}(x1,x2)
                                            k = k + 1; nodes(k) = j; novel(j) = false;
                                        end
                                    end
                                end
                            end
                        end
                        Sim.Fc_NkFunc_t_el{x} = nodes(1:k);
                        x = x + 1;
                    end
                end
                if novel(end); Sim.Fc_NkFunc_t_el{x} = length(novel); end
                Sim.Fc_NkFunc_t(~novel) = [];
            end

            % region now represents how the engine is divided up
            regions = cell(region_count,1);
            isEnvironmentRegion = false(region_count,1);
            isEnvironmentRegion(region(end)) = true;
            loop_ind_cell = cell(region_count,1);
            loops_cell = cell(region_count,1);
            regionFcCount = zeros(region_count,1);
            regionFcs = cell(region_count,1);
            Sim.ActiveRegionFcs = cell(region_count,1);
            Sim.A_Press = cell(region_count,1);

            for i = 1:region_count
                % loop_ind = [ start end condition ]
                %            [ ...   ... ind or 0  ]
                loop_ind_cell{i} = zeros(3,0);
                % loops = [nd1, fc12, sign]
                loops_cell{i} = zeros(3,0);
            end
            % Make a list of nodes that are under this region
            for i = 1:region_count
                c = 1;
                regions{i} = zeros(length(region),1);
                for k = 1:length(region)-1
                    if region(k) == i; regions{i}(c) = k; c = c + 1; end
                end
                if isEnvironmentRegion(i)
                    regions{i}(c) = length(region);
                    c = c + 1;
                end
                if c <= length(region); regions{i}(c:end) = []; end
            end

            % Take a count of faces that are under this region
            % ... This will tell us how many loops we need to define
            % ... May not be necassary

            %       extfc = cell(n,2);
            for Fc = this.Faces
                if isfield(Fc.data,'dx')
                    if region(Fc.Nodes(1).index) == region(Fc.Nodes(2).index)
                        r = region(Fc.Nodes(1).index);
                        regionFcCount(r) = regionFcCount(r) + 1;
                        regionFcs{r}(end+1) = Fc.index;
                    end
                end
            end
            %       Sim.extfc = extfc;

            % Find Loops in each region
            LEN = length(Sim.Fc_U);
            % Make visited/closed any string who goes to a dead end
            Closed_Edge = TrimFaces(this,region,false(LEN,1));

            % What is left is all the nodes that could possibly be a part of a
            % ... loop.
            % Create Loops using the available faces and nodes
            open = LoopNode.empty;
            for i = 1:region_count
                lequ = 1;
                lcount = 0;
                %         TimesVisited = zeros(length(Sim.Fc_dx),1);
                % Find the edges that close during the cycle. These are classified
                % ... as holes.
                holes = Face.empty;
                for Fc = this.Faces
                    if Fc.index <= LEN && ...
                            region(Fc.Nodes(1).index) == i && ...
                            region(Fc.Nodes(2).index) == i && ...
                            any(Fc.data.Area == 0)
                        % This is a node that is transient, used to trim loops
                        holes(end+1) = Fc;
                        Closed_Edge(Fc.index) = true;
                    end
                end

                % We have defined all the "holes", the first n loops will be
                % ... dedicated to covering those holes.
                % NIndependent_Equations = # of Nodes - 1
                % N loops = Unknowns - NIndependent_Equations - Environment_Node
                % Nloops = (regionFcCount(i)-length(regions{i})+1-isEnvironmentRegion(i));
                for k = 1:(regionFcCount(i)-length(regions{i})+1)
                    Vis_Edge = Closed_Edge;
                    % Get a starting Point
                    if k <= length(holes)
                        % Find loops that cover these holes
                        Fc = holes(k);
                    else
                        % Find open edges, and find loops that cover them
                        found = false;
                        for Fc = this.Faces
                            if Fc.index <= LEN && ~Closed_Edge(Fc.index) && ...
                                    region(Fc.Nodes(1).index) == i  && ...
                                    region(Fc.Nodes(2).index) == i
                                found = true; break;
                            end
                        end
                        if ~found
                            fprintf('XXX No valid Loop Starting Point! XXX\n'); return;
                        end
                        Closed_Edge(Fc.index) = true; Vis_Edge(Fc.index) = true;
                    end
                    closed = LoopNode(LoopNode.empty, Face.empty, Fc.Nodes(1));
                    target = Fc.Nodes(1);
                    open = LoopNode(closed(1), Fc, Fc.Nodes(2));
                    % EdgeClosed = Fc;

                    % Use open as a starting point and path to the closed
                    % ... "target" is the end node
                    % ... Do not path though Closed_Edge's
                    done = false;
                    while ~(isempty(open) || done)
                        len = length(open);
                        for x = len:-1:1
                            % Expand it
                            LpNd = open(x);
                            for Fc = LpNd.Nd.Faces
                                if Fc.index <= length(Vis_Edge) && ...
                                        region(Fc.Nodes(1).index) == i && ...
                                        region(Fc.Nodes(2).index) == i && ...
                                        ~Vis_Edge(Fc.index)
                                    Vis_Edge(Fc.index) = true;
                                    % Add it to the open list
                                    if Fc.Nodes(1) == LpNd.Nd; newNd = Fc.Nodes(2);
                                    else; newNd = Fc.Nodes(1); end
                                    if newNd == target
                                        done = true;
                                        closed(end+1) = LoopNode(LpNd,Fc,newNd);
                                        break;
                                    else
                                        open(end+1) = LoopNode(LpNd,Fc,newNd);
                                    end
                                end
                            end
                            if done; break; end
                        end
                        if ~done; open = open(len+1:end); end
                    end

                    % The loop should of reached its target.
                    if done
                        % Backtrace the loop
                        current = closed(end);
                        lcount = lcount + 1;
                        loop_ind_cell{i}(1,lcount) = lequ;
                        while ~isempty(current.parent)
                            loops_cell{i}(1,lequ) = current.Nd.index;
                            loops_cell{i}(2,lequ) = current.parentFc.index;
                            if current.parentFc.Nodes(1) == current.Nd
                                loops_cell{i}(3,lequ) = 1;
                            else
                                loops_cell{i}(3,lequ) = -1;
                            end
                            lequ = lequ + 1;
                            current = current.parent;
                        end
                        loop_ind_cell{i}(2,lcount) = lequ - 1;
                        % closed(end) is the start node
                        % Determine if the loop has a condition
                        if k <= length(holes)
                            % This one is connected to the area state of holes(k)
                            loop_ind_cell{i}(3,lcount) = holes(k).index;
                        else
                            % This one is unnconnected to a hole
                            loop_ind_cell{i}(3,lcount) = 0;
                        end

                        % Close all edges that run into the "EdgeClosed"
                        if k >= length(holes)
                            Closed_Edge = TrimFaces(this, region, Closed_Edge);
                        end

                    else
                        fprintf(['XXX Failed to complete a loop. Loop: ' num2str(k) ' XXX\n']);
                    end
                end

            end

            % Find ActiveFaces
            Vis_Node = false(length(region),1);
            for i = 1:region_count
                k = 0;
                Temp = zeros(regionFcCount(i),1);
                for Nd = this.Nodes
                    if Nd.index <= length(region) && ...
                            ~Vis_Node(Nd.index) && ...
                            region(Nd.index) == i
                        [k,Temp,Vis_Node] = PropegateActiveFaces(Nd,Vis_Node,k,Temp);
                        break;
                    end
                end
                Temp(k+1:end) = [];
                Sim.ActiveRegionFcs{i} = Temp;
            end

            % Find A-PressureLoss
            for i = 1:region_count
                Sim.A_Press{i} = zeros(length(regions{i}));
                for x = 1:length(Sim.ActiveRegionFcs{i})
                    Fc = Sim.ActiveRegionFcs{i}(x);
                    % n1 = +ve;
                    % n2 = -ve;
                    temp = Sim.Fc_Nd(Fc,1);
                    for k = 1:length(regions{i})
                        if temp == regions{i}(k)
                            Sim.A_Press{i}(x,k) = 1;
                            break;
                        end
                    end
                    temp = Sim.Fc_Nd(Fc,2);
                    for k = 1:length(regions{i})
                        if temp == regions{i}(k)
                            Sim.A_Press{i}(x,k) = -1;
                            break;
                        end
                    end
                end
            end

            % Calculate what the gas constant would be
            % We have Rs
            for i = 1:region_count
                if isEnvironmentRegion(i)
                    Sim.R(i) = Rs(end);
                else
                    % Pick the most common
                    Sim.R(i) = mode(Rs(regions{i}));
                end
                for j = regions{i}
                    if Rs(j) ~= Sim.R(i)
                        fprintf(['XXX Node in region ' num2str(i) ...
                            ' found that had a different gas than the bulk. XXX\n']);
                        fprintf(['XXX ... Region is of size: ' ...
                            num2str(length(regions{i})) '. XXX\n']);
                    end
                end
            end
            Sim.Rs = Rs;

            % loops_cell
            % loop_ind_cell
            % regions (cell array containing all nodes separated by a region)
            Sim.Regions = regions;
            Sim.isEnvironmentRegion = isEnvironmentRegion;

            Sim.RegionFcs = regionFcs;
            for i = 1:length(regionFcs)
                Sim.Fc2Col(regionFcs{i}(:)) = 1:length(regionFcs{i});
            end
            Sim.RegionFcCount = regionFcCount;
            Sim.RegionLoops = loops_cell;
            Sim.RegionLoops_Ind = loop_ind_cell;
            for list = loop_ind_cell
                count = count + size(list{1},2);
            end
            fprintf(['Found ' num2str(count) ' loops. \n']);

            % Collapse F2C for the limited set
            %       Sim.isLoopRegionFcs = cell(size(Sim.RegionFcs));
            %       Sim.Fc2Col_loop = zeros(size(Sim.Fc_V));
            %       for i = 1:region_count
            %         if ~isempty(Sim.RegionLoops{i})
            %           Sim.isLoopRegionFcs{i} = false(size(Sim.RegionFcs{i}));
            %           for x = 1:size(Sim.RegionLoops{i},2)
            %             Sim.isLoopRegionFcs{i}(Sim.RegionLoops{i}(2,x)) = true;
            %           end
            %         end
            %       end

            Sim.Faces = cell(length(Sim.Dh),1);

            % Define "Sim.Faces"
            for Nd = this.Nodes
                if Nd.index <= length(Sim.Dh)
                    Fcs = Face.empty;
                    % It is a gas node
                    % ... Get list of gas faces for this node
                    for Fc = Nd.Faces
                        if isfield(Fc.data,'dx')
                            Fcs(end+1) = Fc;
                        end
                    end
                    if ~isempty(Fcs)
                        % This node has many gas faces
                        Sim.Faces{Nd.index} = zeros(length(Fcs),3);
                        for i = 1:length(Fcs)
                            if Fcs(i).Nodes(1) == Nd
                                dir = -1;
                            else
                                dir = 1;
                            end
                            Sim.Faces{Nd.index}(i,:) = [Fcs(i).index dir...
                                region(Fcs(i).Nodes(1).index) ~= region(Fcs(i).Nodes(2).index)];
                        end
                    else
                        Sim.Faces{Nd.index} = zeros(0,3);
                    end
                end
            end

            % So we have faces, which has an entry for each node
            % ... List of Face Indexes
            % ... List of BValues
            % ... List of signs (-1 for outlet, 1 for inlet)
            % ... List of 0 = implicit, 1 = explicit

            % Need to make a list of implicit velocities that need to be
            % ... calculated, use region pressure
            Sim.LeakFaces = LeakFaces;
            Sim.LeakDM = Sim.P;
            Sim.ExplicitNorm = zeros(0,3);
            for Fc = this.Faces
                if isfield(Fc.data,'dx')
                    if region(Fc.Nodes(1).index) ~= region(Fc.Nodes(2).index)
                        % Add to list
                        Sim.ExplicitNorm = [Sim.ExplicitNorm; [Fc.index region(Fc.Nodes(1).index) region(Fc.Nodes(2).index)]];
                    end
                end
            end
            % Flow Network
            % NEED EXTERNAL FACES TO BE LABELLED
            % ... explicit faces
            % ... ... Between regions, sources, sinks, leaks.. etc
            % ... ... Used on region scale for mass change
            % ... ... Used on local scale
            % ... implicit faces
            % ... ... Internal to region,
            % NEED FACES AND NODES ORGANIZED BY REGION

            %% Pressure/Shear Contacts, Sensors, PVoutputs
            progressbar('Pressure/Shear Contacts, Sensors, PVoutputs');

            % Pressure Contacts
            PC_n = 1;
            for PC = this.PressureContacts
                addto = true;
                for i = 1:PC_n-1
                    if PC.GasNode == Sim.Press_Contact(3,i) && ...
                            PC.Area == Sim.Press_Contact(2,i) && ...
                            PC.MechanismIndex == Sim.Press_Contact(1,i)
                        addto = false;
                    end
                end
                if addto
                    Sim.Press_Contact(1,PC_n) = PC.ConverterIndex;
                    Sim.Press_Contact(2,PC_n) = PC.MechanismIndex;
                    Sim.Press_Contact(3,PC_n) = PC.Area;
                    Sim.Press_Contact(4,PC_n) = PC.GasNode.index;
                    PC_n = PC_n + 1;
                end
            end
            this.PressureContacts = PressureContact.empty;

            % Shear Contacts
            SC_n = 1;
            SC_Active_n = 1;
            for SC = this.ShearContacts
                addto = true;
                for i = 1:SC_n-1
                    if SC.UpperNode.index == Sim.Shear_Contact(4,i) && ...
                            SC.LowerNode.index == Sim.Shear_Contact(3,i) && ...
                            SC.Area == Sim.Shear_Contact(2,i) && ...
                            SC.MechanismIndex == Sim.Shear_Contact(1,i)
                        addto = false;
                    end
                end
                if addto
                    if any(SC.ActiveTimes)
                        Sim.Shear_Contact(1,SC_n) = SC.ConverterIndex;
                        Sim.Shear_Contact(2,SC_n) = SC.MechanismIndex;
                        Sim.Shear_Contact(3,SC_n) = SC.Area;
                        Sim.Shear_Contact(4,SC_n) = SC.LowerNode.index;
                        Sim.Shear_Contact(5,SC_n) = SC.UpperNode.index;
                        Sim.Shear_Contact(6,SC_n) = 1;
                        if ~all(SC.ActiveTimes)
                            if size(SC.ActiveTimes,2) ~= 1
                                SC.ActiveTimes = SC.ActiveTimes';
                            end
                            Sim.Dynamic(:,Sim.Dyn) = SC.ActiveTimes;
                            Sim.SC_Active(1,SC_Active_n) = SC_n;
                            Sim.SC_Active(2,SC_Active_n) = Sim.Dyn;
                            SC_Active_n = SC_Active_n + 1;
                            Sim.Dyn = Sim.Dyn + 1;
                        end
                        SC_n = SC_n + 1;
                    end
                end
            end
            this.ShearContacts = ShearContact.empty;

            % Sensors
            for i = length(this.Sensors):-1:1
                if ~isValid(this.Sensors(i))
                    len = length(this.Sensors);
                    this.Sensors(i).deReference()
                    if len == length(this.Sensors)
                        this.Sensors(i) = [];
                    end
                end
            end
            if ~isempty(this.Sensors)
                for iSense = this.Sensors
                    iSense.update();
                end
            end
            if ~isempty(this.PVoutputs)
                for iPVoutput = this.PVoutputs; iPVoutput.update(region); end
            end
            Sim.PRegion = zeros(length(Sim.Regions),1);
            Sim.PRegionTime = 0;

            progressbar(12/13);
            progressbar('Defining Area for Turbulence');

            % Node Faces For Turbulent Decay and Generation
            Len = 1 + size(Sim.Area,2);
            for Nd = this.Nodes
                if Nd.index < Len
                    if Nd.Body.divides(1) > Nd.Body.divides(2)
                        % It is divides along by cylindrical shells
                        % Look for two dynamic Dh faces that have the same motion
                        % ... Pattern

                        % 1 and 2 dynamic face pairs within body
                        if (~isscalar(Nd.ymax) || ~isscalar(Nd.ymin)) && ...
                                ~all(Nd.ymax-Nd.ymin == Nd.ymax(1)-Nd.ymin(1))
                            startindex = 1;
                            count = 0;
                            while startindex ~= 0 && startindex <= length(Nd.Faces)
                                Pattern = 0;
                                oldstartindex = startindex;
                                startindex = 1;
                                i = 0;
                                for Fc = Nd.Faces(startindex:end)
                                    i = i + 1;
                                    if Fc.Type ~= enumFType.Mix
                                        if ~isscalar(Fc.data.Dh) && isempty(Fc.Connection)
                                            count = count + 1;
                                            if ~any(Pattern)
                                                Pattern = Fc.data.Dh;
                                                startindex = i;
                                            else
                                                temp = Pattern./Fc.data.Dh;
                                                if all(temp == temp(1))
                                                    % Simply take the average of the faces
                                                    Sim.Area(1,Nd.index) = Fc.index;
                                                    Sim.Area(2,Nd.index) = (temp(1)+1)/2;
                                                    startindex = 0;
                                                    break;
                                                end
                                            end
                                        end
                                    end
                                end
                                if oldstartindex == startindex
                                    startindex = 0;
                                elseif startindex ~= 0
                                    startindex = startindex + 1;
                                end
                            end
                            if count == 1
                                % There is only one non-Connection Face
                                for Fc = Nd.Faces
                                    if Fc.Type ~= enumFType.Mix && ~isscalar(Fc.data.Dh) && isempty(Fc.Connection)
                                        if all(temp == temp(1))
                                            % Simply take the average of the faces
                                            Sim.Area(1,Nd.index) = Fc.index;
                                            Sim.Area(2,Nd.index) = 1;
                                            break;
                                        end
                                    end
                                end
                            end
                        end

                        % 1 and 2 static face pairs within body
                        if ~Sim.Area(2,Nd.index)
                            % No two faces were found
                            % Find a face that is static and not a connection
                            count = 0;
                            for Fc = Nd.Faces
                                if Fc.Type ~= enumFType.Mix
                                    if isscalar(Fc.data.Dh) && isempty(Fc.Connection)
                                        count = count + 1;
                                    end
                                end
                            end
                            if count == 2
                                for Fc = Nd.Faces
                                    if Fc.Type ~= enumFType.Mix
                                        if isscalar(Fc.data.Area) && isempty(Fc.Connection)
                                            Sim.Area(2,Nd.index) = Sim.Area(2,Nd.index) + 0.5*Fc.data.Area;
                                        end
                                    end
                                end
                            end
                            if count == 1
                                for Fc = Nd.Faces
                                    if Fc.Type ~= enumFType.Mix
                                        if isscalar(Fc.data.Area) && isempty(Fc.Connection)
                                            Sim.Area(2,Nd.index) = Sim.Area(2,Nd.index) + Fc.data.Area;
                                        end
                                    end
                                end
                            end
                        end

                        %
                        if ~Sim.Area(2,Nd.index)
                            fprintf('XXX Deficiency in Node Face Calculation in Model XXX');
                        end
                    else
                        % It is divided by horizontal planes or not divided,
                        % ... simply take the radius of the shape
                        Sim.Area(1,Nd.index) = 0;
                        Sim.Area(2,Nd.index) = pi*Nd.xmax^2;
                    end
                end
            end

            if isempty(this.MechanicalSystem)
                Sim.MechanicalSystem = ...
                    MechanicalSystem(this,this.Converters,[],...
                    1,function_handle.empty);
            else
                Sim.MechanicalSystem = ...
                    MechanicalSystem(this,this.Converters,[],...
                    this.MechanicalSystem.Inertia,this.MechanicalSystem.LoadFunction);
            end

            %% Defining Energy Statistics Handlers
            progressbar('Defining Energy Statistics Handlers');

            % Statistics
            % Find all Solid Faces that go to the Environment
            Sim.ToEnvironmentSolid = zeros(2,length(this.surroundings.Node.Faces));
            Sim.ToEnvironmentGas = zeros(2,length(this.surroundings.Node.Faces));
            nS = 1; nG = 1;
            % Matthias: Here, the '1' or '-1' assigned to these faces represents the
            % sign, i.e. '1' means positive heat flow to environment and '-1' negative.
            % Here, in the first and 4th case where the environment node (EN) is node
            % number 2 in the face, sign is negative. This means the positive flow
            % direction of a face is defined from node 2 to 1. Below in the definition
            % of source and sink heat flow (ca. line 3200), it is the opposite way.
            % This may be the reason why the 'statistics.ToEnvironment' output seems to
            % have the opposite sign from what is expected.
            % CHANGED SIGNS --> ToEnvironment sign has changed, magnitude is same. I'd
            % call it success.
            for Fc = this.surroundings.Node.Faces
                if Fc.Nodes(1).Type == enumNType.SN
                    % It is a solid -> environment face
                    Sim.ToEnvironmentSolid(1,nS) = Fc.index;
                    Sim.ToEnvironmentSolid(2,nS) = 1; %changed
                    nS = nS + 1;
                elseif Fc.Nodes(2).Type == enumNType.SN
                    % It is a environment -> solid face
                    Sim.ToEnvironmentSolid(1,nS) = Fc.index;
                    Sim.ToEnvironmentSolid(2,nS) = -1; %changed
                    nS = nS + 1;
                elseif Fc.Nodes(1).Type == enumNType.EN
                    % It is a environment -> gas face
                    Sim.ToEnvironmentGas(1,nG) = Fc.index;
                    Sim.ToEnvironmentGas(2,nG) = -1; %changed
                    nG = nG + 1;
                else
                    % It is a gas -> environment face
                    Sim.ToEnvironmentGas(1,nG) = Fc.index;
                    Sim.ToEnvironmentGas(2,nG) = 1; %changed
                    nG = nG + 1;
                end
            end
            Sim.ToEnvironmentSolid = Sim.ToEnvironmentSolid(:,1:nS-1);
            Sim.ToEnvironmentGas = Sim.ToEnvironmentGas(:,1:nG-1);

            % Find all Faces that go to a Source
            isToSourceOrSink = false(1, length(this.Faces));
            isSourceOrSink = false(1, length(this.Nodes));
            for Nd = this.Nodes
                if Nd.Type == enumNType.SN && ...
                        (strcmp(Nd.Body.matl.name, 'Constant Temperature') || (...
                        isfield(Nd.data,'matl') && ...
                        strcmp(Nd.data.matl.name, 'Constant Temperature')) ...
                        )
                    isSourceOrSink(Nd.index) = true;
                    for Fc = Nd.Faces
                        isToSourceOrSink(Fc.index) = ~isToSourceOrSink(Fc.index);
                    end
                end
            end

            temp = 1:length(this.Faces);
            Subject_Faces = temp(isToSourceOrSink);
            temp = 1:length(this.Nodes);
            Subject_Nodes = temp(isSourceOrSink);

            % Get Average Temperatures
            T = mean(Sim.T(isSourceOrSink));
            Sim.ToSource = zeros(2,length(this.Faces));
            nSr = 1;
            Sim.ToSink = zeros(2,length(this.Faces));
            nSi = 1;
            IsSource = false(1, length(this.Nodes));
            if T > this.surroundings.Temperature
                IsSource(Subject_Nodes) = Sim.T(Subject_Nodes) >= T;
            else
                IsSource(Subject_Nodes) = Sim.T(Subject_Nodes) > T;
            end
            for findex = Subject_Faces
                % if node 1 is source/sink, sign is negative
                if isSourceOrSink(Sim.Fc_Nd(findex,1))
                    if IsSource(Sim.Fc_Nd(findex,1))
                        Sim.ToSource(1,nSr) = findex;
                        Sim.ToSource(2,nSr) = -1;
                        nSr = nSr + 1;
                    else
                        Sim.ToSink(1,nSi) = findex;
                        Sim.ToSink(2,nSi) = -1;
                        nSi = nSi + 1;
                    end
                    % if node 2 is source/sink, sign is positive:
                    % flow direction is 1 --> 2
                else
                    if IsSource(Sim.Fc_Nd(findex,2))
                        Sim.ToSource(1,nSr) = findex;
                        Sim.ToSource(2,nSr) = 1;
                        nSr = nSr + 1;
                    else
                        Sim.ToSink(1,nSi) = findex;
                        Sim.ToSink(2,nSi) = 1;
                        nSi = nSi + 1;
                    end
                end
            end
            Sim.ToSource = Sim.ToSource(:,1:nSr-1);
            Sim.ToSink = Sim.ToSink(:,1:nSi-1);
            Sim.Sources = temp(IsSource);
            Sim.Sinks = temp(and(isSourceOrSink, ~IsSource));

            % identify shearing faces
            % All Mixed Faces, All Solid Faces
            if ~isempty(Sim.Fc_DynArea)
                ShuttleFaces = Sim.Fc_DynArea(1,:);%[Sim.Fc_DynArea(1,:) Sim.Fc_DynCond(1,:)];
            else
                ShuttleFaces = zeros(1,0);
            end
            if ~isempty(Sim.Fc_DynCond)
                ShuttleFaces = [ShuttleFaces Sim.Fc_DynCond(1,:)];
            end
            % Exclude Gas Faces
            Sim.ShuttleFaces = ShuttleFaces(ShuttleFaces>length(Sim.Fc_U));

            % idenfity static faces
            % All Mixed Faces, All Solid Faces
            % Exclude Gas Faces
            Sim.StaticFaces = 1:length(Sim.Fc_Cond);
            Sim.StaticFaces(Sim.ShuttleFaces) = [];

            Sim.ExergyLossShuttle = 0;
            Sim.ExergyLossStatic = 0;

            this.Simulations = Sim;

            this.isStateDiscretized = true;

            Sim.Fc_K12(isnan(Sim.Fc_K12)) = 1;
            Sim.Fc_K21(isnan(Sim.Fc_K21)) = 1;
            Sim.Dynamic(isnan(Sim.Dynamic)) = 0;

            progressbar(1);
        end
        %%
        function [success] = Run(ME, runs)
            success = false;
            backup_path = ME.outputPath;
            if nargin > 1
                %if running test set, record all outputs
                tests = length(runs);
                ME.showLivePV = true;
                ME.showPressureAnimation = true;
                ME.recordPressure = true;
                ME.showTemperatureAnimation = true;
                ME.recordTemperature = true;
                ME.showVelocityAnimation = true;
                ME.recordVelocity = true;
                ME.showTurbulenceAnimation = true;
                ME.recordTurbulence = true;
                ME.showConductionAnimation = true;
                ME.recordConductionFlux = true;
                ME.showPressureDropAnimation = true;
                ME.recordPressureDrop = true;
                %new
                ME.recordReynolds = true;
                ME.showReynoldsAnimation = true;

                ME.recordOnlyLastCycle = true;
                ME.recordStatistics = true;
                for i = 1:tests
                    runs(i).isManual = false;
                end
            else
                % if running a single test
                tests = 1;
                crun = struct(...
                    'isManual',true,...
                    'Model',ME.name,...
                    'title',[ME.name ' Test- ' date], ...
                    'NodeFactor',ME.deRefinementFactorInput);
            end

            for Nt = 1:tests
                if nargin > 1
                    % crun = current run
                    crun = runs(Nt);
                    %                     TestSetStatistics(Nt).Name = crun.title; % Matthias
                end
                % If it has a steady state end condition and only the last cycle is
                % ... important then use the Multi-Grid Formulation.
                useTrials = nargin > 1 && crun.SS == true && ME.recordOnlyLastCycle;
                ntrials = 1;

                [status] = mkdir('../Runs',crun.title);
                if status
                    ME.outputPath = ['../Runs/' crun.title];
                else
                    msgbox(['Please create file: ../Runs/' crun.title])
                end

                for trial = 1:ntrials
                    % Only do warmup when starting from scratch
                    do_warmup = (Nt == 1 && trial == 1);

                    ME.resetDiscretization();

                    %% Apply Geometry Modifications
                    if nargin > 1
                        % Uniform Scale Modification
                        if isfield(crun,'Uniform_Scale')
                            % Scale the connections
                            for iGroup = ME.Groups
                                for iCon = iGroup.Connections
                                    iCon.x = iCon.x*crun.Uniform_Scale;
                                end
                                % Scale the positions
                                iGroup.Position.x = iGroup.Position.x*crun.Uniform_Scale;
                                iGroup.Position.y = iGroup.Position.y*crun.Uniform_Scale;
                            end

                            % Scale the bridge offsets
                            for iBridge = ME.Bridges
                                iBridge.x = iBridge.x*crun.Uniform_Scale;
                            end

                            % Scale the mechanisms
                            for iLRM = ME.Converters
                                iLRM.Uniform_Scale(crun.Uniform_Scale);
                            end

                            % Scale the view window
                            XL = get(ME.AxisReference, 'XLim');
                            YL = get(ME.AxisReference, 'YLim');
                            set(ME.AxisReference,'XLim', XL*crun.Uniform_Scale);
                            set(ME.AxisReference,'YLim', YL*crun.Uniform_Scale);


                            % X_Scale Modification (Diameter only)
                        elseif isfield(crun,'X_Scale')
                            % Scale the connections
                            for iGroup = ME.Groups
                                for iCon = iGroup.Connections
                                    if iCon.Orient == enumOrient.Vertical
                                        iCon.x = iCon.x*crun.X_Scale;
                                    end
                                end
                                % Scale the positions
                                iGroup.Position.x = iGroup.Position.x*crun.X_Scale;
                            end

                            % Scale the bridge offsets, for bridges with
                            % horizontal (X) offset
                            for iBridge = ME.Bridges
                                if iBridge.Connection1.Orient == enumOrient.Horizontal...
                                        && iBridge.Connection2.Orient == enumOrient.Horizontal
                                    iBridge.x = iBridge.x*crun.X_Scale;
                                end
                            end

                            %                             % Don't Scale the mechanisms so strokes remain same

                            % For 'Tube Bank' heat exchangers: Scale the
                            % number of tubes with the square of the
                            % diameter.
                            for iGroup = ME.Groups
                                for iBody = iGroup.Bodies
                                    if ~isempty(iBody.Matrix) && isfield(iBody.Matrix.data,'Classification') && strcmp(iBody.Matrix.data.Classification, 'Tube Bank Internal')
                                        iBody.Matrix.data.Number = iBody.Matrix.data.Number*crun.X_Scale^2;
                                    end
                                end
                            end


                            % Scale the view window
                            %                             XL = get(ME.AxisReference, 'XLim');
                            %                             set(ME.AxisReference,'XLim', XL*crun.X_Scale);
                        end

                    end

                    %% Modify Working Gas (Matthias)
                    if nargin > 1
                        if isfield(crun,'Gas')
                            for iGroup = ME.Groups
                                for iBody = iGroup.Bodies
                                    if iBody.matl.Phase == enumMaterial.Gas
                                        GasBAK = iBody.matl.name;
                                        iBody.matl.Configure(crun.Gas);
                                    end
                                end
                            end
                        end
                    end

                    %% Matthias: Modify Regenerator (Woven Screen or Random Fiber)
                    if nargin > 1
                        run_dw_por = isfield(crun,{'Reg_dw','Reg_Porosity'});
                        if any(run_dw_por)
                            for iGroup = ME.Groups
                                for iBody = iGroup.Bodies
                                    if ~isempty(iBody.Matrix)

                                        switch iBody.Matrix.Geometry
                                            case {enumMatrix.WovenScreen, enumMatrix.RandomFiber}
                                                if run_dw_por(1); iBody.Matrix.data.dw = crun.Reg_dw; end
                                                if run_dw_por(2); iBody.Matrix.data.Porosity = crun.Reg_Porosity; end
                                        end
                                    end
                                end
                            end
                        end
                    end

                    %% Run
                    ME.update();

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % This is the tolerance used to detect steady state. To
                    % be considered steady state, the RSS (root sum square)
                    % of the changes/increments in calculated power (as
                    % displayed after each cycle) over the last 5 cycles
                    % (specified by 'ss_cycles') must be smaller than
                    % (ss_tolerance * latest power) or (ss_tolerance),
                    % whatever is larger. This gives a tolerance that
                    % increases propoertionally with power.
                    % Only sst1 is relevant unless using 'trials'
                    % (Multigrid Optimization).

                    sst1 = 0.005; %smaller value for ss_tolerance (default 0.01)
                    sst2 = 0.025; %larger value for ss_tolerance (default 0.025)
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    % Discretize according to the Multigrid Optimization
                    % To use this, must set 'ntrials' to > 1 above
                    if useTrials
                        if isfield(crun,'NodeFactor') && crun.NodeFactor ~= 1
                            islast = true;
                            ss_tolerance = sst1;
                        else
                            if trial == ntrials % 3/3 or 2/2 or 1/1
                                islast = true;
                                ss_tolerance = sst1;
                            else
                                islast = false;
                                if ntrials - trial == 1 % 2/3 or 1/2
                                    crun.NodeFactor = crun.NodeFactor*0.1;
                                    ss_tolerance = sst1;
                                else % 1/3
                                    crun.NodeFactor = crun.NodeFactor*0.001;
                                    ss_tolerance = sst2;
                                end
                            end
                        end
                    else
                        islast = true;
                        ss_tolerance = sst1;
                    end

                    %Matthias: added MeshCounts
                    MeshCounts = ME.discretize(crun);

                    % If discretization was successful
                    if ME.isStateDiscretized
                        % Apply Snapshot
                        % ... Which Snapshot would the user like to use?
                        if ~isempty(ME.SnapShots)
                            names = cell(length(ME.SnapShots)+1,1);
                            if nargin < 2
                                % Have the user pick a starting Snap-Shot
                                for i = 1:length(ME.SnapShots)
                                    names{i} = ME.SnapShots{i}.Name;
                                end
                                names{end} = '... From Scratch';
                                [answer, selectionMade] = listdlg(...
                                    'PromptString','Select a SnapShot',...
                                    'ListString',names,...
                                    'SelectionMode','single',...
                                    'ListSize',[1000 800]); % [W H] Default: [160 300]
                            else
                                % Try to find a snapshot with matching name
                                selectionMade = true;
                                found = false;
                                for i = 1:length(ME.SnapShots)
                                    if strcmp(ME.SnapShots{i}.Name, crun.title)
                                        found = true;
                                        answer = i;
                                        break;
                                    end
                                end

                                % If it did not find a match then take the last one listed
                                if ~found
                                    answer = length(ME.SnapShots);
                                end

                            end

                            % Apply the snapshot if it is selected
                            if selectionMade && answer ~= length(names)
                                %% Comment out below to disable Snapshots %
                                %                                 SS = ME.SnapShots{answer};
                                %                                 ME.assignSnapShot(SS);
                                %                                 disp("Applied Snapshot no. "+answer+"/"+length(ME.SnapShots) +", named '" +SS.Name +"'")
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            end
                        end

                        % Comment Matthias: If set to variable speed and SS-convergence is enabled,
                        % this is a 'dynamic' case. The code below sets speed to constant for a
                        % first run that is used to calculate a load and a snapshot. Then a second
                        % run (further below) with variable speed uses the calculated load &
                        % snapshot to produce a 'cyclic steady state' result with in-cycle speed
                        % variations.
                        % Only works when running from a Test Set!
                        if nargin > 1 && ...
                                crun.movement_option == 'V' && ...
                                crun.SS && ...
                                ME.recordStatistics && ...
                                ME.recordOnlyLastCycle
                            dynamic = true;
                            record_P_backup = ME.recordPressure;
                            record_T_backup = ME.recordTemperature;
                            record_t_backup = ME.recordTurbulence;
                            ME.recordPressure = true;
                            ME.recordTemperature = true;
                            ME.recordTurbulence = true;
                            crun.movement_option = 'C';
                            ss_tolerance = sst1;
                        else
                            dynamic = false;
                        end

                        tic; % starts simulation timer
                        % 'crun' contains run options from test set
                        % 'RunConditions' structure
                        % Matthias: Added cycle_count and final_speed output
                        [ME.Results, success, cycle_count, final_speed, final_power] = ME.Simulations(1).Run(...
                            islast, do_warmup, ss_tolerance, crun);
                        if isempty(ME.Results)
                            ME.CurrentSim(:) = [];
                            ME.Results(:) = [];
                            ME.resetDiscretization();
                            return;
                        end

                        % 2nd run (final transient cycle) for 'dynamic' cases
                        if dynamic
                            % Reset Settings
                            crun.movement_option = 'V';
                            crun.set_Load = mean(ME.Results.Data.Power)/mean(ME.Results.Data.dA);
                            % Save and Reload Snapshot
                            ME.Results.getSnapShot(ME,'Temp');
                            ME.assignSnapShot(ME.SnapShots{end});
                            ME.SnapShots(end) = [];
                            ME.recordPressure = record_P_backup;
                            ME.recordTemperature = record_T_backup;
                            ME.recordTurbulence = record_t_backup;
                            % Run
                            [ME.Results, success, cycle_count, final_speed, final_power] = ME.Simulations(1).Run(...
                                islast, do_warmup, ss_tolerance, crun);
                        end

                        runtime = toc; % reads simulation timer
                        fprintf(['Elapsed time: ' num2str(runtime) 's\n']);

                        % write test set statistics file
                        % Matthias: For test sets, record runtime (s), number of
                        % simulated cycles and speed (Hz) at finish in struct
                        % (In future, may want to save to CSV file to work with more
                        % easily)
                        if isfile('../Runs/TestSetStatistics.mat')
                            load('../Runs/TestSetStatistics.mat');
                        else
                            TestSetStatistics = struct([]);
                        end
                        TestSetStatistics(end+1).Name = crun.title;
                        TestSetStatistics(end).Runtime = runtime;
                        TestSetStatistics(end).Cycle_Count = cycle_count;
                        TestSetStatistics(end).Final_Speed = final_speed;
                        TestSetStatistics(end).Final_Power = final_power;
                        TestSetStatistics(end).GN = MeshCounts.GN;
                        TestSetStatistics(end).SN = MeshCounts.SN;
                        TestSetStatistics(end).EN = MeshCounts.EN;
                        TestSetStatistics(end).GF = MeshCounts.GF;
                        TestSetStatistics(end).SF = MeshCounts.SF;
                        TestSetStatistics(end).MF = MeshCounts.MF;
                        TestSetStatistics(end).EF = MeshCounts.EF;
                        save('../Runs/TestSetStatistics', 'TestSetStatistics');

                        if ~success || isempty(ME.Results); return; end

                        % If it is a recording set then ready the display matricies and
                        %    record everything
                        if islast
                            % Calculate Node Locations
                            if ME.showPressureAnimation || ...
                                    ME.showTemperatureAnimation || ...
                                    ME.showTurbulenceAnimation || ...
                                    ME.showConductionAnimation || ...
                                    ME.showPressureDropAnimation || ...
                                    ME.showReynoldsAnimation
                                cpnts = cell(1,length(ME.Nodes));
                                nodesleft = 0;
                                for Nd = ME.Nodes
                                    if nodesleft == 0
                                        if isa(Nd.Body,'Body')
                                            iGroup = Nd.Body.Group;
                                            Rot = RotMatrix(iGroup.Position.Rot - pi/2);
                                            Trans = [iGroup.Position.x; iGroup.Position.y];
                                            AxisAligned = (iGroup.Position.Rot == pi/2);
                                            nodesleft = length(iGroup.Nodes)-1;
                                        else
                                            Rot = [1 0; 0 1];
                                            Trans = [0; 0];
                                            AxisAligned = true;
                                            % nodesleft = 0;
                                        end
                                    else
                                        nodesleft = nodesleft - 1;
                                    end
                                    % Corner points

                                    % Type 1 (static) ,4 (dynamic): Translation Only
                                    % ... [Type d1x d2x d3x cx ... ]
                                    % ... [ --  d1y d2y d3y cy ... ]
                                    % ... c is the center of the node
                                    % ... d1 is the diagonal between the center and top right corner
                                    % ... d2 is the diagonal between the center and the bottom right corner
                                    % ... d3 is the vector between centers of the ring, (0,0) if node is centered

                                    % Type 2: Stretching in One Direction
                                    % ... [Type cx d1x d2x d3x ... ]
                                    % ... [ --  cy d1y d2y d3y ... ]
                                    % ... c is the bottom left corner
                                    % ... d1 is the vector to the bottom right corner from c
                                    % ... d2 is the vector to the bottom right corner of the other side
                                    % ... ... (0,0) if the node is centered
                                    % ... d3 is the vector to the top left corner

                                    % Type 3: Movement of both ybounds
                                    % ... [Type d1x cx  ... ]
                                    % ... [ --  d1y cy  ... ]
                                    % ... [ --  d2x d3x ... ]
                                    % ... [ --  d2y d3y ... ]
                                    % ... c is the bottom left corner
                                    % ... d1 is the vector to the bottom right corner from c
                                    % ... d2 is the vector to the bottom right corner of the other side
                                    % ... ... (0,0) if the node is centered
                                    % ... d3 is the vector to the top left corner

                                    if isscalar(Nd.ymin)
                                        if isscalar(Nd.ymax)
                                            Type = 1;
                                            if Nd.xmin == 0
                                                pnts = [Type Nd.xmax              Nd.xmax             0  0                 ; ...
                                                    0    (Nd.ymax-Nd.ymin)/2 -(Nd.ymax-Nd.ymin)/2 0 (Nd.ymax+Nd.ymin)/2];
                                            else
                                                pnts = [Type (Nd.xmax-Nd.xmin)/2 (Nd.xmax-Nd.xmin)/2  -(Nd.xmin+Nd.xmax) (Nd.xmax+Nd.xmin)/2; ...
                                                    0    (Nd.ymax-Nd.ymin)/2 -(Nd.ymax-Nd.ymin)/2 0                  (Nd.ymax+Nd.ymin)/2];
                                            end
                                            % Rotate
                                            if ~AxisAligned; pnts(:,2:5) = Rot*pnts(:,2:5); end
                                            pnts(:,5) = pnts(:,5) + Trans;
                                        else
                                            Type = 2;
                                            pnts = zeros(2,4+length(Nd.ymax));
                                            % Nd.ymax is dynamic
                                            if Nd.xmin == 0
                                                pnts(:,1:4) = [Type -Nd.xmax 2*Nd.xmax 0; ...
                                                    0    Nd.ymin  0         0];
                                            else
                                                pnts(:,1:4) = [Type Nd.xmin Nd.xmax-Nd.xmin -Nd.xmax-Nd.xmin; ...
                                                    0    Nd.ymin 0               0               ];
                                            end
                                            pnts(1,5:end) = 0;
                                            pnts(2,5:end) = Nd.ymax - pnts(2,2);
                                            % Rotate
                                            if ~AxisAligned; pnts(:,2:end) = Rot*pnts(:,2:end); end
                                            pnts(:,2) = pnts(:,2) + Trans;
                                        end
                                    else
                                        if isscalar(Nd.ymax)
                                            Type = 2;
                                            pnts = zeros(2,4+length(Nd.ymin));
                                            % Nd.ymin is dynamic
                                            if Nd.xmin == 0
                                                pnts(:,1:4) = [Type -Nd.xmax 2*Nd.xmax 0; ...
                                                    0    Nd.ymax  0         0];
                                            else
                                                pnts(:,1:4) = [Type Nd.xmin Nd.xmax-Nd.xmin -Nd.xmax-Nd.xmin; ...
                                                    0    Nd.ymax 0               0               ];
                                            end
                                            pnts(1,5:end) = 0;
                                            pnts(2,5:end) = Nd.ymin - pnts(2,2);
                                            % Rotate
                                            if ~AxisAligned; pnts(:,2:end) = Rot*pnts(:,2:end); end
                                            pnts(:,2) = pnts(:,2) + Trans;
                                        else
                                            if isfield(Nd.data,'matl'); matl = Nd.data.matl;
                                            else; matl = Nd.Body.matl;
                                            end
                                            if matl.Phase == enumMaterial.Solid
                                                % ... [Type d1x d2x d3x cx ... ]
                                                % ... [ --  d1y d2y d3y cy ... ]
                                                Type = 4; % Stretching is impossible
                                                pnts = zeros(2,4+length(Nd.ymax));
                                                if Nd.xmin == 0
                                                    pnts(:,1:4) = [Type Nd.xmax                    Nd.xmax                   0; ...
                                                        0    (Nd.ymax(1)-Nd.ymin(1))/2 -(Nd.ymax(1)-Nd.ymin(1))/2 0];
                                                    x = 0;
                                                else
                                                    pnts(:,1:4) = [Type (Nd.xmax-Nd.xmin)/2       (Nd.xmax-Nd.xmin)/2        -(Nd.xmin+Nd.xmax); ... (Nd.xmax+Nd.xmin)/2       ; ...
                                                        0    (Nd.ymax(1)-Nd.ymin(1))/2 -(Nd.ymax(1)-Nd.ymin(1))/2 0                 ];% (Nd.ymax+Nd.ymin)/2];
                                                    x = (Nd.xmax+Nd.xmin)/2;
                                                end
                                                pnts(1,5:end) = x;
                                                pnts(2,5:end) = (Nd.ymax+Nd.ymin)/2;
                                                % Rotate
                                                if ~AxisAligned; pnts(:,2:end) = Rot*pnts(:,2:end); end
                                                pnts(:,5:end) = pnts(:,5:end) + Trans;
                                            else
                                                Type = 3; % Stretching is very probable
                                                pnts = zeros(4,2+length(Nd.ymax));
                                                if Nd.xmin == 0
                                                    pnts(:,1:2) = [Type 2*Nd.xmax; ...
                                                        0    0        ; ...
                                                        0    0        ; ...
                                                        0    0        ];
                                                    x = -Nd.xmax;
                                                else
                                                    pnts(:,1:2) = [Type Nd.xmax-Nd.xmin   ; ...
                                                        0    0                 ; ...
                                                        0    -(Nd.xmax+Nd.xmin); ...
                                                        0    0                 ];
                                                    x = Nd.xmin;
                                                end
                                                pnts(1,3:end) = x;
                                                pnts(2,3:end) = Nd.ymin;
                                                pnts(3,3:end) = 0;
                                                pnts(4,3:end) = (Nd.ymax-Nd.ymin);
                                                % Rotate
                                                if ~AxisAligned
                                                    pnts(1:2,2:end) = Rot*pnts(1:2,2:end);
                                                    pnts(3:4,2:end) = Rot*pnts(3:4,2:end);
                                                end
                                                % Translate
                                                pnts(1:2,3:end) = pnts(1:2,3:end) + Trans;
                                            end
                                        end
                                    end
                                    cpnts{Nd.index} = pnts;
                                end
                            end

                            % Calculate Face Locations and directions
                            if isfield(ME.Results.Data,'U') && ME.showPressureDropAnimation
                                if isfield(ME.Results.Data,'U')
                                    fpnts = cell(1,size(ME.Results.Data.U,1));
                                end
                                % Define X,Y,Nx,Ny
                                maxIndex = length(ME.Simulations.Fc_U);
                                if ~isempty(ME.Faces)
                                    if isa(ME.Faces(1).Nodes(1).Body,'Body')
                                        iGroup = ME.Faces(1).Nodes(1).Body.Group;
                                    else
                                        iGroup = ME.Faces(1).Nodes(2).Body.Group;
                                    end
                                    Rot = RotMatrix(iGroup.Position.Rot - pi/2);
                                    Trans = [iGroup.Position.x; iGroup.Position.y];
                                    for Fc = ME.Faces
                                        if Fc.index <= maxIndex
                                            if isa(Fc.Nodes(1).Body,'Environment')
                                                Rot = RotMatrix(0);
                                                Trans = [0; 0];
                                            else
                                                if iGroup ~= Fc.Nodes(1).Body.Group
                                                    iGroup = Fc.Nodes(1).Body.Group;
                                                    Rot = RotMatrix(iGroup.Position.Rot - pi/2);
                                                    Trans = [iGroup.Position.x; iGroup.Position.y];
                                                end
                                            end
                                            i = Fc.index;
                                            if Fc.Nodes(1).Body == Fc.Nodes(2).Body
                                                if Fc.Nodes(1).xmax == Fc.Nodes(2).xmin
                                                    % Aligned horizontally
                                                    x = Fc.Nodes(1).xmax;
                                                    y = (Fc.Nodes(1).ymin + Fc.Nodes(1).ymax)/2;
                                                    Nx = 1;
                                                    Ny = 0;
                                                elseif Fc.Nodes(1).xmin == Fc.Nodes(2).xmax
                                                    % Aligned horizontally
                                                    x = Fc.Nodes(1).xmin;
                                                    y = (Fc.Nodes(1).ymin + Fc.Nodes(1).ymax)/2;
                                                    Nx = -1;
                                                    Ny = 0;
                                                elseif abs(Fc.Nodes(1).ymax(1) - Fc.Nodes(2).ymin(1)) < ...
                                                        abs(Fc.Nodes(1).ymin(1) - Fc.Nodes(2).ymax(1))
                                                    % Aligned Vertically
                                                    x = (Fc.Nodes(1).xmin + Fc.Nodes(1).xmax)/2;
                                                    y = Fc.Nodes.ymax;
                                                    Nx = 0;
                                                    Ny = 1;
                                                else
                                                    % Aligned Vertically
                                                    x = (Fc.Nodes(1).xmin + Fc.Nodes(1).xmax)/2;
                                                    y = Fc.Nodes.ymin;
                                                    Nx = 0;
                                                    Ny = -1;
                                                end
                                            else
                                                if Fc.Nodes(1).xmax == Fc.Nodes(2).xmin
                                                    % Aligned horizontally
                                                    x = Fc.Nodes(1).xmax; % Done
                                                    y = getCenterOfOverlapRegion(...
                                                        Fc.Nodes(1).ymin,...
                                                        Fc.Nodes(2).ymin,...
                                                        Fc.Nodes(1).ymax,...
                                                        Fc.Nodes(2).ymax);
                                                    Nx = 1; % Done
                                                    Ny = 0; % Done
                                                elseif Fc.Nodes(1).xmin == Fc.Nodes(2).xmax
                                                    % Aligned horizontally
                                                    x = Fc.Nodes(1).xmin; % Done
                                                    y = getCenterOfOverlapRegion(...
                                                        Fc.Nodes(1).ymin,...
                                                        Fc.Nodes(2).ymin,...
                                                        Fc.Nodes(1).ymax,...
                                                        Fc.Nodes(2).ymax);
                                                    Nx = -1; % Done
                                                    Ny = 0; % Done
                                                elseif abs(Fc.Nodes(1).ymax(1) - Fc.Nodes(2).ymin(1)) < ...
                                                        abs(Fc.Nodes(1).ymin(1) - Fc.Nodes(2).ymax(1))
                                                    % Aligned Vertically
                                                    x = getCenterOfOverlapRegion(...
                                                        Fc.Nodes(1).xmin,...
                                                        Fc.Nodes(2).xmin,...
                                                        Fc.Nodes(1).xmax,...
                                                        Fc.Nodes(2).xmax);
                                                    y = Fc.Nodes(1).ymax; % Done
                                                    Nx = 0; % Done
                                                    Ny = 1; % Done
                                                else
                                                    % Aligned Vertically
                                                    x = getCenterOfOverlapRegion(...
                                                        Fc.Nodes(1).xmin,...
                                                        Fc.Nodes(2).xmin,...
                                                        Fc.Nodes(1).xmax,...
                                                        Fc.Nodes(2).xmax);
                                                    y = Fc.Nodes(1).ymin; % Done
                                                    Nx = 0; % Done
                                                    Ny = -1; % Done
                                                end
                                            end
                                            if isscalar(y)
                                                fpnts{i} = Rot*[Nx x; Ny y] + [[0;0] Trans];
                                            else
                                                fpnts{i} = [Rot*[Nx; Ny] Rot*[x(ones(1,length(y))); y]+Trans];
                                            end
                                        end
                                    end
                                end
                            end

                            % Calculate Solid Body Boundaries
                            n = 0;
                            for iGroup = ME.Groups
                                for iBody = iGroup.Bodies
                                    if iBody.matl.Phase == enumMaterial.Solid
                                        n = n + 1;
                                    end
                                end
                            end
                            bpnts = cell(1,n);
                            n = 1;
                            for iGroup = ME.Groups
                                Rot = RotMatrix(iGroup.Position.Rot - pi/2);
                                Trans = [iGroup.Position.x; iGroup.Position.y];
                                for iBody = iGroup.Bodies
                                    if iBody.matl.Phase == enumMaterial.Solid
                                        [~,~,x1,x2] = iBody.limits(enumOrient.Vertical);
                                        [y1,y2,~,~] = iBody.limits(enumOrient.Horizontal);
                                        if isscalar(y1) %&& isscalar(y2)
                                            if x1 == 0
                                                bpnts{n} = Rot*[-x2 x2 x2 -x2; y1 y1 y2 y2] + Trans;
                                            else
                                                bpnts{n} = Rot*[x1 x2 x2 x1; y1 y1 y2 y2] + Trans;
                                                n = n + 1;
                                                bpnts{n} = Rot*[-x1 -x2 -x2 -x1; y1 y1 y2 y2] + Trans;
                                            end
                                        else
                                            bpnts{n} = zeros(2,4,length(y1));
                                            if x1 == 0
                                                for i = 1:length(y1)
                                                    bpnts{n}(:,:,i) = ...
                                                        Rot*[-x2 x2 x2 -x2; y1(i) y1(i) y2(i) y2(i)] + Trans;
                                                end
                                            else
                                                for i = 1:length(y1)
                                                    bpnts{n}(:,:,i) = ...
                                                        Rot*[x1 x2 x2 x1; y1(i) y1(i) y2(i) y2(i)] + Trans;
                                                end
                                                n = n + 1;
                                                bpnts{n} = zeros(2,4,length(y1));
                                                for i = 1:length(y1)
                                                    bpnts{n}(:,:,i) = ...
                                                        Rot*[-x1 -x2 -x2 -x1; y1(i) y1(i) y2(i) y2(i)] + Trans;
                                                end
                                            end
                                        end
                                        n = n + 1;
                                    end
                                end
                            end

                            % Animate
                            frate = ME.animationFrameTime;
                            if isfield(ME.Results.Data,'P') && ME.showPressureAnimation
                                ME.Results.animateNode('P',cpnts,bpnts,frate,[],[],crun.title,ME.AxisReference);
                            end
                            if isfield(ME.Results.Data,'T') && ME.showTemperatureAnimation
                                ME.Results.animateNode('T',cpnts,bpnts,frate,[],[],crun.title,ME.AxisReference);
                            end
                            if isfield(ME.Results.Data,'U') && ME.showVelocityAnimation
                                ME.Results.animateFace('U',fpnts,bpnts,frate,[],[],crun.title,ME.AxisReference);
                            end
                            if isfield(ME.Results.Data,'turb') && ME.showTurbulenceAnimation
                                ME.Results.animateNode('turb',cpnts,bpnts,frate,[],[],crun.title,ME.AxisReference);
                            end
                            if isfield(ME.Results.Data,'cond') && ME.showConductionAnimation
                                ME.Results.animateNode('cond',cpnts,bpnts,frate,[],[],crun.title,ME.AxisReference);
                            end
                            if isfield(ME.Results.Data,'dP') && ME.showPressureDropAnimation
                                ME.Results.animateNode('dP',cpnts,bpnts,frate,[],[],crun.title,ME.AxisReference);
                            end
                            %new
                            if isfield(ME.Results.Data,'RE') && ME.showReynoldsAnimation
                                ME.Results.animateNode('RE',cpnts,bpnts,frate,[],[],crun.title,ME.AxisReference);
                            end

                        end

                        % Ask if the user would like to save a snapshot
                        if nargin > 1
                            if ~ME.Simulations(1).stop
                                % Remove the snapshot as it will be replaced now
                                for i = 1:length(ME.SnapShots)
                                    if strcmp(ME.SnapShots{i}.Name, crun.title)
                                        ME.SnapShots(i) = [];
                                        break;
                                    end
                                end
                                ME.Results.getSnapShot(ME,crun.title);
                                saveME(ME);
                            end
                        else
                            response = questdlg('Would you like to save a SnapShot?', ...
                                'Save SnapShot','Yes','No','Yes');
                            if strcmp(response,'Yes')
                                ME.Results.getSnapShot(ME,getProperName('SnapShot'));
                            end
                        end
                    end

                    %% Undo Geometry Modifications
                    if nargin > 1
                        % Uniform Scale Modification
                        if isfield(crun,'Uniform_Scale')
                            % Scale the connections
                            for iGroup = ME.Groups
                                for iCon = iGroup.Connections
                                    iCon.x = iCon.x/crun.Uniform_Scale;
                                end
                                % Scale the positions
                                iGroup.Position.x = iGroup.Position.x/crun.Uniform_Scale;
                                iGroup.Position.y = iGroup.Position.y/crun.Uniform_Scale;
                            end

                            % Scale the bridge offsets
                            for iBridge = ME.Bridges
                                iBridge.x = iBridge.x/crun.Uniform_Scale;
                            end

                            % Scale the mechanisms
                            for iLRM = ME.Converters
                                iLRM.Uniform_Scale(1/crun.Uniform_Scale);
                            end

                            % Scale the view window
                            set(ME.AxisReference, ...
                                'XLim',get(ME.AxisReference, 'XLim')/crun.Uniform_Scale);
                            set(ME.AxisReference, ...
                                'YLim',get(ME.AxisReference, 'YLim')/crun.Uniform_Scale);


                            % Undo X_Scale Modification
                        elseif isfield(crun,'X_Scale')
                            % Scale the connections
                            for iGroup = ME.Groups
                                for iCon = iGroup.Connections
                                    if iCon.Orient == enumOrient.Vertical
                                        iCon.x = iCon.x/crun.X_Scale;
                                    end
                                end
                                % Scale the positions
                                iGroup.Position.x = iGroup.Position.x/crun.X_Scale;
                            end

                            % Scale the bridge offsets, for bridges with
                            % horizontal (X) offset
                            for iBridge = ME.Bridges
                                if iBridge.Connection1.Orient == enumOrient.Horizontal...
                                        && iBridge.Connection2.Orient == enumOrient.Horizontal
                                    iBridge.x = iBridge.x/crun.X_Scale;
                                end
                            end

                            % For 'Tube Bank' heat exchangers: Scale the
                            % number of tubes with the square of the
                            % diameter.
                            for iGroup = ME.Groups
                                for iBody = iGroup.Bodies
                                    if ~isempty(iBody.Matrix) && isfield(iBody.Matrix.data,'Classification') && strcmp(iBody.Matrix.data.Classification, 'Tube Bank Internal')
                                        iBody.Matrix.data.Number = iBody.Matrix.data.Number/crun.X_Scale^2;
                                    end
                                end
                            end

                            % Scale the view window
                            %                             XL = get(ME.AxisReference, 'XLim');
                            %                             set(ME.AxisReference,'XLim', XL/crun.X_Scale);
                        end

                        % Undo Gas modification
                        if isfield(crun,'Gas')
                            for iGroup = ME.Groups
                                for iBody = iGroup.Bodies
                                    if iBody.matl.Phase == enumMaterial.Gas
                                        iBody.matl.Configure(GasBAK);
                                    end
                                end
                            end
                        end


                        % To save the modified geometry
                        saveME(ME);
                    end
                end
            end
            ME.outputPath = backup_path;
            ME.CurrentSim(:) = [];
            ME.Results(:) = [];
            ME.resetDiscretization();
        end
        %%
        function assignSnapShot(ME, SS)
            Sim = ME.Simulations;
            for iGroup = ME.Groups
                for iBody = iGroup.Bodies
                    for BData = SS.Data
                        if iBody.ID == BData.ID
                            if applyBody(BData,iBody)
                                if iBody.matl.Phase == enumMaterial.Solid
                                    for Nd = iBody.Nodes
                                        i = Nd.index;
                                        if isnan(Nd.data.T)
                                            fprintf('err detected');
                                        else
                                            Sim.T(i) = Nd.data.T;
                                        end
                                    end
                                else
                                    for Nd = iBody.Nodes
                                        i = Nd.index;
                                        if isfield(Nd.data,'matl')
                                            matl = Material(Nd.data.matl.name);
                                        else
                                            matl = Material(Nd.Body.matl.name);
                                        end
                                        if i <= length(Sim.P)
                                            if isfield(Nd.data,'P') && ~isnan(Nd.data.P)
                                                P = Nd.data.P;
                                            else
                                                P = ME.enginePressure;
                                                for j = 1:length(Sim.Regions)
                                                    if any(Sim.Regions{j} == i)
                                                        if Sim.isEnvironmentRegion(j)
                                                            P = Sim.P(end);
                                                        end
                                                        break;
                                                    end
                                                end
                                            end
                                            if isfield(Nd.data,'T')
                                                if isnan(Nd.data.T)
                                                    fprintf('err detected');
                                                else
                                                    Sim.T(i) = Nd.data.T;
                                                end
                                            end
                                            if isfield(Nd.data,'Turb')
                                                if isnan(Nd.data.Turb)
                                                    fprintf('err detected');
                                                else
                                                    Sim.turb(i) = Nd.data.Turb;
                                                end
                                            end
                                            if ~isnan(P)
                                                vol = Nd.vol();
                                                % Need to figure out what gas constant to
                                                % ... use
                                                Rgas = matl.R;
                                                Sim.m(i) = P*vol(1)/(Rgas*Sim.T(i));
                                            end
                                        else
                                            if isnan(Nd.data.T)
                                                fprintf('err detected');
                                            else
                                                Sim.T(i) = Nd.data.T;
                                            end
                                        end
                                        if matl.Phase == enumMaterial.Gas
                                            Sim.u(i) = matl.initialInternalEnergy(Sim.T(i));
                                        end
                                    end
                                end
                            end
                            break;
                        end
                    end
                end
            end
        end

        function saveME(Model)
            Model.Faces(:) = [];
            Model.Nodes(:) = [];
            Model.Simulations(:) = [];
            Model.CurrentSim(:) = [];
            Model.Results(:) = [];
            Model.PressureContacts(:) = [];
            Model.ShearContacts(:) = [];
            for iPV = Model.PVoutputs
                iPV.reset();
            end
            for iSense = Model.Sensors
                if ~isempty(iSense)
                    iSense.reset();
                    iSense.GUIObjects(:) = [];
                end
            end
            backupAxis = Model.AxisReference;
            Model.AxisReference(:) = [];
            for iGroup = Model.Groups
                for iBody = iGroup.Bodies
                    iBody.GUIObjects(:) = [];
                    iBody.Nodes(:) = [];
                    iBody.Faces(:) = [];
                    if ~isempty(iBody.Matrix)
                        iBody.Matrix.Nodes(:) = [];
                        iBody.Matrix.Faces(:) = [];
                    end
                end
                for iCon = iGroup.Connections
                    iCon.GUIObjects(:) = [];
                    iCon.Faces(:) = [];
                    iCon.NodeContacts(:) = [];
                end
                iGroup.GUIObjects(:) = [];
            end
            for iBridge = Model.Bridges
                iBridge.GUIObjects(:) = [];
                iBridge.Faces(:) = [];
            end
            save(['Saved Files\' Model.name '.mat'],'Model');
            Model.AxisReference = backupAxis;
            fprintf('Model Saved.\n');
        end

        %% Interface / Find stuff
        function FindGroup(this,Pos)
            TheGroup = this.findNearestGroup(Pos,inf);
            this.HighLight(TheGroup);
        end
        function distributeGroup(this, GroupSpacing)
            % Take existing horizontal order and distribute
            for i = 1:length(this.Groups)
                for j = i+1:length(this.Groups)
                    if this.Groups(j).Position.x < this.Groups(i).Position.x
                        tempGroup = this.Groups(i);
                        this.Groups(i) = this.Groups(j);
                        this.Groups(j) = tempGroup;
                    end
                end
            end
            x = 0;
            for iGroup = this.Groups
                iGroup.Position.x = x;
                dim1 = RotMatrix(iGroup.Position.Rot-pi/2)*[iGroup.Width*2; iGroup.Height];
                dim2 = RotMatrix(iGroup.Position.Rot-pi/2)*[iGroup.Width*2; -iGroup.Height];
                x = x + max([dim1(1) dim2(1)])+GroupSpacing;
            end
        end
        function [names, objects] = findNearest(this,Pnt,Tolerance)
            objects = cell(0);
            names = cell(0);
            % Find, within a radius of confidence, the nearest...
            %   Body, Group, Connection, Bridge and Leak Connection
            Tolerance = Tolerance^2;
            index = 1;
            %% Group
            if isempty(this.ActiveGroup)
                obj = this.findNearestGroup(Pnt,Tolerance);
                if ~isempty(obj)
                    objects{index} = obj;
                    names{index} = obj.name;
                    index = index + 1;
                end
                TheGroup = obj;
            else
                TheGroup = this.ActiveGroup;
                objects{index} = TheGroup;
                names{index} = TheGroup.name;
                index = index + 1;
            end

            %% Body
            mindist = Tolerance;
            Pntmod = (RotMatrix(pi/2 - TheGroup.Position.Rot)*Pnt') - ...
                [TheGroup.Position.x; TheGroup.Position.y];
            for iBody = TheGroup.Bodies
                % Establish Rectangle of iBody
                [~,~,x1,x2] = iBody.limits(enumOrient.Vertical);
                [~,~,y1,y2] = iBody.limits(enumOrient.Horizontal);

                R.Width = x2-x1;
                R.Height = y2-y1;
                R.Cx = (x1+x2)/2;
                R.Cy = (y1+y2)/2;
                dist = Dist2Rect(Pntmod(1),Pntmod(2),R.Cx,R.Cy,R.Width,R.Height);
                if dist < mindist
                    mindist = dist;
                    TheBody = iBody;
                else
                    R.Cx = -R.Cx;
                    dist = Dist2Rect(...
                        Pntmod(1),Pntmod(2),R.Cx,R.Cy,R.Width,R.Height);
                    if dist < mindist
                        mindist = dist;
                        TheBody = iBody;
                    end
                end
            end
            if mindist < Tolerance
                objects{index} = TheBody;
                names{index} = TheBody.name;
                index = index + 1;
            end

            %% Connection
            mindist = Tolerance;
            Pntmod = (RotMatrix(pi/2 - TheGroup.Position.Rot)*Pnt') - ...
                [TheGroup.Position.x; TheGroup.Position.y];
            for iConnection = TheGroup.Connections
                % Find nearest Connection
                switch iConnection.Orient
                    case enumOrient.Vertical
                        % Two lines to test
                        if abs(Pntmod(1) - iConnection.x) < mindist
                            mindist = abs(Pntmod(1) - iConnection.x);
                            TheConnection = iConnection;
                        end
                        if abs(Pntmod(1) + iConnection.x) < mindist
                            mindist = abs(Pntmod(1) + iConnection.x);
                            TheConnection = iConnection;
                        end
                    case enumOrient.Horizontal
                        % One line to test
                        if abs(Pntmod(2) - iConnection.x) < mindist
                            mindist = abs(Pntmod(2)-iConnection.x);
                            TheConnection = iConnection;
                        end
                end
            end
            if mindist < Tolerance
                objects{index} = TheConnection;
                names{index} = TheConnection.name;
                index = index + 1;
            end

            %% Bridge
            mindist = Tolerance;
            for iBridge = this.Bridges

            end

            %% Leak Connection
            mindist = Tolerance;
            for iLeakCon = this.LeakConnections

            end
        end
        function [TheGroup] = findNearestGroup(this,Pos,Tolerance)
            try Pnt = Pos(1,1:2);
            catch
                try Pnt = Pos(1:2,1)';
                catch; msgbox('Group Not Found due to improper input coordinates');
                end
            end
            [iBody, mindist] = this.findNearestBody(Pnt,Tolerance);
            for iGroup = this.Groups
                if isempty(iGroup.Bodies)
                    if mindist > Dist2Rect(Pnt(1),Pnt(2),iGroup.Position.x,iGroup.Position.y,0,0)
                        TheGroup = iGroup;
                        return;
                    end
                end
            end
            if ~isempty(iBody)
                TheGroup = iBody.Group;
            else
                TheGroup = this.Groups(1);
            end
        end
        function [TheBody, mindist] = findNearestBody(this,Pnt,Tolerance)
            mindist = Tolerance;
            TheBody = Body.empty;
            for iGroup = this.Groups
                Pntmod = (RotMatrix(pi/2 - iGroup.Position.Rot)*Pnt') - ...
                    [iGroup.Position.x; iGroup.Position.y];
                for iBody = iGroup.Bodies
                    % Establish Rectangle of iBody
                    [~,~,x1,x2] = iBody.limits(enumOrient.Vertical);
                    [~,~,y1,y2] = iBody.limits(enumOrient.Horizontal);

                    R.Width = x2-x1;
                    R.Height = y2-y1;
                    R.Cx = (x1+x2)/2;
                    R.Cy = (y1+y2)/2;
                    dist = Dist2Rect(Pntmod(1),Pntmod(2),R.Cx,R.Cy,R.Width,R.Height);
                    if dist < mindist
                        mindist = dist;
                        TheBody = iBody;
                    else
                        R.Cx = -R.Cx;
                        dist = Dist2Rect(...
                            Pntmod(1),Pntmod(2),R.Cx,R.Cy,R.Width,R.Height);
                        if dist < mindist
                            mindist = dist;
                            TheBody = iBody;
                        end
                    end
                end
            end
        end
        function [names, objects] = findFrames(this)
            for i = length(this.RefFrames):-1:1
                names{i} = this.RefFrames(i).name;
                objects{i} = this.RefFrames(i);
            end
        end

        %% Graphics
        % Tests
        function isInWindow = inWindow(this,pnt1,pnt2)
            if nargin == 2
                if isempty(this.AxisReference)
                    this.AxisReference = gca;
                    axes = this.AxisReference;
                else
                    axes = this.AxisReference;
                end
                xlim = axes.XLim;
                ylim = axes.YLim;
                isInWindow = pnt1.x < xlim(2) && pnt1.x > xlim(1) && ...
                    pnt1.y < ylim(2) && pnt1.y > ylim(1);
            elseif nargin == 3
                xlim = this.AxisReference.XLim;
                ylim = this.AxisReference.YLim;
                isInWindow = pnt1.x < xlim(2) && pnt1.x > xlim(1) && ...
                    pnt1.y < ylim(2) && pnt1.y > ylim(1) && ...
                    pnt2.x < xlim(2) && pnt2.x > xlim(1) && ...
                    pnt2.y < ylim(2) && pnt2.y > ylim(1);
            end
        end
        function showOptions = produceShowOptions(this,showOptions)
            if nargin > 1 && length(showOptions) == 9
                this.showGroups = showOptions(1); % Groups
                if ~showOptions(2) && showOptions(2) ~= this.showBodies
                    for iGroup = this.Groups
                        for iBody = iGroup.Bodies
                            iBody.removeFromFigure(this.AxisReference);
                        end
                    end
                end
                this.showBodies = showOptions(2); % Bodies
                if ~showOptions(3) && showOptions(3) ~= this.showConnections
                    for iGroup = this.Groups
                        for iCon = iGroup.Connections
                            iCon.removeFromFigure(this.AxisReference);
                        end
                    end
                end
                this.showConnections = showOptions(3); % Connections
                if ~showOptions(4) && showOptions(4) ~= this.showLeaks
                    for iLeak = this.LeakConnections
                        iLeak.removeFromFigure(this.AxisReference);
                    end
                end
                this.showLeaks = showOptions(4); % Leaks
                if ~showOptions(5) && showOptions(5) ~= this.showBridges
                    for iBridge = this.Bridges
                        iBridge.removeFromFigure(this.AxisReference);
                    end
                end
                this.showBridges = showOptions(5); % Bridges
                % Already deleted
                this.showInterConnections = showOptions(6); % Node Connections
                % Already deleted
                this.showEnvironmentConnections = showOptions(7); % Environment Surround
                % Already deleted
                this.showBodyGhosts = showOptions(8); % Motion Ghosts
                % ?????
                this.showNodes = showOptions(9); % Node Outlines
            elseif nargin > 1 && ~isempty(showOptions)
                fprintf('XXX showOptions in "Model.show" should be a vector of length 9 containing logical show conditions XXX\n');
                return;
            else
                % Define showOptions;
                showOptions = zeros(8,1);
                showOptions(1) = this.showGroups;
                showOptions(2) = this.showBodies;
                showOptions(3) = this.showConnections;
                showOptions(4) = this.showLeaks;
                showOptions(5) = this.showBridges;
                showOptions(6) = this.showInterConnections;
                showOptions(7) = this.showEnvironmentConnections;
                showOptions(8) = this.showBodyGhosts;
                showOptions(9) = this.showNodes;
            end
        end

        % Highlighting and Selecting
        function ActiveGroup = get.ActiveGroup(this)
            ActiveGroup = [];
            for obj = this.Selection
                if isa(obj{1},'Group')
                    ActiveGroup = obj{1};
                    return;
                end
            end
        end
        function switchHighLightedGroup(this,otherGroup)
            update(this);
            if ~isempty(otherGroup) && isvalid(otherGroup)
                for i = 1:length(this.Selection)
                    if isa(this.Selection{i},'Group')
                        this.Selection{i}.isActive = false;
                        this.Selection{i} = otherGroup;
                        otherGroup.isActive = true;
                    end
                end
            end
        end
        function switchHighLighting(this,NewHighlightedObjects)
            update(this);
            this.clearHighLighting();
            for iObj = NewHighlightedObjects
                iObj.isActive = true;
                this.Selection{end+1} = iObj;
            end
        end
        function HighLight(this,HighlightedObjects)
            update(this);
            for iObj = HighlightedObjects
                iObj.isActive = true;
                this.Selection{end+1} = iObj;
            end
        end
        function clearHighLighting(this)
            update(this);
            i = 1; j = 0;
            for iObj = this.Selection
                if ~isa(iObj,'Group')
                    iObj{1}.isActive = false; %#ok<FXSET>
                else; j = i;
                end
                i = i + 1;
            end
            if j > 0; this.Selection = {this.Selection{j}};
            else; this.Selection = cell(0);
            end
        end

        % Bulk Display
        function XLim = getXLim(this)
            XLim = [inf -inf];
            for iGroup = this.Groups
                w = iGroup.Width;
                h = iGroup.Height;
                dx = w/2*sin(iGroup.Position.Rot);
                dy = h*cos(iGroup.Position.Rot);
                lim = iGroup.Position.x + [dx dx+dy -dx -dx+dy];
                limmx = max(lim);
                limmn = min(lim);
                if limmx > XLim(2); XLim(2) = limmx; end
                if limmn < XLim(1); XLim(1) = limmn; end
            end
        end
        function YLim = getYLim(this)
            YLim = [inf -inf];
            for iGroup = this.Groups
                w = iGroup.Width;
                h = iGroup.Height;
                dx = w/2*cos(iGroup.Position.Rot);
                dy = h*sin(iGroup.Position.Rot);
                lim = iGroup.Position.y + [dx dx+dy -dx -dx+dy];
                limmx = max(lim);
                limmn = min(lim);
                if limmx > YLim(2); YLim(2) = limmx; end
                if limmn < YLim(1); YLim(1) = limmn; end
            end
        end
        function removeStaticFromFigure(this)
            if ~isempty(this.StaticGUIObjects)
                children = get(this.AxisReference,'Children');
                for j = 1:length(this.StaticGUIObjects)
                    if isgraphics(this.StaticGUIObjects(j))
                        for i = length(children):-1:1
                            if isgraphics(children(i)) && children(i) == this.StaticGUIObjects(j)
                                children(i).delete;
                                break;
                            end
                        end
                    end
                end
                this.StaticGUIObjects = [];
            end
        end
        function removeDynamicFromFigure(this)
            if ~isempty(this.DynamicGUIObjects)
                children = get(this.AxisReference,'Children');
                for j = 1:length(this.DynamicGUIObjects)
                    if isgraphics(this.DynamicGUIObjects(j))
                        for i = length(children):-1:1
                            if isgraphics(children(i)) && children(i) == this.DynamicGUIObjects(j)
                                children(i).delete;
                                break;
                            end
                        end
                    end
                end
                this.DynamicGUIObjects = [];
            end
        end
        function removeGhostFromFigure(this)
            if ~isempty(this.GhostGUIObjects)
                children = get(this.AxisReference,'Children');
                for obj = this.GhostGUIObjects
                    if isgraphics(obj)
                        for i = length(children):-1:1
                            if isgraphics(children(i)) && children(i) == obj
                                children(i).delete;
                                break;
                            end
                        end
                    end
                end
                this.DynamicGUIObjects = [];
            end
        end
        function bringGhostToFront(this)
            if ~isempty(this.GhostGUIObjects)
                children = get(this.AxisReference,'Children');
                END = length(children);
                for obj = this.GhostGUIObjects
                    if isgraphics(obj)
                        for i = END:-1:1
                            if isgraphics(children(i)) && children(i) == obj
                                uistack(obj,'top');
                                break;
                            end
                        end
                    end
                end
            end
        end

        %% For showing elements in GUI. Edited by Matthias.
        function show(this,showOptions)
            if this.isChanged; this.update(); end
            this.removeStaticFromFigure();
            this.removeGhostFromFigure();
            if nargin > 1
                showOptions = this.produceShowOptions(showOptions);
            else
                showOptions = this.produceShowOptions();
            end
            %showOptions = [inputshowGroup,inputshowBodies,inputshowConnections,ishowLeaks,ishowBridges,ishowIntCon,ishowEnvirCon)]
            % Fig = get(this.AxisReference,'parent');
            % hP = pan(Fig);
            % Go down through the hierarchy
            for iGroup = this.Groups
                % show(this,CODE,AxisReference,Inc,showGroups,showBodies,showConnections,showLeaks,showInterConnections,showEnvironmentConnections)
                iGroup.show('all',this.AxisReference,0,showOptions);
                % showGroups showBodies showConnections showLeaks showBridges showInterConnections showEnvironmentConnections]
            end

            if this.showInterConnections || this.showNodes || this.showNodeBounds
                % if condition below added by Matthias to prevent wait for discretization each time view is changed.
                if ~this.isDiscretized()
                    crun = struct('Model',this.name,...
                        'title',[this.name ' test: ' date],...
                        'rpm',this.engineSpeed,...
                        'NodeFactor',this.deRefinementFactorInput);
                    this.discretize(crun);
                end
                if ~this.isDiscretized()
                    fprintf('XXX No Nodes generated. XXX\n');
                end
                n = length(this.Nodes);
                if n ~= 0
                    nodeCenter(n) = Pnt2D(0,0);
                    %Matthias: Added node bounds to plot nodes as boxes
                    % Size = 6 for: 4 points of rectangle, ending with 1st point to close it,
                    % and a NaN
                    nodeBoundsX = NaN(6,n);
                    nodeBoundsY = NaN(6,n);
                    for iNode = this.Nodes
                        nodeCenter(iNode.index) = iNode.minCenterCoords;
                        % Take min of y values since ymin/ymax are vectors
                        % for variable volume nodes.
                        % to be used by 'line' function. One 'NaN' after
                        % each line so that separate lines will be drawn.
                        nodeBoundsX(:,iNode.index) = [iNode.xmin iNode.xmin...
                            iNode.xmax iNode.xmax iNode.xmin NaN]';
                        nodeBoundsY(:,iNode.index) = [min(iNode.ymin) min(iNode.ymax)...
                            min(iNode.ymax) min(iNode.ymin) min(iNode.ymin) NaN]';
                        isVis(iNode.index) = this.inWindow(nodeCenter(iNode.index));
                    end
                end
            end

            if this.showInterConnections % Show Inter-Node Connections
                if this.isDiscretized()
                    % Make array of Node Centers
                    % Count nodes, stored in Groups
                    n = length(this.Nodes);
                    if n ~= 0
                        % Make array of face coords
                        % Count faces, stored in Model
                        n = length(this.Faces);
                        faceCoord = zeros(4,n);
                        n = 1;
                        % Take each face, assess whether it is active, then record
                        for iFace = this.Faces
                            if ~(iFace.Nodes(1).Type == enumNType.EN || ...
                                    iFace.Nodes(2).Type == enumNType.EN)
                                if iFace.Nodes(2).index < 1
                                    fprintf('XXX error XXX');
                                end
                                % Matthias: Added 'if' below to allow plotting faces of specific type only.
                                % Types: Solid Gas Mix Leak
                                %                                 if iFace.Type == enumFType.MatrixTransition
                                % Matthias: Added conditions to show only faces selected in GUI
                                facetypes = {};
                                if this.showFacesGas; facetypes{end+1} = enumFType.Gas; end
                                if this.showFacesSolid; facetypes{end+1} = enumFType.Solid; end
                                if this.showFacesMix; facetypes{end+1} = enumFType.Mix; end
                                if this.showFacesLeak; facetypes{end+1} = enumFType.Leak; end
                                if this.showFacesMatrixTransition; facetypes{end+1} = enumFType.MatrixTransition; end
                                if this.showFacesEnvironment; facetypes{end+1} = enumFType.Environment; end

                                switch iFace.Type
                                    case facetypes
                                        if isVis(iFace.Nodes(1).index) && ...
                                                isVis(iFace.Nodes(2).index)
                                            c1 = nodeCenter(iFace.Nodes(1).index);
                                            c2 = nodeCenter(iFace.Nodes(2).index);
                                            faceCoord(:,n) = [c1.x,c2.x,c1.y,c2.y];
                                            n = n + 1;
                                        end
                                        %                                 end
                                end
                            end
                        end
                        n = n - 1;

                        % Plot
                        nT = 3*n;
                        xData = NaN(nT,1);
                        yData = NaN(nT,1);
                        ind = 1;
                        for i = 1:3:nT-2
                            xData(i:i+1) = faceCoord(1:2,ind);
                            yData(i:i+1) = faceCoord(3:4,ind);
                            ind = ind + 1;
                        end
                        if isempty(this.StaticGUIObjects)
                            this.StaticGUIObjects = line(xData,yData,'Color',[0 1 0]);
                        else
                            this.StaticGUIObjects(end+1:end+length(this.Faces)) = line(xData,yData,'Color',[0 1 0]);
                        end
                    end
                end
                clear xData yData
            end

            % Prepare for showing node centerpoints and outlines
            if this.showNodes || this.showNodeBounds
                if this.isDiscretized()
                    % Make array of Node Centers
                    % Count nodes, stored in Groups
                    n = length(this.Nodes);
                    if n ~= 0
                        % create structs to hold point data separated by Node type
                        xData(n).SN = [];
                        xData(n).SVGN = [];
                        xData(n).VVGN = [];
                        xData(n).SAGN = [];
                        xData(n).EN = [];
                        yData = xData;
                        xBoundsData = xData;
                        yBoundsData = xData;

                        % Define colors for node circles and outlines
                        colors = struct(...
                            'SN',[1 0 0],...
                            'SVGN',[0 0 1],...
                            'VVGN',[1 0 1],... % magenta
                            'SAGN',[0 1 1],... % light blue
                            'EN',[0 1 0]);

                        % Define circle sizes
                        sizes = struct(...
                            'SN', 2,...
                            'SVGN', 5,...
                            'VVGN', 5,...
                            'SAGN', 5,...
                            'EN', 10);

                        % Matthias: Added functionality to plot nodes in different colors based on node type.
                        j = 1;
                        for nd = this.Nodes
                            if isVis(nd.index)
                                c1 = nodeCenter(nd.index);
                                if nd.Type == enumNType.SN % Solid node
                                    xData(j).SN = c1.x;
                                    yData(j).SN = c1.y;
                                    xBoundsData(j).SN = nodeBoundsX(:,nd.index);
                                    yBoundsData(j).SN = nodeBoundsY(:,nd.index);
                                elseif nd.Type == enumNType.SVGN % Static Volume Gas Node
                                    xData(j).SVGN = c1.x;
                                    yData(j).SVGN = c1.y;
                                    xBoundsData(j).SVGN = nodeBoundsX(:,nd.index);
                                    yBoundsData(j).SVGN = nodeBoundsY(:,nd.index);
                                elseif nd.Type == enumNType.VVGN % Variable Volume Gas Node
                                    xData(j).VVGN = c1.x;
                                    yData(j).VVGN = c1.y;
                                    xBoundsData(j).VVGN = nodeBoundsX(:,nd.index);
                                    yBoundsData(j).VVGN = nodeBoundsY(:,nd.index);
                                elseif nd.Type == enumNType.SAGN % Shearing Annular Gas Node
                                    xData(j).SAGN = c1.x;
                                    yData(j).SAGN = c1.y;
                                    xBoundsData(j).SAGN = nodeBoundsX(:,nd.index);
                                    yBoundsData(j).SAGN = nodeBoundsY(:,nd.index);
                                elseif nd.Type == enumNType.EN %environment
                                    xData(j).EN = c1.x;
                                    yData(j).EN = c1.y;
                                    xBoundsData(j).EN = nodeBoundsX(:,nd.index);
                                    yBoundsData(j).EN = nodeBoundsY(:,nd.index);
                                end
                                j = j + 1;
                            end
                        end


                    end
                end
            end

            if this.isDiscretized() && ~isempty(this.Nodes)

                if this.showNodes && ~isempty(xData)
                    % Plot node center points
                    % cannot plot all points individually as that takes ages

                    % plot solid nodes first as there will never be none of these
                    if any([xData.SN]) && this.showNodesSN
                        if isempty(this.StaticGUIObjects)
                            this.StaticGUIObjects = ...
                                plot([xData.SN],[yData.SN],'o',...
                                'MarkerSize',sizes.SN,...
                                'MarkerEdgeColor',colors.SN);
                        else
                            this.StaticGUIObjects(end+1) = ...
                                plot([xData.SN],[yData.SN],'o',...
                                'MarkerSize',sizes.SN,...
                                'MarkerEdgeColor',colors.SN);
                        end
                    end
                    % Plot rest
                    if any([xData.SVGN]) && this.showNodesSVGN
                        this.StaticGUIObjects(end+1) = ...
                            plot([xData.SVGN],[yData.SVGN],'o',...
                            'MarkerSize',sizes.SVGN,...
                            'MarkerEdgeColor',colors.SVGN);
                    end
                    if any([xData.VVGN]) && this.showNodesVVGN
                        this.StaticGUIObjects(end+1) = ...
                            plot([xData.VVGN],[yData.VVGN],'o',...
                            'MarkerSize',sizes.VVGN,...
                            'MarkerEdgeColor',colors.VVGN);
                    end
                    if any([xData.SAGN]) && this.showNodesSAGN
                        this.StaticGUIObjects(end+1) = ...
                            plot([xData.SAGN],[yData.SAGN],'o',...
                            'MarkerSize',sizes.SAGN,...
                            'MarkerEdgeColor',colors.SAGN);
                    end
                    if any([xData.EN]) && this.showNodesEN
                        this.StaticGUIObjects(end+1) = ...
                            plot([xData.EN],[yData.EN],'o',...
                            'MarkerSize',sizes.EN,...
                            'MarkerEdgeColor',colors.EN);
                    end
                end

                if this.showNodeBounds && ~isempty(xData)
                    % Matthias: Initial approach to draw node outlines using 'rectangle'. Slow.
                    %                         if this.showNodeBounds
                    %                             % bound is 4x1 double
                    %                             for bound = [BoundsData.SN]
                    %                                 % Could potentially plot boxes as four lines each to make plottign and
                    %                                 % deleting them faster
                    %                                 this.StaticGUIObjects(end+1) = ...
                    %                                     rectangle('Position',bound, 'EdgeColor',colors.SN);
                    %                             end
                    %                         end

                    % Matthias: Another approach to plot node bounds using 'fill'. Does not work faster than 'rectangle'.
                    %                         if this.showNodeBounds
                    %                                   bounds_fill = [BoundsData.SN];
                    %                                   xmin = bounds_fill(1,:);
                    %                                   xmax = bounds_fill(1,:)+bounds_fill(3,:);
                    %                                   ymin = bounds_fill(2,:);
                    %                                   ymax = bounds_fill(2,:)+bounds_fill(4,:);
                    %                                   % Xmin Xmin Xmax Xmax (clockwise order of
                    %                                   % points of rectangle, starting at
                    %                                   % xmin,ymin)
                    %                                   Xs = [xmin; xmin; xmax; xmax];
                    %                                   % ymin ymax ymax ymin
                    %                                   Ys = [ymin; ymax; ymax; ymin];
                    %                                   this.StaticGUIObjects = [this.StaticGUIObjects; fill(Xs,Ys,...
                    %                         'w',...
                    %                         'EdgeColor',colors.SN,...
                    %                         'LineWidth',0.5,...
                    %                         'FaceAlpha',0,... % transparent
                    %                         'HitTest','off')];
                    %                         end

                    % Matthias: Another approach to plot node bounds using 'line(x,y)'.
                    % If x and y have size [4, nRectangles]: Draws separate lines --> takes
                    % long time.
                    % If x and y have size [1, nRectangles*(4+1)] and after every 4 values
                    % there is a 'NaN' before the next 4: Draws one line with breaks where
                    % there is 'NaN' --> Fast!

                    % Plot solid nodes first
                    if any([xData.SN]) && this.showNodesSN
                        Xs = reshape([xBoundsData.SN],[],1);
                        Ys = reshape([yBoundsData.SN],[],1);
                        if isempty(this.StaticGUIObjects)
                            this.StaticGUIObjects = line(Xs,Ys,...
                                'Color',colors.SN, 'LineWidth',0.5);
                        else
                            this.StaticGUIObjects(end+1) = line(Xs,Ys,...
                                'Color',colors.SN, 'LineWidth',0.5);
                        end
                    end
                    % Plot rest
                    if any([xData.SVGN]) && this.showNodesSVGN
                        Xs = reshape([xBoundsData.SVGN],[],1);
                        Ys = reshape([yBoundsData.SVGN],[],1);
                        this.StaticGUIObjects(end+1) = line(Xs,Ys,...
                            'Color',colors.SVGN, 'LineWidth',0.5, 'LineStyle','--');
                    end
                    if any([xData.VVGN]) && this.showNodesVVGN
                        Xs = reshape([xBoundsData.VVGN],[],1);
                        Ys = reshape([yBoundsData.VVGN],[],1);
                        this.StaticGUIObjects(end+1) = line(Xs,Ys,...
                            'Color',colors.VVGN, 'LineWidth',0.5, 'LineStyle','--');
                    end
                    if any([xData.SAGN]) && this.showNodesSAGN
                        Xs = reshape([xBoundsData.SAGN],[],1);
                        Ys = reshape([yBoundsData.SAGN],[],1);
                        this.StaticGUIObjects(end+1) = line(Xs,Ys,...
                            'Color',colors.SAGN, 'LineWidth',0.5, 'LineStyle','--');
                    end
                    if any([xData.EN]) && this.showNodesEN
                        Xs = reshape([xBoundsData.EN],[],1);
                        Ys = reshape([yBoundsData.EN],[],1);
                        this.StaticGUIObjects(end+1) = line(Xs,Ys,...
                            'Color',colors.EN, 'LineWidth',0.5, 'LineStyle','--');
                    end
                end

            end


            if this.showBridges
                for iBridge = this.Bridges
                    iBridge.show(this.AxisReference);
                end
            else
                for iBridge = this.Bridges
                    iBridge.removeFromFigure(this.AxisReference);
                end
            end
            if this.showLeaks
                for iLeak = this.LeakConnections
                    iLeak.show(this.AxisReference);
                end
            else
                for iLeak = this.LeakConnections
                    iLeak.removeFromFigure(this.AxisReference);
                end
            end
            if this.showSensors
                if ~isempty(this.Sensors)
                    for iSensor = this.Sensors
                        iSensor.show(this.AxisReference);
                    end
                end
            else
                if ~isempty(this.Sensors)
                    for iSensor = this.Sensors
                        iSensor.removeFromFigure(this.AxisReference);
                    end
                end
            end
            if this.showBodyGhosts
                this.bringGhostToFront();
            end
        end
        function Animate(this,showOptions)
            if this.isChanged; this.update(); end
            this.removeStaticFromFigure();
            this.removeGhostFromFigure();
            %showOptions = [inputshowGroup,inputshowBodies,inputshowConnections,ishowLeaks,ishowBridges,ishowIntCon,ishowEnvirCon)]
            if nargin > 1
                showOptions = this.produceShowOptions(showOptions);
            else
                showOptions = this.produceShowOptions();
            end

            % Don't show connections in annimation
            showOptions(3) = false;

            cla;
            % Set Screen to be constant dimensions
            ReferenceAxis = gca;
            mode = get(ReferenceAxis,'XLimMode');
            set(ReferenceAxis,'XLimMode','manual');
            set(ReferenceAxis,'YLimMode','manual');
            set(ReferenceAxis,'ZLimMode','manual');

            % Initialize
            t = cputime;
            FrameTime = ((2*pi)/(this.AnimationSpeed_rads*Frame.NTheta));
            figure(gcf);
            axes(this.AxisReference);
            Inc = 1;
            % Make all static Bodies visible
            for iGroup = this.Groups
                iGroup.show('Static',this.AxisReference,0,showOptions);
            end

            k = 1;
            i_ani = 1;
            while this.isAnimating && cputime-t < this.AnimationLength_s

                %Matthias: For pausing animation with a breakpoint at a
                %specified time
                i_ani = i_ani+1;

                nexttime = cputime + FrameTime;

                % Go down through the hierarchy
                for iGroup = this.Groups
                    iGroup.show('Dynamic',this.AxisReference,Inc,showOptions);
                end
                if showOptions(4) % Leak Connections
                    for iLeak = this.LeakConnections
                        if iLeak.isDynamic
                            iLeak.show(this.AxisReference);
                        end
                    end
                end
                if showOptions(5) % Bridge Connections
                    for iBridge = this.Bridges
                        iBridge.show(this.AxisReference);
                    end
                end
                if showOptions(6) % Inter Node Connections, dynamic
                    if this.isDiscretized()
                        this.removeDynamicFromFigure();
                        % Make array of Node Centers
                        % Count nodes, stored in Groups
                        n = length(this.Nodes);
                        if n ~= 0
                            % Calculate the node center, at bottom dead center for all
                            for iNode = this.Nodes
                                nodeCenter(iNode.index) = iNode.CenterCoords(Inc);
                            end

                            % Make array of face coords
                            % Count faces, stored in Model
                            n = 1;
                            xData = NaN(3*length(this.Faces),1);
                            yData = NaN(3*length(this.Faces),1);

                            % Take each face, assess whether it is active, then record
                            for iFace = this.Faces
                                %if iFace.isDynamic && ...
                                if ~(iFace.Nodes(1).Type == enumNType.EN || ...
                                        iFace.Nodes(2).Type == enumNType.EN) && ...
                                        iFace.isActive(Inc)
                                    c1 = nodeCenter(iFace.Nodes(1).index);
                                    c2 = nodeCenter(iFace.Nodes(2).index);
                                    if this.inWindow(c1,c2)
                                        xData(n) = c1.x;
                                        xData(n+1) = c2.x;
                                        yData(n) = c1.y;
                                        yData(n+1) = c2.y;
                                        n = n + 3;
                                    end
                                end
                            end
                            n = n-1;
                            xData = xData(1:n);
                            yData = yData(1:n);

                            if isempty(this.StaticGUIObjects)
                                this.DynamicGUIObjects = line(xData,yData,'Color',[0 1 0]);
                            else
                                this.DynamicGUIObjects(end+1) = line(xData,yData,'Color',[0 1 0]);
                            end
                        end
                    end
                end
                % Iterate the counter
                Inc = Inc + 1;
                if Inc > Frame.NTheta
                    Inc = 1;
                end
                % Wait
                pause(10*max([0 nexttime-cputime]));
            end

            % Reset Screen to previous settings
            set(ReferenceAxis,'XLimMode',mode);
            set(ReferenceAxis,'YLimMode',mode);
            set(ReferenceAxis,'ZLimMode',mode);
        end

    end

end

function [Closed_Edge] = TrimFaces(this, region, Closed_Edge)
    LEN = length(Closed_Edge);
    for Nd = this.Nodes
        if Nd.index <= length(region)
            from = Nd;
            c = 1;
            while c == 1
                c = 0;
                % Determine the number of access points for the node
                for Fc = from.Faces
                    if Fc.index <= LEN && ~Closed_Edge(Fc.index) && ...
                            region(Fc.Nodes(1).index) == region(Fc.Nodes(2).index)
                        c = c + 1; if c > 1; break; end; edge = Fc;
                    end
                end
                if c == 1
                    % This Node has only one access point (withing a region),
                    % ... therefore it cannot be a part of a loop.
                    % Any nodes that are chain to this node with only two total
                    % ... access points must also not be part of a loop.
                    Closed_Edge(edge.index) = true;
                    if from == edge.Nodes(1)
                        from = edge.Nodes(2);
                    else
                        from = edge.Nodes(1);
                    end
                end
            end
        end
    end
end

function [A,B,C,D] = populate_Fc_ABCD(Sim, Fc)
    fcb = Face.empty;
    fcf = Face.empty;
    count = 0;
    for fc = Fc.Nodes(1).Faces
        if fc.Type == enumFType.Gas && fc ~= Fc
            if count == 0
                fcb = fc;
                count = 1;
            else
                % pick the larger face
                if mean(fcb.data.Area) < mean(fc.data.Area)
                    fcb = fc;
                end
            end
        end
    end
    if count == 1
        % Reference that backwards face
        if fcb.Nodes(2) == Fc.Nodes(1)
            Sim.Fc_Nd03(Fc.index,1) = fcb.Nodes(1).index;
        else
            Sim.Fc_Nd03(Fc.index,1) = fcb.Nodes(2).index;
        end
    else
        % Reference itself
        Sim.Fc_Nd03(Fc.index,1) = Fc.Nodes(1).index;
        fcb = Fc;
    end
    count = 0;
    for fc = Fc.Nodes(2).Faces
        if fc.Type == enumFType.Gas && ...
                fc ~= Fc
            if count == 0
                fcf = fc;
                count = 1;
            else
                % pick the larger face
                if mean(fcf.data.Area) < mean(fc.data.Area)
                    fcf = fc;
                end
            end
        end
    end
    if count == 1
        % Reference that backwards face
        if fcb.Nodes(1) == Fc.Nodes(2)
            Sim.Fc_Nd03(Fc.index,2) = fcb.Nodes(2).index;
        else
            Sim.Fc_Nd03(Fc.index,2) = fcb.Nodes(1).index;
        end
    else
        % Reference itself
        Sim.Fc_Nd03(Fc.index,2) = Fc.Nodes(2).index;
        fcf = Fc;
    end
    
    x1 = -0.5*Fc.data.Dist;
    x0 = x1 - fcb.data.Dist;
    x2 = -x1;
    x3 = x2 + fcf.data.Dist;
    if fcb ~= Fc && all(fcb.data.Area > 0) % Fc i - 1 exists
        if fcf ~= Fc && all(fcf.data.Area > 0) % Fc i + 1 exists
            % can fill xi, xi-1, xi+1 and xi+2, as well as A, B, C and D
            A = -((x1.*x2.*x3)./(x0-x1)./(x0-x2)./(x0-x3));
            B = -((x0.*x2.*x3)./(x1-x0)./(x1-x2)./(x1-x3));
            C = -((x0.*x1.*x3)./(x2-x0)./(x2-x1)./(x2-x3));
            D = -((x0.*x1.*x2)./(x3-x0)./(x3-x1)./(x3-x2));
        else
            A = -((x1.*x2)./(x0-x1)./(x0-x2));
            B = -((x0.*x2)./(x1-x0)./(x1-x2));
            C = -((x0.*x1)./(x2-x0)./(x2-x1));
            D = 0;
        end
    else
        if fcf ~= Fc && all(fcf.data.Area > 0) % Fc i + 1 exists
            A = 0;
            B = -((x2.*x3)./(x1-x2)./(x1-x3));
            C = -((x1.*x3)./(x2-x1)./(x2-x3));
            D = -((x1.*x2)./(x3-x1)./(x3-x2));
        else
            A = 0.0;
            B = 0.5;
            C = 0.5;
            D = 0.0;
        end
    end
    sum = A+B+C+D;
    for i = 1:length(sum)
        roundsum = round(sum);
        if roundsum == 1
            % No change
        elseif roundsum == -1
            A(min(i,length(A))) = -A(min(i,length(A)));
            B(min(i,length(B))) = -B(min(i,length(B)));
            C(min(i,length(C))) = -C(min(i,length(C)));
            D(min(i,length(D))) = -D(min(i,length(D)));
        else
            A(min(i,length(A))) = 0;
            B(min(i,length(B))) = 0.5;
            C(min(i,length(C))) = 0.5;
            D(min(i,length(D))) = 0;
        end
    end
    A = CollapseVector(A);
    B = CollapseVector(B);
    C = CollapseVector(C);
    D = CollapseVector(D);
end
