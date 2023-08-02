classdef Body < handle
    %{
    A body in MSPM is a rectangular object in the GUI,
    it has a material, nodes and faces, and a temperature, etm.
    %}

    properties (Constant)
        MaterialUndefinedColor = [1 0.5569 1];
        ActiveColor = [0 1 0];
        NormalColor = [0 0 0];
        InvalidColor = [1 0 0];
        % Added color if there is a matrix element
        MatrixColor = [0.85 1 1];
    end

    properties (Hidden)
        GUIObjects;
        isStateValid logical = false;
        isStateDiscretized logical = false;
        StateMovingStatus enumMove;
        s_lb_Vert double;
        s_ub_Vert double;
        s_lb_Hor double;
        d_lb_Hor double;
        s_ub_Hor double;
        d_ub_Hor double;
        customTemperature = [];
        customPressure = [];
    end

    properties (Dependent)
        name;
        isValid;
        MovingStatus;
        RefFrame;
        Temperature;
        Pressure;
        isDiscretized;
    end

    properties
        customname = '';
        ID;
        nodeIndex int32;
        Group Group;
        Connections Connection;
        PVoutputs PVoutput;
        Sensors Sensor;
        matl Material;
        divides = [1 1]; % [Nx, Ny]
        NuFunc function_handle;
        fFunc function_handle;
        Matrix Matrix;
        Mesher Mesher;
        DiscretizationFunctionRadial;
        DiscretizationFunctionAxial;

        % Boolean Values
        isActive logical = false;
        isChanged logical = true;

        % Discretization
        Nodes Node;
        Faces Face;

        % Added by Matthias: Custom Heat Transfer Coefficient
        h_custom = NaN;

        % Added by Matteo: Include in calculate volume
        includeVol logical = true;
    end

    methods
        %% Constructor
        function this = Body(Group,Connections,matl)
            if nargin == 3
                % Get name from
                this.Group = Group;
                this.Connections = Connections;
                for iCon = this.Connections; iCon.addBody(this); end
                this.isChanged = true;
                this.matl = matl;
                fprintf(['Body created in Group ' Group.name '.\n']);
            end
        end
        function addPVoutput(this,PVoutputToAdd)
            this.PVoutputs = PVoutputToAdd;
        end
        function addSensor(this,SensorToAdd)
            for iS = SensorToAdd
                found = false;
                for i = 1:length(this.Sensors)
                    if this.Sensors(i) == iS
                        found = true;
                        break;
                    end
                end
                if ~found
                    this.Sensors(end+1) = iS;
                    this.Group.Model.addSensor(iS); % why create a duplicate of the sensor in a different part of the Model :(
                end
            end
        end
        function deReference(this)
            % Remove Reference from connections
            for iCon = this.Connections
                for i = length(iCon.Bodies):-1:1
                    if iCon.Bodies(i) == this
                        iCon.Bodies(i) = [];
                        iCon.change();
                        break;
                    end
                end
            end
            for i = length(this.Connections):-1:1
                if isempty(this.Connections(i).Bodies)
                    this.Connections(i).deReference();
                end
            end
            % Remove Reference from Group
            iGroup = this.Group;
            for i = length(iGroup.Bodies):-1:1
                if iGroup.Bodies(i) == this
                    iGroup.Bodies(i) = [];
                    iGroup.isChanged = true;
                    break;
                end
            end
            % Remove Reference from any Bridges
            iModel = iGroup.Model;
            for i = length(iModel.Bridges):-1:1
                if iModel.Bridges(i).Body1 == this || iModel.Bridges(i).Body2 == this
                    iModel.Bridges(i).deReference();
                end
            end
            % Remove Reference from any Leaks
            for i = length(iModel.LeakConnections):-1:1
                if (isa(iModel.LeakConnections(i).obj1,'Body') ...
                        && iModel.LeakConnections(i).obj1 == this) ...
                        || (isa(iModel.LeakConnections(i).obj2,'Body') ...
                        && iModel.LeakConnections(i).obj2 == this)
                    iModel.LeakConnections(i).deReference();
                end
            end
            % Remove Reference from any Custom Minor Losses
            for i = length(iModel.CustomMinorLosses):-1:1
                if iModel.CustomMinorLosses(i).Body1 == this || ...
                        iModel.CustomMinorLosses(i).Body2 == this
                    iModel.CustomMinorLosses(i) = [];
                end
            end
            % Remove Reference from any NonConnections
            for i = length(iModel.NonConnections):-1:1
                if iModel.NonConnections(i).Body1 == this || ...
                        iModel.NonConnections(i).Body2 == this
                    iModel.NonConnections(i) = [];
                end
            end
            % Remove Reference from any PVoutputs
            for i = length(iModel.PVoutputs):-1:1
                if iModel.PVoutputs(i) == this.PVoutputs
                    iModel.PVoutputs(i).deReference();
                end
            end
            % Remove Reference from any Sensors
            for i = length(iModel.Sensors):-1:1
                for j = 1:length(this.Sensors)
                    if iModel.Sensors(i) == this.Sensors(j)
                        iModel.Sensors(i).deReference();
                        break;
                    end
                end
            end
            this.Nodes(:) = [];
            this.Faces(:) = [];
            % Remove any visual remenant
            this.removeFromFigure(gca);
            this.delete();
            iModel.show();
        end

        %% get/set
        function Item = get(this,PropertyName)
            switch PropertyName
                case 'Name'
                    Item = this.name;
                case 'Bottom Connection'
                    miny = inf;
                    for iCon = this.Connections
                        if iCon.Orient == enumOrient.Horizontal && iCon.x < miny
                            miny = iCon.x;
                            Item = iCon;
                        end
                    end
                case 'Top Connection'
                    maxy = -inf;
                    for iCon = this.Connections
                        if iCon.Orient == enumOrient.Horizontal && iCon.x > maxy
                            maxy = iCon.x;
                            Item = iCon;
                        end
                    end
                case 'Inner Connection'
                    minx = inf;
                    for iCon = this.Connections
                        if iCon.Orient == enumOrient.Vertical && iCon.x < minx
                            minx = iCon.x;
                            Item = iCon;
                        end
                    end
                case 'Outer Connection'
                    maxx = -inf;
                    for iCon = this.Connections
                        if iCon.Orient == enumOrient.Vertical && iCon.x > maxx
                            maxx = iCon.x;
                            Item = iCon;
                        end
                    end
                case 'Material'
                    Item = this.matl;
                case 'Temperature'
                    Item = this.Temperature;
                case 'Pressure'
                    Item = this.Pressure;
                case 'Radial Divides'
                    Item = this.divides(1);
                case 'Axial Divides'
                    Item = this.divides(2);
                case 'RefFrame'
                    Item = Frame.empty;
                    for iCon = this.Connections
                        if iCon.Orient == enumOrient.Horizontal && ~isempty(iCon.RefFrame)
                            if isempty(Item)
                                Item = iCon.RefFrame;
                            else
                                if Item ~= iCon.RefFrame
                                    Item = Frame.empty;
                                    break;
                                end
                            end
                        end
                    end
                case 'Change Matrix'
                    if isempty(this.Matrix)
                        Item = Matrix(this); %#ok<PROPLC>
                        this.Matrix = Item;
                    else
                        Item = this.Matrix;
                    end
                case 'Expand Matrix'
                    Item = this.Matrix;
                case 'Radial Discretization Function'
                    Item = this.DiscretizationFunctionRadial;
                case 'Axial Discretization Function'
                    Item = this.DiscretizationFunctionAxial;
                    % Matthias: Added 'h_custom'
                case 'Custom Heat Transfer Coefficient'
                    Item = this.h_custom;
                case 'Include in Volume Calculation'
                    Item = this.includeVol;
                otherwise
                    fprintf(['XXX Body GET Inteface for ' PropertyName ' is not found XXX\n']);
            end
        end
        function set(this,PropertyName,Item)
            switch PropertyName
                case 'Name'
                    this.customname = Item;
                case 'Radial Divides'
                    this.divides(1) = Item;
                case 'Axial Divides'
                    this.divides(2) = Item;
                case 'Temperature'
                    if Item ~= this.Group.Model.engineTemperature
                        this.customTemperature = Item;
                    else
                        this.customTemperature = [];
                    end
                case 'Pressure'
                    if Item ~= this.Group.Model.enginePressure
                        this.customPressure = Item;
                    else
                        this.customPressure = [];
                    end
                case 'Change Matrix'
                    this.Matrix = Item;
                    this.Matrix.Body = this;
                case 'Radial Discretization Function'
                    this.DiscretizationFunctionRadial = Item;
                case 'Axial Discretization Function'
                    this.DiscretizationFunctionAxial = Item;
                case 'RefFrame'
                    if isempty(Item)
                        for iCon = this.Connections
                            if iCon.Orient == enumOrient.Horizontal
                                iCon.set('RefFrame',Item);
                            end
                        end
                    else
                        for iCon = this.Connections
                            if iCon.Orient == enumOrient.Horizontal
                                if isempty(iCon.RefFrame) || iCon.RefFrame ~= Item
                                    iCon.set('RefFrame',Item);
                                end
                            end
                        end
                    end
                    % Matthias: Added 'h_custom'
                case 'Custom Heat Transfer Coefficient'
                    this.h_custom = Item;
                case 'Include in Volume Calculation'
                    this.includeVol = Item;
                otherwise
                    fprintf(['XXX Body SET Inteface for ' PropertyName ' is not found XXX\n']);
                    return;
            end
            this.change();
        end

        %% Utility
        function sortConnections(this)
            % Sort the connections in an order that is xmin,xmax,ymin,ymax
            for i = 1:length(this.Connections)-1
                for j = i+1:length(this.Connections)
                    if this.Connections(i).Orient == this.Connections(j).Orient
                        if this.Connections(i).x > this.Connections(j).x
                            % swap the two
                            tempCon = this.Connections(i);
                            this.Connections(i) = this.Connections(j);
                            this.Connections(j) = tempCon;
                        end
                    elseif this.Connections(i).Orient == enumOrient.Horizontal
                        % swap the two
                        tempCon = this.Connections(i);
                        this.Connections(i) = this.Connections(j);
                        this.Connections(j) = tempCon;
                    end
                end
            end
        end
        function dir = getBodyDirection(this)
            if this.divides(1) > this.divides(2)
                dir = 1;
            elseif this.divides(2) > this.divides(1)
                dir = 2;
            else
                cons = zeros(1,2);
                for iCon = this.Connections
                    switch iCon.Orient
                        case enumOrient.Vertical
                            [b1,b2,~,~] = this.limits(enumOrient.Horizontal);
                            for iBody = iCon.Bodies
                                [y1,y2,~,~] = iBody.limits(enumOrient.Horizontal);
                                % if there is overlap between this body and
                                % the other body that it shares a connection
                                % with, the counter goes 1 up
                                if ~(all(y1 > b2) || all(y2 < b1))
                                    cons(1) = cons(1) + 1;
                                end
                            end
                        case enumOrient.Horizontal
                            [b1,b2,~,~] = this.limits(enumOrient.Vertical);
                            for iBody = iCon.Bodies
                                % Matthias: not sure about the logic of
                                % this method to determine the Body's flow
                                % direction. the command below always
                                % returns [0,0] for 'Vertical'
                                [x1,x2,~,~] = this.limits(enumOrient.Vertical);
                                if ~(all(x1 > b2) || all(x2 < b1))
                                    cons(2) = cons(2) + 1;
                                end
                            end
                    end
                end          
                if cons(1) == 0
                    dir = 2;
                elseif cons(2) == 0
                    dir = 1;
                elseif cons(1) > cons(2)
                    dir = 1;
                else
                    dir = 2;
                end
            end
        end

        %% Creation Tests
        function isit = overlaps(thisBody,otherBody)
            %{
            returns bool
            %}
            isit = false;
            if thisBody ~= otherBody
                % Test x-coords
                [ ~, ~, xmin1, xmax1] = thisBody.limits(enumOrient.Vertical);
                [ ~, ~, xmin2, xmax2] = otherBody.limits(enumOrient.Vertical);
                if xmin1 >= xmax2 || xmin2 >= xmax1
                    isit = false;
                    return;
                end
                [ymin1, ymax1, ~, ~] = thisBody.limits(enumOrient.Horizontal);
                [ymin2, ymax2, ~, ~] = otherBody.limits(enumOrient.Horizontal);
                N = max([1 length(ymin1) length(ymax1)]);
                if N ~= 1
                    if (~isscalar(ymin2) && N ~= length(ymin2)) || ...
                            (~isscalar(ymax2) && N ~= length(ymax2))
                        otherBody.update();
                        [ymin2, ymax2, ~, ~] = otherBody.limits(enumOrient.Horizontal);
                    end
                end
                if all(ymin1 >= ymax2) || all(ymin2 >= ymax1)
                    isit = false;
                    return;
                end
                isit = true;
            end
        end
        function [doesit, orient, xmin, xmax, y] = touches(thisBody,otherBody)
            if thisBody.Connections(1) == otherBody.Connections(2) || ...
                    thisBody.Connections(2) == otherBody.Connections(1)
                % Vertical Connections
                orient = thisBody.Connections(1).Orient;
                [ ~, ~, xmin1, xmax1] = thisBody.limits(enumOrient.Vertical);
                [ ~, ~, xmin2, xmax2] = otherBody.limits(enumOrient.Vertical);
                xmin = xmin1; xmin(xmin<xmin2) = xmin2(xmin<xmin2);
                xmax = xmax1; xmax(xmax>xmax2) = xmax2(xmax>xmax2);
                if thisBody.Connections(1) == otherBody.Connections(2)
                    y = thisBody.Connections(1).x;
                else
                    y = thisBody.Connections(2).x;
                end
                doesit = any(xmin<xmax);
            elseif thisBody.Connections(3) == otherBody.Connections(4) || ...
                    thisBody.Connections(4) == otherBody.Connections(3)
                % Horizontal Connections
                orient = thisBody.Connections(3).Orient;
                [ymin1, ymax1, ~, ~] = thisBody.limits(enumOrient.Horizontal);
                [ymin2, ymax2, ~, ~] = otherBody.limits(enumOrient.Horizontal);
                xmin = ymin1;
                if isscalar(ymin2)
                    xmin(xmin<ymin2) = ymin2;
                else
                    if isscalar(ymin1)
                        xmin = ymin1*ones(size(ymin2));
                    end
                    xmin(xmin<ymin2) = ymin2(xmin<ymin2);
                end
                xmax = ymax1;
                if isscalar(ymax2)
                    xmax(xmax>ymax2) = ymax2;
                else
                    if isscalar(ymin1)
                        xmax = ymax1*ones(size(ymax2));
                    end
                    xmax(xmax>ymax2) = ymax2(xmax>ymax2);
                end
                if thisBody.Connections(3) == otherBody.Connections(4)
                    y = thisBody.Connections(3);
                else
                    y = thisBody.Connections(4);
                end
                doesit = any(xmin<xmax);
            else
                doesit = false;
                orient = enumOrient.Vertical;
                xmin = inf;
                xmax = inf;
                y = inf;
            end
        end

        %% Update on Demand
        function update(this)
            if isempty(this.ID); this.ID = this.Group.Model.getBodyID(); end
            if isempty(this.Connections)
                this.isChanged = false;
                return;
            end
            if any(~isvalid(this.Sensors))
                this.Sensors = this.Sensors(isvalid(this.Sensors));
            end
            if any(~isvalid(this.PVoutputs))
                this.PVoutputs = this.PVoutputs(isvalid(this.PVoutputs));
            end

            if ~isempty(this.Matrix)
                if isempty(this.Matrix.matl) || isempty(this.Matrix.Dh)
                    delete(this.Matrix);
                    this.Matrix(:) = [];
                elseif ~(this.Matrix.Body == this)
                    this.Matrix.Body = this;
                end
            end

            this.isChanged = false;

            % Update Connections
            for iCon = this.Connections
                found = false;
                iCon.CleanUpBodies;
                for iBody = iCon.Bodies
                    if iBody == this; found = true; end
                end
                if ~found; iCon.addBody(this); end
            end

            this.sortConnections();
            %% Update Limits
            % Find vertical connections
            nv = 2; nh = 2;
            arrConV(2) = Connection();
            arrConH(2) = Connection();
            for iCon = this.Connections
                if iCon.Orient == enumOrient.Vertical
                    arrConV(nv) = iCon; nv = 1;
                else
                    arrConH(nh) = iCon; nh = 1;
                end
            end
            if arrConV(1).x > arrConV(2).x
                this.s_lb_Vert = arrConV(2).x;
                this.s_ub_Vert = arrConV(1).x;
            else
                this.s_lb_Vert = arrConV(1).x;
                this.s_ub_Vert = arrConV(2).x;
            end
            if arrConH(1).x > arrConH(2).x
                this.s_lb_Hor = arrConH(2).x;
                if arrConH(2).get('isStationary')
                    this.d_lb_Hor = this.s_lb_Hor;
                else
                    this.d_lb_Hor = this.s_lb_Hor + arrConH(2).RefFrame.Positions;
                end
                this.s_ub_Hor = arrConH(1).x;
                if arrConH(1).get('isStationary')
                    this.d_ub_Hor = this.s_ub_Hor;
                else
                    this.d_ub_Hor = this.s_ub_Hor + arrConH(1).RefFrame.Positions;
                end
            else
                this.s_lb_Hor = arrConH(1).x;
                if arrConH(1).isStationary
                    this.d_lb_Hor = this.s_lb_Hor;
                else
                    this.d_lb_Hor = this.s_lb_Hor + arrConH(1).RefFrame.Positions;
                end
                this.s_ub_Hor = arrConH(2).x;
                if arrConH(2).isStationary
                    this.d_ub_Hor = this.s_ub_Hor;
                else
                    this.d_ub_Hor = this.s_ub_Hor + arrConH(2).RefFrame.Positions;
                end
            end


            %% Update MovingStatus
            found = false;
            frame = [];
            varenum = enumMove.Stretching;
            for i = 1:length(this.Connections)
                if ~this.Connections(i).get('isStationary')
                    frame = this.Connections(i).RefFrame;
                    found = true;
                    break;
                end
            end
            if ~found
                varenum = enumMove.Static;
            else
                found = false;
                for j = i+1:length(this.Connections)
                    if ~this.Connections(j).get('isStationary') ...
                            && this.Connections(j).RefFrame == frame
                        varenum = enumMove.Moving;
                        found = true;
                    end
                end
                if ~found
                    varenum = enumMove.Stretching;
                end
            end
            this.StateMovingStatus = varenum;

            %% Update isValid
            varb = true;
            isSolid = (this.matl.Phase == enumMaterial.Solid);
            % Gas bodies do not support multiple dimensions
            if isSolid
                % SOLIDS MUST HAVE FINITE VOLUME
                [~,~,dim1, dim2] = limits(this,enumOrient.Vertical);
                if dim1 == dim2
                    fprintf(...
                        ['Solid volumes must have finite volumes, please ' ...
                        'define a x-dimension for ' ...
                        this.name '.\n']);
                    varb = false;
                end
                [~,~,dim1, dim2] = limits(this,enumOrient.Horizontal);
                if dim1 == dim2
                    fprintf(...
                        ['Solid volumes must have finite volumes, please ' ...
                        'define a y-dimension for ' ...
                        this.name '.\n']);
                    varb = false;
                end
                % SOLIDS CANNOT STRETCH
                if this.MovingStatus == enumMove.Stretching
                    fprintf(...
                        ['Solid volumes cannot be stretched, please define ' ...
                        'the same frame to both lateral surfaces of ' ...
                        this.name '.\n']);
                    varb = false;
                end
            else
                % GASES CANNOT HAVE MULTIPLE DIMENSIONS
                if min(this.divides) ~= 1
                    fprintf(...
                        ['Gas volumes are restricted to single dimensional discretization,' ...
                        'please review '  this.name  '"s definition.\n']);
                    varb = false;
                end
            end

            % Check with interference from other bodies
            if this.Group.isOverlaping(this)
                varb = false;
            end
            %fprintf(['Update Body: ' this.name '\n']);
            this.isStateValid = varb;
        end
        function resetDiscretization(this)
            for iCon = this.Connections
                iCon.resetDiscretization();
            end
            this.Nodes(:) = [];
            this.Faces(:) = [];
            this.isStateDiscretized = false;
        end
        function change(this)
            this.isChanged = true;
            this.resetDiscretization();
            this.Group.change();
        end
        function name = get.name(this)
            if isempty(this.customname)
                [~,~,x1,x2] = this.limits(enumOrient.Vertical);
                [~,~,y1,y2] = this.limits(enumOrient.Horizontal);
                name = [this.matl.name ' Body ' ...
                    '(' num2str(x1) ', ' num2str(x2) ' )' ...
                    '(' num2str(y1) ', ' num2str(y2) ' ) vol:' ...
                    num2str(pi*(x2^2-x1^2)*(y2(1)-y1(1))) ];
            else
                name = this.customname;
            end
        end
        function [d_lb, d_ub, s_lb, s_ub] = limits(this, Orient)
            if this.isChanged; this.update(); end
            switch Orient
                case enumOrient.Vertical
                    d_lb = 0;
                    d_ub = 0;
                    s_lb = this.s_lb_Vert;
                    s_ub = this.s_ub_Vert;
                case enumOrient.Horizontal
                    d_lb = this.d_lb_Hor;
                    d_ub = this.d_ub_Hor;
                    s_lb = this.s_lb_Hor;
                    s_ub = this.s_ub_Hor;
            end
        end
        % for some reason, the getters below change this, which you'd think
        % isn't something that a getter should do
        function isValid = get.isValid(this)
            this.update();
            %             if this.isChanged; this.update(); end
            isValid = this.isStateValid;
        end
        function frame = get.RefFrame(this)
            if this.isChanged; this.update(); end
            frame = [];
            if this.MovingStatus == enumMove.Moving
                for iCon = this.Connections
                    if iCon.Orient == enumOrient.Horizontal && ~iCon.get('isStationary')
                        frame = iCon.RefFrame;
                    end
                end
            end
        end
        function MovingStatus = get.MovingStatus(this)
            if this.isChanged; this.update(); end
            MovingStatus = this.StateMovingStatus;
        end
        function Discretized = get.isDiscretized(this)
            if this.isChanged; this.update(); end
            if isempty(this.Nodes)
                this.isStateDiscretized = false;
            end
            Discretized = this.isStateDiscretized;
        end

        %% Property Parameters
        function Temp = get.Temperature(this)
            if isempty(this.customTemperature)
                Temp = this.Group.Model.engineTemperature;
            else
                Temp = this.customTemperature;
            end
        end
        function Press = get.Pressure(this)
            if isempty(this.customPressure)
                Press = this.Group.Model.enginePressure;
            else
                Press = this.customPressure;
            end
        end

        %% Node Generation
        function discretize(this)
            this.update();
            if this.isDiscretized % || ~this.isValid
                return;
            end
            isSolid = (this.matl.Phase == enumMaterial.Solid);
            if isSolid; FType = enumFType.Solid; else; FType = enumFType.Gas; end
            if this.isChanged
                this.update();
            end
            %% DETERMINE THE NODE TYPE
            if isSolid
                NType = enumNType.SN; % SN - Solid Node
            else
                % SVGN - Static Volume Gas Node
                % VVGN - Variable Volume Gas Node
                % SAGS - Shearing Annular Gas Node
                switch this.MovingStatus
                    case enumMove.Static
                        % Decide, is it shearing or just moving?
                        % Looking at the two vertical connections
                        for iCon = this.Connections
                            NType = enumNType.SVGN;
                        end
                    case enumMove.Moving
                        % Decide, is it shearing or just moving?
                        % Looking at the two vertical connections
                        for iCon = this.Connections
                            NType = enumNType.SVGN;
                            if iCon.Orient == enumOrient.Vertical
                                % Find a body that shares that
                                % connection and scope of x
                                for iBody = this.Group.Bodies
                                    if iBody ~= this
                                        if isempty(iBody.RefFrame)
                                            NType = enumNType.SAGN;
                                            frame = this.RefFrame;
                                            break;
                                        end
                                    end
                                end
                            end
                        end
                    case enumMove.Stretching
                        NType = enumNType.VVGN;
                end
            end

            %% Y LIMITS
            [ymin,ymax,~,~] = this.limits(enumOrient.Horizontal);
            if ~prod(ymax>=ymin) % Will give true if this is not true everywhere
                changed_registered = false;
                for iCon = this.Group.Connections
                    if iCon.Orient == this.Connections(3).Orient && ...
                            iCon.x == this.Connections(3).x
                        if length(iCon.RefFrame) ~= length(this.Connections(3).RefFrame)
                            this.Connections(3) = iCon.x;
                            this.update();
                            changed_registered = true;
                        end
                    elseif iCon.Orient == this.Connections(4).Orient && ...
                            iCon.x == this.Connections(4).x
                        if length(iCon.RefFrame) > length(this.Connections(4).RefFrame)
                            this.Connections(4).RefFrame = iCon.RefFrame;
                            this.update();
                            changed_registered = true;
                        end
                    end
                end
                if changed_registered
                    fprintf(...
                        ['XXX A memory error occured for Body ' this.name ...
                        ' in which a connection reference was duplicated,' ...
                        ' this has been mitigated but will require a restart of' ...
                        ' the discretization. XXX\n']);
                    return;
                else
                    fprintf(...
                        ['XXX Calculated maximum and minimum positions ' this.name ...
                        ' for will result in a case of negative area, consider' ...
                        ' readjusting gas volume or start positions to mitigate' ...
                        ' this overlap. XXX\n']);
                    return;
                end
            end
            %% X LIMITS
            [~,~,xmin,xmax] = this.limits(enumOrient.Vertical);
            if isempty(this.DiscretizationFunctionRadial)
                x = transpose(linspace(xmin,xmax,this.divides(1)+1));
            else
                if isSolid
                    [x] = this.DiscretizationFunctionRadial(this,this.Group.Model.Mesher,enumOrient.Vertical);
                    if isempty(x); return; end
                    deltas = diff(x);
                    if ~(all(sign(deltas) > 0) || all(sign(deltas) < 0))
                        fprintf('XXX x generation issue in Body\m');
                        [x] = this.DiscretizationFunctionRadial(this,this.Group.Model.Mesher,enumOrient.Vertical);
                    end
                    if x(end,1) < x(1,1); x = flip(x,1); end
                else
                    if isempty(this.Matrix)
                        fprintf(...
                            ['XXX Smart Discretization functions currently cannot' ...
                            ' be used for matrixless gas nodes. Problem found in radial direction of Body:' ...
                            this.name '. XXX\n']);
                        return;
                    else
                        if this.divides(1) > 1
                            [x] = this.DiscretizationFunctionRadial(this,this.Group.Model.Mesher,enumOrient.Vertical); % is this supposed to be .Mesh instead of .Mesher ???
                            if isempty(x); return; end
                            deltas = diff(x);
                            if ~(all(sign(deltas) > 0) || all(sign(deltas) < 0))
                                fprintf('XXX x generation issue in Body\m');
                                [x] = this.DiscretizationFunctionRadial(this,this.Group.Model.Mesher,enumOrient.Vertical);
                            end
                            if x(end,1) < x(1,1); x = flip(x,1); end
                        else
                            x = [xmin; xmax];
                        end
                    end
                end
            end


            %% Y LIMITS
            LEN = this.divides(2)+1;
            if isempty(this.DiscretizationFunctionAxial)
                if isscalar(ymin)
                    if  isscalar(ymax)
                        % SCALAR-SCALAR CASE
                        y = transpose(linspace(ymin,ymax,LEN));
                    else % only ymin is scalar - stretching
                        y = zeros(LEN,Frame.NTheta);
                        for i = 1:length(ymax)
                            y(:,i) = transpose(linspace(ymin,ymax(i),LEN));
                        end
                    end
                elseif isscalar(ymax) % only ymax is scalar - stretching
                    y = zeros(this.divides(2)+1,Frame.NTheta);
                    for i = 1:length(ymin)
                        y(:,i) = transpose(linspace(ymin(i),ymax,LEN));
                    end
                else % both are stretching or moving
                    y = zeros(this.divides(2)+1,Frame.NTheta);
                    for i = 1:length(ymin)
                        y(:,i) = transpose(linspace(ymin(i),ymax(i),LEN));
                    end
                end
            else
                if isSolid
                    [y] = this.DiscretizationFunctionAxial(this,this.Group.Model.Mesher,enumOrient.Horizontal);
                    if isempty(y); return; end
                    deltas = diff(y);
                    try
                        if ~(all(all(sign(deltas) > 0)) || all(all(sign(deltas) < 0)))
                            fprintf('XXX y generation issue in Body\m');
                            this.DiscretizationFunctionAxial(this,this.Group.Model.Mesher,enumOrient.Horizontal);
                        end
                    catch
                        fprintf('err');
                    end
                    if y(end,1) < y(1,1); y = flip(y,1); end
                else
                    if isempty(this.Matrix)
                        fprintf(...
                            ['XXX Smart Discretization functions currently cannot' ...
                            ' be used for matrixless gas nodes. Problem found in axial direction of Body:' ...
                            this.name '. XXX\n']);
                        return;
                    else
                        if this.divides(2) > 1
                            [y] = this.DiscretizationFunctionAxial(this,this.Group.Model.Mesher,enumOrient.Horizontal);
                            if isempty(y); return; end
                            deltas = diff(y);
                            try
                                if ~(all(all(sign(deltas) > 0)) || all(all(sign(deltas) < 0)))
                                    fprintf('XXX y generation issue in Body\m');
                                    this.DiscretizationFunctionAxial(this,this.Group.Model.Mesher,enumOrient.Horizontal);
                                end
                            catch
                                fprintf('err');
                            end
                            if y(end,1) < y(1,1); y = flip(y,1); end
                        else
                            if isscalar(ymin)
                                if  isscalar(ymax)
                                    % SCALAR-SCALAR CASE
                                    y = transpose(linspace(ymin,ymax,LEN));
                                else % only ymin is scalar - stretching
                                    y = zeros(LEN,Frame.NTheta);
                                    for i = 1:length(ymax)
                                        y(:,i) = transpose(linspace(ymin,ymax(i),LEN));
                                    end
                                end
                            elseif isscalar(ymax) % only ymax is scalar - stretching
                                y = zeros(LEN,Frame.NTheta);
                                for i = 1:length(ymin)
                                    y(:,i) = transpose(linspace(ymin(i),ymax,LEN));
                                end
                            else % both are stretching or moving
                                y = zeros(LEN,Frame.NTheta);
                                for i = 1:length(ymin)
                                    y(:,i) = transpose(linspace(ymin(i),ymax(i),LEN));
                                end
                            end
                        end
                    end
                end
            end

            if strcmp(this.matl.name ,'Perfect Insulator') || ...
                    strcmp(this.matl.name ,'Constant Temperature')
                x = [x(1,:); x(end,:)];
                y = [y(1,:); y(end,:)];
            end
            divx = size(x,1) - 1;
            divy = size(y,1) - 1;

            this.Nodes = Node.empty;
            this.Faces = Face.empty;

            %% INITIALIZE
            sendtoConnections{4} = NodeContact.empty;
            ncount = divx*divy;
            fcount = (divx-1)*divy + divx*(divy-1);
            %fcount = prod([divx divy]-[1 0])+prod(this.divides-[0 1]);

            %% FOR EACH DISTINCT NODE WITHIN BODY
            for iy = (size(y,1) - 1):-1:1
                % loop initialization
                starty = y(iy,:);
                endy = y(iy+1,:);
                starty = CollapseVector(starty);
                endy = CollapseVector(endy);

                for ix = (size(x,1) - 1):-1:1
                    %% Define this.Nodes
                    CurrentNode = Node(NType,x(ix),x(ix+1),starty,endy,Face.empty,Node.empty,this,0);
                    this.Nodes(ncount) = CurrentNode;

                    ncount = ncount - 1;
                end
            end

            for i = 1:length(this.Nodes)
                nd = this.Nodes(i);
                if nd.xmin == xmin
                    sendtoConnections{1}(end+1) = ...
                        NodeContact(nd,nd.ymin,nd.ymax,FType,this.Connections(1));
                end
                if nd.xmax == xmax
                    sendtoConnections{2}(end+1) = ...
                        NodeContact(nd,nd.ymin,nd.ymax,FType,this.Connections(2));
                else
                    % Make Vertical connection
                    this.Faces(fcount) = ...
                        Face([this.Nodes(i+1) nd],FType,enumOrient.Vertical);
                    fcount = fcount - 1;
                end
                if nd.ymin(1) == ymin(1)
                    sendtoConnections{3}(end+1) = ...
                        NodeContact(nd,nd.xmin,nd.xmax,FType,this.Connections(3));
                end
                if nd.ymax(1) == ymax(1)
                    sendtoConnections{4}(end+1) = ...
                        NodeContact(nd,nd.xmin,nd.xmax,FType,this.Connections(4));
                else
                    % Make Horizontal connection
                    this.Faces(fcount) = ...
                        Face([this.Nodes(i+divx) nd],FType,enumOrient.Horizontal);
                    fcount = fcount - 1;
                end
            end

            %% SEND THE COMPILED LIST TO CONNECTIONS FOR PROCESSING
            for i = 1:length(this.Connections)
                this.Connections(i).addNodeContacts(sendtoConnections{i});
            end

            if ~isempty(this.Matrix) && ~isempty(this.Matrix.Geometry)
                % Pass Nodes to Matrix for generation
                [nodes, faces] = this.Matrix.discretize(this.Nodes);
                this.Nodes = [this.Nodes nodes];
                this.Faces = [this.Faces faces];
            end

            this.isStateDiscretized = true;
            % fprintf(['Body ' this.name ' is discretized, but this.Nodes still need to reference their this.Faces.\n']);
        end

        %% GRAPHICS FUNCTIONS
        function color = getColor(this)
            if this.isActive
                color = Body.ActiveColor;
            else
                color = Body.NormalColor;
            end
        end
        function updateColor(this)
            if ~isempty(this.GUIObjects)
                for iGraphicsObject = this.GUIObjects
                    set(iGraphicsObject,'FaceColor',this.getColor());
                end
            end
        end
        function removeFromFigure(this,AxisReference)
            if ~isempty(this.GUIObjects)
                children = get(AxisReference,'Children');
                for obj = this.GUIObjects
                    if isgraphics(obj)
                        for i = length(children):-1:1
                            if isgraphics(children(i)) && children(i) == obj
                                children(i).delete;
                                break;
                            end
                        end
                    end
                end
                this.GUIObjects = [];
            end
        end
        function show(this,AxisReference,Inc)
            if this.isChanged; this.update(); end
            % fprintf(['Plotted Body ' this.name '.\n']);
            % Remove object from plot
            % this.removeFromFigure(AxisReference);

            if this.isValid
                if ~isempty(this.Matrix)
                    fillcolor = Body.MatrixColor;
                elseif ~isempty(this.matl) && ~isempty(this.matl.Color)
                    fillcolor = this.matl.Color;
                else
                    fillcolor = Body.MaterialUndefinedColor;
                end
            else
                fillcolor = Body.InvalidColor;
            end
            edgecolor = this.getColor();
            % Find the extents of the body and position the rectangle(s)
            % accordingly

            %% Case 1: If it has 6 connections it is a cuboid
            if length(this.Connections) == 6
                % Render as cuboid

                return;
            end

            %% Case 2: It is a cylinder
            % If one connection is vertical and x = 0
            for iConnection = this.Connections
                if iConnection.Orient == enumOrient.Vertical && iConnection.x == 0
                    % Treat it as a cylinder
                    [~, ~,~,maxx] = this.limits(enumOrient.Vertical);
                    if nargin > 2 % Inc Exists
                        [miny, maxy,~,~] = this.limits(enumOrient.Horizontal);
                        if length(miny) > 1; miny = miny(Inc); end
                        if length(maxy) > 1; maxy = maxy(Inc); end
                    else
                        % plot a motion ghost
                        if this.Group.Model.showBodyGhosts && this.MovingStatus == enumMove.Moving
                            [y1,y2,miny,maxy] = this.limits(enumOrient.Horizontal);
                            gminy = max(y1);
                            gmaxy = max(y2);
                            OffsetRot = this.Group.Position.Rot;
                            R = RotMatrix(OffsetRot);
                            RootPosition = [this.Group.Position.x; this.Group.Position.y];
                            p = [R*[gminy;maxx]+RootPosition ...
                                R*[gmaxy;maxx]+RootPosition ...
                                R*[gmaxy;-maxx]+RootPosition ...
                                R*[gminy;-maxx]+RootPosition];

                            this.Group.Model.GhostGUIObjects(end+1) = fill(p(1,:),p(2,:),...
                                fillcolor,...
                                'EdgeColor',edgecolor,...
                                'LineWidth',1,...
                                'HitTest','off',...
                                'FaceAlpha',0.25,...
                                'EdgeAlpha',0.75);
                        else
                            [~,~,miny,maxy] = this.limits(enumOrient.Horizontal);
                        end
                    end

                    OffsetRot = this.Group.Position.Rot;
                    R = RotMatrix(OffsetRot);
                    RootPosition = [this.Group.Position.x; this.Group.Position.y];
                    p = [R*[miny;maxx]+RootPosition ...
                        R*[maxy;maxx]+RootPosition ...
                        R*[maxy;-maxx]+RootPosition ...
                        R*[miny;-maxx]+RootPosition];

                    this.removeFromFigure(AxisReference)
                    this.GUIObjects = fill(p(1,:),p(2,:),...
                        fillcolor,...'FaceColor',fillcolor,...
                        'EdgeColor',edgecolor,...
                        'LineWidth',1,...
                        'HitTest','off');
                    return;
                end
            end

            %% Case 3: It is an annulus
            % Get extents of body
            [~,~,minx, maxx] = this.limits(enumOrient.Vertical);
            if nargin > 2 % Inc exists
                [miny, maxy,~,~] = this.limits(enumOrient.Horizontal);
                if length(miny) > 1; miny = miny(Inc); end
                if length(maxy) > 1; maxy = maxy(Inc); end
            else
                % plot a motion ghost
                if this.Group.Model.showBodyGhosts && this.MovingStatus == enumMove.Moving
                    [y1,y2,miny,maxy] = this.limits(enumOrient.Horizontal);
                    gminy = max(y1);
                    gmaxy = max(y2);
                    OffsetRot = this.Group.Position.Rot;
                    R = RotMatrix(OffsetRot);
                    RootPosition = [this.Group.Position.x; this.Group.Position.y];
                    p = [R*[gminy;maxx]+RootPosition ...
                        R*[gmaxy;maxx]+RootPosition ...
                        R*[gmaxy;minx]+RootPosition ...
                        R*[gminy;minx]+RootPosition];

                    this.Group.Model.GhostGUIObjects(end+1) = fill(p(1,:),p(2,:),...
                        fillcolor,...
                        'EdgeColor',edgecolor,...
                        'LineWidth',1,...
                        'HitTest','off',...
                        'FaceAlpha',0.25,...
                        'EdgeAlpha',0.75);

                    p = [R*[gminy;-minx]+RootPosition ...
                        R*[gminy;-maxx]+RootPosition ...
                        R*[gmaxy;-maxx]+RootPosition ...
                        R*[gmaxy;-minx]+RootPosition];

                    this.Group.Model.GhostGUIObjects(end+1) = fill(p(1,:),p(2,:),...
                        fillcolor,...'FaceColor',fillcolor,...
                        'EdgeColor',edgecolor,...
                        'LineWidth',1,...
                        'HitTest','off',...
                        'FaceAlpha',0.25,...
                        'EdgeAlpha',0.75);
                else
                    [~,~,miny,maxy] = this.limits(enumOrient.Horizontal);
                end
            end
            OffsetRot = this.Group.Position.Rot;
            R = RotMatrix(OffsetRot);
            RootPosition = [this.Group.Position.x; this.Group.Position.y];

            p1 = [R*[miny;maxx]+RootPosition ...
                R*[maxy;maxx]+RootPosition ...
                R*[maxy;minx]+RootPosition ...
                R*[miny;minx]+RootPosition];
            p2 = [R*[miny;-minx]+RootPosition ...
                R*[miny;-maxx]+RootPosition ...
                R*[maxy;-maxx]+RootPosition ...
                R*[maxy;-minx]+RootPosition];

            if length(this.GUIObjects) == 2 && ...
                    isgraphics(this.GUIObjects(1)) && ...
                    isgraphics(this.GUIObjects(2))
                set(this.GUIObjects(1),'XData',p1(1,:));
                set(this.GUIObjects(1),'YData',p1(2,:));
                set(this.GUIObjects(1),'FaceColor',fillcolor);
                set(this.GUIObjects(1),'EdgeColor',edgecolor);
                set(this.GUIObjects(2),'XData',p2(1,:));
                set(this.GUIObjects(2),'YData',p2(2,:));
                set(this.GUIObjects(2),'FaceColor',fillcolor);
                set(this.GUIObjects(2),'EdgeColor',edgecolor);
            else
                this.removeFromFigure(AxisReference)
                this.GUIObjects(2) = fill(p2(1,:),p2(2,:),...
                    fillcolor,...
                    'EdgeColor',edgecolor,...
                    'LineWidth',1,...
                    'HitTest','off');
                this.GUIObjects(1) = fill(p1(1,:),p1(2,:),...
                    fillcolor,...
                    'EdgeColor',edgecolor,...
                    'LineWidth',1,...
                    'HitTest','off');
            end

        end

    end
end

