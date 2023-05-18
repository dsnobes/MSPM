classdef Simulation < handle
    % Simulation objects contain all the arrays of each particular node, and
    % each particular interface type along with all supporting information
    % tables

    properties (Constant)
        U_Tolerance = 1e-6;
        turb_Tolerance = 0.05;
        RE_Tolerance = 1;
        InertiaMod = 0.1;
    end

    properties

        MaxCourant = 0.025;
        MaxFourier = 0.025;

        Model Model;
        %% Face Properties
        % Face Types
        Mix_Fc;

        % Dynamic Data
        Dynamic;
        Dyn = 1;

        % Node Property Pointers to Dynamic Data
        isDynVol double;%
        DynVol int16;
        DynDh int16;
        Fc_DynArea int16;
        Fc_DynDh int16;
        Fc_DynK12 int16;
        Fc_DynK21 int16;
        Fc_DynVel_Factor int16;
        Fc_DynShear_Factor int16;
        Fc_DynDist int16;
        Fc_DynCond_Dist int16;
        Fc_DynCond int16;
        Fc_Dyndx int16;
        Fc_DynWCond int16;
        SC_Active int16;
        %dL_dt double;
        %dD_dt double;

        %% Solid Conduction
        Cond_Nds1;
        Cond_Nds2;
        Cond_Nds;
        Cond_Fcs;
        CondNet;
        % Energy Transport
        Trans_Fcs;
        TransNet;
        % Faces to Nodes

        %% MEchanical System
        Press_Contact;
        Shear_Contact;
        MechanicalSystem MechanicalSystem;
        dA = 0;
        dA_old = 0;

        %% Max Courant
        dt_max double;

        %% General Gas
        dT_duFunc cell;
        dh_dTFunc cell; % Additions
        kFunc cell;
        muFunc cell;
        R double; % Defined by Region
        Rs; % All Nodes

        NuFunc_l_el cell;
        NuFunc_t_el cell;
        Fc_NkFunc_l_el cell;
        Fc_NkFunc_t_el cell;

        %% Node Properties
        CondFlux double;%
        NuFunc_l cell;%
        NuFunc_t cell;%
        dT_dU double;%
        dh_dT double;% Gas nodes only, Additions
        dV_dt double;%
        h double;%
        T double;%
        P double;%
        dP double;%
        rho double;%
        m double;%
        vol double;%
        old_vol double;%
        k double;%
        mu double;%
        Dh double;%
        Nu double;%
        RE double;%
        f double;%
        P_backup double;%
        U double;%
        dU double;

        % Turbulence
        turb double;
        Area double;
        Va double;
        to double;

        %% Face Properties
        Fc_Nd int16;%
        Fc_Dist double;%
        Fc_Cond_Dist double;%
        Fc_dx double;%
        Fc_K12 double;%
        Fc_K21 double;%
        Fc_U double;%
        Fc_RE double;%
        Fc_f double;%
        Fc_R double;%
        Fc_fFunc_l cell;%
        Fc_fFunc_t cell;%
        Fc_NkFunc_l cell;%
        Fc_NkFunc_t cell;%
        Fc_Area double;%
        Fc_Dh double;%
        Fc_Cond double;%
        Fc_T double;
        Fc_u double;
        Fc_k double;
        Fc_mu double;
        Fc_rho double;
        Fc_Vel_Factor double;
        Fc_Shear_Factor double;
        Fc_W double;

        % Prandtl Number
        PR double;%
        Fc_PR;

        %% Parameter inspection made it here:

        % Turbulence
        Fc_turb double;
        Fc_to double;
        useTurbulenceFc logical;
        useTurbulenceNd logical;
        dturb double;
        REcrit double;

        stop logical;
        curTime double;
        Solid_t double;
        MAXdt double;
        A_Inc;
        Inc;
        MoveCondition int16;

        % Solver
        Regions cell;
        isEnvironmentRegion logical;
        RegionFcs cell;
        ActiveRegionFcs cell;
        RegionFcCount int16;
        RegionLoops cell;
        RegionLoops_Ind cell;
        Faces cell;
        Fc2Col double;
        ExplicitLeak double;
        ExplicitNorm double;
        KpU_2A double;
        Fc_V double;
        Fc_V_averager double;
        Fc_turb_averager double;
        Fc_dP double;
        Fc_V_backup double;
        A_Press cell;
        u2T cell;
        %     extfc cell;
        Solid_dt_max;
        isLoopRegionFcs;
        Fc2Col_loop;

        Nd_Solid_dt;
        doScale;
        Acceleration_Coef = 1;
        SteadyState_Factor = 1;
        Acceleration_Factor = 1;

        % Statistics Collection
        ToEnvironmentSolid;
        ToEnvironmentGas;
        ToSource;
        ToSink;
        E_ToEnvironment;
        E_ToSource;
        E_ToSink;
        E_Flow_Loss;
        Sources;
        Sinks;
        VolMin;
        VolMax;
        ShuttleFaces;
        StaticFaces;
        ExergyLossShuttle;
        ExergyLossStatic;

        countFailed = 0.0;
        countSuccess = 0.0;

        ACond;
        bCond;
        BoundaryNodes;
        MixFcs;
        CondEff;
        CondTempEff;
        CycleTime;
        ss_condition;
        continuetoSS;

        %     Fric_l_current;
        %     Fric_t_current;
        %     Fric_l_index;
        %     Fric_t_index;
        %     Fric_tbl;
        %     Fric_tbt;


        % Engine Pressure Assignment
        PRegion = [];
        PRegionTime = [];
        CycledE = 0;

        Fc_Nd03 int16;
        Fc_A double;
        Fc_DynA;
        Fc_B double;
        Fc_DynB;
        Fc_C double;
        Fc_DynC;
        Fc_D double;
        Fc_DynD;


        EffRE double;

        FcApprox;
    end

    methods

        function [Results, success] = Run(ME, islast, do_warmup, ss_tolerance, options)
            success = true;
            ME.stop = false;

            if nargin > 4 && options.isManual == false
                simTime = options.simTime; % Maximum Simulation Time
                ME.ss_condition = options.SS; % True or False for steady state detection
                ME.continuetoSS = false;
                switch options.movement_option % C - Continuous, V - Variable
                    case 'C'; ME.MoveCondition = 1;
                    case 'V'; ME.MoveCondition = 2;
                end
                ME.dA = options.rpm*2*pi/60;
                ME.dA_old = ME.dA;
                ME.MAXdt = options.max_dt;
                ME.T(ME.Sources) = options.SourceTemp;
                ME.T(ME.Sinks) = options.SinkTemp;
                engine_Pressure = options.EnginePressure;
            else
                %% Get user input
                while isempty(ME.Model.name) && ~isempty(ME.Model.Sensors)
                    answer = inputdlg(...
                        ['Please name the model so that ' ...
                        'the data can be saved properly'],'Name Model',[1 200],{''});
                    if ~isempty(answer{1})
                        ME.Model.name = answer{1};
                    end
                end
                % inputdlg( prompt , dlg_title , num_lines , defAns );
                invalid = true;
                output = {'10','SS','C','60','0.1'};
                while invalid
                    output = inputdlg({...
                        'Maximum Simulation Time (seconds)',...
                        'End Condition (SS - Steady State)',...
                        'Motion Condition (C - Constant Velocity, V - Variable Velocity)',...
                        'Initial Velocity (rpm)',...
                        'maximum time step (s)'},...
                        'Enter Simulation Parameters',...
                        [1 20],...
                        output);
                    invalid = false;
                    if isempty(output)
                        Results = [];
                        return;
                    end
                    if ~all(ismember(output{1}, '0123456789+-.eE')); invalid = true;
                    elseif ~strcmp(output{2},'SS') && ~isempty(output{2}); invalid = true;
                    elseif ~strcmp(output{3},'C') && ~strcmp(output{3},'V'); invalid = true;
                    elseif ~all(ismember(output{4}, '0123456789+-.eE')); invalid = true;
                    elseif ~all(ismember(output{5}, '0123456789+-.eE')); invalid = true;
                    end
                end

                simTime = str2double(output{1});
                switch output{2}
                    case 'SS'; ME.ss_condition = true;
                    otherwise; ME.ss_condition = false;
                end
                ME.continuetoSS = false;
                switch output{3}
                    case 'C'; ME.MoveCondition = 1;
                    case 'V'; ME.MoveCondition = 2;
                end
                ME.dA = str2double(output{4})*2*pi/60;
                ME.dA_old = ME.dA;
                ME.MAXdt = str2double(output{5});
                engine_Pressure = ME.Model.enginePressure;
            end

            Load_Function_is_Not_Given = false;

            if ME.Model.recordOnlyLastCycle
                ME.MaxCourant = ME.Model.MaxCourantConverging;
                ME.MaxFourier = ME.Model.MaxFourierConverging;
            else
                ME.MaxCourant = ME.Model.MaxCourantFinal;
                ME.MaxFourier = ME.Model.MaxFourierFinal;
            end

            %% Early Initialize
            ME.A_Inc = 2*pi/(Frame.NTheta-1);
            ME.Inc = 1;
            ME.curTime = 0;
            Results = Result();
            Results.Model = ME.Model;
            Results.Data = struct();
            Results.Data.QEnv = 0;
            Results.Data.QSource = 0;
            Results.Data.QSink = 0;
            Results.Data.Flow_Loss = 0;
            Results.Data.ExergyLossShuttle = 0;
            Results.Data.ExergyLossStatic = 0;
            Results.Data.Power = 0;
            Results.Data.CR = 0;

            indf = 1:length(ME.Fc_V);
            record_data = islast || ME.ss_condition == false;

            %% Set up data acquisition
            grab_Pressure = ME.Model.recordPressure;
            grab_Temperature = ME.Model.recordTemperature;
            grab_Velocity = ME.Model.recordVelocity;
            grab_PressureDrop = ME.Model.recordPressureDrop;
            grab_Turbulence = ME.Model.recordTurbulence;
            grab_ConductionFlux = ME.Model.recordConductionFlux;
            if ME.MoveCondition == 1 || ME.Model.recordOnlyLastCycle
                dt = ME.A_Inc/ME.dA;
                if ME.Model.recordOnlyLastCycle; LEN = Frame.NTheta-1;
                else; LEN = ceil((simTime*ME.dA/ME.A_Inc));
                end
                Results.Data.A = linspace(0,ME.A_Inc*LEN,LEN);
                Results.Data.dA = ME.dA(ones(1, LEN+2));
                Results.Data.t = linspace(0,LEN*dt,LEN+2);
                if grab_Pressure
                    Results.Data.P = zeros(length(ME.P),LEN);
                    Results.Data.P(:,1) = ME.P;
                end
                if grab_Temperature
                    Results.Data.T = zeros(length(ME.T),LEN);
                    Results.Data.T(:,1) = ME.T;
                end
                if grab_Velocity
                    Results.Data.U = zeros(length(ME.Fc_dx),LEN);
                    Results.Data.U(:,1) = ME.Fc_V./ME.Fc_Area(indf);
                end
                if grab_PressureDrop
                    Results.Data.dP = zeros(length(ME.P),LEN);
                    Results.Data.dP(:,1) = ME.dP;
                end
                if grab_Turbulence
                    Results.Data.turb = zeros(length(ME.P),LEN);
                    Results.Data.turb(:,1) = ME.turb;
                end
                if grab_ConductionFlux
                    Results.Data.cond = zeros(length(ME.T),LEN);
                    Results.Data.cond(:,1) = ME.CondFlux;
                end
            else
                % Grab Pressure
                if grab_Pressure; Results.Data.P = ME.P; end
                % Grab Temperature
                if grab_Temperature; Results.Data.T = ME.T; end
                % Grab Velocity
                if grab_Velocity
                    Results.Data.U = ME.Fc_V./ME.Fc_Area(indf);
                end
                if grab_PressureDrop
                    Results.Data.dP = ME.dP;
                end
                % Grab Turbulence
                if grab_Turbulence; Results.Data.turb = ME.turb; end
                if grab_ConductionFlux; Results.Data.cond = ME.CondFlux; end
                Results.Data.A = 0;
                Results.Data.dA = ME.dA;
                Results.Data.t = 0;
            end
            if ~isempty(ME.Model.Sensors)
                for iSensor = ME.Model.Sensors; iSensor.reset(); end
            end
            if ~isempty(ME.Model.PVoutputs)
                for iPVoutput = ME.Model.PVoutputs; iPVoutput.reset(); end
            end
            n = 2;

            AdjustTime = 0;
            previousTime = 0;
            ME.dt_max = 2*ME.A_Inc/(ME.dA_old + ME.dA);

            %% Initialize All the sub functions
            clear assignDynamic;
            clear implicitSolve;
            % clear dUFunc;
            clear KValue;
            clear solve_loops;
            % dUFunc(ME);
            % KValue(ME);
            assignDynamic(ME, ME.Inc, false);
            implicitSolve(ME, true);
            sindn = length(ME.P)+1:length(ME.T);
            ME.old_vol = ME.vol;

            %% Warm Up Phase
            %{
      if do_warmup
        progressbar('Warmup Phase');
        hmax = mean(ME.Solid_dt_max);
        t = 0;
        progressbar_update = 1;
      
        if ME.Model.warmUpPhaseLength > 0; assignAvgDynamic(ME); end
      
        % Record a backup of the gas properties, just so that we don't have
        % ... to bother.
        indn = 1:length(ME.P); indf = 1:length(ME.Fc_U); indmf = ME.Mix_Fc;
        Cfcs = ME.Cond_Fcs; Cnd1 = ME.Cond_Nds1; Cnd2 = ME.Cond_Nds2;
        Gm = ME.m(indn); Gu = ME.u(indn); GT = ME.T(indn);
        Sm = ME.m(sindn); ST = ME.T(sindn);
        Q = zeros(length(ME.T),1);
        ME.Fc_Cond(indmf) = ME.Fc_Area(indmf)./(ME.Fc_R(indmf)' + 15);
        ME.Fc_Cond(indf) = 0.5*ME.Fc_Area(indf)./ME.Fc_Cond_Dist(indf);
        while (t < ME.Model.warmUpPhaseLength)
          h = min(hmax, ME.Model.warmUpPhaseLength - t);
          
          Ti = [GT; ME.T(sindn)];
          
          Q(:) = 0;
          Qfc = ME.Fc_Cond(Cfcs).*(Ti(Cnd1) - Ti(Cnd2));
          for i = 1:3:length(ME.CondNet)-2
            Q(ME.CondNet{i+1}) = Q(ME.CondNet{i+1}) + ...
              ME.CondNet{i}.*Qfc(ME.CondNet{i+2});
          end

          % Internal Energy Change - Gas
          Gu = Gu + h*Q(indn)./Gm;

          % Temperature - Gas
          GT = ME.u2T(Gu);

          % Temperature - Solid
          ST = ME.dT_dU(sindn).*Q(sindn)./Sm;
          
          t = t + h;
          if progressbar_update > 1/h
            progressbar(t/ME.Model.warmUpPhaseLength);
            progressbar_update = 1;
          else
            progressbar_update = progressbar_update + 1;
          end
        end
        
        ME.T(sindn) = ST;
      end
            %}

            sindn = length(ME.P):length(ME.T);

            progressbar('Main Dynamic Loop');
            %% Set up Steady State Detection Code
            if ME.ss_condition
                ss_cycles = 5;
                Precord = zeros(1,ss_cycles);
                Load_Function_is_Not_Given = isempty(ME.MechanicalSystem.LoadFunction);
                if Load_Function_is_Not_Given && ME.MoveCondition == 2
                    ME.MaxCourant = ME.Model.MaxCourantFinal;
                    ME.MaxFourier = ME.Model.MaxFourierFinal;
                    % Turn off pressure, temperature adjustments.
                    % Set timestep to final value.
                    ME.continuetoSS = true;
                    if nargin > 4 && ...
                            isfield(options,'set_Load') && options.set_Load ~= 0
                        temp = options.set_Load;
                    else
                        temp = 0;
                    end
                    LoadRecord = temp;
                    SetSpeed = ME.dA;
                else
                    ME.continuetoSS = false;
                end
            end

            %% Main Loop

            ME.curTime = 0;
            ME.CycledE = 0;
            cycle_count = 0;
            MechCycleEnergy = 0;
            Plot_Powers = zeros(1000,1);
            Plot_Learning_Rate = zeros(1000,1);
            since_inflection = 0;
            Plot_Number = 0;
            power_factor = 1;
            %Convergence_Plot = figure();
            %Factor_Plot = figure();
            if ME.ss_condition
                Tavg = zeros(size(ME.T));
                Tavg_count = 0;
            end
            while (ME.curTime < simTime)
                %% Main Solve
                ME.dt_max = 2*ME.A_Inc/(ME.dA_old + ME.dA);
                Forces = ME.Iteration_Solve();
                for i = length(Forces)
                    for j = length(Forces{i})
                        if isnan(Forces{i}(j)) || ~isreal(Forces{i}(j))
                            ME.stop = true;
                            success = false;
                        end
                    end
                end
                if ME.stop
                    %           fprintf('Simulation Finished Prematurely. (in Run)\n');
                    clear assignDynamic;
                    clear implicitSolve;
                    % clear dUFunc;
                    clear KValue;
                    clear solve_loops;
                    break;
                end
                ME.curTime = ME.curTime +  ME.dt_max;
                progressbar(ME.curTime/simTime);
                Power = ME.MechanicalSystem.Solve(ME.Inc,(ME.dA_old + ME.dA)/2,0,Forces);
                MechCycleEnergy = MechCycleEnergy + Power*ME.dt_max;
                if ~isempty(ME.MechanicalSystem.LoadFunction)
                    Power = Power - ME.MechanicalSystem.LoadFunction((ME.dA_old + ME.dA)/2)*(ME.dA_old + ME.dA)/2;
                end
                switch ME.MoveCondition
                    case 1 % For Constant Motion Systems
                        % Do nothing
                    case 2 % For variable systems
                        ME.dA_old = ME.dA;
                        % fprintf([num2str(Power*ME.dt_max) '\n']);
                        new_ke = Power*ME.dt_max + 0.5*ME.MechanicalSystem.Inertia*ME.dA^2;
                        if new_ke < 0 && ME.ss_condition && ...
                                ME.Model.recordOnlyLastCycle && ...
                                Load_Function_is_Not_Given
                            ME.dA = 0.1*2*pi; % Minimum speed of 0.1 Hz
                        else
                            if new_ke < 0
                                ME.stop = true;
                            else
                                ME.dA = sqrt(2*new_ke/ME.MechanicalSystem.Inertia);
                            end
                        end
                        if ME.ss_condition && ...
                                ME.Model.recordOnlyLastCycle && ...
                                Load_Function_is_Not_Given
                            if ME.dA < 0.1*2*pi
                                ME.dA = 0.1*2*pi;
                            end
                        end
                        % fprintf([num2str(ME.dA) '\n']);
                end

                if ME.stop
                    fprintf('Simulation Finished Prematurely. (in Run)\n');
                    clear assignDynamic;
                    clear implicitSolve;
                    % clear dUFunc;
                    clear KValue;
                    clear solve_loops;
                    return;
                end

                %% Obtain Results
                if ME.Model.recordOnlyLastCycle
                    Results.Data.dA(ME.Inc) = ME.dA;
                    Results.Data.t(ME.Inc) = ME.curTime - AdjustTime;
                    if grab_Pressure; Results.Data.P(:,ME.Inc) = ME.P; end
                    if grab_Temperature; Results.Data.T(:,ME.Inc) = ME.T; end
                    if grab_Velocity
                        Results.Data.U(:,ME.Inc) = ME.Fc_V./ME.Fc_Area(indf);
                    end
                    if grab_PressureDrop
                        Results.Data.dP(:,ME.Inc) = ME.dP;
                    end
                    if grab_Turbulence; Results.Data.turb(:,ME.Inc) = ME.turb; end
                    if grab_ConductionFlux; Results.Data.cond(:,ME.Inc) = ME.CondFlux; end
                    if ME.Model.recordStatistics
                        Results.Data.QEnv(ME.Inc) = ME.E_ToEnvironment;
                        Results.Data.QSource(ME.Inc) = ME.E_ToSource;
                        Results.Data.QSink(ME.Inc) = ME.E_ToSink;
                        Results.Data.Flow_Loss(ME.Inc) = ME.E_Flow_Loss;
                        Results.Data.Power(ME.Inc) = Power;
                        Results.Data.ExergyLossStatic(ME.Inc) = ME.ExergyLossStatic;
                        Results.Data.ExergyLossShuttle(ME.Inc) = ME.ExergyLossShuttle;
                        % Reset them
                        ME.ExergyLossStatic = 0;
                        ME.ExergyLossShuttle = 0;
                        ME.E_ToEnvironment = 0;
                        ME.E_ToSource = 0;
                        ME.E_ToSink = 0;
                        ME.E_Flow_Loss = 0;
                    end
                else
                    if ME.MoveCondition == 2
                        Results.Data.A(n) = Results.Data.A(n-1) + ME.A_Inc;
                        Results.Data.dA(n) = ME.dA;
                        Results.Data.t(n) = ME.curTime;
                        if length(Results.Data.t) == n
                            LEN = abs(min([100 ceil(((simTime-ME.curTime)*ME.dA/ME.A_Inc))]));
                            Results.Data.A(n:n+LEN) = linspace(Results.Data.A(n-1),Results.Data.A(n-1)+...
                                LEN*ME.A_Inc,LEN+1);
                            Results.Data.dA(n+LEN) = 0;
                            Results.Data.t(n+LEN) = 0;
                            if grab_Pressure; Results.Data.P(length(ME.P),n+LEN) = 0; end
                            if grab_Temperature; Results.Data.T(length(ME.P),n+LEN) = 0; end
                            if grab_Velocity
                                Results.Data.U(length(ME.Fc_dx),n+LEN) = 0;
                            end
                            if grab_PressureDrop
                                Results.Data.dP(length(ME.P),n+LEN) = 0;
                            end
                            if grab_Turbulence; Results.Data.turb(length(ME.turb),n+LEN) = 0; end
                            if grab_ConductionFlux; Results.Data.cond(length(ME.CondFlux),n+LEN) = 0; end
                            if ME.Model.recordStatistics
                                Results.Data.QEnv(n+LEN) = 0;
                                Results.Data.QSource(n+LEN) = 0;
                                Results.Data.QSink(n+LEN) = 0;
                                Results.Data.Power(n+LEN) = 0;
                            end
                        end
                    end
                    if grab_Pressure; Results.Data.P(:,n) = ME.P; end
                    if grab_Temperature; Results.Data.T(:,n) = ME.T; end
                    if grab_Velocity
                        Results.Data.U(:,n) = ME.Fc_V./ME.Fc_Area(indf);
                    end
                    if grab_PressureDrop
                        Results.Data.dP(:,n) = ME.dP;
                    end
                    if grab_Turbulence; Results.Data.turb(:,n) = ME.turb; end
                    if grab_ConductionFlux; Results.Data.cond(:,n) = ME.CondFlux; end
                    if ME.Model.recordStatistics
                        Results.Data.QEnv(n) = ME.E_ToEnvironment;
                        Results.Data.QSource(n) = ME.E_ToSource;
                        Results.Data.QSink(n) = ME.E_ToSink;
                        Results.Data.Flow_Loss(n) = ME.E_Flow_Loss;
                        Results.Data.Power(n) = Power;
                        Results.Data.ExergyLossStatic(n) = ME.ExergyLossStatic;
                        Results.Data.ExergyLossShuttle(n) = ME.ExergyLossShuttle;
                        % Reset them
                        ME.ExergyLossStatic = 0;
                        ME.ExergyLossShuttle = 0;
                        ME.E_ToEnvironment = 0;
                        ME.E_ToSource = 0;
                        ME.E_ToSink = 0;
                        ME.E_Flow_Loss = 0;
                    end
                end
                if ~isempty(ME.Model.Sensors)
                    for iSensor = ME.Model.Sensors; iSensor.getData(ME); end
                end
                if ~isempty(ME.Model.PVoutputs)
                    for iPVoutput = ME.Model.PVoutputs; iPVoutput.getData(ME); end
                end
                if ME.curTime > previousTime + ME.Model.animationFrameTime
                    previousTime = ME.curTime;
                end
                ME.old_vol = ME.vol;
                n = n + 1;

                %% Test Conditions (Reverse, Steady State, etc...)
                if ME.ss_condition && ME.Model.recordOnlyLastCycle
                    if ME.MoveCondition == 2
                        if Load_Function_is_Not_Given
                            if ME.dA < 0
                                ME.dA = 0.1*2*pi; % Minimum speed of 0.1 Hz
                            end
                        end
                    end
                end
                if ME.dA < 0
                    fprintf('XXX Engine Reversed Directions, solving exited XXX\n');
                    return;
                else
                    if ME.ss_condition && ~ME.continuetoSS
                        Tavg = Tavg + ME.T;
                        Tavg_count = Tavg_count + 1;
                        if Tavg_count == 1
                            T_previous = Tavg;
                        end
                    end
                    ME.Inc = ME.Inc + 1;
                    if ME.Inc == Frame.NTheta
                        if cycle_count == 1 && ...
                                ME.Model.recordOnlyLastCycle && ME.Model.recordStatistics
                            Results.Data.CR = ME.VolMax(:)./ME.VolMin(:);
                        end
                        cycle_count = cycle_count + 1;
                        Plot_Number = Plot_Number + 1;
                        Plot_Powers(Plot_Number) = MechCycleEnergy/(ME.curTime - AdjustTime);
                        fprintf(['Speed: (rpm) ' num2str(60*ME.dA/(2*pi)) ...
                            'Power: (W) ' num2str(Plot_Powers(Plot_Number)) '\n']);

                        Results.Data.SnapShot_P = ME.Rs.*ME.T(1:length(ME.P)).*...
                            ME.m(1:length(ME.P))./ME.vol(1:length(ME.P));

                        if ME.Model.showLivePV
                            for iPVoutput = ME.Model.PVoutputs; iPVoutput.updatePlot(); end
                        end

                        % Acquire an understanding of the solution plateauing
                        Plot_Number = Plot_Number + 1;
                        Plot_Powers(Plot_Number) = MechCycleEnergy/(ME.curTime - AdjustTime);
                        MechCycleEnergy = 0;
                        Plot_Learning_Rate(Plot_Number) = power_factor;
                        %             if isempty(Convergence_Plot) || ...
                        %                 ~isvalid(Convergence_Plot) || ...
                        %                 Convergence_Plot < 1
                        %               Convergence_Plot = figure();
                        %             end
                        %             figure(Convergence_Plot);
                        %             plot(1:Plot_Number,Plot_Powers(1:Plot_Number));

                        %cycle_count = cycle_count + 1;
                        ME.Inc = 1;

                        %             if isempty(Factor_Plot) || ...
                        %                 ~isvalid(Factor_Plot) || ...
                        %                 Factor_Plot < 1
                        %               Factor_Plot = figure();
                        %             end
                        %figure(Factor_Plot);
                        %plot(1:Plot_Number,Plot_Learning_Rate(1:Plot_Number));

                        % Get Local curvature
                        if Plot_Number > 2
                            Power_curv_backup = power_curv;
                            power_curv = (Plot_Powers(Plot_Number) - ...
                                2*Plot_Powers(Plot_Number - 1) + ...
                                Plot_Powers(Plot_Number - 2));
                            if Plot_Number > 3
                                % Detect if crossed inflection point
                                if sign(power_curv) ~= sign(Power_curv_backup) && since_inflection > 3
                                    power_factor = 0;
                                    since_inflection = 0;
                                else
                                    power_factor = ...
                                        min(1,max(0,...
                                        power_factor + 0.25/(1 + 2*abs(power_factor - 0.5))));
                                end
                            end
                        else
                            power_curv = 1;
                            power_factor = ...
                                min(1,max(0,...
                                power_factor + 0.25/(1 + 2*abs(power_factor - 0.5))));
                        end
                        since_inflection = since_inflection + 1;

                        % Detect if it is steady state
                        if ME.ss_condition
                            if ~ME.continuetoSS
                                %                 fprintf(['Mixed Face Conduction: ' ...
                                %                   num2str(sum(ME.CondEff / ME.CycleTime)) '.\n']);
                                %                 fprintf(['Volume Averaged Reynolds Number: ' ...
                                %                   num2str(sum(ME.EffRE / ME.CycleTime)) '.\n']);
                                %                 ME.EffRE(:) = 0;
                                % Calculate Average Temperatures and current shift
                                Tavg = Tavg/Tavg_count;

                                % Modify T_delta to prevent a constant change in
                                % ... temperature being regarded as an oscillation.
                                T_constant = ME.T - T_previous;
                                Tavg = Tavg + T_constant/2;
                                T_delta = ME.T - Tavg;

                                A = ME.ACond;
                                b = ME.bCond;
                                ME.CondEff = ME.CondEff / ME.CycleTime;
                                ME.CondTempEff = ME.CondTempEff / ME.CycleTime;
                                for i = ME.BoundaryNodes
                                    % Modify the diagonal from default values to include the
                                    % ... average conductance to other nodes (gas nodes)
                                    A(i,i) = A(i,i) + sum(ME.CondEff(ME.MixFcs{i}));
                                    % Calculate the b values so that they are:
                                    % ...  bi = sum of others( sum of other(delta * Cond * To))
                                    % ...                    ( / sum of delta
                                    b(i) = b(i) + sum(ME.CondTempEff(ME.MixFcs{i}));
                                end

                                if cycle_count == 1
                                    for i = 1:size(A,1)
                                        if all(A(i,:) == 0)
                                            ME.ACond(i,i) = 1;
                                            ME.bCond(i) = 298;
                                            A(i,i) = 1;
                                            b(i) = 298;
                                        end
                                    end
                                end

                                ME.CondEff(:) = 0;
                                ME.CondTempEff(:) = 0;
                                ME.CycleTime = 0;

                                A = sparse(A);
                                var = A\b;

                                % Calculate shifted values based on current transient
                                ME.T(sindn) = var + T_delta(sindn);

                                % Reset Tavg for the next cycle
                                Tavg(:) = 0;
                                Tavg_count = 0;

                            end

                            % Detect if it is steady state
                            % Compare the average over 10 cycles to see if it appears to
                            % be converged
                            Precord(1:ss_cycles-1) = Precord(2:ss_cycles);
                            Precord(ss_cycles) = Plot_Powers(Plot_Number);
                            temp = ss_tolerance*max(Precord(end),1);
                            % ContinuetoSS is the a flag for the last cycle which is run
                            % ... at a finer timestep that the converging cycles.
                            if ME.continuetoSS; break; end
                            if CustomRSSQ(diff(Precord)) < temp
                                ME.continuetoSS = true;
                                ME.MaxCourant = ME.Model.MaxCourantFinal;
                                ME.MaxFourier = ME.Model.MaxFourierFinal;
                            end
                        end

                        % Modify Gas Mass so that the engine is at the engine pressure.
                        if ME.Model.recordOnlyLastCycle
                            %i = 1;
                            for i = 1:length(ME.Regions)
                                if ~ME.isEnvironmentRegion(i)
                                    nodes = ME.Regions{i};
                                    Pregion = ME.PRegion(i)/ME.PRegionTime;
                                    ME.m(nodes) = ...
                                        (power_factor*engine_Pressure/Pregion + ...
                                        (1-power_factor))*ME.m(nodes);
                                end
                            end
                            ME.PRegion(:) = 0; ME.PRegionTime(:) = 0;
                            %               for iPVoutput = ME.Model.PVoutputs
                            %                 Pregion = ME.PRegion(i)/ME.PRegionTime(i);
                            %                 ME.PRegion(i) = 0; ME.PRegionTime(i) = 0;
                            %                 ME.m(iPVoutput.RegionNodes) = ...
                            %                   (power_factor*engine_Pressure/Pregion + ...
                            %                   (1-power_factor))*ME.m(iPVoutput.RegionNodes);
                            %                 i = i + 1;
                            %               end

                        end

                        % Assess cycle time and modify mechanism load accordingly
                        if ME.ss_condition && ME.Model.recordOnlyLastCycle
                            if ME.MoveCondition == 2
                                if Load_Function_is_Not_Given
                                    % Modify Load to approach initial speed
                                    % Calculate Speed
                                    speed = 2*pi/(ME.curTime - AdjustTime);
                                    dspeed = min(0.01/(max(log(Plot_Number),1)), ...
                                        0.5*abs((SetSpeed - speed)/SetSpeed));
                                    if speed < SetSpeed
                                        LoadRecord = LoadRecord - power_factor*dspeed;
                                    else
                                        LoadRecord = LoadRecord + power_factor*dspeed;
                                    end
                                    ME.MechanicalSystem.LoadFunction = @(Speed) LoadRecord;
                                end
                            end
                        end

                        AdjustTime = ME.curTime;
                    end
                    assignDynamic(ME,ME.Inc,false); % Initialize the dynamic function
                end
            end
            progressbar(1);

            if ~ME.Model.recordOnlyLastCycle
                Results.Data.dA = Results.Data.dA(1:n-1);
                Results.Data.t = Results.Data.t(1:n-1);
                if grab_Pressure; Results.Data.P = Results.Data.P(:,1:n-1); end
                if grab_Temperature; Results.Data.T = Results.Data.T(:,1:n-1); end
                if grab_Velocity; Results.Data.U = Results.Data.U(:,1:n-1); end
                if grab_PressureDrop; Results.Data.dP = Results.Data.dP(:,1:n-1); end
                if grab_Turbulence; Results.Data.turb = Results.Data.turb(:,1:n-1); end
                if grab_ConductionFlux; Results.Data.cond = Results.Data.cond(:,1:n-1); end
                if ME.Model.recordStatistics
                    Results.Data.QEnv = Results.Data.QEnv(:,1:n-1);
                    Results.Data.QSource = Results.Data.QSource(:,1:n-1);
                    Results.Data.QSink = Results.Data.QSink(:,1:n-1);
                    Results.Data.Flow_Loss = Results.Data.Flow_Loss(:,1:n-1);
                    Results.Data.ExergyLossShuttle = Results.Data.ExergyLossShuttle(:,1:n-1);
                    Results.Data.ExergyLossStatic = Results.Data.ExergyLossStatic(:,1:n-1);
                    Results.Data.Power = Results.Data.Power(:,1:n-1);
                    Results.Data.CR(:) = ME.VolMax(:)./ME.VolMin(:);
                end
            end

            %% Save Data
            if record_data
                if ME.Model.recordStatistics
                    statistics = struct(...
                        'Time',Results.Data.t,...
                        'Angle',Results.Data.A,...
                        'Omega',Results.Data.dA,...
                        'To_Environment',Results.Data.QEnv,...
                        'To_Source',Results.Data.QSource,...
                        'To_Sink',Results.Data.QSink,...
                        'Flow_Loss',Results.Data.Flow_Loss,...
                        'ExergyLossShuttle',Results.Data.ExergyLossShuttle,...
                        'ExergyLossStatic',Results.Data.ExergyLossStatic,...
                        'Power',Results.Data.Power,...
                        'TotalPower',Plot_Powers,...
                        'Gas_Nodes',length(ME.P)-1,...
                        'Solid_Nodes',length(ME.T)-length(ME.P)+1,...
                        'Gas_Faces',length(ME.Fc_V),...
                        'Mixed_Faces',length(ME.Fc_R)-length(ME.Fc_V),...
                        'Solid_Faces',length(ME.Fc_Cond)-length(ME.Fc_R),...
                        'CR',Results.Data.CR,...
                        'VMin',sum(ME.VolMin(:)),...
                        'VMax',sum(ME.VolMin(:)));
                    if nargin > 4
                        if isempty(ME.Model.outputPath)
                            save([options.title '_Statistics'],'statistics');
                        else
                            save([ME.Model.outputPath '\' options.title '_Statistics'],'statistics');
                        end
                    else
                        if isempty(ME.Model.outputPath)
                            save([ME.Model.name '_Statistics'],'statistics');
                        else
                            save([ME.Model.outputPath '\' ME.Model.name '_Statistics'],'statistics');
                        end
                    end
                end
                if nargin > 4
                    if ~isempty(ME.Model.Sensors)
                        for iSensor = ME.Model.Sensors; iSensor.plotData(true,options.title); end
                    end
                    if ~isempty(ME.Model.PVoutputs)
                        for iPVoutput = ME.Model.PVoutputs; iPVoutput.plotData(true,options.title); end
                    end
                else
                    if ~isempty(ME.Model.Sensors)
                        for iSensor = ME.Model.Sensors; iSensor.plotData(true,ME.Model.name); end
                    end
                    if ~isempty(ME.Model.PVoutputs)
                        for iPVoutput = ME.Model.PVoutputs; iPVoutput.plotData(true,ME.Model.name); end
                    end
                end
            end
            if Load_Function_is_Not_Given
                ME.MechanicalSystem.LoadFunction = function_handle.empty;
            end
            %% Clean up
            clear assignDynamic;
            clear implicitSolve;
            % clear dUFunc;
            clear KValue;
            clear solve_loops;
        end

        function implicitSolve(ME,initialize) %#ok<INUSD>
            persistent indf;
            persistent indS;
            persistent indmf;
            persistent indn;
            persistent sindn;
            persistent indnminus;
            persistent indmfminus;
            persistent totalNodes;
            persistent isDynVol;
            persistent dvind;
            persistent lenf;
            persistent lenn;
            persistent nd0;
            persistent nd1;
            persistent nd2;
            persistent nd3;
            persistent nd1mf;
            persistent nd2mf;
            persistent Cfcs;
            persistent Cnd1;
            persistent Cnd2;
            persistent Pi;
            persistent Ti;
            persistent rhoEnv;
            persistent PEnv;
            persistent hEnv;
            persistent TEnv;
            persistent Fcrho;
            persistent Fch;
            persistent Fcmu;
            persistent FcT;
            persistent FcP;
            persistent theta_FL;
            persistent Q;
            persistent Qtd;
            persistent ReCritComparitor;
            persistent F2C;
            persistent ExFc;
            persistent ExR1;
            persistent ExR2;
            persistent ExLFc;
            persistent ExLC;
            persistent ExLN;
            persistent FlowTimeStep;
            persistent RecordStatistics;
            persistent facesES;
            persistent sgnES;
            persistent facesEG;
            persistent sgnEG;
            persistent facesSr;
            persistent sgnSr;
            persistent facesSi;
            persistent sgnSi;
            persistent Ci;
            persistent Cs;
            persistent Qi;
            persistent Qs;
            persistent C1;
            persistent C2;
            persistent C3;
            persistent C4;
            persistent CT;
            persistent nlambda;
            persistent hi;
            persistent dP_dt;
            persistent dh_dt;
            %       persistent handle;
            % persistent dP_dt;
            if nargin == 2
                %           handle = figure();
                dP_dt = zeros(length(ME.Regions),1);
                ME.Fc_V_averager = zeros(size(ME.Fc_V));
                ME.Fc_turb_averager = ME.Fc_V_averager;
                ME.assignDynamic(ME.Inc);
                indf = (1:length(ME.Fc_U))';
                if ~isempty(ME.Fc_DynShear_Factor)
                    indS = ME.Fc_DynShear_Factor(1,:);
                else
                    indS = [];
                end
                Cs = ME.m(ME.Fc_Nd(ME.FcApprox,2)).*ME.dh_dT(ME.Fc_Nd(ME.FcApprox,2));
                Cs(isinf(Cs)) = 1e6;
                indmf = ME.Mix_Fc;
                indn = (1:length(ME.P))';
                totalNodes = length(ME.T);
                lenf = length(indf);
                lenn = length(indn);
                sindn = (lenn+1:totalNodes);
                indnminus = (1:lenn-1)';
                nd0 = ME.Fc_Nd03(indf,1);
                nd1 = ME.Fc_Nd(indf,1);
                nd2 = ME.Fc_Nd(indf,2);
                nd3 = ME.Fc_Nd03(indf,2);
                nd1mf = ME.Fc_Nd(indmf,1);
                nd2mf = ME.Fc_Nd(indmf,2);
                isDynVol = logical(ME.isDynVol(indn));
                dvind = indn(isDynVol);
                elements = ME.dT_dU(nd2mf)>0;
                indmfminus = indmf(elements);
                nd2mf = nd2mf(elements);
                Ti = zeros(size(ME.T));
                Pi = zeros(size(ME.P));
                dh_dt = zeros(size(ME.P));
                rhoEnv = ME.rho(lenn);
                PEnv = ME.P(end);
                ME.h(indn) = ME.h(indn) + ME.T(indn).*ME.Rs(indn);
                hEnv = ME.h(lenn);
                TEnv = ME.T(lenn);
                Q = zeros(totalNodes,1);
                Qtd = Q;
                Cfcs = ME.Cond_Fcs;
                Cnd1 = ME.Cond_Nds1;
                Cnd2 = ME.Cond_Nds2;
                ReCritComparitor = [zeros(1,lenn-1); ...
                    11.5*ones(1,lenn-1)];
                ExR1 = ME.ExplicitNorm(:,2);
                ExR2 = ME.ExplicitNorm(:,3);
                F2C = ME.Fc2Col;
                ExFc = ME.ExplicitNorm(:,1);
                ExLFc = ME.ExplicitLeak(:,1);
                ExLC = ME.ExplicitLeak(:,2);
                ExLN = ME.ExplicitLeak(:,3);
                ME.Fc_V = zeros(lenf,1);

                Fch = zeros(lenf,1); Fcrho = Fch; Fcmu = Fch;
                FcT = Fch; FcP = Fch; theta_FL = Fch;

                FlowTimeStep = 1;
                RecordStatistics = ME.Model.recordStatistics;
                if RecordStatistics
                    facesES = ME.ToEnvironmentSolid(1,:);
                    sgnES = ME.ToEnvironmentSolid(2,:)';
                    facesEG = ME.ToEnvironmentGas(1,:);
                    sgnEG = ME.ToEnvironmentGas(2,:)';
                    facesSr = ME.ToSource(1,:); sgnSr = ME.ToSource(2,:)';
                    facesSi = ME.ToSink(1,:); sgnSi = ME.ToSink(2,:)';
                    ME.E_ToEnvironment = 0;
                    ME.E_ToSource = 0;
                    ME.E_ToSink = 0;
                    ME.E_Flow_Loss = 0;
                end
                return
            end
            t = 0; done = false;
            ME.Fc_V_averager(:) = 0;
            ME.Fc_turb_averager(:) = 0;
            while ~done
                hmax = min(ME.dt_max-t, ME.Solid_dt_max(ME.Inc));

                %% Assign Properties
                mi = ME.m(indn);
                hi = [ME.h; ME.T(sindn)./ME.dT_dU(sindn)];
                signU = sign(ME.Fc_U);
                Tnew = zeros(size(ME.vol(indn)));
                dm_dt = Tnew;
                hnew = Tnew;
                mnew = Tnew;

                inc = ME.Inc + t/ME.dt_max;

                time = ME.curTime + t;
                ME.assignDynamic(inc);
                ME.vol(ME.vol<=0) = 1e-8;
                Areai = ME.Fc_Area(indf);

                % Density - Upwinding
                rhoi = mi./ME.vol(indn);
                rhoi(end) = rhoEnv;

                % Pressure
                n = length(ME.Regions);
                for i = 1:n
                    nodes = ME.Regions{i};
                    uTemp = hi(nodes) - ME.Rs(nodes).*ME.T(nodes);
                    %ME.T(nodes) = ME.u2T{i}(uTemp);
                    TTemp = ME.T(nodes);
                    ME.k(nodes) = ME.kFunc{i}(TTemp);
                    ME.mu(nodes) = ME.muFunc{i}(TTemp);
                    ME.dT_dU(nodes) = ME.dT_duFunc{i}(uTemp);
                    ME.dh_dT(nodes) = (1./ME.dT_dU(nodes) + ME.Rs(nodes));
                    Ti(nodes) = TTemp;
                end
                Ti(sindn) = ME.T(sindn);
                ME.Fc_turb = 0.5*(ME.turb(nd1) + ME.turb(nd2));

                Pi = Ti(indn).*rhoi.*ME.Rs;

                Pi(end) = PEnv;
                FcP = 0.5*(Pi(nd1) + Pi(nd2));
                % Thermal Conductivity
                ME.k(dvind) = ME.k(dvind) + ...
                    0.021*rhoi(dvind).*ME.Dh(dvind).*ME.dh_dT(dvind).*sqrt(ME.turb(dvind));
                % Viscosity
                ME.mu(dvind) = ME.mu(dvind) + 0.021*rhoi(dvind).*ME.Dh(dvind).*sqrt(ME.turb(dvind));
                % Do flux limiting on the int energy, then calculate T from u2T
                forward = (ME.Fc_V > 0);
                % Fch = 0.5*(hi(nd1) + hi(nd2));
                Fch(forward) = hi(nd1(forward));
                FcT(forward) = Ti(nd1(forward));
                Fch(~forward) = hi(nd2(~forward));
                FcT(~forward) = Ti(nd2(~forward));
                Fcrho(forward) = rhoi(nd1(forward));
                Fcrho(~forward) = rhoi(nd2(~forward));
                theta_FL(forward) = (hi(nd1(forward))-hi(nd0(forward)))./...
                    (hi(nd2(forward))-hi(nd1(forward)));
                theta_FL(~forward) = (hi(nd2(~forward))-hi(nd3(~forward)))./...
                    (hi(nd1(~forward))-hi(nd2(~forward)));
                theta_FL(isnan(theta_FL)) = 1;
                theta_FL(theta_FL > 1) = 1;
                theta_FL(theta_FL < -1) = -1;
                factor = ((theta_FL.^2 + theta_FL)./(theta_FL.^2 + 1));
                Fch = Fch + factor.*(ME.Fc_A.*hi(nd0) + ME.Fc_B.*hi(nd1) + ...
                    ME.Fc_C.*hi(nd2) + ME.Fc_D.*hi(nd3) - Fch);
                n = length(ME.Regions);
                for i = 1:n
                    faces = ME.RegionFcs{i};
                    ME.Fc_k(faces) = ME.kFunc{i}(FcT(faces));
                    Fcmu(faces) = ME.muFunc{i}(FcT(faces));
                end
                ME.PR = abs(ME.dh_dT.*ME.mu./ME.k);
                ME.Fc_PR = 0.5*(ME.PR(nd1) + ME.PR(nd2));

                % Parameters used by outside calculation
                ME.Fc_RE = abs(ME.Fc_U.*Fcrho.*ME.Fc_Dh./Fcmu);
                ME.Fc_RE(ME.Fc_RE==0) = 1e-8;
                ME.getWeight();

                % Assign Node Reynold's Number
                area = zeros(lenn-1,1);
                ME.RE = area;
                for i = 1:3:length(ME.TransNet)-2
                    ME.RE(ME.TransNet{i+1}) = ME.RE(ME.TransNet{i+1}) + ...
                        ME.Fc_RE(ME.TransNet{i+2}).*Areai(ME.TransNet{i+2});
                    area(ME.TransNet{i+1}) = area(ME.TransNet{i+1}) + ...
                        Areai(ME.TransNet{i+2});
                end
                ME.RE = ME.RE./(area);
                ME.RE(isnan(ME.RE)) = 1e-8;

                %% Calculate Flow Independent Energy Flux to Nodes
                invConv = ME.Dh(indnminus)./(ME.k(indnminus).*ME.Nusselt());
                ME.Fc_Cond(indmf) = ME.Fc_Area(indmf)./(ME.Fc_R(indmf)' + invConv(nd1mf));
                ME.Fc_Cond(indf) = ME.NkFunc().*ME.Fc_k(indf).*Areai./ME.Fc_Cond_Dist(indf);
                ME.Fc_Cond(indS) = ME.Fc_Cond(indS) + abs((ME.dA/4)*(1./ME.dT_dU(indS)).*...
                    ME.Fc_Shear_Factor(indS).*Fcrho(indS).*Areai(indS));

                Q(:) = 0;
                Qfc = ME.Fc_Cond(Cfcs).*(Ti(Cnd1) - Ti(Cnd2));
                for i = 1:3:length(ME.CondNet)-2
                    Q(ME.CondNet{i+1}) = Q(ME.CondNet{i+1}) + ME.CondNet{i}.*Qfc(ME.CondNet{i+2});
                end

                fcs = ME.FcApprox;
                Ci = mi(ME.Fc_Nd(fcs,1)).*ME.dh_dT(ME.Fc_Nd(fcs,1));
                C1 = Ci + Cs;
                CT = (Ti(ME.Fc_Nd(fcs,1)).*Ci + Ti(ME.Fc_Nd(fcs,2)).*Cs)./C1 - Ti(ME.Fc_Nd(fcs,1));
                nlambda = -ME.Fc_Cond(fcs).*(1./Cs + 1./Ci);
                Qs = Q(ME.Fc_Nd(fcs,2));
                BW = zeros(size(Q(indn)));

                % Assign TimeStep
                if ~isempty(ME.Fc_dx)
                    if ~isempty(ME.Fc_Cond)
                        hmax = min([hmax FlowTimeStep ...
                            ME.MaxFourier*...
                            min(min(mi(nd1)./(ME.dT_dU(nd1).*ME.Fc_Cond(indf))), ...
                            min(mi(nd2)./(ME.dT_dU(nd2).*ME.Fc_Cond(indf)))) ...
                            ME.MaxFourier*min(mi(nd1mf)./(ME.dT_dU(nd1mf).*ME.Fc_Cond(indmf))) ...
                            ME.MaxFourier*min(ME.m(nd2mf)./(ME.dT_dU(nd2mf).*ME.Fc_Cond(indmfminus)))]);
                    else
                        hmax = min([hmax FlowTimeStep ...
                            ME.MaxFourier*min(mi(nd1mf)./(ME.dT_dU(nd1mf).*ME.Fc_Cond(indmf))) ...
                            ME.MaxFourier*min(ME.m(nd2mf)./(ME.dT_dU(nd2mf).*ME.Fc_Cond(indmfminus)))]);
                    end
                else
                    if ~isempty(ME.Fc_Cond)
                        hmax = min([hmax ...
                            ME.MaxFourier*...
                            min(min(mi(nd1)./(ME.dT_dU(nd1).*ME.Fc_Cond(indf))), ...
                            min(mi(nd2)./(ME.dT_dU(nd2).*ME.Fc_Cond(indf))))]);
                    end
                end
                %hmax = 1e-5;

                RegionPressure = zeros(n,1);
                %         dm_region = RegionPressure;
                %         m_region = RegionPressure;
                %         V_region = RegionPressure;
                %         dV_region = RegionPressure;
                E_region = RegionPressure;

                %% Calculate Explicit Volume Flow - Normal
                if ~isempty(ME.ExplicitNorm)
                    ME.Fc_dP(ExFc) = Pi(nd1(ExFc)) - Pi(nd2(ExFc));
                    x = sign(ME.Fc_dP(ExFc)).*...
                        sqrt(2*(Areai(ExFc).^2).*abs(ME.Fc_dP(ExFc))./Fcrho(ExFc));
                    V = ME.Fc_V(ExFc);
                    V_max = 350*Areai(ExFc);
                    V(V > V_max) = V_max(V > V_max);
                    iteration = 1;
                    while iteration < 100
                        oldV = V;
                        K = ME.KValue(ExFc);
                        V = x./sqrt(K);
                        V(V > V_max) = V_max(V > V_max);
                        V(isnan(V)) = 1;
                        if CustomRSSQ(oldV-V) < 1e-8; break; end
                    end
                    ME.Fc_V(ExFc) = V;
                    for i = 1:length(ExR1)
                        E = ME.Fc_V(ExFc(i)).*FcP(ExFc(i));
                        E_region(ExR1(i)) = E_region(ExR1(i)) - E;
                        E_region(ExR2(i)) = E_region(ExR2(i)) + E;
                    end
                end

                %% Calculate Explicit Volume Flow - Leak
                if ~isempty(ME.ExplicitLeak)
                    dP = Pi(nd1(ExLFc)) - Pi(nd2(ExLFc));
                    ME.Fc_V(ExLFc) = sign(dP).*ExLC.*(abs(dP)).^ExLN;
                    for i = 1:length(ExLR1)
                        if ME.Fc_V(ExLFc(i)) > 0; x = Pi(nd2(ExLFc(i)));
                        else; x = Pi(nd1(ExLFc(i)));
                        end
                        E = ME.Fc_V(ExLFc(i)).*x;
                        E_region(ExLR1(i)) = E_region(ExLR1(i)) - E;
                        E_region(ExLR2(i)) = E_region(ExLR2(i)) + E;
                    end
                end

                % Assume that flow can't change that much
                if ~isempty(ME.Fc_dx); h = min(hmax, 0.8*FlowTimeStep);
                else; h = hmax;
                end

                % Boundary Work
                P0 = zeros(length(ME.Regions),1);
                for i = 1:length(ME.Regions)
                    if ME.isEnvironmentRegion(i)
                        P0(i) = PEnv;
                    else
                        %             nodes = ME.Regions{i};
                        %             ni = nodes(1);
                        %             P0(i) = Ti(ni)*ME.R(i)*mi(ni)/ME.vol(ni);
                        %             dV_dt_region = sum(ME.dV_dt(nodes));
                        %             M_region = sum(mi(nodes));
                        %             E_region(i) = E_region(i) - P0(i)*dV_dt_region;
                        %             Q(nodes) = (mi(nodes)/M_region).*E_region(i);
                        %             nodes = ME.Regions{i}(isDynVol(ME.Regions{i}));
                        nodes = ME.Regions{i}(:);
                        P0(i) = sum(Ti(nodes).*ME.R(i).*mi(nodes))/sum(ME.vol(nodes));
                        dV_dtregion = sum(ME.dV_dt(nodes));
                        m_region = sum(mi(nodes));
                        for ni = nodes
                            BW(ni) =  dV_dtregion.*mi(ni)./m_region;
                        end
                    end
                end


                %% Setup Variables for Volume Flux Solving
                not_done = true;
                while not_done
                    i = 1;
                    Qi = Q(ME.Fc_Nd(fcs,1));
                    for nd = ME.Fc_Nd(fcs,1)'
                        data = ME.Faces{nd,1};
                        mdot = ME.Fc_V(data(:,1)).*double(data(:,2)).*Fcrho(data(:,1));
                        dm_dt(nd) = sum(mdot);
                        Qi(i) = Qi(i) + ...
                            sum(mdot.*(Fch(data(:,1)) + P0(i)./Fcrho(data(:,1)))) - ...
                            P0(i).*ME.dV_dt(nd);
                        %             Qi(i) = Qi(i) + ...
                        %               sum(mdot.*(Fcu(data(:,1)) + (P0(i) + dP_dt(i,ME.Inc))./Fcrho(data(:,1)))) - ...
                        %               P0(i).*ME.dV_dt(nd) - h*(ME.vol(nd) + 0.5*ME.dV_dt(nd)).*dP_dt(i,ME.Inc);
                        i = i + 1;
                    end
                    C2 =(Qi + Qs)./C1;
                    C3 = (Ci.*Qs - Cs.*Qi)./(ME.Fc_Cond(fcs).*C1.^2);
                    C3(isnan(C3)) = 0;
                    C3(isinf(C3)) = 0;
                    C4 = (Ti(ME.Fc_Nd(fcs,1)) - Ti(ME.Fc_Nd(fcs,2)))./(C3.*C1);
                    C4(isnan(C4)) = 0;
                    C4(isinf(C4)) = 0;
                    Qtd(:) = 0;
                    Qtemp = -(Ci.*(CT-Cs.*C3.*(1-(1+C4)).*exp(nlambda*h))+(Ci.*C2-Qi)*h);
                    for i = 1:length(ME.FcApprox)
                        fc = ME.FcApprox(i);
                        % 1st is gas, it can have multiple connections
                        Qtd(ME.Fc_Nd(fc,1)) = Qtd(ME.Fc_Nd(fc,1)) - Qtemp(i);
                        % 2nd is solid, it can only have 1 connection
                        Qtd(ME.Fc_Nd(fc,2)) = Qtemp(i);
                    end

                    not_done = false;
                    Vnew = ME.vol(indn) + h*ME.dV_dt(indn);

                    for ind = find(Vnew<=0); Vnew(ind) = 1e-8; end

                    %% Enter Volume Flux Solving Loop
                    % Qtemp = zeros(size(Q(indn)));
                    for i = 1:length(ME.Regions)
                        if ~isempty(ME.RegionFcs{i})
                            faces = ME.ActiveRegionFcs{i};
                            nodes = ME.Regions{i};
                            A = zeros(ME.RegionFcCount(i));
                            b = zeros(ME.RegionFcCount(i),1);
                            if ME.isEnvironmentRegion(i)
                                % Vdot Rows
                                for row = 1:length(faces)
                                    ni = nodes(row);
                                    b(row) = Vnew(ni)*PEnv/ME.R(i) - Ti(ni)*mi(ni) + ...
                                        (Qtd(ni) + h*(Q(ni) + BW(ni)))/ME.dh_dT(ni);
                                    %                   b(row) = Vnew(ni)*PEnv/ME.R(i) - Ti(ni)*mi(ni) + ...
                                    %                     (Qtd(ni) + h*(Q(ni) - PEnv.*ME.dV_dt(ni)))/ME.dh_dT(ni);
                                    data = ME.Faces{ni,1};
                                    for p = 1:size(data,1)
                                        fc = data(p,1);
                                        y = double(data(p,2));
                                        X = h*y*(Ti(ni)+(Fch(fc)-hi(ni))/ME.dh_dT(ni))/Vnew(ni);
                                        if data(p,3); b(row) = b(row) - ME.Fc_V(fc)*X;
                                        else; A(row,F2C(fc)) = A(row,F2C(fc)) + X;
                                        end
                                    end
                                end
                                if isempty(ME.RegionLoops{i})
                                    As = sparse(A);
                                    %                 [Peq,Req,Ceq] = equilibrate(As);
                                    % Ax=b into By=d, B = RPAC, d = RPb, x = Cy
                                    %                   As = Req*Peq*As*Ceq;
                                    %                   b = Req*Peq*b;
                                    m = A\b;%Ceq*(As\b);
                                    ME.Fc_V(faces) = m(F2C(faces))./Fcrho(faces);
                                    ME.Fc_U(faces) = ME.Fc_V(faces)./ME.Fc_Area(faces) + ME.Fc_Vel_Factor(faces)*ME.dA;
                                else
                                    solve_loops(ME,i,F2C,length(faces)+1,A,b,Fcrho,Fcmu,time);
                                end
                            else
                                % Solve for Vdot
                                for row = 1:length(faces)
                                    ni = nd1(faces(row));
                                    nj = nd2(faces(row));
                                    b(row) = ...
                                        (Ti(ni)*mi(ni) + (Qtd(ni) + h*(Q(ni) + BW(ni)))/ME.dh_dT(ni))/Vnew(ni) - ...
                                        (Ti(nj)*mi(nj) + (Qtd(nj) + h*(Q(nj) + BW(nj)))/ME.dh_dT(nj))/Vnew(nj);
                                    %                 b(row) = (Ti(ni)*mi(ni) + (Qtd(ni) + ...
                                    %                     h*(Q(ni) - P0(i).*ME.dV_dt(ni)))/ME.dh_dT(ni))/Vnew(ni) - ...
                                    %                     (Ti(nj)*mi(nj) + (Qtd(nj) + ...
                                    %                     h*(Q(nj) - P0(i).*ME.dV_dt(nj)))/ME.dh_dT(nj))/Vnew(nj);
                                    %                   b(row) = ...
                                    %                     (Ti(ni)*mi(ni) + ME.dT_dU(ni)*(h*Q(ni) + Qtd(ni) ...
                                    %                     - (P0(i) + 0.5*h*dP_dt(i,ME.Inc)).*(Vnew(ni)-ME.vol(ni)) ...
                                    %                     - h*(ME.vol(ni)).*dP_dt(i)))/Vnew(ni) - ...
                                    %                     (Ti(nj)*mi(nj) + ME.dT_dU(nj)*(h*Q(nj) + Qtd(nj)...
                                    %                     - (P0(i) + 0.5*h*dP_dt(i,ME.Inc)).*(Vnew(nj)-ME.vol(nj)) ...
                                    %                     - h*(ME.vol(nj)).*dP_dt(i)))/Vnew(nj);
                                    data = ME.Faces{ni,1};
                                    for p = 1:size(data,1)
                                        fc = data(p,1);
                                        y = double(data(p,2));
                                        X = h*y*(Ti(ni) + (Fch(fc) - hi(ni))/ME.dh_dT(ni))/Vnew(ni);
                                        %                     X = h*double(data(p,2))*Fcrho(fc)*(...
                                        %                       Ti(ni) + ME.dT_dU(ni)*(Fcu(fc) - ui(ni)...
                                        %                       + (P0(i) + 0.5*h*dP_dt(i,ME.Inc))/Fcrho(fc)))/Vnew(ni);
                                        if data(p,3); b(row) = b(row) + ME.Fc_V(fc)*X;
                                        else; A(row,F2C(fc)) = A(row,F2C(fc)) - X;
                                        end
                                    end
                                    data = ME.Faces{nj,1};
                                    for p = 1:size(data,1)
                                        fc = data(p,1);
                                        y = double(data(p,2));
                                        X = h*y*(Ti(nj) + (Fch(fc) - hi(nj))/ME.dh_dT(nj))/Vnew(nj);
                                        %                     X = h*double(data(p,2))*Fcrho(fc)*(...
                                        %                       Ti(nj) + ME.dT_dU(nj)*(Fcu(fc) - ui(nj)...
                                        %                       + (P0(i) + 0.5*h*dP_dt(i,ME.Inc))/Fcrho(fc)))/Vnew(nj);
                                        if data(p,3); b(row) = b(row) - ME.Fc_V(fc)*X;
                                        else; A(row,F2C(fc)) = A(row,F2C(fc)) + X;
                                        end
                                    end
                                end
                                %                 figure(handle);
                                %                 plot(Ti(nodes));
                                if isempty(ME.RegionLoops{i})
                                    As = sparse(A);
                                    %                   [Peq,Req,Ceq] = equilibrate(As);
                                    % Ax=b into By=d, B = RPAC, d = RPb, x = Cy
                                    %                   As = Req*Peq*As*Ceq;
                                    %                   temp = condest(As)
                                    %                   b = Req*Peq*b;
                                    m = As\b;%Ceq*(As\b);
                                    if any(isnan(m)) || any(any(isnan(A))) || any(isnan(b))
                                        ME.stop = true;
                                    end
                                    ME.Fc_V(faces) = m(F2C(faces))./Fcrho(faces);
                                    ME.Fc_U(faces) = ME.Fc_V(faces)./ME.Fc_Area(faces) + ME.Fc_Vel_Factor(faces)*ME.dA;
                                else
                                    solve_loops(ME,i,F2C,length(faces)+1,A,b,Fcrho,Fcmu,time);
                                end
                                % Calculate dP
                                %{
                ni = ME.Regions{i}(1);
                data = ME.Faces{ni,1};
                mdot = ME.Fc_V(data(:,1)).*double(data(:,2)).*Fcrho(data(:,1));
                mnewi = ME.m(ni) + h*sum(mdot);
                unewi = ui(ni) + (... u + 
                  h*Q(ni) + Qtd(ni) ...
                  - (P0(i) + 0.5*h.*dP_dt(i,ME.Inc)).*(Vnew(ni) - ME.vol(ni)) ...
                  - 0.5*h*(Vnew(ni) + ME.vol(ni)).*dP_dt(i,ME.Inc) ... (dU
                  - ui(ni).*dm_dt(ni).*h)./mnew(ni); % - u dm)/mnew;
                newValue = (mnewi*ME.u2T{i}(unewi)*ME.R(i)/Vnew(ni) - Pi(ni))/h;
                if newValue ~= 0
                  if abs(dP_dt(i,ME.Inc)-newValue) > 1e-4 && abs((dP_dt(i,ME.Inc)-newValue)/dP_dt(i,ME.Inc)) > 0.01
                    not_done = true;
                    dP_dt(i,ME.Inc) = newValue;
                  else
                    if ME.Inc < Frame.NTheta
                      if dP_dt(i,ME.Inc+1) == 0
                        dP_dt(i,ME.Inc+1) = dP_dt(i,ME.Inc);
                      end
                    end
                  end
                end
                                %}
                            end
                        end
                    end
                    if ~isempty(ME.Fc_dx)
                        FlowTimeStep = max(1e-8, min(ME.MaxCourant*ME.Fc_dx./(abs(ME.Fc_V./(ME.Fc_Area(1:lenf)+1e-8)))));
                        if FlowTimeStep < h
                            not_done = true;
                            h = FlowTimeStep;
                        end
                    end
                    if isnan(FlowTimeStep)
                        ME.stop = true;
                        break;
                    end
                end

                % Vnew = ME.vol(indn) + h*ME.dV_dt(indn);
                % Update Parameters
                for i = 1:n
                    nodes = ME.Regions{i};
                    %           Pregion_avg(i) = Pi(nodes(1)) + 0.5*h*dP_dt(i,ME.Inc);
                    if ME.isEnvironmentRegion(i); nodes = nodes(nodes~=lenn); end
                    for nd = nodes'
                        data = ME.Faces{nd,1};
                        mdot = ME.Fc_V(data(:,1)).*double(data(:,2)).*Fcrho(data(:,1));
                        dm_dt(nd) = sum(mdot);
                        Q(nd) = Q(nd) + sum(mdot.*Fch(data(:,1)));
                    end
                    mnew(nodes) = mi(nodes) + h*dm_dt(nodes);
                    hnew(nodes) = (hi(nodes).*mi(nodes) + Qtd(nodes) + ...
                        h.*(Q(nodes) + BW(nodes)))./mnew(nodes);
                    %           hnew(nodes) = (hi(nodes).*mi(nodes) + Qtd(nodes) + h.*(Q(nodes) - P0(i).*ME.dV_dt(nodes))./mnew(nodes);
                    Tnew(nodes) = ME.T(nodes) + (hnew(nodes) - hi(nodes))./ME.dh_dT(nodes);
                    ME.P(nodes) = ME.R(i).*mnew(nodes).*Tnew(nodes)./Vnew(nodes);
                    % Fix The parameters to ensure that the pressure is constant
                    %           if ME.isEnvironmentRegion(i)
                    %             Pavg = PEnv; % dP_dt(i) = 0;
                    %           else
                    %             Pavg = sum(ME.P(nodes).*ME.vol(nodes))/sum(ME.vol(nodes));
                    % %             if ME.Inc == 1 && t == 0
                    % %               dP_dt(i) = dP_dt(i);
                    % %             else
                    % %               dP_dt(i) = (Pavg - P0(i))/h;
                    % %             end
                    %           end
                    %Tnew(nodes) = Pavg./ME.P(nodes).*Tnew(nodes);
                    % dP_dt(i) = (ME.P(nodes(1)) - P0(i))/h;
                end
                ME.P(lenn) = PEnv;

                %% TURBULENCE ITEMS
                if lenf ~= 0
                    change = indf(sign(ME.Fc_U(indf))~=signU);
                    ME.Fc_to(change) = ME.curTime + t;
                    changed_nodes = false(lenn,1);
                    changed_nodes(nd1(change)) = true;
                    changed_nodes(nd2(change)) = true;
                    changed_nodes(isDynVol) = false;
                    ME.to(changed_nodes) = ME.curTime + t;
                    ME.turb(changed_nodes) = 0;
                    % Define (for those that care) the critcal reynolds number
                    ME.Va(indnminus) = ME.dA*rhoi(indnminus).*(ME.Dh(indnminus).^2)./ME.mu(indnminus);
                    ReCritComparitor(1,:) = (sqrt(ME.Va(indnminus))./...
                        (0.075+0.112.*(ME.curTime + t - ME.to(1:lenn-1))))';
                    ME.REcrit(indnminus) = 200*max(ReCritComparitor);
                    TurbTime = 0;
                    steps = ME.Fc_K12 > 0;
                    while TurbTime < h
                        ME.Fc_turb =  0.5*(ME.turb(nd1) + ME.turb(nd2));
                        h_turb = h - TurbTime;
                        dturb_dt = zeros(lenn,1);
                        % Turbulence Transport
                        for i = indf(steps)'
                            n1 = nd1(i);
                            n2 = nd2(i);
                            % dturb_dt = turb*(dKE_dt / KE - dm_dt / m)
                            if ME.Fc_V(i) > 0
                                % Leaving n1
                                % Leaving a variable volume space ... No change to kappa
                                if ~isDynVol(n1)
                                    dturb_dt(n1) = dturb_dt(n1) + (- ME.Fc_turb(i) + ME.turb(n1));
                                end
                                % Entering n2
                                if isDynVol(n2)
                                    dKE_dm = 0.5*(ME.Fc_V(i)/Areai(i))^2;
                                    dturb_dt(n2) = dturb_dt(n2) + (dKE_dm - ME.turb(n2));
                                else
                                    dturb_dt(n2) = dturb_dt(n2) + (1 - ME.turb(n2));
                                end
                            else
                                % Entering n1
                                if isDynVol(n1)
                                    dKE_dm = 0.5*(ME.Fc_V(i)/Areai(i))^2;
                                    dturb_dt(n1) = dturb_dt(n1) + (dKE_dm - ME.turb(n1));
                                else
                                    dturb_dt(n1) = dturb_dt(n1) + (1 - ME.turb(n1));
                                end
                                % Leaving n2
                                % Leaving a variable volume space ... No change to kappa
                                if ~isDynVol(n2)
                                    dturb_dt(n2) = dturb_dt(n2) + (- ME.Fc_turb(i) + ME.turb(n2));
                                end
                            end
                        end
                        for i = indf(~steps)'
                            % dturb_dt = turb*(dKE_dt / KE - dm_dt / m)
                            % dturb_dt = turb * (dKE_dm / ke - 1) * dm_dt / m
                            % dturb_dt = .... * (dKE_dm / ke - 1) * ..... / ..
                            dKE_dm = ME.Fc_turb(i);
                            dturb_dt(nd1(i)) = dturb_dt(nd1(i)) - ...
                                (dKE_dm - ME.turb(nd1(i))) * sign(ME.Fc_V(i));
                            dturb_dt(nd2(i)) = dturb_dt(nd2(i)) + ...
                                (dKE_dm - ME.turb(nd2(i))) * sign(ME.Fc_V(i));
                        end
                        dturb_dt = dturb_dt .* (dm_dt ./ mi);

                        %% Turbulence Decay/Generation Within Nodes
                        for i = 1:lenn-1
                            if isDynVol(i)
                                % Variable Volume
                                % F. J. Cantelmi, Measurement and Modeling of In-Cylinder Heat Transfer
                                %    with Inflow-Produced Turbulence, MS Thesis, Virginia Polytechnic Institute
                                %    and State University, June (1995)
                                dturb_dt(i) = dturb_dt(i) - ...
                                    5.8*(abs(ME.turb(i) + dturb_dt(i)*h)^(3/2))/ME.Dh(i) - ...
                                    ME.turb(i)/mi(i)*dm_dt(i);
                            else
                                if ME.RE(i) > ME.REcrit(i)
                                    % Generate
                                    dturb_dt(i) = dturb_dt(i) + ...
                                        (0.008*ME.dA*ME.RE(i)/ME.Va(i))*(1-ME.turb(i));
                                else
                                    % Decay
                                    dturb_dt(i) = dturb_dt(i) - ...
                                        (0.25*ME.dA*2300/ME.Va(i))*abs(ME.turb(i))^(3/2);
                                end
                            end
                        end
                        % Test - To limit timestep
                        d_turb = zeros(size(ME.turb(indn)));
                        for i = indn'
                            if isDynVol(i)
                                d_turb(i) = h_turb*dturb_dt(i);
                            else
                                d_turb(i) = max(0,min(1,ME.turb(i) + ...
                                    h_turb*dturb_dt(i))) - ME.turb(i);
                            end
                        end
                        max_d_turb = max(abs(d_turb(~isDynVol(indn))));
                        if max_d_turb > 0.1; h_turb = h_turb*0.1/max_d_turb; end
                        % Assign Values
                        ME.turb = ME.turb + h_turb*dturb_dt;
                        ME.turb(ME.turb<0) = 0;
                        for i = indn'
                            if ME.turb(i) > 1 && ~isDynVol(i)
                                ME.turb(i) = 1;
                            end
                        end
                        ME.turb(lenn) = 0;
                        TurbTime = TurbTime + h_turb;
                    end
                end

                if ME.Model.recordOnlyLastCycle
                    for i = 1:length(ME.Regions)
                        if ~ME.isEnvironmentRegion(i)
                            nodes = ME.Regions{i};
                            ME.PRegion(i) = ME.PRegion(i) + ME.P(nodes(1))*h;
                        end
                    end
                    ME.PRegionTime = ME.PRegionTime + h;
                    %           i = 1;
                    %           for iPVoutput = ME.Model.PVoutputs
                    %             ME.PRegion(i) = ME.PRegion(i) + ME.P(iPVoutput.RegionNodes(1))*h;
                    %             ME.PRegionTime(i) = ME.PRegionTime(i) + h;
                    %             i = i + 1;
                    %           end
                end

                % Mass Change
                ME.m(indn) = mnew(indn);

                % Enthalpy Energy Change
                ME.h(indn) = hnew(indn);

                % Temperature
                ME.T(indn) = Tnew(indn);
                ME.T(sindn) = ME.T(sindn) + ...
                    ME.dT_dU(sindn).*(h*Q(sindn) + Qtd(sindn))./ME.m(sindn);

                % Environment
                ME.m(lenn) = inf;
                ME.h(lenn) = hEnv;
                ME.T(lenn) = TEnv;

                % Basic Boundary Work
                ME.CycledE = ME.CycledE + h*(0.5*sum(ME.dV_dt.*(Pi + ME.P)));

                % Parameters used by functions that are called after each
                % ... angular increment.
                if lenf ~= 0
                    ME.Fc_V_averager = ME.Fc_V_averager + h*ME.Fc_V;
                    ME.Fc_turb_averager = ME.Fc_turb_averager + h*ME.Fc_turb;
                end
                t = t + h;
                if t >= ME.dt_max
                    done = true;
                    % Setup for Flow Loss Calculation
                    ME.Fc_V = ME.Fc_V_averager / ME.dt_max;
                    ME.Fc_turb = ME.Fc_turb_averager / ME.dt_max;
                    for i = 1:length(ME.Regions)
                        if isempty(ME.RegionLoops{i})
                            faces = ME.ActiveRegionFcs{i};
                            ME.Fc_RE(faces) = abs(ME.Fc_U(faces).*Fcrho(faces).*ME.Fc_Dh(faces)./Fcmu(faces));
                            ME.Fc_RE(ME.Fc_RE==0) = 1e-7;
                            ME.getWeight(faces);
                            ME.KpU_2A(faces) = ME.KValue(faces).*Fcrho(faces).*ME.Fc_U(faces)./Areai(faces);
                        end
                    end

                    if ME.ss_condition || ~ME.continuetoSS
                        % Get cycle time for averaging the effective conductance and
                        % ... conductance temperatures
                        ME.CycleTime = ME.CycleTime + ME.dt_max;

                        % Calculate Effective Conduction for mixed faces
                        ME.CondEff(indmf) = ME.CondEff(indmf) + ...
                            ME.dt_max * ME.Fc_Cond(indmf);

                        % Calculate the Effective Conduction * Temperature of mixed faces
                        ME.CondTempEff(indmf) = ME.CondTempEff(indmf) + ...
                            ME.dt_max * ME.Fc_Cond(indmf).* ME.T(nd1mf);

                        % Test The reynold's number
                        %             if isempty(ME.EffRE); ME.EffRE = zeros(size(indn)); end
                        %             ME.EffRE = ME.EffRE + ...
                        %               (ME.dt_max/sum(ME.vol(indnminus))) * sum(ME.Dh(indnminus).*ME.vol(indnminus));
                    end

                    % Record statistics
                    if ME.Model.recordConductionFlux
                        ME.CondFlux(:) = 0;
                        for i = 1:3:length(ME.CondNet)-2
                            ME.CondFlux(ME.CondNet{i+1}) = ...
                                ME.CondFlux(ME.CondNet{i+1}) + ...
                                abs(ME.CondNet{i}.*Qfc(ME.CondNet{i+2}));
                        end
                        if any(~isreal(Qtd(:)))
                            fprintf('err');
                        end
                        ME.CondFlux = (ME.CondFlux + real(Qtd(:)))./ME.vol;
                    end
                    if RecordStatistics
                        ME.E_ToEnvironment = ME.E_ToEnvironment + ...
                            ME.dt_max*(sum(Qfc(facesES).*sgnES) + ...
                            sum(sgnEG.*(Qfc(facesEG) + ...
                            ME.Fc_V(facesEG).*rhoi(facesEG).*hi(facesEG))));
                        ME.E_ToSource = ME.E_ToSource + ...
                            ME.dt_max*sum(Qfc(facesSr).*sgnSr);
                        ME.E_ToSink = ME.E_ToSink + ...
                            ME.dt_max*sum(Qfc(facesSi).*sgnSi);
                        if length(ME.VolMin) < length(ME.Regions)
                            ME.VolMin = 100000*ones(size(ME.Regions));
                            ME.VolMax = zeros(size(ME.Regions));
                        end
                        for i = 1:length(ME.Regions)
                            if ~ME.isEnvironmentRegion(i)
                                nodes = ME.Regions{i};
                                Vol = sum(ME.vol(nodes));
                                ME.VolMin(i) = min(ME.VolMin(i),Vol);
                                ME.VolMax(i) = max(ME.VolMax(i),Vol);
                            end
                        end
                        % Qfc = ME.Fc_Cond(Cfcs).*(Ti(Cnd1) - Ti(Cnd2));
                        TRatio = Ti(Cnd1)./Ti(Cnd2);
                        TRatio(TRatio>1) = 1./TRatio(TRatio>1);
                        ME.ExergyLossStatic = ME.ExergyLossStatic + ...
                            ME.dt_max*sum(abs(Qfc(ME.StaticFaces).*(1-TRatio(ME.StaticFaces))));
                        ME.ExergyLossShuttle = ME.ExergyLossShuttle + ...
                            ME.dt_max*sum(abs(Qfc(ME.ShuttleFaces).*(1-TRatio(ME.ShuttleFaces))));
                    end
                end
            end
        end

        function solve_loops(ME,region,F2C,startrow,A,b,Fcrho,Fcmu,time)
            persistent recordValues;
            persistent recordTimes;
            if isempty(recordValues)
                recordValues = cell(length(ME.Regions),1);
                recordTimes = recordValues;
                for indl = 1:length(ME.Regions)
                    recordValues{indl} = [];
                    recordTimes{indl} = [];
                end
            end

            % Loop Definitions
            loop = ME.RegionLoops{region};
            Ind = ME.RegionLoops_Ind{region};
            Nloops = size(Ind, 2);

            % UnCollapsed References
            rows = startrow:startrow + Nloops-1;

            % Predict Values at this time-step
            if size(recordValues{region},2) == 3
                % Quadratically Extrapolate
                y0 = recordValues{region}(:,1);
                y1 = recordValues{region}(:,2);
                y2 = recordValues{region}(:,3);
                x0 = recordTimes{region}(1);
                x1 = recordTimes{region}(2);
                x2 = recordTimes{region}(3);
                prediction = ...
                    y0*(((time-x1)*(time-x2)) / ((x0-x1)*(x0-x2))) + ...
                    y1*(((time-x0)*(time-x2)) / ((x1-x0)*(x1-x2))) + ...
                    y2*(((time-x0)*(time-x1)) / ((x2-x0)*(x2-x1)));
            end

            skipLoop = false(Nloops,1);
            % Define loops that participate
            for p = 1:Nloops
                if Ind(3, p) && ME.Fc_Area(Ind(3, p)) == 0
                    % The Area has gone to 0, therefore the volume flow rate is 0
                    A(rows(p), F2C(Ind(3, p))) = 1;
                    skipLoop(p) = true;
                else
                    % The entry in "A" will be a 1, to set the volume flow rate to the
                    % ... value defined in "b". The Last entry of the loop is the
                    % ... only one that cannot be a part of another loop.
                    A(rows(p), F2C(loop(2,Ind(2,p)))) = 1;
                    if size(recordValues,2) == 3
                        b(rows(p)) = prediction(p);
                    else
                        b(rows(p)) = ME.Fc_V(loop(2, Ind(2, p))).*Fcrho(loop(2, Ind(2, p)));
                    end
                end
            end

            % Calculate inverse of matrix
            %       [Peq,Req,Ceq] = equilibrate(A);
            % Ax=b into By=d, B = RPAC, d = RPb, x = Cy
            %       b = Req*Peq*b;
            %       A = Req*Peq*A*Ceq;
            Ainv = inv(A);%Ceq*inv(A);

            % Eliminate the rows that are not useful outputs
            indl = 1:length(skipLoop);
            rows(skipLoop) = [];
            indl(skipLoop) = [];
            x = Ainv*b;

            % Initialize Solving Loop
            iteration = 1;
            max_iterations = 300;
            fn = ones(length(indl),1);

            tol = 1e-8;
            if ~isempty(indl)

                %  Newton's Method
                J = zeros(length(indl));

                while iteration < max_iterations

                    for i = 1:length(indl)
                        Sgni = loop(3,Ind(1,indl(i)):Ind(2,indl(i)))';
                        Fcsi = loop(2,Ind(1,indl(i)):Ind(2,indl(i)));
                        for j = 1:length(indl)
                            Deltam = Ainv(:,rows(j));
                            if i == j
                                [dfi_dxj, fni] = getCost(...
                                    ME,x(F2C(Fcsi))./Fcrho(Fcsi), Sgni, Fcsi, Fcmu(Fcsi), ...
                                    Fcrho(Fcsi), Deltam(F2C(Fcsi)));
                                J(i,j) = dfi_dxj;
                                fn(i) = fni;
                            else
                                [dfi_dxj] = getCost(...
                                    ME,x(F2C(Fcsi))./Fcrho(Fcsi), Sgni, Fcsi, Fcmu(Fcsi), ...
                                    Fcrho(Fcsi), Deltam(F2C(Fcsi)));
                                J(i,j) = dfi_dxj;
                            end
                        end
                    end

                    % Test Convergence
                    if sum(abs(fn)) < tol; break; end

                    % x = x + J\(-f); - Calculate the shift in x
                    x = x + Ainv(:,rows)*(J\(-fn));

                    iteration = iteration + 1;
                end
            end

            if iteration == max_iterations
                fprintf('XXX Failed to Converge 300 iterations. XXX\n');
                %       else
                %         fprintf(['Converged in ' num2str(iteration) ' iterations. \n']);
            end

            % Record for extrapolation
            if size(recordValues{region},2) == 3
                recordValues{region}(:,1:2) = recordValues{region}(:,2:3);
                recordTimes{region}(1:2) = recordTimes{region}(2:3);
                recordValues{region}(:,end) = x(rows(:));
                recordTimes{region}(end) = time;
            else
                recordValues{region}(:,end+1) = x(rows(:));
                recordTimes{region}(end+1) = time;
            end

            ME.Fc_V(ME.RegionFcs{region}) = x(F2C(ME.RegionFcs{region}))./Fcrho(F2C(ME.RegionFcs{region}));
        end

        %{
    function dP = p_drop(ME,fc)
      nd1 = ME.Fc_Nd(fc,1);
      nd2 = ME.Fc_Nd(fc,2);
      rho1 = ME.m(nd1)/ME.vol(nd1);
      rho2 = ME.m(nd2)/ME.vol(nd2);
      rho = (rho1 + rho2)/2;
      mu1 = ME.muFunc(ME.T(nd1));
      mu2 = ME.muFunc(ME.T(nd2));
      mu = (mu1 + mu2)/2;
      U = ME.Fc_V(fc)./ME.Fc_Area(fc) + ME.Fc_Vel_Factor(fc)*ME.dA;
      RE = abs(rho*U*ME.Fc_Dh(fc)./mu) + 1e-7;
      ME.getWeight(fc);
      [K,~] = ME.KValue(fc);
      dP = K*rho*abs(U)*U;
    end
        %}

        function [derivative, cost] = getCost(ME, Vnew, Sgn, Fcs, Fcmu, Fcrho, DeltaV)
            ME.Fc_U(Fcs) = Vnew./ME.Fc_Area(Fcs) + ME.Fc_Vel_Factor(Fcs)*ME.dA;
            ME.Fc_RE(Fcs) = abs(ME.Fc_U(Fcs).*Fcrho.*ME.Fc_Dh(Fcs)./Fcmu) + 1e-7;
            ME.getWeight(Fcs);
            if nargout == 2
                [K, derv] = ME.KValue(Fcs);
                cost = sum(Sgn.*K.*Fcrho.*abs(ME.Fc_U(Fcs)).*ME.Fc_U(Fcs));
                derivative = sum(...
                    (DeltaV.*Sgn.*Fcrho.*abs(ME.Fc_U(Fcs))./ME.Fc_Area(Fcs)).*(...
                    sign(ME.Fc_U(Fcs)).*ME.Fc_RE(Fcs).*derv + 2*K));
            else
                [K, derv] = ME.KValue(Fcs);
                derivative = sum(...
                    (DeltaV.*Sgn.*Fcrho.*abs(ME.Fc_U(Fcs))./ME.Fc_Area(Fcs)).*(...
                    sign(ME.Fc_U(Fcs)).*ME.Fc_RE(Fcs).*derv + 2*K));
                return;
            end
        end

        function Forces = Iteration_Solve(ME)
            % Inc = next position, iterate up to this position, where dynamics
            % ... are calculated

            %% Step 2: Start Recursive Algorithm
            ME.implicitSolve();
            if ME.stop
                fprintf('Simulation Finished Prematurely. (In Iteration_Solve)\n');
            end

            %% Step 5: Collect Information for Dynamics, in the form of "Forces"
            % Pressure Boundaries
            Forces = ME.CalcForces();
        end

        function assignAvgDynamic(ME)
            if ~isempty(ME.Dynamic)
                p = mean(ME.Dynamic);
                if ~isempty(ME.DynDh)
                    ME.Dh(ME.DynDh(1,:)) = p(ME.DynDh(2,:));
                end
                % Dynamic Volume
                if ~isempty(ME.DynVol)
                    ME.vol(ME.DynVol(1,:)) = p(ME.DynVol(2,:));
                end
                % Dynamic Area
                if ~isempty(ME.Fc_DynArea)
                    ME.Fc_Area(ME.Fc_DynArea(1,:)) = p(ME.Fc_DynArea(2,:));
                end
                % Dynamic Conductance
                if ~isempty(ME.Fc_DynCond)
                    ME.Fc_Cond(ME.Fc_DynCond(1,:)) = p(ME.Fc_DynCond(2,:));
                end
                % Dynamic Distance
                if ~isempty(ME.Fc_DynDist)
                    ME.Fc_Dist(ME.Fc_DynDist(1,:)) = p(ME.Fc_DynDist(2,:));
                end
                if ~isempty(ME.Fc_DynCond_Dist)
                    ME.Fc_Cond_Dist(ME.Fc_DynCond_Dist(1,:)) = ...
                        p(ME.Fc_DynCond_Dist(2,:));
                end
                % Dynamic dx for Courant Calculation
                if ~isempty(ME.Fc_Dyndx)
                    ME.Fc_dx(ME.Fc_Dyndx(1,:)) = p(ME.Fc_Dyndx(2,:));
                end
            end
        end

        function Assign_Engine_Pressure(ME, P)
            for i = 1:length(ME.Regions)
                if ~ME.isEnvironmentRegion(i)
                    Nds = ME.Regions{i};
                    ME.m(Nds) = P*(ME.vol(Nds)./ME.T(Nds))./ME.R(i);
                else
                    Nds = ME.Regions{i};
                    ME.m(Nds) = ME.P(end)*(ME.vol(Nds)./ME.T(Nds))./ME.R(i);
                end
            end
        end

        function assignDynamic(ME,Inc,initialize)
            persistent A;
            persistent B;
            persistent C;
            persistent D;
            persistent DynLength;
            persistent IncBase;
            if nargin == 3
                if initialize == false
                    if ~isempty(ME.Dynamic)
                        % Define A,B,C,D for all variables
                        DynLength = size(ME.Dynamic,1);
                        IncBase = floor(Inc);
                        if IncBase >= 2
                            V0 = ME.Dynamic(IncBase - 1,:);
                            V1 = ME.Dynamic(IncBase,:);
                            if IncBase < DynLength - 1
                                V2 = ME.Dynamic(IncBase+1,:);
                                V3 = ME.Dynamic(IncBase+2,:);
                            elseif IncBase < DynLength
                                V2 = ME.Dynamic(IncBase+1,:);
                                V3 = ME.Dynamic(2,:);
                            else
                                V2 = ME.Dynamic(2,:);
                                V3 = ME.Dynamic(3,:);
                            end
                        else
                            V2 = ME.Dynamic(IncBase+1,:);
                            V3 = ME.Dynamic(IncBase+2,:);
                            if IncBase >= 1
                                V0 = ME.Dynamic(DynLength-1,:);
                                V1 = ME.Dynamic(1,:);
                            else
                                V0 = ME.Dynamic(DynLength-2,:);
                                V1 = ME.Dynamic(DynLength-1,:);
                            end
                        end
                        dV1 = (V2 - V0) / (2 * ME.A_Inc / ME.dA_old);
                        dV2 = (V3 - V1) / (2 * ME.A_Inc / ME.dA);
                        A = ME.dt_max * (dV1 + dV2) - 2 * (V2 - V1);
                        B = ME.dt_max * (-2*dV1 - dV2) + 3 * (V2 - V1);
                        C = ME.dt_max * dV1;
                        D = V1;
                    end
                end
                return;
            end
            if ~isempty(ME.Dynamic)
                Inc_p = Inc-IncBase;
                if Inc_p > 1; frac = 1; else; frac = Inc_p; end
                point = A*frac^3 + B*frac^2 + C*frac + D;


                % Dynamic Velocity Factor
                if ~isempty(ME.Fc_DynVel_Factor)
                    ME.Fc_Vel_Factor(ME.Fc_DynVel_Factor(1,:)) = ...
                        point(ME.Fc_DynVel_Factor(2,:));
                end
                if ~isempty(ME.Fc_DynShear_Factor)
                    ME.Fc_Shear_Factor(ME.Fc_DynShear_Factor(1,:)) = ...
                        point(ME.Fc_DynShear_Factor(2,:));
                end

                point(point<0) = 0;
                % Dynamic Area
                if ~isempty(ME.Fc_DynArea)
                    ME.Fc_Area(ME.Fc_DynArea(1,:)) = point(ME.Fc_DynArea(2,:));
                end
                % Dynamic Conductance
                if ~isempty(ME.Fc_DynCond)
                    ME.Fc_Cond(ME.Fc_DynCond(1,:)) = point(ME.Fc_DynCond(2,:));
                end
                % Dynamic Fc_A
                if ~isempty(ME.Fc_DynA)
                    ME.Fc_A(ME.Fc_DynA(1,:)) = point(ME.Fc_DynA(2,:));
                end
                % Dynamic Fc_B
                if ~isempty(ME.Fc_DynB)
                    ME.Fc_B(ME.Fc_DynB(1,:)) = point(ME.Fc_DynB(2,:));
                end
                % Dynamic Fc_C
                if ~isempty(ME.Fc_DynC)
                    ME.Fc_C(ME.Fc_DynC(1,:)) = point(ME.Fc_DynC(2,:));
                end
                % Dynamic Fc_D
                if ~isempty(ME.Fc_DynD)
                    ME.Fc_D(ME.Fc_DynD(1,:)) = point(ME.Fc_DynD(2,:));
                end
                if any(isnan(ME.Fc_A)) || any(isnan(ME.Fc_B)) || ...
                        any(isnan(ME.Fc_C)) || any(isnan(ME.Fc_D))
                    fprintf('err');
                end

                point(point<1e-8) = 1e-8;
                % Dynamic Volume
                if ~isempty(ME.DynVol)
                    ME.vol(ME.DynVol(1,:)) = point(ME.DynVol(2,:));
                    ME.dV_dt(ME.DynVol(1,:)) = (1/ME.dt_max)*(...
                        3*A(ME.DynVol(2,:))*frac^2 + ...
                        2*B(ME.DynVol(2,:))*frac + ...
                        C(ME.DynVol(2,:)));
                end
                % Dynamic Active Times for ShearContacts
                if ~isempty(ME.SC_Active)
                    ME.Shear_Contact(6,ME.SC_Active(1,:)) = ...
                        round(point(ME.SC_Active(2,:)));
                end
                % Dynamic K12
                if ~isempty(ME.Fc_DynK12)
                    ME.Fc_K12(ME.Fc_DynK12(1,:)) = point(ME.Fc_DynK12(2,:));
                end
                if ~isempty(ME.Fc_DynK21)
                    ME.Fc_K21(ME.Fc_DynK21(1,:)) = point(ME.Fc_DynK21(2,:));
                end

                point(point<1e-4) = 1e-4;
                % Dynamic Dh (node)
                if ~isempty(ME.DynDh)
                    ME.Dh(ME.DynDh(1,:)) = point(ME.DynDh(2,:));
                end
                % Dynamic Dh (face)
                if ~isempty(ME.Fc_DynDh)
                    ME.Fc_Dh(ME.Fc_DynDh(1,:)) = point(ME.Fc_DynDh(2,:));
                end
                % Dynamic Distance
                if ~isempty(ME.Fc_DynDist)
                    ME.Fc_Dist(ME.Fc_DynDist(1,:)) = point(ME.Fc_DynDist(2,:));
                end
                if ~isempty(ME.Fc_DynCond_Dist)
                    ME.Fc_Cond_Dist(ME.Fc_DynCond_Dist(1,:)) = ...
                        point(ME.Fc_DynCond_Dist(2,:));
                    if any(ME.Fc_Cond_Dist==0)
                        ME.Fc_Cond_Dist(ME.Fc_Cond_Dist==0) = 0.0001;
                    end
                end
                % Dynamic dx for Courant Calculation
                if ~isempty(ME.Fc_Dyndx)
                    ME.Fc_dx(ME.Fc_Dyndx(1,:)) = point(ME.Fc_Dyndx(2,:));
                end
            end
        end

        function Forces = CalcForces(ME)
            % Distribute pressure losses

            fcs = 1:length(ME.Fc_U);
            nds = 1:length(ME.P);
            nd1 = ME.Fc_Nd(fcs,1);
            nd2 = ME.Fc_Nd(fcs,2);
            rhoi = ME.m(nds)./ME.vol(nds);
            rhoi(end) = ME.rho(end);
            Fcrho = 0.5*(rhoi(nd1) + rhoi(nd2));
            Fcmu = 0.5*(ME.mu(nd1) + ME.mu(nd2));
            for i = 1:length(ME.Regions)
                nodes = ME.Regions{i};
                if ~isempty(ME.ActiveRegionFcs{i})
                    faces = ME.ActiveRegionFcs{i};
                    % Calculate KpU_2A
                    % ME.Fc_U(faces) = ME.Fc_U(faces);
                    ME.Fc_RE(faces) = abs(ME.Fc_U(faces).*Fcrho(faces).*ME.Fc_Dh(faces)./Fcmu(faces));
                    ME.Fc_RE(ME.Fc_RE==0) = 1e-7;
                    ME.getWeight();
                    len = length(faces) + 1;
                    A = ME.A_Press{i};
                    b = zeros(len,1);
                    A(len,:) = ME.vol(nodes);
                    if ME.isEnvironmentRegion(i)
                        b(len) = ME.P(end);
                        A(len,len) = 1e8; % Some large value that is not infinity
                    else
                        b(len) = ME.R(i)*sum(ME.vol(nodes))*...
                            ME.T(nodes(1)).*ME.m(nodes(1))./ME.vol(nodes(1));
                    end
                    ME.Fc_dP(faces) = ME.KValue(faces).*Fcrho(faces).*abs(ME.Fc_U(faces)).*ME.Fc_U(faces);
                    b(1:len-1) = ME.Fc_dP(faces);
                    A = sparse(A);
                    ME.P(nodes) = A\b;
                    ME.dP(nodes) = ME.P(nodes) -  ME.R(i)*ME.T(nodes(1))*ME.m(nodes(1))/ME.vol(nodes(1));
                else
                    if ~ME.isEnvironmentRegion(i)
                        ME.P(nodes) = ME.R(i)*ME.T(nodes(1)).*ME.m(nodes(1))./ME.vol(nodes(1));
                    end
                    ME.dP(nodes) = 0;
                end

            end
            ME.E_Flow_Loss = ME.E_Flow_Loss + ...
                ME.dt_max * sum(abs(ME.Fc_V(fcs).*(ME.P(nd1)-ME.P(nd2))));

            % Make forces
            if ~isempty(ME.MechanicalSystem)
                Forces = cell(1,length(ME.MechanicalSystem.Converters));
            else
                Forces = cell(0);
            end
            if ~isempty(Forces)
                for i = 1:length(Forces)
                    Forces{i} = zeros(1,length(ME.MechanicalSystem.Converters(i).Stroke));
                end
                for i = 1:size(ME.Press_Contact,2)
                    conv = ME.Press_Contact(1,i);
                    subconv = ME.Press_Contact(2,i);
                    area = ME.Press_Contact(3,i);
                    index = ME.Press_Contact(4,i);
                    Forces{conv}(subconv) = Forces{conv}(subconv) + area.*ME.P(index);
                end
                for i = 1:size(ME.Shear_Contact,2)
                    if ME.Shear_Contact(6,i)
                        conv = ME.Shear_Contact(1,i);
                        subconv = ME.Shear_Contact(2,i);
                        area = ME.Shear_Contact(3,i);
                        ind1 = ME.Shear_Contact(4,i);
                        ind2 = ME.Shear_Contact(5,i);
                        Forces{conv}(subconv) = Forces{conv}(subconv) + ...
                            area*(ME.P(ind1)-ME.P(ind2));
                    end
                end
            end
        end

        function getWeight(ME,faces)
            if nargin == 1; faces = 1:length(ME.Fc_U); end
            W = zeros(length(faces),1);

            % Ignore turbulence transport
            ind = ~ME.useTurbulenceFc(faces);
            W(ind) = (ME.Fc_RE(faces(ind))-2300)/1700;
            W(W>1) = 1;
            W(W<0) = 0;
            W = W.*W.*(3 - 2*W);

            % Use turubulence transport
            ind = ~ind;
            W(ind) = ME.Fc_turb(faces(ind));
            W(W>1) = 1;
            W(W<0) = 0;
            ME.Fc_W(faces) = W;
        end

        function [K, derv] = KValue(ME,faces)
            K = zeros(length(faces),1);
            if nargout == 2
                derv = K;
            end
            for i = 1:length(faces)
                fc = faces(i);
                if ME.Fc_K12(fc) > 0
                    if ME.Fc_V(fc) > 0
                        K(i) = ME.Fc_K12(fc)/2;
                    else
                        K(i) = ME.Fc_K21(fc)/2;
                    end
                else
                    if ME.Fc_W(fc) == 0
                        K(i) = ME.Fc_fFunc_l{fc}(ME.Fc_RE(fc))*ME.Fc_Dist(fc)/(ME.Fc_Dh(fc)*2);
                        if nargout == 2
                            derv(i) = (ME.Fc_fFunc_l{fc}(ME.Fc_RE(fc) + 1e-8)*ME.Fc_Dist(fc)/(ME.Fc_Dh(fc)*2) - ...
                                K(i))/1e-8;
                        end
                    elseif ME.Fc_W(fc) == 1
                        K(i) = ME.Fc_fFunc_t{fc}(ME.Fc_RE(fc))*ME.Fc_Dist(fc)/(ME.Fc_Dh(fc)*2);
                        if nargout == 2
                            derv(i) = (ME.Fc_fFunc_t{fc}(ME.Fc_RE(fc) + 1e-8)*ME.Fc_Dist(fc)/(ME.Fc_Dh(fc)*2) - ...
                                K(i))/1e-8;
                        end
                    else
                        K(i) = ((1-ME.Fc_W(fc))*ME.Fc_fFunc_l{fc}(ME.Fc_RE(fc)) + ...
                            ME.Fc_W(fc)*ME.Fc_fFunc_t{fc}(ME.Fc_RE(fc)))*...
                            ME.Fc_Dist(fc)/(ME.Fc_Dh(fc)*2);
                        if nargout == 2
                            derv(i) = (((1-ME.Fc_W(fc))*ME.Fc_fFunc_l{fc}(ME.Fc_RE(fc) + 1e-8) + ...
                                ME.Fc_W(fc)*ME.Fc_fFunc_t{fc}(ME.Fc_RE(fc) + 1e-8))*ME.Fc_Dist(fc)/(ME.Fc_Dh(fc)*2) - ...
                                K(i))/1e-8;
                        end
                    end
                end
            end
        end

        function Nk = NkFunc(ME)
            Nk = zeros(size(ME.Fc_U));
            Nkt = Nk;
            % Laminar Functions
            for i = 1:length(ME.Fc_NkFunc_l)
                fcs = ME.Fc_NkFunc_l_el{i};
                if nargin(ME.Fc_NkFunc_l{i}) == 1
                    Nk(fcs) = (1-ME.Fc_W(fcs)).*ME.Fc_NkFunc_l{i}(ME.Fc_RE(fcs));
                else
                    Nk(fcs) = (1-ME.Fc_W(fcs)).*...
                        ME.Fc_NkFunc_l{i}(ME.Fc_RE(fcs),ME.Fc_PR(fcs));
                end
            end
            % Turbulent Functions
            for i = 1:length(ME.Fc_NkFunc_t)
                fcs = ME.Fc_NkFunc_t_el{i};
                if nargin(ME.Fc_NkFunc_t{i}) == 1
                    Nkt(fcs) = ME.Fc_W(fcs).*ME.Fc_NkFunc_t{i}(ME.Fc_RE(fcs));
                else
                    Nkt(fcs) = ME.Fc_W(fcs).*...
                        ME.Fc_NkFunc_t{i}(ME.Fc_RE(fcs),ME.Fc_PR(fcs));
                end
            end
            Nk = Nk + Nkt;
            Nk(Nk<1) = 1; % Nothing can be worse than pure conduction
        end

        function Nu = Nusselt(ME)
            Nu = zeros(length(ME.P)-1,1);
            Nut = Nu;
            ME.RE = abs(ME.RE);
            W = (ME.RE-2300)/1700;
            W(W<0) = 0; W(W>1) = 1;
            W = W.*(W.*(3 - 2*W) - 1);
            W(ME.useTurbulenceNd) = ME.turb(ME.useTurbulenceNd);
            ME.turb(1:length(W)) = W;
            W(W<0) = 0; W(W>1) = 1;

            % Laminar Functions
            for i = 1:length(ME.NuFunc_l)
                nds = ME.NuFunc_l_el{i};
                if nargin(ME.NuFunc_l{i}) == 1
                    Nu(nds) = (1-W(nds)).*ME.NuFunc_l{i}(ME.RE(nds));
                else
                    Nu(nds) = (1-W(nds)).*ME.NuFunc_l{i}(ME.RE(nds),ME.PR(nds));
                end
            end
            % Turbulent Function
            for i = 1:length(ME.NuFunc_t)
                nds = ME.NuFunc_t_el{i};
                if nargin(ME.NuFunc_t{i}) == 1
                    Nut(nds) = W(nds).*ME.NuFunc_t{i}(ME.RE(nds));
                else
                    Nut(nds) = W(nds).*ME.NuFunc_t{i}(ME.RE(nds),ME.PR(nds));
                end
            end
            Nu = Nu + Nut;
            % Nu(Nu<1) = 1;% Pure Conduction Nusselt Number
        end

    end

end

