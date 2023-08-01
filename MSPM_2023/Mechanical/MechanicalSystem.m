classdef MechanicalSystem < handle
    % models the mechanical system of the output shaft.
    % contains LinRotMechanisms, the inertia of the flywheel,
    % friction coefficient for the output, calculates output shaft power
    % and checks if shaft power converges during simulation

    properties (Constant)
        SteadyStateRMS = 0.1;
        NDimModelCalcRadius = [10 10 3];
    end

    properties (Dependent)
        isConverged;
    end

    properties
        Model Model; %

        Converters LinRotMechanism; % Array Containing Linear-Rotational Converters
        Inertia double = 1; % Real Flywheel Inertia
        DriveTrainWeight double = 1;
        DriveTrainFricCoef double = 0;
        LoadFunction function_handle; % Function that takes current motion and provides a counter load

        InertiaMod double = 1; % Modifier Used to allow the engine to get up to speed faster, or stabilize it during slow times.
        KE double = 0; % Kinetic Energy
        Alpha double = 0; % The rotational acceleration
        Omega double = 0; % The rotational speed
        Theta double = 0; % The physical Angle


        LastCycle double; % (Theta, Omega)
        ThisCycle double; % Continously recorded and checked for convergence

        % Set in SetInitialConditions
        Points double; % Array indicating the points at which the model is calculated for each variable
        Inc double; % Vector indicating the increment that is used to discretize each variable
    end

    properties (Dependent)
        name;
    end

    methods
        %% Constructor
        function this = MechanicalSystem(Model,Converters,~,Inertia,LoadFunction)
            this.Model = Model;
            % Define other parameters
            this.Converters = Converters;
            this.Inertia = Inertia;
            this.LoadFunction = LoadFunction;
        end
        function iname = get.name(~)
            iname = 'Mechanical System';
        end
        function Item = get(this, PropertyName)
            switch PropertyName
                case 'name'
                    Item = this.name();
                case 'Flywheel Inertia'
                    Item = this.Inertia;
                case 'Drive Train Weight'
                    Item = this.DriveTrainWeight;
                case 'Drive Train Normal Friction Coefficient'
                    Item = this.DriveTrainFricCoef;
                case 'Load Function'
                    Item = this.LoadFunction;
                otherwise
                    fprintf(['XXX MechanicalSystem GET Inteface for ' PropertyName ' is not found XXX\n']);
                    return;
            end
        end
        function set(this,PropertyName,Item)
            switch PropertyName
                case 'name'
                    % Do nothing
                case 'Flywheel Inertia'
                    this.Inertia = Item;
                case 'Drive Train Weight'
                    this.DriveTrainWeight = Item;
                case 'Drive Train Normal Friction Coefficient'
                    this.DriveTrainFricCoef = Item;
                case 'Load Function'
                    this.LoadFunction = Item;
                otherwise
                    fprintf(['XXX MechanicalSystem SET Inteface for ' PropertyName ' is not found XXX\n']);
                    return;
            end
        end

        function Power = Solve(this,Inc,dA,ddA,Forces)
            M = 0;
            fric = abs(this.DriveTrainWeight*this.DriveTrainFricCoef);
            for i = 1:length(this.Converters)
                for j = 1:length(Forces{i})
                    F = this.Converters(i).outputFcn([dA ddA Forces{i}(j) Inc j]);
                    M = M + F(3);
                    fric = fric + sqrt(F(1)^2 + F(2)^2)*this.DriveTrainFricCoef;
                end
                %            if i == length(this.Converters)
                %                fprintf([', ' num2str(M*dA) '\n']);
                %            elseif i == 1
                %               fprintf(num2str(M*dA));
                %            else
                %               fprintf([', ' num2str(M*dA)]);
                %            end
            end
            Power = (M - fric)*dA;
        end

        function SetInitialConditions(this,iTheta,iOmega)
            this.Theta = iTheta;
            this.Omega = iOmega;
            this.Alpha = 0;
        end

        %% Analysis Function
        function RMS = compareCycles(this)
            % Calculate the RMS error between cycles
            Match = interp1(this.LastCycle(:).Theta,...
                this.LastCycle(:).Omega,...
                this.ThisCycle(:).Theta);
            RMS = sqrt(sum((Match - this.ThisCycle.Omega).^2))/sqrt(length(Match));
        end
        function Converged = get.isConverged(this)
            Converged = this.compareCycles() < this.SteadyStateRMS;
        end

        %% Simulation Function
        function move(this,InputForces)
            %% Do something with the Input Forces
            % http://matlab.izmiran.ru/help/techdoc/matlab_prog/ch_dat41.html
            % If you use the colon to index multiple cells in conjunction
            %  with the curly brace notation, MATLAB treats the contents of
            %  each cell as a separate variable. For example, assume you have
            %  a cell array T where each cell contains a separate vector. The
            %  expression T{1:5} is equivalent to a comma-separated list of
            %  the vectors in the first five cells of T.
            if this.isKinematic
                % Collect the input parameters
                Parameters = cell(length(InputForces)+2,1);
                Parameters{1} = mod(this.Theta,2*pi);
                Parameters{2} = this.Omega*this.Omega;
                for r = 3:length(Parameters)
                    Parameters{r} = InputForces(r-2);
                end
                % Interpolate the Mechanical System Results
                this.Alpha = interpn(Parameters{:},this.NDimModel,...
                    this.Points{:},'linear',NaN);
                % ThetaInc,   this.sqOmegaInc,   this.ForceInc{:},...
                if isnan(this.Alpha)
                    % Assess if the extrapolation array needs to be expanded to
                    % the next parameter

                    % Find the parameter that goes out
                    % Points
                    C = zeros(length(this.Points),1);
                    for i = 1:length(this.Points)
                        if Parameters(i) > this.Points{i}(end)
                            C(i) = ceil((Parameters(i)-this.Points{i}(end))/this.Inc(i));
                        elseif Parameters(i) < this.Points{i}(1)
                            C(i) = -ceil(abs(Parameters(i)-this.Points{i}(end))/this.Inc(i));
                        end
                    end

                    this.UpdateMechanicalModel(C);

                    this.Alpha = interpn(Parameters{:},this.NDimModel,...
                        this.Points{:},'linear',NaN);
                end

                % Move Position ahead
                ChThetaeInVelocity = this.Model.dt*this.Alpha;
                this.Theta = this.Theta + this.Model.dt*(this.Omega+ChThetaeInVelocity/2);
                this.Omega = this.Omega + ChThetaeInVelocity;

                for iFrame = this.Model.RefFrames
                    if iFrame.Mechanism == this
                        iFrame.Position = getPosition(this.Theta);
                    end
                end
            end
        end
    end

end

