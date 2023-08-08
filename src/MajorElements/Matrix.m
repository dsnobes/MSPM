classdef Matrix < handle
    % models a "gas matrix", for example, that can be
    % a heat exchanger or a regenerator for a stirling engine.
    % contains various fluid dynamics functions that help
    % define the flow characteristics of fluids through the matrix.
    % contains a body, nodes and faces
    properties (Constant)
        GeometrySource = {...
            'Woven Screen';
            'Random Fibre';
            'Packed Sphere';
            'Stacked Foil';
            'Custom Regen';
            'Heat Exchanger'};
    end

    properties
        GeometryEnum enumMatrix;

        matl Material;
        Geometry enumMatrix;

        fFunc_t function_handle;
        fFunc_l function_handle;
        NuFunc_t function_handle;
        NuFunc_l function_handle;
        NkFunc_l function_handle;
        NkFunc_t function_handle;

        Volumetric_HeatCapacity;

        Dh;
        Volumetric_SurfaceArea;
        data struct;
        isFullyLaminar logical = false;
        %     hasSource logical = false;
        %     HasSource logical = false;

        Body Body;
        Nodes Node;
        Faces Face;
    end

    properties (Dependent)
        name;
    end

    methods
        function this = Matrix(Body)
            if nargin == 0
                return;
            end
            if nargin == 1
                this.Body = Body;
            end
            if isempty(this.GeometryEnum); this.assignGeometryEnum(); end
        end
        function deReference(this)
            if ~isempty(this)
                if ~isempty(this.Body)
                    this.Body.Matrix = Matrix.empty;
                    this.Body.change();
                end
                delete(this.Nodes);
                delete(this.Faces);
                if isfield(this.data,'Connection')
                    this.data.Connection.change();
                end
                this.delete();
            end
        end
        function assignGeometryEnum(this)
            this.GeometryEnum(1) = enumMatrix.WovenScreen;
            this.GeometryEnum(2) = enumMatrix.RandomFiber;
            this.GeometryEnum(3) = enumMatrix.PackedSphere;
            this.GeometryEnum(4) = enumMatrix.StackedFoil;
            this.GeometryEnum(5) = enumMatrix.CustomRegen;
            this.GeometryEnum(6) = enumMatrix.HeatExchanger;
        end
        function item = get(this,PropertyName)
            switch PropertyName
                case 'Material'
                    if isempty(this.matl)
                        item = Material();
                    else
                        item = this.matl;
                    end
                case 'Laminar Friction Function'
                    item = this.fFunc_l;
                case 'Turbulent Friction Function'
                    item = this.fFunc_t;
                case 'Laminar Nusselt Function'
                    item = this.NuFunc_l;
                case 'Turbulent Nusselt Function'
                    item = this.NuFunc_t;
                case 'Laminar Streamwise Cond. Enhancement'
                    item = this.NkFunc_l;
                case 'Turbulent Streamwise Cond. Enhancement'
                    item = this.NkFunc_t;
                case 'Source Temperature'
                    if isfield(this.data,'SourceTemperature')
                        item = this.data.SourceTemperature;
                    else
                        item = 0;
                    end
            end
        end
        function set(this,PropertyName,item)
            switch PropertyName
                case 'Material'
                    this.matl = item;
                case 'Laminar Friction Function'
                    this.fFunc_l = item;
                case 'Turbulent Friction Function'
                    this.fFunc_t = item;
                case 'Laminar Nusselt Function'
                    this.NuFunc_l = item;
                case 'Turbulent Nusselt Function'
                    this.NuFunc_t = item;
                case 'Laminar Streamwise Mixing Enhancement'
                    this.NkFunc_l = item;
                case 'Turbulent Streamwise Mixing Enhancement'
                    this.NkFunc_t = item;
                case 'Source Temperature'
                    if isfield(this.data,'SourceTemperature')
                        this.data.SourceTemperature = item;
                    end
            end
        end
        function Modify(this)
            this.assignGeometryEnum();
            % define Material
            if isempty(this.matl); this.matl = Material(); end
            this.matl.Modify();
            if isempty(this.matl.name)
                disp("No material selected. Matrix Creation Failed")
                return
            end

            % define Geometry
            if ~isempty(this.Geometry)
                for index = 1:length(this.GeometryEnum)
                    if this.GeometryEnum(index) == this.Geometry; break; end
                end
            else; index = 1;
            end
            [index, tf] = listdlg('ListString',this.GeometrySource,...
                'SelectionMode','single',...
                'InitialValue',index);
            if ~tf
                disp("No Geometry Selected. Matrix Creation Failed")
                return
            end
            if isempty(this.GeometryEnum); this.assignGeometryEnum(); end
            this.Geometry = this.GeometryEnum(index);

            % calculate Properties
            %% Regenerators
            if isempty(this.data); this.data = struct('hasSource',false);
            else; this.data.hasSource = false; end

            switch this.Geometry
                case enumMatrix.WovenScreen
                    this.isFullyLaminar = true;
                    %           this.hasSource = false;
                    %           this.HasSource = false;

                    % Assign Default User Inputs, from history or hardcoded values
                    op = {'90','0.001'}; % Default Values
                    if isfield(this.data,'Porosity'); op{1} = num2str(this.data.Porosity*100); end
                    if isfield(this.data,'dw'); op{2} = num2str(this.data.dw); end

                    % Get User Inputs
                    firstround = true;
                    while firstround || ~isStrNumeric(op{1}) || ~isStrNumeric(op{2})
                        if firstround; firstround = false;
                        else; msgbox('Numeric Values only'); end
                        op = inputdlg(...
                            {'Porosity (%)','Wire Diameter (m)'},...
                            'Generate a Woven Screen Matrix',[1 100],op);
                    end
                    this.data.Porosity = str2double(op{1})/100;
                    %this.Volumetric_HeatCapacity = (1 - this.data.Porosity)*this.matl.HeatCapacity*this.matl.Density;
                    this.data.dw = str2double(op{2});
                    this.Dh = this.data.dw/(1-this.data.Porosity);

                    % Friction Factor
                    this.fFunc_l = @(Re) 129./Re+2.91*(Re.^(-0.103));
                    this.fFunc_t = this.fFunc_l;

                    % Nusselt Number
                    %           this.NuFunc_l = @(Re,Pr) 1+0.99*(this.data.Porosity^1.79)*(Re.*Pr).^0.66;
                    %Matthias: fixed from Sage guide
                    this.NuFunc_l = @(Re,Pr) (1+0.99*(Re.*Pr).^0.66) .* (this.data.Porosity^1.79);
                    this.NuFunc_t = this.NuFunc_l;

                    % Streamwise mixing enhancement
                    this.NkFunc_l = @(Re,Pr) 1+0.5*(this.data.Porosity^(-2.91))*((Re.*Pr).^0.66);
                    this.NkFunc_t = this.NkFunc_l;

                case enumMatrix.RandomFiber
                    this.isFullyLaminar = true;
                    %           this.hasSource = false;
                    %           this.HasSource = false;

                    % Assign Default User Inputs, from history or hardcoded values
                    op = {'90','0.001'}; % Default Values
                    if isfield(this.data,'Porosity'); op{1} = num2str(this.data.Porosity*100); end
                    if isfield(this.data,'dw'); op{2} = num2str(this.data.dw); end

                    % Get User Inputs
                    firstround = true;
                    while firstround || ~isStrNumeric(op{1}) || ~isStrNumeric(op{2})
                        if firstround; firstround = false;
                        else; msgbox('Numeric Values only'); end
                        op = inputdlg(...
                            {'Porosity (%)','Wire Diameter (m)'},...
                            'Generate a Random Fibre Matrix',[1 100],op);
                    end
                    this.data.Porosity = str2double(op{1})/100;
                    %this.Volumetric_HeatCapacity = (1-this.data.Porosity)*this.matl.HeatCapacity*this.matl.Density;
                    this.data.dw = str2double(op{2});
                    this.Dh = this.data.dw/(1-this.data.Porosity);
                    alpha = this.data.Porosity/(1-this.data.Porosity);

                    % Friction Factor
                    this.fFunc_l = @(Re) (25.7*alpha+79.8)./Re+...
                        (0.146*alpha+3.76)*(Re.^(-0.00283*alpha-0.0748));
                    this.fFunc_t = this.fFunc_l;

                    % Nusselt Number
                    this.NuFunc_l = @(Re,Pr) 1+0.186*alpha*(Re.*Pr).^0.55;
                    this.NuFunc_t = this.NuFunc_l;

                    % Streamwise Mixing Enhancement
                    this.NkFunc_l = @(Re,Pr) (1+(Re.*Pr).^0.55);
                    this.NkFunc_t = this.NkFunc_l;

                case enumMatrix.PackedSphere
                    this.isFullyLaminar = true;
                    %           this.hasSource = false;
                    %           this.HasSource = false;

                    % Assign Default User Inputs, from history or hardcoded values
                    op = {'90','0.001'}; % Default Values
                    if isfield(this.data,'Porosity'); op{1} = num2str(this.data.Porosity*100); end
                    if isfield(this.data,'Dp'); op{2} = num2str(this.data.dw); end

                    % Get User Inputs
                    firstround = true;Run
                    while firstround || ~isStrNumeric(op{1}) || ~isStrNumeric(op{2})
                        if firstround; firstround = false;
                        else; msgbox('Numeric Values only'); end
                        op = inputdlg(...
                            {'Porosity (%)','Particle Diameter (m)'},...
                            'Generate a Stacked Particle Matrix',[1 100],op);
                    end
                    this.data.Porosity = str2double(op{1});
                    %this.Volumetric_HeatCapacity = (1-this.data.Porosity)*this.matl.HeatCapacity*this.matl.Density;
                    this.data.Dp = str2double(op{2});
                    this.Dh = this.data.Dp*this.data.Porosity/(6*(1-this.data.Porosity));

                    % Friction Factor
                    this.fFunc_l = @(Re) (157./Re+(5.15*(this.data.Porosity/0.39)^(3.48))*(Re.^-0.137));
                    this.fFunc_t = @(Re,Pr) (157./Re+(5.15*(this.data.Porosity/0.39)^(3.48))*(Re.^-0.137));

                    % Nusselt Number
                    this.NuFunc_l = @(Re,Pr) (1+0.48*(Re.*Pr).^0.65);
                    this.NuFunc_t = this.NuFunc_l;

                    % Streamwise Mixing Enhancement
                    this.NkFunc_l = @(Re,Pr) 1+3*(Re.*Pr).^0.65;
                    this.NkFunc_t = this.NkFunc_l;

                case enumMatrix.StackedFoil
                    this.isFullyLaminar = false;
                    %           this.hasSource = true;
                    %            this.HasSource = true;

                    % Assign Default User Inputs, from history or hardcoded values
                    op = {'0.00025','0.0001','0.0001'}; % Default Values
                    if isfield(this.data,'gap'); op{1} = num2str(this.data.gap); end
                    if isfield(this.data,'dw'); op{2} = num2str(this.data.dw); end
                    if isfield(this.data,'e'); op{3} = num2str(this.data.e); end

                    % Get User Inputs
                    firstround = true;
                    while firstround || ~isStrNumeric(op{1}) || ...
                            ~isStrNumeric(op{2}) || ~isStrNumeric(op{3})
                        if firstround; firstround = false;
                        else; msgbox('Numeric Values only'); end
                        op = inputdlg(...
                            {'Gap Width (m)','Sheet Thickness (m)','Sheet Roughness (m)'},...
                            'Generate a Stacked Foil Matrix',[1 100],op);
                    end
                    this.data.gap = str2double(op{1});
                    this.data.dw = str2double(op{2});
                    this.data.e = str2double(op{3});
                    this.Dh = 2*this.data.gap;
                    this.data.Porosity = this.data.gap/(this.data.gap+this.data.dw);
                    %this.Volumetric_HeatCapacity = (1-this.data.Porosity)*this.matl.HeatCapacity*this.matl.Density;

                    % Friction Factors
                    % E. Fried, I.E. Idelchik, Flow Resistance: A Design Guide for Engineers,
                    %    Hemisphere, (1989)
                    this.fFunc_l = @(Re) 96./Re;
                    this.fFunc_t = @(Re) 0.121*(this.data.e/this.Dh+68./Re).^0.25;

                    % Nusselt Number
                    this.NuFunc_l = @(Re) 8.23;
                    this.NuFunc_t = @(Re,Pr) 0.025*(Re.^0.79).*(Pr.^0.33);

                    % Streamwise Mixing Enhancement
                    this.NkFunc_l = @(Re) 1;
                    this.NkFunc_t = @(Re,Pr) 0.022*(Re.^0.75).*(Pr);

                case enumMatrix.CustomRegen
                    this.isFullyLaminar = false;
                    %           this.hasSource = true;
                    %           this.HasSource = true;
                    op = {'0.025','0.80','0.121','-0.25','1000','0.95'}; % Default Values
                    if isfield(this.data,'C1'); op{1} = num2str(this.data.C1); end
                    if isfield(this.data,'C2'); op{2} = num2str(this.data.C2); end
                    if isfield(this.data,'C3'); op{3} = num2str(this.data.C3); end
                    if isfield(this.data,'C4'); op{4} = num2str(this.data.C4); end
                    if isfield(this.data,'SA_V'); op{5} = num2str(this.data.SA_V); end
                    if isfield(this.data,'Porosity'); op{6} = num2str(this.data.Porosity); end

                    % Get User Inputs
                    firstround = true;
                    while firstround || ~isStrNumeric(op{1}) || ...
                            ~isStrNumeric(op{2}) || ~isStrNumeric(op{3}) || ...
                            ~isStrNumeric(op{4}) || ~isStrNumeric(op{5}) || ...
                            ~isStrNumeric(op{6})
                        if firstround; firstround = false;
                        else; msgbox('Numeric Values only'); end
                        op = inputdlg(...
                            {'C1','C2','C3','C4','Surface area to volume ratio [m^2/m^3]','Porosity'},...
                            'Provide Parameters Nu = C1*Re^C2, F = C3*Re^C4 and other properties',[1 100],op);
                    end
                    this.data.C1 = str2double(op{1});
                    this.data.C2 = str2double(op{2});
                    this.data.C3 = str2double(op{3});
                    this.data.C4 = str2double(op{4});
                    this.data.SA_V = str2double(op{5});
                    this.data.Porosity = str2double(op{6});
                    this.Dh = 4/this.data.SA_V;

                    % Friction Factors
                    this.fFunc_l = @(Re) this.data.C3.*Re.^this.data.C4;
                    this.fFunc_t = this.fFunc_l;

                    % Nusselt Number
                    this.NuFunc_l = @(Re,Pr) this.data.C1.*Re.^this.data.C2.*Pr.^0.33333;
                    this.NuFunc_t = this.NuFunc_l;

                    % Streamwise Mixing Enhancement
                    this.NkFunc_l = @(Re) 1;
                    this.NkFunc_t = @(Re,Pr) 0.022*(Re.^0.75).*(Pr);
            end
            %% Heat Exchangers
            switch this.Geometry
                % Friction Factors
                % G.W. Swift, Thermoacoustics: A Unifying Perspective for some Engines
                %    and Refrigerators, Fourth draft, LA-UR-99-895, 1999
                % this.fFunc_l = @(Va)
                % this.fFunc_t = @(Re) 0.11*(this.data.e/this.Dh+68/Re)^0.25;
                % Nusselt Numbers
                % this.NuFunc_l = @(Re)
                % this.NuFunc_t = @(Re,Pr) 0.036*(Re^0.8)*(
                case enumMatrix.HeatExchanger
                    %% Determine what Classification
                    % Fined Surface Type
                    % Channel Type
                    % Normal to Tube Type
                    ChoosingClassification = true;
                    while (ChoosingClassification)
                        % Select Heat Exchanger Type from List
                        Source = {'Fin Enhanced Surface','Fin Connected Channels','Staggered Fin Connected Tubes','Tube Bank Internal','Custom HX'};
                        found = false;
                        if isfield(this.data,'Classification')
                            for index = 1:length(Source)
                                if strcmp(this.data.Classification,Source{index})
                                    found = true;
                                    break;
                                end
                            end
                        end
                        if ~found; index = 1; end
                        [index, tf] = listdlg('ListString',Source,'SelectionMode','single','InitialValue',index,'ListSize',[300 350]); % [W H] Default: [160 300]
                        if tf
                            if isempty(this.data); this.data = struct('Classification',Source{index});
                            else; this.data.Classification = Source{index}; end
                        end

                        % If the User Made a selection
                        if index > 0
                            ChoosingClassification = false;
                            switch index
                                case 1 % 'Fin Enhanced Surface'
                                    %% Assume straight Flat fins aligned with flow direction
                                    % Assign Values
                                    Source = {'Fin Separation','Fin Thickness','Surface Roughness'};
                                    op = {'0.00318', '0.00318', '0.000001'};
                                    if isfield(this.data,'FinSeparation'); op{1} = num2str(this.data.FinSeparation); end
                                    if isfield(this.data,'FinThickness'); op{2} = num2str(this.data.FinThickness); end
                                    if isfield(this.data,'Roughness'); op{3} = num2str(this.data.Roughness); end

                                    DeterminingFinProperties = true;

                                    while (DeterminingFinProperties)
                                        op = inputdlg(Source,'Determine Fin Properties',[1 100],op);
                                        if isempty(op); ChoosingClassification = true; break; end

                                        % If the User inputed the appropriate data
                                        if isStrNumeric(op{1}) && isStrNumeric(op{2}) && isStrNumeric(op{3})
                                            DeterminingFinProperties = false;
                                            this.data.FinSeparation = str2double(op{1});
                                            this.data.FinThickness = str2double(op{2});
                                            this.data.Roughness = str2double(op{3});
                                            lg = this.data.FinSeparation;
                                            lth = this.data.FinThickness;
                                            e = this.data.Roughness;

                                            % Get the user to select a surface that will be
                                            % ... enhanced
                                            Source = cell(1,4);
                                            i = 1;
                                            for iCon = this.Body.Connections
                                                Source{i} = iCon.name; i = i + 1;
                                            end
                                            index = listdlg('ListString',Source,'SelectionMode','single','InitialValue',1, 'ListSize',[300 350]); % [W H] Default: [160 300]

                                            % If the User made a selection
                                            if index > 0
                                                this.data.Connection = this.Body.Connections(index);
                                                this.data.Porosity = lg/(lg+lth);

                                                %% Hydraulic Diameter
                                                if this.data.Connection.Orient == enumOrient.Vertical
                                                    % Along the wall
                                                    [~,~,xmin,xmax] = this.Body.limits(enumOrient.Vertical);
                                                    this.data.FinLength = xmax - xmin;
                                                else
                                                    % Along the top or bottom surface
                                                    [ymin,ymax,~,~] = this.Body.limits(enumOrient.Horizontal);
                                                    this.data.FinLength = min(ymax-ymin);
                                                end
                                                % Deviations from Thesis Table 8.2 commented by Matthias %%%%%%%%%%%%%%%%%%
                                                % 'lth' here should be 'lf' or 'FinLength' according to Thesis
                                                %                         this.Dh = (4*lg*lth)/(2*lg + 2*lth);
                                                % Matthias:
                                                lf = this.data.FinLength; % Added definition of 'lf'
                                                this.Dh = (4*lg*lf)/(2*lg + 2*lf);

                                                % Friction Factor
                                                % ... E. Fried, I.E. Idelchik, Flow Resistance: A Design Guide for Engineers,
                                                % ...    Hemisphere, (1989)
                                                % 'lf' here is undefined!!!!!!!!!!!!!!!! Should be 'FinLength' (fixed above)
                                                x = min(lg/lf,lf/lg);
                                                % coefficients differ from thesis. same as for 'Fin Connected Channel' type.
                                                C1 = -59.33*x^3+145.6*x^2-125.37*x+96;
                                                this.fFunc_l = @(Re) C1./Re;
                                                % Thesis equation with 'c' (here 'x') has been replaced with '0.121' here.
                                                % Similar to 'Fin Connected Channel' type.
                                                this.fFunc_t = @(Re) 0.121*(e/this.Dh+68./Re).^0.25;

                                                % Nusselt Number
                                                this.NuFunc_l = @(Re) 8.23;
                                                this.NuFunc_t = @(Re,Pr) 0.025*(Re.^0.79).*(Pr.^0.33);

                                                % Stramwise Mixing Enhancement
                                                this.NkFunc_l = @(Re) 1;
                                                this.NkFunc_t = @(Re,Pr) 0.022*(Re.^0.75).*(Pr);
                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                            else
                                                DeterminingFinProperties = true;
                                            end
                                        end
                                    end
                                    this.data.hasSource = false;
                                case 2 % 'Fin Connected Channels'
                                    % Assume the source runs in planes concident with flow
                                    % ... direction with fins weaving their way between these
                                    % ... channels
                                    % Assign Values
                                    Source = {'Gap Between Source Channels',...
                                        'Source Channel Total Width',...
                                        'Source Channel Wall Thickness',...
                                        'Surface Roughness'};
                                    op = {'0.01','0.002','0.0005','0.000001'};
                                    if isfield(this.data,'gap'); op{1} = num2str(this.data.gap); end
                                    if isfield(this.data,'ChannelThickness'); op{2} = num2str(this.data.ChannelThickness); end
                                    if isfield(this.data,'WallThickness'); op{3} = num2str(this.data.WallThickness); end
                                    if isfield(this.data,'Roughness'); op{4} = num2str(this.data.Roughness); end

                                    DeterminingGeneralChannelGeometry = true;

                                    while (DeterminingGeneralChannelGeometry)
                                        op = inputdlg(Source,'Define General Heat Exchanger Geometry',...
                                            [1 100],op);
                                        if isempty(op); ChoosingClassification = true; break; end
                                        if isStrNumeric(op{1}) && isStrNumeric(op{2}) && ...
                                                isStrNumeric(op{3}) && isStrNumeric(op{4})
                                            DeterminingGeneralChannelGeometry = false;
                                            this.data.gap = str2double(op{1});
                                            this.data.ChannelThickness = str2double(op{2});
                                            this.data.WallThickness = str2double(op{3});
                                            this.data.Roughness = str2double(op{4});
                                            lf = this.data.gap;
                                            lcth = this.data.ChannelThickness;
                                            e = this.data.Roughness;
                                            DeterminingGeometry = true;

                                            % Pick the fin pattern, straight across or zig-zag
                                            Source = {'Rectangular','Triangular'};
                                            index = 1;
                                            while (DeterminingGeometry)
                                                index = listdlg('ListString',Source,'SelectionMode','single','InitialValue',index);

                                                % If the User made a selection
                                                if index > 0
                                                    DeterminingGeometry = false;
                                                    this.data.Geometry = Source{index};

                                                    DetermingGeometryProperties = true;
                                                    % Assign Defaults
                                                    Source = {'Base Width','Fin Thickness'};
                                                    op = {'0.002','0.0002'};
                                                    if isfield(this.data,'BaseWidth'); op{1} = num2str(this.data.BaseWidth); end
                                                    if isfield(this.data,'FinThickness'); op{2} = num2str(this.data.FinThickness); end

                                                    while (DetermingGeometryProperties)
                                                        op = inputdlg(Source,'Define In Channel Geometry',...
                                                            [1 100],op);
                                                        if isempty(op); DeterminingGeometry = true; break; end
                                                        this.data.BaseWidth = str2double(op{1});
                                                        this.data.FinThickness = str2double(op{2});
                                                        lb = this.data.BaseWidth;
                                                        lth = this.data.FinThickness;
                                                        switch index
                                                            case 1 % 'Rectangular'
                                                                this.data.FinLength = lf;
                                                                % Deviations from Thesis Table 8.2 commented by Matthias %%%%%%%%%%%%%%%%%%

                                                                % base width 'lb' seems to be defined differently in different equations.
                                                                % Here, for 'Porosity' and 'Dh', it is defined to NOT include fin thickness
                                                                % 'lth'. In Thesis it includes fin thickness. Later in code (ca. line 1230)
                                                                % it is used in both definitions.
                                                                % Porosity
                                                                this.data.Porosity = ...
                                                                    ((lf - lth)/(lf - lth + lcth))*...
                                                                    (lb/(lb + lth));
                                                                %Matthias:
                                                                % this.data.Porosity = ...
                                                                %                                         (lf /(lf +lcth))*...
                                                                %                                         ((lb - lth)/ lb);

                                                                % Hydraulic Diameter
                                                                this.Dh = 4*lf*lb/(2*lf + 2*lb);
                                                                %Matthias:
                                                                % this.Dh = 4*lf*(lb-lth)/(2*lf + 2*(lb-lth));
                                                                % Since 'lb' includes fin thickness AND
                                                                % gas channel 'height' (see thesis)

                                                                % Friction Factor
                                                                % E. Fried, I.E. Idelchik, Flow Resistance: A Design Guide for Engineers,
                                                                %    Hemisphere, (1989)
                                                                % Deviates from thesis equation: Should use (lf - lth) in place of lf
                                                                x = min(lf/lb,lb/lf);
                                                                % Coefficient values differ from thesis except 96. Also, 'x' used here
                                                                % instead of the undefined 'alpha' in Thesis
                                                                % assuming that 'x' is supposed to be gas channel aspect ratio
                                                                C1 = -59.33*x^3+145.6*x^2-125.37*x+96;
                                                                if C1 > 96; C1 = 96; elseif C1 < 56.92; C1 = 56.92; end
                                                                this.fFunc_l = @(Re) C1./Re;
                                                                % Thesis equation with 'c' (here 'x') has been replaced with '0.25' here
                                                                this.fFunc_t = @(Re) 0.25*(e/this.Dh+68./Re).^0.25;

                                                                % Nusselt Number
                                                                this.NuFunc_l = @(Re) 8.23;
                                                                this.NuFunc_t = @(Re,Pr) 0.025*(Re.^0.79).*(Pr.^0.33);

                                                                % Streamwise Mixing Enhancement
                                                                this.NkFunc_l = @(Re) 1;
                                                                this.NkFunc_t = @(Re,Pr) 0.022*(Re.^0.75).*(Pr);
                                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                            case 2 % 'Triangular'
                                                                A = atan(lb/(2*(this.data.gap-lth)));
                                                                this.data.FinLength = this.data.gap/cos(A);
                                                                lf = this.data.FinLength;
                                                                % Porosity
                                                                lth2 = lth/cos(A);
                                                                this.data.Porosity = ...
                                                                    (this.data.gap/(this.data.gap + lcth))*...
                                                                    (lb/(lb + lth2));

                                                                % Hydraulic Diameter
                                                                this.Dh = (lb/2)/(1+sqrt(1/(tan(A)^2) + 1));

                                                                % Friction Factor
                                                                Cl = 2.263*A^3 - 7.208*A^2 + 5.738*A + 12;
                                                                this.fFunc_l = @(Re) Cl./Re;
                                                                C2 = -0.0184*A^2 + 0.0414*A + 0.0847;
                                                                this.fFunc_t = @(Re) C2*(e/this.Dh+68./Re).^0.25;

                                                                % Nusselt Number
                                                                NuT = 2.66*A^5 - 12.19*A^4 + 21.63*A^3 - 19.9*A^2 + 8.92*A + 0.956;
                                                                this.NuFunc_l = @(Re) NuT;
                                                                TempFunc = @(f,Re,Pr) (f./8).*Re.*Pr./(1.07+12.7*(Pr.^(2/3)-1).*(f./8).^0.5);
                                                                this.NuFunc_t = @(Re,Pr) TempFunc(this.fFunc_t(Re),Re,Pr);

                                                                % Mixing
                                                                this.NkFunc_l = @(Re) 1;
                                                                this.NkFunc_t = @(Re,Pr) 0.022*(Re.^0.75).*(Pr); % its similiar to rectangular flows
                                                        end
                                                        DetermingGeometryProperties = false;
                                                    end
                                                else
                                                    DeterminingGeneralChannelGeometry = true;
                                                    break;
                                                end
                                            end
                                        end
                                    end
                                    this.data.hasSource = true;
                                case 3 % 'Staggered Fin Connected Tubes'
                                    Source = {'Spacing Perpendicular to Flow',...
                                        'Spacing Parallel to Flow',...
                                        'Fin: Thickness',...
                                        'Fin: Separation',...
                                        'Fin: Fin Radial Length (C: Continuous Plate)',...
                                        'Tube Outer Diameter',...
                                        'Tube Inner Diameter',...
                                        'Surface Area Factor',...
                                        'Heat Transfer Factor'};
                                    op = {'0.02',...
                                        '0.02',...
                                        '0.0002',...
                                        '0.002',...
                                        'C',...
                                        '0.00635',...
                                        '0.00508',...
                                        '1',...
                                        '1'};
                                    if isfield(this.data,'PerpSpacing'); op{1} = num2str(this.data.PerpSpacing); end
                                    if isfield(this.data,'ParaSpacing'); op{2} = num2str(this.data.ParaSpacing); end
                                    if isfield(this.data,'FinThickness'); op{3} = num2str(this.data.FinThickness); end
                                    if isfield(this.data,'FinSeparation'); op{4} = num2str(this.data.FinSeparation); end
                                    if isfield(this.data,'FinLength'); op{5} = num2str(this.data.FinLength); end
                                    if isfield(this.data,'do'); op{6} = num2str(this.data.do); end
                                    if isfield(this.data,'di'); op{7} = num2str(this.data.di); end
                                    if isfield(this.data,'SurfaceAreaFactor'); op{8} = num2str(this.data.SurfaceAreaFactor); end
                                    if isfield(this.data,'HeatTransferFactor'); op{9} = num2str(this.data.HeatTransferFactor); end

                                    DeterminingNormalToTubeType = true;
                                    while (DeterminingNormalToTubeType)
                                        op = inputdlg(Source,'Define Finned Tube HX Geometry',...
                                            [1 100],op);
                                        if isempty(op); ChoosingClassification = true; break;
                                        end
                                        if isStrNumeric(op{1}) && isStrNumeric(op{2}) && ...
                                                isStrNumeric(op{3}) && isStrNumeric(op{4}) && ...
                                                (strcmp(op{5},'C') || isStrNumeric(op{5})) && ...
                                                isStrNumeric(op{6}) && isStrNumeric(op{7}) && ...
                                                isStrNumeric(op{8})
                                            % Assign Base Properties
                                            DeterminingNormalToTubeType = false;
                                            this.data.PerpSpacing = str2double(op{1});
                                            this.data.ParaSpacing = str2double(op{2});
                                            this.data.FinThickness = str2double(op{3});
                                            this.data.FinSeparation = str2double(op{4});
                                            if ~strcmp(op{5},'C')
                                                this.data.FinLength = str2double(op{5});
                                                lf = this.data.FinLength;
                                            end
                                            this.data.do = str2double(op{6});
                                            this.data.di = str2double(op{7});
                                            this.data.SurfaceAreaFactor = str2double(op{8});
                                            this.data.HeatTransferFactor = str2double(op{9});

                                            lperp = this.data.PerpSpacing;
                                            lpara = this.data.ParaSpacing;
                                            lth = this.data.FinThickness;
                                            lg = this.data.FinSeparation;
                                            do = this.data.do;

                                            Ao = lperp*lpara;
                                            Vo = Ao*(lth + lg);

                                            % Porosity
                                            this.data.PercentageTube = (pi/4*do^2)/Ao;
                                            if isfield(this.data,'FinLength')
                                                ro = do/2 + lf;
                                                this.data.Porosity = ...
                                                    (lg + lth)*(Ao - pi*ro^2)/Vo + ... Empty space
                                                    lg*pi*(ro^2 - 0.25*do^2)/Vo; % Finned Areas
                                            else
                                                this.data.Porosity = ...
                                                    lg*(Ao - pi/4*do^2)/Vo; % Finned Areas
                                            end
                                            this.Dh = do;

                                            % Nusselt Number
                                            % Aligned with theta; may be axial, may be radial
                                            [~,~,xmin,xmax] = this.Body.limits(enumOrient.Vertical);
                                            [~,~,ymin,ymax] = this.Body.limits(enumOrient.Horizontal);
                                            if this.Body.divides(1) > 1
                                                dist = abs(xmax-xmin);
                                            elseif this.Body.divides(2) > 1
                                                dist = abs(ymax-ymin);
                                            else
                                                if abs(xmax-xmin) > abs(ymax-ymin)
                                                    dist = abs(xmax-xmin);
                                                else
                                                    dist = abs(ymax-ymin);
                                                end
                                            end
                                            Nr = dist/this.data.ParaSpacing;

                                            if isfield(this.data,'FinLength')
                                                % Individual Finned Tubes - Staggered
                                                lf_do = this.data.FinLength/this.data.do;
                                                if lf_do < 0.09
                                                    % Low finned tubes
                                                    % if Re -> (895, 713,000)
                                                    C1 = 0.255*(2*ro/lg);
                                                    this.NuFunc_t = @(Re,Pr) ...
                                                        this.data.HeatTransferFactor*...
                                                        C1*(Re.^0.7).*Pr.^(0.333);
                                                    do_Xt = do/lperp;
                                                    if do_Xt < 0.25
                                                        fprintf('XXX LaterialSpacing/OuterDiameter is out friction correlation range XXX\n');
                                                    end
                                                    if round(Nr) < 4
                                                        fprintf('XXX Calcualted # of tube rows is out friction correlation range XXX\n');
                                                    end
                                                    C2 = 4*1.748*(lf/lg)^0.552*do_Xt^0.599*(do/lpara)^0.1738;
                                                    this.fFunc_t = @(Re) C2*Re.^(-0.233);

                                                    % Laminar Cases - assume always turbulent
                                                    this.NuFunc_l = this.NuFunc_t;
                                                    this.fFunc_l = this.fFunc_t;

                                                else % High finned tubes
                                                    % if Re -> (1100, 18,000)
                                                    s_lf = lg/lf;
                                                    s_df = lg/lth;
                                                    lf_do = lf/do;
                                                    df_do = lth/do;
                                                    Xt_do = lperp/do;
                                                    if s_lf < 0.13 || s_lf > 0.63
                                                        fprintf('XXX FinSeparation/FinLength is out of Nusselt correlation range XXX\n');
                                                    end
                                                    if s_df < 1.01 || s_df > 6.62
                                                        fprintf('XXX FinSeparation/FinThickness is out of Nusselt correlation range XXX\n');
                                                    end
                                                    if lf_do > 0.69 || lf_do < 0.09
                                                        fprintf('XXX FinLength/OuterDiameter is out of Nusselt correlation range XXX\n');
                                                    end
                                                    if df_do < 0.011 || df_do > 0.15
                                                        fprintf('XXX FinThickness/OuterDiameter is out Nusselt correlation range XXX\n');
                                                    end
                                                    if Xt_do < 1.54 || Xt_do > 8.23
                                                        fprintf('XXX LaterialSpacing/OuterDiameter is out Nusselt correlation range XXX\n');
                                                    end
                                                    if this.data.do < 0.0111 || this.data.do > 0.0409
                                                        fprintf('XXX OuterDiameter is out Nusselt correlation range XXX\n');
                                                    end
                                                    C1 = 0.134*(s_lf^0.2)*(s_df^0.11);
                                                    this.NuFunc_t = @(Re,Pr) ...
                                                        this.data.HeatTransferFactor*...
                                                        C1*(Re.^(0.681)).*(Pr.^(0.333));
                                                    C2 = (2*this.Dh/dist)*4*9.465*(Xt_do^-0.927)*(lperp/...
                                                        sqrt(lperp^2 + lpara^2))^0.515;
                                                    this.fFunc_t = @(Re) C2*Re.^(-0.316);

                                                    % Laminar Cases - assume always turbulent
                                                    this.NuFunc_l = this.NuFunc_t;
                                                    this.fFunc_l = this.fFunc_t;

                                                end
                                            else
                                                fprintf('XXX Sorry, the Flat Plan Fins on Staggered Tube Bank is currently under development\n');
                                                fprintf('The Best Source is here: http://thermopedia.com/content/750/\n');
                                                %{
                        % Flat Plain Fins on a Staggered Tube Bank
                        C1 = 0.14*...
                          (lperp/lpara)^-0.502*...
                          (lg/do)^0.031;
                        if Nr >= 4
                          this.NuFunc_t = @(Re,Pr) C1*Re^0.672*Pr^0.333;
                        else
                          C2 = C1*0.991*(2.24*(Nr/4)^-0.031)^(-0.607*(4-Nr));
                          C3 = 1+(-0.092*0.607*(4-Nr))-0.328;
                          this.NuFunc_t = @(Re,Pr) C2*Re^C3*Pr^0.333;
                        end
                        % Re -> (500, 24,700)
                        Xt_do = lperp/do;
                        Xl_do = lpara/do;
                        s_do = lg/do;
                        C4 = SFin/(STube+SFin);
                        C5 = (1-C4)*FinVoid;
                        if Xt_do < 1.97 || Xt_do > 2.55
                          fprintf('XXX LaterialSpacing/OuterDiameter is out of Friction correlation range XXX\n');
                        end
                        if Xl_do < 1.7 || Xl_do > 2.58
                          fprintf('XXX LongitudinalSpacing/OuterDimeter is out of Friction correlation range XXX\n');
                        end
                        if s_do < 0.08 || s_do > 0.64
                          fprintf('XXX FinSeparation/OuterDimeter is out of Friction correlation range XXX\n');
                        end
                        C4a = 4*C4*0.508*(Xt_do)^1.318;
                        % Staggered Tube Grid Friction Factor
                        % Re -> (300, 15,000)
                        C5a = 4*C5*TubeBankFriction(lperp,lpara,do);
                        this.fFunc_t = @(Re) C4a*Re^(-0.521) + C5a*((do/this.Dh)*Re)^(-0.18);
                        
                        % Laminar Cases - assume always turbulent due to
                        %   being tripped
                        this.NuFunc_l = this.NuFunc_t;
                        this.fFunc_l = this.fFunc_t;
                                                %}
                                            end

                                            %% Mixing
                                            % Axial Conduction Enhancement
                                            %      Taken From woven regenerators
                                            this.NkFunc_l = @(Re,Pr) 1+0.5*(this.data.Porosity^(-2.91))*((Re.*Pr).^0.66);
                                            this.NkFunc_t = @(Re,Pr) 0.022*(Re.^0.75).*(Pr);
                                        end
                                    end
                                    this.data.hasSource = true;
                                case 4 % Tube Bank Internal
                                    Source = {'Number of Tubes',...
                                        'Tube Outer Diameter',...
                                        'Tube Inner Diameter'};
                                    op = {'100',...
                                        '0.01',...
                                        '0.008'};
                                    if isfield(this.data,'Number'); op{1} = num2str(this.data.Number); end
                                    if isfield(this.data,'do'); op{2} = num2str(this.data.do); end
                                    if isfield(this.data,'di'); op{3} = num2str(this.data.di); end

                                    DeterminingNormalToTubeType = true;
                                    while (DeterminingNormalToTubeType)
                                        op = inputdlg(Source,'Define Tube Bank Internal HX Geometry',...
                                            [1 100],op);
                                        if isempty(op); ChoosingClassification = true; break;
                                        end
                                        if isStrNumeric(op{1}) && isStrNumeric(op{2}) && ...
                                                isStrNumeric(op{3})
                                            DeterminingNormalToTubeType = false;
                                            this.data.Number = str2double(op{1});
                                            this.data.do = str2double(op{2});
                                            this.data.di = str2double(op{3});
                                            di = this.data.di;

                                            % Problem with calculating A and dist here: If
                                            % geometry is scaled by 'Uniform_Scaling' before run,
                                            % A and dist are not updated and errors occur.
                                            % -> move this code to 'discretize' function.

                                            % Nusselt Number
                                            % Aligned with theta; may be axial, may be radial
                                            [~,~,xmin,xmax] = this.Body.limits(enumOrient.Vertical);
                                            [~,~,ymin,ymax] = this.Body.limits(enumOrient.Horizontal);
                                            if this.Body.divides(1) > 1
                                                dist = abs(xmax-xmin);
                                                A = 2*pi*abs(ymax-ymin)*xmin;
                                            elseif this.Body.divides(2) > 1
                                                dist = abs(ymax-ymin);
                                                A = pi*(xmax^2-xmin^2);
                                            else
                                                if abs(xmax-xmin) > abs(ymax-ymin)
                                                    dist = abs(xmax-xmin);
                                                    A = 2*pi*(ymax-ymin)*xmin;
                                                else
                                                    dist = abs(ymax-ymin);
                                                    A = pi*(xmax^2-xmin^2);
                                                end
                                            end
                                            this.data.Ao = A/this.data.Number; % Area per tube
                                            this.data.Spacing = sqrt(4*this.data.Ao/sqrt(3));
                                            this.data.Porosity = ((pi/4)*di^2)/this.data.Ao;
                                            this.Dh = di;

                                            %Matthias: If packign density of tubes is higher than physically possible (hexagonal lattice), give warning
                                            if pi/4*this.data.do^2 / this.data.Ao > pi*sqrt(3)/6
                                                fprintf('XXX Tube number is too high to physically fit into this heat exchanger XXX\n');
                                            end

                                            Cturb = 0.036*(dist/di)^(-0.055);
                                            this.NuFunc_t = @(Re,Pr) Cturb*(Re.^0.8).*(Pr.^0.33);
                                            this.fFunc_t = @(Re) 0.11*(this.Body.Group.Model.roughness/di +68./Re).^0.25;

                                            % Laminar Cases - assume always turbulent
                                            this.NuFunc_l = @(Re) 6;
                                            this.fFunc_l = @(Re) 64./Re;

                                            %% Mixing
                                            % Axial Conduction Enhancement
                                            %      Taken From woven regenerators
                                            this.NkFunc_l = @(Re) 1;
                                            this.NkFunc_t = @(Re,Pr) 0.022*(Re.^0.75).*Pr;
                                        end
                                    end
                                    this.data.hasSource = true;
                                case 5 % Custom HX
                                    Source = {'C1','C2','C3','C4','Surface area to gas volume ratio [m^2/m^3]','Porosity'};
                                    op = {'0.020', '0.8', '0.11', '-0.25', '1.5', '0.5'};
                                    if isfield(this.data,'C1'); op{1} = num2str(this.data.C1); end
                                    if isfield(this.data,'C2'); op{2} = num2str(this.data.C2); end
                                    if isfield(this.data,'C3'); op{3} = num2str(this.data.C3); end
                                    if isfield(this.data,'C4'); op{4} = num2str(this.data.C4); end
                                    if isfield(this.data,'SA_V'); op{5} = num2str(this.data.SA_V); end
                                    if isfield(this.data,'Porosity'); op{6} = num2str(this.data.Porosity); end

                                    DeterminingParameterSet = true;
                                    while (DeterminingParameterSet)
                                        op = inputdlg(Source,'Pick Nu = C1*Re^C2*Pr^0.33, F = C3*Re^C4, HX Surface to Volume Ratio and porosity',...
                                            [1 100],op);
                                        if isempty(op); ChoosingClassification = true; break;
                                        end
                                        if isStrNumeric(op{1}) && isStrNumeric(op{2}) && ...
                                                isStrNumeric(op{3}) && isStrNumeric(op{4}) && ...
                                                isStrNumeric(op{5}) && isStrNumeric(op{6})
                                            DeterminingParameterSet = false;
                                            this.data.C1 = str2double(op{1});
                                            this.data.C2 = str2double(op{2});
                                            this.data.C3 = str2double(op{3});
                                            this.data.C4 = str2double(op{4});
                                            this.data.SA_V = str2double(op{5});
                                            this.data.Porosity = str2double(op{6});

                                            this.Dh = 4/this.data.SA_V;

                                            % Nusselt Number
                                            % Aligned with theta; may be axial, may be radial
                                            this.NuFunc_t = @(Re,Pr) this.data.C1.*(Re.^this.data.C2).*(Pr.^0.33);
                                            this.fFunc_t = @(Re) this.data.C3.*Re.^this.data.C4;

                                            % Laminar Cases - assume always turbulent
                                            this.NuFunc_l = @(Re) 3.66;
                                            this.fFunc_l = @(Re) 64./Re;

                                            %% Mixing
                                            % Axial Conduction Enhancement
                                            %      Taken From woven regenerators
                                            this.NkFunc_l = @(Re) 1;
                                            this.NkFunc_t = @(Re,Pr) 0.022*(Re.^0.75).*Pr;
                                        end
                                    end
                                    this.data.hasSource = true;
                            end
                        else
                            fprintf('HX Type Not Selected. Matrix Creation Failed\n');
                            % this.Geometry = [];
                            return;
                        end
                    end
            end
            if this.data.hasSource
                op = cell(1);
                if isfield(this.data,'SourceTemperature')
                    op{1} = num2str(this.data.SourceTemperature);
                else
                    op{1} = '';
                end
                op = inputdlg('What will be the source Temperature?','Define Source Temperature',1,op);
                if ~isnan(str2double(op{1}))
                    this.data.SourceTemperature = str2double(op{1});
                else
                    this.data.SourceTemperature = this.Body.Temperature();
                end
            end
        end
        function [nodes, faces] = discretize(this,pnd)
            Np = length(pnd);
            this.Nodes = Node.empty;
            this.Faces = Face.empty;
            k = this.matl.ThermalConductivity;
            % Create Nodes to depth based on biot number
            switch this.Geometry
                case {enumMatrix.WovenScreen, ...
                        enumMatrix.RandomFiber, ...
                        enumMatrix.PackedSphere, ...
                        enumMatrix.StackedFoil, ...
                        enumMatrix.CustomRegen}
                    this.data.ignore_canister = true;
                    ncount = Np + 1;
                    fcount = Np + 1;
                    switch this.Geometry
                        case {enumMatrix.WovenScreen, enumMatrix.RandomFiber}
                            % Coefficient = Length of wire per volume * pi * diameter
                            % ... Total_Area/Volume = pi*dw*L / (0.25*pi*dw*dw*L)
                            % ... Total_Area/Volume = 1 / (0.25*dw)
                            A_V = 4*(1-this.data.Porosity)/this.data.dw;
                            % ... Resistance * Total_Area = log(2)/(2*pi*L*k) * pi*dw*L
                            % ... = log(2)/(2) * dw/k
                            RxA = 0.3466*this.data.dw/k; % ds/(2*k/ln(2));

                            %Matthias: Recalculate functions in case properties were changed by RunConditions before discretization
                            this.Dh = this.data.dw/(1-this.data.Porosity);
                            switch this.Geometry
                                case enumMatrix.WovenScreen
                                    % Friction Factor
                                    this.fFunc_l = @(Re) 129./Re+2.91*(Re.^(-0.103));
                                    this.fFunc_t = this.fFunc_l;
                                    % Nusselt Number
                                    %           this.NuFunc_l = @(Re,Pr) 1+0.99*(this.data.Porosity^1.79)*(Re.*Pr).^0.66;
                                    %Matthias: fixed from Sage guide
                                    this.NuFunc_l = @(Re,Pr) (1+0.99*(Re.*Pr).^0.66) .* (this.data.Porosity^1.79);
                                    this.NuFunc_t = this.NuFunc_l;
                                    % Streamwise mixing enhancement
                                    this.NkFunc_l = @(Re,Pr) 1+0.5*(this.data.Porosity^(-2.91))*((Re.*Pr).^0.66);
                                    this.NkFunc_t = this.NkFunc_l;

                                case enumMatrix.RandomFiber
                                    alpha = this.data.Porosity/(1-this.data.Porosity);
                                    % Friction Factor
                                    this.fFunc_l = @(Re) (25.7*alpha+79.8)./Re+...
                                        (0.146*alpha+3.76)*(Re.^(-0.00283*alpha-0.0748));
                                    this.fFunc_t = this.fFunc_l;
                                    % Nusselt Number
                                    this.NuFunc_l = @(Re,Pr) 1+0.186*alpha*(Re.*Pr).^0.55;
                                    this.NuFunc_t = this.NuFunc_l;
                                    % Streamwise Mixing Enhancement
                                    this.NkFunc_l = @(Re,Pr) (1+(Re.*Pr).^0.55);
                                    this.NkFunc_t = this.NkFunc_l;
                            end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        case enumMatrix.PackedSphere
                            % Coefficient = Number of spheres per volume*pi*dw^2
                            % ... A/V = (pi*dw^2)/(4*pi*dw^3/(8*3)) = 6/dw
                            A_V = 6*(1-this.data.Porosity)/this.data.dw;
                            % Resistance * Total_Area = 0.5*dw/(4*pi*k*dw*dw*0.5) *
                            % ... pi*dw^2
                            % ... = pi*dw^2/(4*pi*k*dw) = dw/(4*k)
                            RxA = this.data.dw/(4*k);
                        case enumMatrix.StackedFoil
                            % Coefficient = Area/Volume = 2/(gap + dw)
                            A_V = 2/(this.data.gap + this.data.dw);
                            % Resistance = L/(k*A) = (dw/2) / (k*2)
                            % Total_Area = 2
                            RxA = this.data.dw/(2*k);
                        case enumMatrix.CustomRegen
                            A_V = this.data.SA_V;
                            dw = 4*(1-this.data.Porosity)/this.data.SA_V;
                            RxA = 0.3466*dw/k;
                    end
                    this.Nodes(1,Np) = Node();
                    % Define Nodes
                    i = 1;
                    for nd = pnd
                        newnd = this.Nodes(i); %
                        newnd.Type = enumNType.SN;
                        newnd.data = struct('matl',this.matl,...
                            'T',nd.data.T,'dT_dU',this.matl.dT_du);
                        newnd.xmin = nd.xmin; %
                        newnd.xmax = nd.xmax; %
                        newnd.ymin = nd.ymin; %
                        newnd.ymax = (nd.ymax-nd.ymin).*(1-this.data.Porosity) + nd.ymin; %
                        i = i + 1;
                    end

                    % Define Faces
                    this.Faces(1,Np) = Face();
                    i = 1;
                    for nd = pnd
                        % Create a mixed Face
                        newfc = this.Faces(i);
                        newfc.Type = enumFType.Mix;
                        newfc.Orient = enumOrient.Vertical;
                        newfc.isEdge = false;
                        newfc.ActiveTimes = true;
                        newfc.Nodes = [nd this.Nodes(i)];
                        newfc.data = struct('Area',nd.total_vol()*A_V,'R',RxA);
                        i = i + 1;
                    end

                    % Matthias: Could add solid faces here for conduction along
                    % regenerator

                case enumMatrix.HeatExchanger
                    % Treat the heat exchanger material as a lumped model.
                    % Heat Comes from the source, using convection, heat leaves the
                    % heat exchanger by convection
                    switch this.data.Classification
                        %%
                        case 'Fin Enhanced Surface' % Channel Fins -
                            this.data.ignore_canister = false;
                            % Source is a connection
                            % FinSeparation, FinThickness, Roughness, Porosity, Dh
                            N = this.Body.Group.Model.Mesher.HeatExchangerFinDivisions;
                            for i = Np*N:-1:1; this.Nodes(i) = Node(); end
                            for i = (Np + 1)*N*Np:-1:1; this.Faces(i) = Face(); end
                            % Matthias: ncount and fcount are supposed to count +1 each time a
                            % node/face is created. In the last lines of function Discretize (aprx.
                            % line 1960) all empty Nodes/Faces that were initialized here but not used
                            % are removed. Need to fix this counting for this heat exchanger type as it
                            % seems that it hasnt been implemented. (FIXED)

                            % Matthias: Much of this code may only work for radial (X) fins and/or axial (Y) gas flow.

                            %               ncount = 1;
                            fcount = 1;
                            Con = this.data.Connection;

                            % Find xs and ys from parent nodes
                            %               if length(pnd)>1 || pnd(1).xmin ~= pnd(2).xmin
                            if length(pnd)>1 && pnd(1).xmin ~= pnd(2).xmin %Matthias
                                % Discretized in X
                                if Con.Orient == enumOrient.Vertical
                                    % Discretized Across the gas path
                                    xs = zeros(Np+1,1); i = 1;
                                    for nd = pnd; xs(i) = nd.xmin; i=i+1; end
                                    xs(end) = pnd(end).xmax;
                                    ys = linspace(pnd(1).ymin(1),pnd(1).ymax(1),N+1);
                                else
                                    % Discretized with the gas path
                                    xs = zeros(Np*N+1,1); i = 1; n = 1;
                                    for nd = pnd
                                        xs(i:i+N-1) = linspace(pnd(n).xmin,pnd(n).xmax,N);
                                        i = i + N;
                                        n = n + 1;
                                    end
                                    xs(end) = pnd(end).xmax;
                                    ys = [pnd(1).ymin(1) pnd(2).ymax(1)];
                                end
                                % below checked by Matthias until next bar of percent symbols %%%%%%%%%%%%%

                                %               else
                            elseif length(pnd)>1 && pnd(1).ymin ~= pnd(2).ymin %Matthias
                                % Discretized in Y
                                % Matthias: Swapped 'Horizontal' for 'Vertical' (see below)
                                if Con.Orient == enumOrient.Vertical
                                    % Discretized with the gas path
                                    ys = zeros(Np+1,1); i = 1;
                                    for nd = pnd; ys(i) = nd.ymin(1); i=i+1; end
                                    ys(end) = pnd(end).ymax(1);
                                    xs = linspace(pnd(1).xmin,pnd(1).xmax,N+1);
                                else
                                    % Aim is to determine the y locations of all nodes of the matrix.
                                    % 'i' is 'row index' counting the rows (of N nodes each) along the fin
                                    % base-tip direction (here X)
                                    % 'k' is node index, here 'pnd(k)' is equal to and could be replaced by 'nd'.
                                    % 'k' is not needed.
                                    % Replaced 'k' with 'n' to avoid conflict with k = material conductivity!
                                    % it seems that in this case (gas path and discretization in Y) the
                                    % geometry is discretized in Y into Np*n+1 elements, and not discretized in
                                    % X at all. It seems that the 'ys' calculated below are for
                                    % 'Con.Orient == enumOrient.Horizontal' and those above for
                                    % 'Con.Orient == enumOrient.Vertical'. --> Swap (see above)
                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                    % Discretized Across the gas path
                                    ys = zeros(Np*N+1,1); i = 1; n = 1;
                                    for nd = pnd
                                        ys(i:i+N-1) = linspace(pnd(n).ymin(1),pnd(n).ymax(1),N);
                                        i = i + N;
                                        n = n + 1;
                                    end
                                    ys(end) = pnd(end).ymax(1);
                                    xs = [pnd(1).xmin pnd(2).xmax];
                                end
                            else
                                disp("XXX Discretization Error!!! XXX")
                                return
                            end
                            % below checked by Matthias until next bar of percent symbols %%%%%%%%%%%%%
                            % Declare Nodes
                            ncount = Np*N;
                            for j = length(ys)-1:-1:1
                                for i = length(xs)-1:-1:1
                                    this.Nodes(ncount).xmin = xs(i);
                                    this.Nodes(ncount).xmax = xs(i+1);
                                    % Suspect that ys sould be using index j, as in loop head (fixed)
                                    this.Nodes(ncount).ymin = ys(j); %Matthias
                                    this.Nodes(ncount).ymax = ys(j+1); %Matthias
                                    %                   this.Nodes(ncount).ymin = ys(i,:);
                                    %                   this.Nodes(ncount).ymax = ys(i+1,:);
                                    this.Nodes(ncount).Type = enumNType.SN;
                                    index = findmatching(pnd, this.Nodes(ncount));
                                    this.Nodes(ncount).data = struct(...
                                        'T',this.Body.Temperature(),...
                                        'dT_dU',this.matl.dT_du,...
                                        'matl',this.matl,...
                                        'ParentNode',index);
                                    ncount = ncount - 1;
                                end
                            end
                            % Matthias: set ncount to number of nodes created above, +1, so that node
                            % removal later (ca line 1960) will work.
                            ncount = Np*N +1;

                            % Declare Mixed Faces
                            % Area / Total Volume
                            % Matthias: A_V might be the area of ONLY the sides of the fins (not the
                            % base surface and the opposite surface), relative to the total volume of
                            % the matrix. Since the base and opposite surface are already modeled by
                            % the bodies without the HX matrix. This way the equation below makes sense.
                            A_V = 2/(this.data.FinThickness + this.data.FinSeparation);
                            % this seems to be "R times A", i.e. conduction resistance times area.
                            % This is in line with thesis definition of R for solid-gas faces.
                            RxA = this.data.FinThickness/(2*k);
                            for i = 1:length(this.Nodes)
                                this.Faces(fcount).Type = enumFType.Mix;
                                this.Faces(fcount).Nodes = ...
                                    [pnd(this.Nodes(i).data.ParentNode) this.Nodes(i)];
                                this.Faces(fcount).data = struct(...
                                    'Area',A_V*this.Nodes(i).total_vol(),...
                                    'R',RxA,...
                                    'NuFunc_l',this.NuFunc_l,...
                                    'NuFunc_t',this.NuFunc_t);
                                this.Faces(fcount).isDynamic = false;
                                fcount = fcount + 1;
                            end

                            % Declare Internal Faces
                            % Matthias: Much of this code may only work for radial (X) fins and/or axial (Y) gas flow.
                            %               NY = length(ys)-1;
                            for i = 1:length(this.Nodes)
                                nd = this.Nodes(i);
                                % Conduction faces in X direction
                                if i > 1 && this.Nodes(i-1).xmax == nd.xmin
                                    this.Faces(fcount) = Face([this.Nodes(i-1) nd], ...
                                        enumFType.Solid,enumOrient.Vertical);
                                    % Multiply default conductance (which would be for a full solid annulus) by
                                    % Solid fraction of node as only the cross section of the fins will
                                    % conduct.
                                    this.Faces(fcount).data.U = ...
                                        this.Faces(fcount).data.U*(1-this.data.Porosity);
                                    fcount = fcount + 1;
                                end
                                % Conduction faces in Y direction
                                %                 if i > NY % Not sure if this condition is correct
                                if i > N && this.Nodes(i-N).ymax == nd.ymin % Matthias
                                    this.Faces(fcount) = Face([this.Nodes(i-N) nd], ...
                                        enumFType.Solid, enumOrient.Horizontal);
                                    this.Faces(fcount).data.U = ...
                                        this.Faces(fcount).data.U*(1-this.data.Porosity);
                                    fcount = fcount + 1;
                                end
                            end

                            % Modify Percentage of Gas Node Connections to Selected Connection
                            for NdCon = Con.NodeContacts
                                if NdCon.Node.Body == this.Body
                                    % 'this' might need to be changed to 'Con.NodeContacts(end)' or similar
                                    if isfield(NdCon.data,'Perc')
                                        NdCon.data.Perc = NdCon.data.Perc * this.data.Porosity; % Matthias
                                        %                     this.data.Perc = this.data.Perc * this.data.Porosity;
                                    else
                                        NdCon.data(1).Perc = this.data.Porosity; % Matthias
                                        %                     this.data.Perc = this.data.Porosity;
                                    end
                                end
                            end

                            % Declare Connections to Selected Connection
                            x = Con.x;
                            if Con.Orient == enumOrient.Vertical
                                for i = 1:length(this.Nodes)
                                    if this.Nodes(i).xmin == x || this.Nodes(i).xmax == x
                                        Con.addNodeContacts(...
                                            NodeContact(this.Nodes(i),...
                                            this.Nodes(i).ymin,this.Nodes(i).ymax,...
                                            enumFType.Solid,Con));
                                        % Matthias: added if statement below to fix error
                                        % when 'Perc' doesnt exist
                                        if isfield(Con.NodeContacts(end).data, 'Perc')
                                            Con.NodeContacts(end).data.Perc = (1-this.data.Porosity);
                                        else
                                            Con.NodeContacts(end).data(1).Perc = (1-this.data.Porosity);
                                        end
                                    end
                                end
                            else
                                x = x(1);
                                for i = 1:length(this.Nodes)
                                    if this.Nodes(i).ymin(1) == x || ...
                                            this.Nodes(i).ymax(1) == x
                                        Con.addNodeContacts(...
                                            NodeContact(this.Nodes(i),...
                                            this.Nodes(i).xmin,this.Nodes(i).xmax,...
                                            enumFType.Solid,Con));
                                        % Matthias: added if statement below to fix error
                                        % when 'Perc' doesnt exist
                                        if isfield(Con.NodeContacts(end).data, 'Perc')
                                            Con.NodeContacts(end).data.Perc = (1-this.data.Porosity);
                                        else
                                            Con.NodeContacts(end).data(1).Perc = (1-this.data.Porosity);
                                        end
                                    end
                                end
                            end

                            % Modify Gas and Solid Node volume
                            % Matthias: Don't understand this section yet. Disabled it since the
                            % discretization makes sense to me without this section, which modifies the
                            % node boundaries for reasons unknown to me.
                            % Nov 2022: Seems like this sizes the matrix nodes according to the
                            % porosity. Solid nodes are scaled with (1-porosity) and gas nodes with
                            % porosity.
                            %{
              for i = 1:4
                if Con == this.Body.Connections(i)
                  break;
                end
              end
              switch i
                case {1, 2}
                    % Connection is vertical
                  for fc = this.Faces
                    if fc.Type == enumFType.Mix
                      % Get parent node
                      if fc.Nodes(1).Type == enumNType.SN
                        p = fc.Nodes(2); s = fc.Nodes(1);
                      else
                        p = fc.Nodes(1); s = fc.Nodes(2);
                      end
                      anchor = p.ymax;
                      s.ymin = anchor + ...
                        (s.ymin - anchor)*(1-this.data.Porosity);
                      s.ymax = anchor + ...
                        (s.ymax - anchor)*(1-this.data.Porosity);
                      anchor = p.ymin;
                      p.ymax = anchor + ...
                        (p.ymax - anchor)*this.data.Porosity;
                    end
                  end
                case {3, 4}
                    % Connection is horizontal                    
                  for fc = this.Faces
                    if fc.Type == enumFType.Mix
                      % Get parent node
                      if fc.Nodes(1).Type == enumNType.SN
                        p = fc.Nodes(2); s = fc.Nodes(1);
                      else
                        p = fc.Nodes(1); s = fc.Nodes(2);
                      end
                      anchor = p.xmax;
                      s.xmin = anchor + ...
                        (s.xmin - anchor)*(1-this.data.Porosity);
                      s.xmax = anchor + ...
                        (s.xmax - anchor)*(1-this.data.Porosity);
                      anchor = p.xmin;
                      p.xmax = anchor + ...
                        (p.xmax - anchor)*this.data.Porosity;
                    end
                  end
              end
                                                        %}
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%
                        case 'Fin Connected Channels'

                            this.data.ignore_canister = true;
                            % Properties:
                            % gap, ChannelThickness, WallThickness, Roughness, BaseWidth,
                            % ... FinThickness, FinLength, sourceConvection
                            % Make the source node
                            N = double(this.Body.Group.Model.Mesher.HeatExchangerFinDivisions);
                            for i = (Np + 1)*N + 1:-1:1; this.Nodes(i) = Node(); end
                            for i = (Np + 1)*N*Np:-1:1; this.Faces(i) = Face(); end
                            ncount = 1; fcount = 1;
                            lcth = this.data.ChannelThickness;
                            lwth = this.data.WallThickness;
                            lg = this.data.gap;
                            lth = this.data.FinThickness;
                            lb = this.data.BaseWidth;


                            % Volume of source / total volume
                            SourceV_V = (lcth - lwth)/(lg + lcth);
                            % Surface area of source / total volume
                            SourceA_V = 2/(lg + lcth);
                            % As a multiple of Remaining Volume
                            switch this.data.Geometry
                                case 'Rectangular'
                                    % Volume of fin / total volume
                                    % 'lb' here defined to INCLUDE fin thickness 'lth'
                                    FinV_V = lth*lg/((lg+lcth)*lb);
                                    FinA_FinV = 2/lth;
                                    % Linear Distance between fin nodes
                                    Li = lg/N;
                                case 'Triangular'
                                    lf = this.data.FinLength;
                                    % Volume of fin / total volume
                                    FinV_V = lth*lf/((lg+lcth)*lb);
                                    FinA_FinV = 2/lth;
                                    % Linear Distance between fin nodes
                                    Li = lf/N;
                            end
                            % Exposed surface of source skin / total volume
                            % 'lb' here defined to NOT include fin thickness 'lth'
                            SkinA_V = SourceA_V*(lb/(lth+lb));
                            % Proportion of channel wall / total volume
                            SkinV_V = lwth/(lg + lcth);

                            % Define Source Node
                            SourceNd = this.Nodes(ncount);
                            SourceNd.Type = enumNType.SN;
                            SourceNd.data = struct(...
                                'matl',Material('Constant Temperature'),...
                                'T',this.data.SourceTemperature,...
                                'dT_dU',-1);
                            [~,~,x1,x2] = this.Body.limits(enumOrient.Vertical);
                            [~,~,y1,y2] = this.Body.limits(enumOrient.Horizontal);
                            isHorizontal = this.Body.divides(1) > this.Body.divides(2);
                            SourceNd.xmin = x1;
                            SourceNd.ymin = y1;
                            if isHorizontal
                                % Discretized along the x direction
                                SourceNd.xmax = x2;
                                y1 = offsety(SourceV_V,Node(enumNType.SN,x1,x2,y1,y2),y1);
                                SourceNd.ymax = y1;
                            else
                                % Discretized along the y direction
                                x1 = offsetx(SourceV_V,Node(enumNType.SN,x1,x2,y1,y2),x1);
                                SourceNd.xmax = x1;
                                SourceNd.ymax = y2;
                            end

                            ncount = ncount + 1;
                            j = 0;
                            backup = x1;
                            backup_y1 = y1;
                            for nd = pnd
                                j = j + 1;
                                Vp = nd.total_vol();
                                % Define Skin Node
                                this.Nodes(ncount) = Node();
                                SkinNd = this.Nodes(ncount);
                                SkinNd.Type = enumNType.SN;
                                SkinNd.data = struct(...
                                    'matl',this.matl,...
                                    'T',this.data.SourceTemperature,...
                                    'dT_dU',this.matl.dT_du);
                                if isHorizontal
                                    SkinNd.xmin = nd.xmin;
                                    SkinNd.xmax = nd.xmax;
                                    SkinNd.ymin = backup_y1;
                                    front = offsety(SkinV_V,nd,backup_y1);
                                    SkinNd.ymax = front;
                                else
                                    SkinNd.xmin = backup;
                                    front = offsetx(SkinV_V,nd,backup);
                                    SkinNd.xmax = front;
                                    SkinNd.ymin = nd.ymin(1);
                                    SkinNd.ymax = nd.ymax(1);
                                end
                                ncount = ncount + 1;

                                % Define Conduction between Skin Node and Source
                                if fcount > length(this.Faces); this.Faces(end+1) = Face(); end
                                newfc = this.Faces(fcount);
                                newfc.Type = enumFType.Solid;
                                newfc.Nodes = [SkinNd SourceNd];
                                USkin2Source = SourceA_V*Vp*k*2/lwth;
                                newfc.data = struct('U',USkin2Source);
                                newfc.isDynamic = false;
                                fcount = fcount + 1;

                                % Define Mixed Face to Skin Node
                                if fcount > length(this.Faces); this.Faces(end+1) = Face(); end
                                newfc = this.Faces(fcount);
                                newfc.Type = enumFType.Mix;
                                newfc.Nodes = [SkinNd nd];
                                RxA = this.data.WallThickness/(k*2);
                                newfc.data = struct(...
                                    'R',RxA,...
                                    'Area',SkinA_V*Vp,...
                                    'NuFunc_l',this.NuFunc_l,...
                                    'NuFunc_t',this.NuFunc_t);
                                fcount = fcount + 1;

                                % Define Fin Nodes
                                Vi = FinV_V*Vp/N;
                                % Li - Defined Earlier
                                for i = 1:N
                                    this.Nodes(ncount) = Node();
                                    newnd = this.Nodes(ncount);
                                    newnd.Type = enumNType.SN;
                                    newnd.data = struct(...
                                        'matl',this.matl,...
                                        'T',this.data.SourceTemperature,...
                                        'dT_dU',this.matl.dT_du);
                                    if isHorizontal
                                        newnd.xmin = nd.xmin;
                                        newnd.xmax = nd.xmax;
                                        newnd.ymin = front;
                                        front = offsety(FinV_V/double(N),nd,front);
                                        newnd.ymax = front;
                                    else
                                        newnd.xmin = front;
                                        front = offsetx(FinV_V/double(N),nd,front);
                                        newnd.xmax = front;
                                        newnd.ymin = nd.ymin(1);
                                        newnd.ymax = nd.ymax(1);
                                    end
                                    ncount = ncount + 1;
                                end

                                % Define Conduction between 1st Fin Node and Skin
                                if fcount > length(this.Faces); this.Faces(end+1) = Face(); end
                                newfc = this.Faces(fcount);
                                newfc.Type = enumFType.Solid;
                                newfc.Nodes = [this.Nodes(ncount-N) this.Nodes(ncount-N-1)];
                                newfc.data = struct(...
                                    'U',FinV_V*SourceA_V*Vp*k*2/(Li+lwth));
                                newfc.isDynamic = false;
                                fcount = fcount + 1;

                                for i = 1:N-1
                                    % Define Conduction between Fin Nodes (1-N)
                                    if fcount > length(this.Faces); this.Faces(end+1) = Face(); end
                                    newfc = this.Faces(fcount);
                                    newfc.Type = enumFType.Solid;
                                    newfc.Nodes = [this.Nodes(ncount-N-1+i) this.Nodes(ncount-N+i)];
                                    newfc.data = struct('U',FinV_V*SourceA_V*Vp*k/Li);
                                    newfc.isDynamic = false;
                                    fcount = fcount + 1;
                                end

                                for i = 1:N
                                    % Define Mixed Faces to Fin Nodes
                                    if fcount > length(this.Faces); this.Faces(end+1) = Face(); end
                                    newfc = this.Faces(fcount);
                                    newfc.Type = enumFType.Mix;
                                    newfc.Nodes = [this.Nodes(ncount-N-1+i) nd];
                                    newfc.data = struct(...
                                        'Area',Vi*FinA_FinV,...
                                        'R',lth/(4*k),...
                                        'NuFunc_l',this.NuFunc_l,...
                                        'NuFunc_t',this.NuFunc_t);
                                    newfc.isDynamic = false;
                                    fcount = fcount + 1;
                                end

                                if j > 1
                                    % Define Downstream Conduction
                                    for i = 1:N
                                        if fcount > length(this.Faces); this.Faces(end+1) = Face(); end
                                        newfc = this.Faces(fcount);
                                        newfc.Type = enumFType.Solid;
                                        newfc.Nodes = [this.Nodes(ncount-(N+1)+i) this.Nodes(ncount-2*(N+1)+i)];
                                        if isHorizontal
                                            newfc.data = struct('U',FinV_V*2*k*...
                                                (2*pi*nd.xmin*(nd.ymax(1)-nd.ymin(1)))/...
                                                (nd.xmax-oldnd.xmin));
                                        else
                                            newfc.data = struct('U',FinV_V*2*k*...
                                                (pi*(nd.xmax^2-nd.xmin^2))/...
                                                (nd.ymax(1)-oldnd.ymin(1)));
                                        end
                                        newfc.isDynamic = false;
                                        fcount = fcount + 1;
                                    end
                                end
                                oldnd = nd;
                            end
                            %%
                        case 'Staggered Fin Connected Tubes'
                            this.data.ignore_canister = true;
                            % Source is a reservoir with h
                            % TubeOrient, PerpSpacing, ParaSpacing, Alignment
                            %   FinThickness, FinSeparation, FinLength, do, di
                            %   PercentageTube, PercentageFin
                            ncount = 1;
                            fcount = 1;
                            N = this.Body.Group.Model.Mesher.HeatExchangerFinDivisions;
                            if isfield(this.data,'FinLength')
                                this.Faces = Face.empty;
                                for i = (2*N+2)*Np - 1:-1:1; this.Faces(i) = Face(); end
                            else
                                this.Faces = Face.empty;
                                for i = (2*N+2)*Np - 1:-1:1; this.Faces(i) = Face(); end
                                this.Faces((2*N+2)*Np - 1) = Face();
                            end
                            this.Nodes = Node.empty;
                            for i = Np*(N+1) + 1:-1:1; this.Nodes(i) = Node(); end

                            % Make the source node
                            [~,~,x1,x2] = this.Body.limits(enumOrient.Vertical);
                            [~,~,y1,y2] = this.Body.limits(enumOrient.Horizontal);
                            lth = this.data.FinThickness;
                            lg = this.data.FinSeparation;
                            di = this.data.di;
                            do = this.data.do;
                            VTube_V = this.data.PercentageTube;
                            VFin_VFinned = lth/(lth + lg);

                            % Percentage of the volume that is the temperature source
                            SourceV_V = VTube_V*(di/do)^2;
                            SkinV_V = VTube_V - SourceV_V;

                            % Surface Area of the tubular source elements
                            SourceA_V = 4*SourceV_V/di;
                            SkinA_V = (1-VFin_VFinned)*do/di*SourceA_V;
                            isHorizontal = this.Body.divides(1) > this.Body.divides(2);

                            % Create the Source Node
                            SourceNd = this.Nodes(ncount);
                            SourceNd.Type = enumNType.SN;
                            SourceNd.xmin = x1;
                            SourceNd.ymin = y1;
                            if isHorizontal
                                SourceNd.xmax = x2;
                                front = offsety(this.data.SurfaceAreaFactor*SourceV_V,Node(enumNType.SN,x1,x2,y1,y2),y1);
                                SourceNd.ymax = front;
                            else
                                front = offsetx(this.data.SurfaceAreaFactor*SourceV_V,Node(enumNType.SN,x1,x2,y1,y2),x1);
                                SourceNd.xmax = front;
                                SourceNd.ymax = y2;
                            end
                            SourceNd.data = struct(...
                                'matl',Material('Constant Temperature'),...
                                'T',this.data.SourceTemperature,...
                                'dT_du',-1);
                            ncount = ncount + 1;

                            % Define Volume, Radii and Surface Area Values
                            % FinRadii(i) - N + 1 length
                            % FinVolume(i) - N length
                            % FinArea(i) - N length
                            Ao = this.data.PerpSpacing*this.data.ParaSpacing;
                            if isfield(this.data,'FinLength')
                                % FinRadii
                                ri = linspace(do,do+this.data.FinLength,N+1);
                                % FinVolume
                                FinV_V = VFin_VFinned*pi*(ri(2:end).^2 - ri(1:end-1).^2)/Ao;
                                % FinArea
                                FinA_V = FinV_V*2/lth;
                                FinA_V(N) = (FinA_V(N) + 2*pi*ri(N+1)*VFin_VFinned/Ao);
                            else
                                % FinRadii
                                Rmax = sqrt(Ao/pi);
                                ri = linspace(do,Rmax,N+1);
                                % FinVolume
                                FinV_V =  VFin_VFinned*pi*(ri(2:end)^2 - ri(1:end-1)^2)/Ao;
                                % FinArea
                                FinA_V = FinV_V*2/lth;
                            end
                            RxA_Fin = lth/(4*k);

                            backup = front;
                            for nd = pnd
                                front = backup;

                                Vp = nd.total_vol();
                                Vp = Vp(1);
                                Lpipe = SourceV_V*Vp/(pi/4*(di^2));

                                % Generate Skin Node
                                SkinNd = this.Nodes(ncount);
                                SkinNd.Type = enumNType.SN;

                                if isHorizontal
                                    SkinNd.xmin = nd.xmin;
                                    SkinNd.xmax = nd.xmax;
                                    SkinNd.ymin = front;
                                    front = offsety(this.data.SurfaceAreaFactor*SkinV_V,...
                                        nd,front);
                                    SkinNd.ymax = front;
                                else
                                    SkinNd.xmin = front;
                                    front = offsetx(this.data.SurfaceAreaFactor*SkinV_V,...
                                        nd,front);
                                    SkinNd.xmax = front;
                                    SkinNd.ymin = nd.ymin;
                                    SkinNd.ymax = nd.ymax;
                                end
                                SkinNd.data = struct(...
                                    'matl',this.matl,...
                                    'T',this.data.SourceTemperature,...
                                    'dT_du',this.matl.dT_du);
                                ncount = ncount + 1;

                                % Generate Conduction Face Between Source and Skin
                                if fcount > length(this.Faces); this.Faces(end+1) = Face(); end
                                newfc = this.Faces(fcount);
                                newfc.Type = enumFType.Solid;
                                newfc.Nodes = [SkinNd SourceNd];
                                ro = sqrt(di*do/4);
                                newfc.data = struct('U',...
                                    this.data.SurfaceAreaFactor*...
                                    2*pi*Lpipe*k/log(ro/(di/2)));
                                newfc.isDynamic = false;
                                fcount = fcount + 1;

                                % Generate Mixed Face Between Skin and Gas
                                if fcount > length(this.Faces); this.Faces(end+1) = Face(); end
                                newfc = this.Faces(fcount);
                                newfc.Type = enumFType.Mix;
                                newfc.Nodes = [SkinNd nd];
                                RxA = log(2*do/(di + do))*(do/2)/k;
                                newfc.data = struct(...
                                    'Area',this.data.SurfaceAreaFactor*Vp*SkinA_V,...
                                    'R',RxA,...
                                    'NuFunc_l',this.NuFunc_l,...
                                    'NuFunc_t',this.NuFunc_t);
                                newfc.isDynamic = false;
                                fcount = fcount + 1;


                                for i = 1:N
                                    % Define Node
                                    newnd = this.Nodes(ncount);
                                    newnd.Type = enumNType.SN;
                                    if isHorizontal
                                        newnd.xmin = nd.xmin;
                                        newnd.xmax = nd.xmax;
                                        newnd.ymin = front;
                                        front = offsety(this.data.SurfaceAreaFactor*FinV_V(i),nd,front);
                                        newnd.ymax = front;
                                    else
                                        newnd.xmin = front;
                                        front = offsetx(this.data.SurfaceAreaFactor*FinV_V(i),nd,front);
                                        newnd.xmax = front;
                                        newnd.ymin = nd.ymin;
                                        newnd.ymax = nd.ymax;
                                    end
                                    newnd.data = struct(...
                                        'matl',this.matl,...
                                        'T',this.Body.Temperature,...
                                        'dT_du',this.matl.dT_du);
                                    ncount = ncount + 1;

                                    % Define Mixed Face
                                    if fcount > length(this.Faces); this.Faces(end+1) = Face(); end
                                    newfc = this.Faces(fcount);
                                    newfc.Type = enumFType.Mix;
                                    newfc.Nodes = [this.Nodes(ncount-1) nd];
                                    newfc.data = struct(...
                                        'Area',this.data.SurfaceAreaFactor*Vp*FinA_V(i),...
                                        'R',RxA_Fin,...
                                        'NuFunc_l',this.NuFunc_l,'NuFunc_t',this.NuFunc_t);
                                    newfc.isDynamic = false;
                                    fcount = fcount + 1;

                                    if fcount > length(this.Faces); this.Faces(end+1) = Face(); end
                                    newfc = this.Faces(fcount);
                                    newfc.Type = enumFType.Solid;
                                    newfc.Nodes = [this.Nodes(ncount-1) this.Nodes(1)];
                                    outside = sqrt(ri(i)*ri(i+1));
                                    if i > 1
                                        % Define Internal Conduction
                                        inside = sqrt(ri(i)*ri(i-1));
                                        newfc.data = struct(...
                                            'U',this.data.SurfaceAreaFactor*VFin_VFinned*...
                                            2*pi*Lpipe*k/log(outside/inside));
                                    else
                                        % Define Skin-Fin Conduction
                                        inside = sqrt(sqrt(di*do/4)*ri(i));
                                        newfc.data = struct(...
                                            'U',this.data.SurfaceAreaFactor*VFin_VFinned*...
                                            2*pi*Lpipe*k/log(outside/inside));
                                    end
                                    newfc.isDynamic = false;
                                    fcount = fcount + 1;
                                end
                            end
                            %% Testing Outputs
                            %               AreaSum = 0;
                            %               CondSum = 0;
                            %               for i = 1:length(this.Faces)
                            %                 fc = this.Faces(i);
                            %                 if ~isempty(fc.data)
                            %                   if isfield(fc.data,'Area')
                            %                     AreaSum = AreaSum + fc.data.Area;
                            %                   end
                            %                   if isfield(fc.data,'U')
                            %                     CondSum = CondSum + fc.data.U;
                            %                   end
                            %                 end
                            %               end
                            %               VolumeSum = 0;
                            %               for i = 1:length(this.Nodes)
                            %                 nd = this.Nodes(i);
                            %                 VolumeSum = VolumeSum + nd.vol();
                            %               end
                            %               fprintf([...
                            %                 'Area Sum: ' num2str(AreaSum) ...
                            %                 ' - Cond Sum: ' num2str(CondSum) ...
                            %                 ' - Vol Sum: ' num2str(VolumeSum) '.\n']);
                            %%
                        case 'Tube Bank Internal'
                            % Update matrix parameters in case 'Uniform_Scaling' was used

                            % Nusselt Number
                            % Aligned with theta; may be axial, may be radial
                            [~,~,xmin,xmax] = this.Body.limits(enumOrient.Vertical);
                            [~,~,ymin,ymax] = this.Body.limits(enumOrient.Horizontal);
                            if this.Body.divides(1) > 1
                                dist = abs(xmax-xmin);
                                A = 2*pi*abs(ymax-ymin)*xmin;
                            elseif this.Body.divides(2) > 1
                                dist = abs(ymax-ymin);
                                A = pi*(xmax^2-xmin^2);
                            else
                                if abs(xmax-xmin) > abs(ymax-ymin)
                                    dist = abs(xmax-xmin);
                                    A = 2*pi*(ymax-ymin)*xmin;
                                else
                                    dist = abs(ymax-ymin);
                                    A = pi*(xmax^2-xmin^2);
                                end
                            end
                            this.data.Ao = A/this.data.Number; % Area per tube
                            this.data.Spacing = sqrt(4*this.data.Ao/sqrt(3));
                            this.data.Porosity = ((pi/4)*this.data.di^2)/this.data.Ao;
                            this.Dh = this.data.di;

                            %Matthias: If packign density of tubes is higher than physically possible (hexagonal lattice), give warning
                            if pi/4*this.data.do^2 / this.data.Ao > pi*sqrt(3)/6
                                fprintf('XXX Tube number is too high to physically fit into this heat exchanger XXX\n');
                            end

                            Cturb = 0.036*(dist/this.data.di)^(-0.055);
                            this.NuFunc_t = @(Re,Pr) Cturb*(Re.^0.8).*(Pr.^0.33);
                            this.fFunc_t = @(Re) 0.11*(this.Body.Group.Model.roughness/this.data.di +68./Re).^0.25;

                            % These are not changed by scaling %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % Laminar Cases - assume always turbulent
                            this.NuFunc_l = @(Re) 6;
                            this.fFunc_l = @(Re) 64./Re;

                            % Mixing
                            % Axial Conduction Enhancement
                            %      Taken From woven regenerators
                            this.NkFunc_l = @(Re) 1;
                            this.NkFunc_t = @(Re,Pr) 0.022*(Re.^0.75).*Pr;

                            % Discretization
                            this.data.ignore_canister = true;
                            % Properties:
                            % gap, ChannelThickness, WallThickness, Roughness, BaseWidth,
                            % ... FinThickness, FinLength, sourceConvection
                            % Make the source node
                            for i = Np + 1:-1:1; this.Nodes(i) = Node(); end
                            for i = 3*Np - 1:-1:1; this.Faces(i) = Face(); end
                            ncount = 1; fcount = 1;
                            % Volume of source / total volume
                            SourceV_V = ...
                                (this.data.Ao - pi/4*this.data.do^2)/this.data.Ao;
                            % Surface area of source / total volume
                            SourceA_V = pi*this.data.do/this.data.Ao;
                            % Surface area of skin / total volume
                            SkinA_V = pi*this.data.di/this.data.Ao;
                            % Volume of skin / total volume
                            SkinV_V = pi/4*...
                                (this.data.do^2 - this.data.di^2)/this.data.Ao;


                            % Define Source Node
                            SourceNd = this.Nodes(ncount);
                            SourceNd.Type = enumNType.SN;
                            SourceNd.data = struct(...
                                'matl',Material('Constant Temperature'),...
                                'T',this.data.SourceTemperature,...
                                'dT_dU',-1);
                            [~,~,x1,x2] = this.Body.limits(enumOrient.Vertical);
                            [~,~,y1,y2] = this.Body.limits(enumOrient.Horizontal);
                            isHorizontal = this.Body.divides(1) > this.Body.divides(2);
                            SourceNd.xmin = x1;
                            SourceNd.ymin = y1;
                            if isHorizontal
                                % Discretized along the x direction
                                SourceNd.xmax = x2;
                                front = offsety(SourceV_V,Node(enumNType.SN,x1,x2,y1,y2),y1);
                                SourceNd.ymax = front;
                            else
                                % Discretized along the y direction
                                %                 front = 0.0279; %Raphael Scaling: Keep same source node size as at scale 1
                                front = offsetx(SourceV_V,Node(enumNType.SN,x1,x2,y1,y2),x1);
                                SourceNd.xmax = front;
                                SourceNd.ymax = y2;
                            end

                            %{
              % Remove Gas Contacts from overlaping solid neighbours
              for iCon = this.Body.Connections
                i = 0;
                keep = true(size(iCon.NodeContacts));
                NodeContactsBackup = cell(length(iCon.NodeContacts),2);
                for iNC = iCon.NodeContacts
                  i = i + 1;
                  NodeContactsBackup{i,1} = iNC.Start;
                  NodeContactsBackup{i,2} = iNC.End;
                  if iNC.Node.Body == this.Body
                    for iBody = iCon.Bodies
                      if iBody ~= this.Body
                        if iBody.matl.Phase == enumMaterial.Solid
                          % Get the connections 
                          switch iCon.Orient
                            case enumOrient.Vertical
                              S = iBody.get('Bottom Connection');
                              E = iBody.get('Top Connection');
                              Sx = S.x;
                              Ex = E.x;
                            case enumOrient.Horizontal
                              S = iBody.get('Inner Connection');
                              E = iBody.get('Outer Connection');
                              if ~isempty(S.RefFrame)
                                Sx = S.x + S.RefFrame.Positions;
                              else
                                Sx = S.x;
                              end
                              if ~isempty(E.RefFrame)
                                Ex = E.x + E.RefFrame.Positions;
                              else
                                Ex = E.x;
                              end
                          end
                          Mask = NodeContact(Node.empty,Sx,Ex,...
                            enumFType.Gas,this.Body.Connections);
                          keep(i) = Mask.AlignedMask(iNC,-inf,inf);
                          if ~keep(i); break; end
                        end
                      end
                    end
                  end
                  if ~keep(i); break; end
                end
              end
              % Replace them with References to the Source
              newNCs = NodeContact.empty;
              for i = 1:length(iCon.NodeContacts)
                oNC_Start = NodeContactsBackup{i,1};
                oNC_End = NodeContactsBackup{i,2};
                nNC = iCon.NodeContacts(i);
                if ~keep(i)
                  nNC.Start = oNC_Start;
                  nNC.End = oNC_End;
                  nNC.Node = SourceNd;
                  nNC.Type = enumFType.Solid;
                else
                  d1 = nNC.Start - oNC_Start;
                  d2 = oNC_End - nNC.End;
                  if any(d1 > 0)
                    newNCs(end+1) = NodeContact(SourceNd, ...
                      oNC_Start,oNC_Start + d1, enumFType.Solid, ...
                      this.Body.Connections);
                  end
                  if any(d2 > 0)
                    newNCs(end+1) = NodeContact(SourceNd, ...
                      oNC_End - d2,oNC_End, enumFType.Solid, ...
                      this.Body.Connections);
                  end
                end
                iCon.addNodeContacts(newNCs);
              end
                            %}

                            ncount = ncount + 1;
                            j = 0;
                            backup = front;
                            for nd = pnd
                                front = backup;
                                if isHorizontal
                                    % Discretized along the x direction
                                    Lcond = (nd.xmax - nd.xmin);
                                else
                                    % Discretized along the y direction
                                    Lcond = (nd.ymax - nd.ymin);
                                end
                                j = j + 1;
                                Vp = nd.total_vol();
                                % Define Skin Node
                                SkinNd = this.Nodes(ncount);
                                SkinNd.Type = enumNType.SN;
                                SkinNd.data = struct(...
                                    'matl',this.matl,...
                                    'T',this.data.SourceTemperature,...
                                    'dT_dU',this.matl.dT_du);
                                if isHorizontal
                                    SkinNd.xmin = nd.xmin;
                                    SkinNd.xmax = nd.xmax;
                                    SkinNd.ymin = front;
                                    front = offsety(SkinV_V,nd,front);
                                    SkinNd.ymax = front;
                                else
                                    SkinNd.xmin = front;
                                    front = offsetx(SkinV_V,nd,front);
                                    SkinNd.xmax = front;
                                    SkinNd.ymin = nd.ymin(1);
                                    SkinNd.ymax = nd.ymax(1);
                                end
                                ncount = ncount + 1;

                                % Define Conduction between Skin Node and Source
                                %                 th = (this.data.do - this.data.di)/2; % Skin thickness
                                if fcount > length(this.Faces); this.Faces(end+1) = Face(); end
                                newfc = this.Faces(fcount);
                                newfc.Type = enumFType.Solid;
                                newfc.Nodes = [SkinNd SourceNd];
                                % Matthias: Conduction through tube wall is simplified here and treated as conduction through a flat wall. (U = A*k/dX)
                                %                 USkin2Source = (SourceA_V*Vp)*k/(th/2);
                                % Matthias: Replaced simplified equation above with equation for annular conduction
                                r = this.data.do/2;
                                mid_r = sqrt(this.data.di/2* r);
                                r_ratio = max([r/mid_r, mid_r/r]);
                                USkin2Source = (SourceA_V*Vp)*k / r / log(r_ratio);

                                % Matthias: Added support for custom convective heat transfer coefficient in heat exchanger component
                                if ~isnan(this.Body.h_custom)
                                    USkin2Source = 1/(1/USkin2Source + 1/(SourceA_V*Vp *this.Body.h_custom));
                                end

                                newfc.data = struct('U',USkin2Source);
                                newfc.isDynamic = false;
                                fcount = fcount + 1;

                                % Define Mixed Face to Skin Node
                                if fcount > length(this.Faces); this.Faces(end+1) = Face(); end
                                newfc = this.Faces(fcount);
                                newfc.Type = enumFType.Mix;
                                newfc.Nodes = [SkinNd nd];
                                % Matthias: Conduction through tube wall is simplified here and treated as conduction through a flat wall. (U = A*k/dX)
                                %                 RxA = th/(k*2);
                                % Matthias: Replaced simplified equation above with equation for annular conduction
                                r = this.data.di/2;
                                r_ratio = max([r/mid_r, mid_r/r]);
                                RxA = r*log(r_ratio) / k;

                                newfc.data = struct('R',RxA,'Area',SkinA_V*Vp);
                                fcount = fcount + 1;

                                if j > 1
                                    % Define Downstream Conduction
                                    if fcount > length(this.Faces); this.Faces(fcount) = Face(); end
                                    newfc = this.Faces(fcount);
                                    newfc.Type = enumFType.Solid;
                                    newfc.Nodes = [SkinNd oldnd];
                                    newfc.data = struct('U',k*this.data.Number*pi/4*...
                                        (this.data.do^2 - this.data.di^2)/Lcond);
                                    newfc.isDynamic = false;
                                    fcount = fcount + 1;
                                end
                                oldnd = SkinNd;
                            end
                            %%
                        case 'Custom HX'
                            this.data.ignore_canister = true;
                            % Make the source node
                            this.Nodes(1) = Node();
                            for i = Np:-1:1; this.Faces(i) = Face(); end
                            ncount = 1; fcount = 1;
                            % Volume of source / total volume
                            SourceV_V = 1-this.data.Porosity;
                            % Surface area of source / total volume
                            SourceA_V = this.data.SA_V/(1-this.data.Porosity);

                            % Define Source Node
                            SourceNd = this.Nodes(ncount);
                            SourceNd.Type = enumNType.SN;
                            SourceNd.data = struct(...
                                'matl',Material('Constant Temperature'),...
                                'T',this.data.SourceTemperature,...
                                'dT_dU',-1);
                            [~,~,x1,x2] = this.Body.limits(enumOrient.Vertical);
                            [~,~,y1,y2] = this.Body.limits(enumOrient.Horizontal);
                            isHorizontal = this.Body.divides(1) > this.Body.divides(2);
                            SourceNd.xmin = x1;
                            SourceNd.ymin = y1;
                            if isHorizontal
                                % Discretized along the x direction
                                SourceNd.xmax = x2;
                                front = offsety(SourceV_V,Node(enumNType.SN,x1,x2,y1,y2),y1);
                                SourceNd.ymax = front;
                            else
                                % Discretized along the y direction
                                front = offsetx(SourceV_V,Node(enumNType.SN,x1,x2,y1,y2),x1);
                                SourceNd.xmax = front;
                                SourceNd.ymax = y2;
                            end

                            ncount = ncount + 1;
                            for nd = pnd
                                Vp = nd.total_vol();

                                % Define Mixed Face to Source Node
                                if fcount > length(this.Faces); this.Faces(end+1) = Face(); end
                                newfc = this.Faces(fcount);
                                newfc.Type = enumFType.Mix;
                                newfc.Nodes = [SourceNd nd];
                                RxA = 0;
                                newfc.data = struct('R',RxA,'Area',SourceA_V*Vp);
                                fcount = fcount + 1;
                            end
                    end
            end
            % Remove extra elements
            % Matthias: Uses node and face counts that were counted when created
            % nodes/faces and removes any obsolete (empty) nodes that were initialized
            % but not used.
            if ncount <= length(this.Nodes); this.Nodes(ncount:end) = []; end
            if fcount <= length(this.Faces); this.Faces(fcount:end) = []; end
            for i = 1:length(this.Nodes)
                this.Nodes(i).Body = this.Body;
            end
            nodes = this.Nodes;
            faces = this.Faces;
            for nd = nodes
                nd.Body = this.Body;
                nd.data.Porosity = this.data.Porosity;
            end
            % WSNG = this.WSNG;
        end

        %% End of Discretize
        % get Properties
        function name = get.name(this)
            if ~isempty(this.Geometry) && ~isempty(this.Dh)
                for index = 1:length(this.GeometryEnum)
                    if this.GeometryEnum(index) == this.Geometry
                        break;
                    end
                end
            else
                name = 'Undefined Matrix';
                return;
            end
            name = [this.GeometrySource{index} 'Matrix with ' ...
                num2str(round(this.data.Porosity*100,1)) ...
                '% Porosity and Hydraulic Diameter: ' num2str(this.Dh)];
        end
    end
end

function newy = offsety(V_V, parent, y)
    newy = ...
        y + V_V*parent.total_vol()/(pi*(parent.xmax^2 - parent.xmin^2));
end

function newx = offsetx(V_V, parent, x)
    newx = ...
        sqrt(V_V*parent.total_vol()/(pi*(parent.ymax(1)-parent.ymin(1))) + x^2);
end

%{
function [xvals,j] = xvals_by_alpha_omega(alpha_omega,dw)
scale = 0.112167*Sqrt(alpha_omega);
% Element size = scale*e^(sqrt(omega/(2*alpha))*x)
% Elements are sized such that there are 10 elements within the
%   oscillation penetration depth. With a growth rate cap at
%   1.5 times
% e^sqrt(omega/2*alpha)
expAlphaOmega = exp(sqrt(1/(2*alpha_omega)));
x = 0;
j = 1;
xvals = zeros(1,10);
dx = scale;
while x < dw/2
  % Move Inward
  dx = min([dx*1.5 scale*(expAlphaOmega^x)]);
  x = x + dx;
  j = j + 1;
  xvals(j) = x;
end
xvals(j) = min([xvals(j) dw/2]);
if xvals(j) - xvals(j-1) < 0.1 * (xvals(j-1) - xvals(j-2))
  j = j - 1;
  xvals(j) = dw/2;
  xvals(j+1:end) = [];
elseif j < 10
  xvals(j+1:end) = [];
end
xvals = dw/2 - xvals;
end
%}

function [U,x1,x2,y1,y2] = InternalNodesVertical(xmin,xmax,ymin,ymax,N,Perc,k,Dir)
    x = xmin:(xmax-xmin)/N:xmax;
    L = ymax-ymin;
    U = zeros(1,N-1);
    x1 = zeros(1,N); x2 = x1;
    for i = 1:N-1
        U(i) = Perc*k*2*pi*L/log((x(i+2)+x(i+1))/(x(i)+x(i+1)));
    end
    Vi = Perc*pi*(xmax^2-xmin^2)*L/N;
    switch Dir
        case 'In'; xstart = xmin;
        case 'Out'; xstart = sqrt(Vi*N/(pi*L)-xmax^2);
    end
    for i = 1:N
        xend = sqrt(Vi/(pi*L)+xstart^2);
        x1(i) = xstart;
        x2(i) = xend;
        xstart = xend;
    end
    y1 = ymin(ones(1,N));
    y2 = ymax(ones(1,N));
end

function [U,x1,x2,y1,y2] = InternalNodesHorizontal(xmin,xmax,ymin,ymax,N,Perc,k,Dir)
    y = ymin:(ymax-ymin)/N:ymax;
    U = zeros(1,N-1);
    y1 = zeros(1,N); y2 = y1;
    for i = 1:N-1
        U(i) = Perc*k*pi*(xmax^2-xmin^2)*N/(ymax-ymin);
    end
    d = Perc*(ymax-ymin)/N;
    switch Dir
        case 'Down'; ystart = ymin;
        case 'Up'; ystart = ymax - N*d;
    end
    for i = 1:N
        yend = ymin + d;
        y1(i) = ystart;
        y2(i) = yend;
        ystart = yend;
    end
    x1 = xmin(ones(1,N));
    x2 = xmax(ones(1,N));
    y1 = y(1:end-1);
    y2 = y(2:end);
end

function GenNodeContact(Connection,Perc,NodeToReference,NodeToFind)
    found = false;
    for ncontact = Connection.NodeContacts
        if ncontact.Node == NodeToReference
            if ~isempty(ncontact.data) && isfield(ncontact.data,'Perc')
                ncontact.data.Perc = ncontact.data.Perc.*(1-Perc);
            else
                ncontact.data.Perc = this.data.Porosity;
            end
            found = true;
            break;
        end
    end
    if found
        NewNodeContact = NodeContact(NodeToFind,ncontact.Start,...
            ncontact.End,enumFType.Solid,Connection);
        NewNodeContact.data.Perc = Perc;
        Connection.addNodeContacts(NewNodeContact);
    end
end

function i = findmatching(pnd, nd)
    % finds the parent node that the node 'nd' is within.
    i = 1;
    for p = pnd
        if p.xmin <= nd.xmin && p.xmax >= nd.xmax
            if p.ymin(1) <= nd.ymin && p.ymax(1) >= nd.ymax
                return;
            end
        end
        i = i + 1;
    end
end