classdef Group < handle
    %Group Summary of this class goes here
    %   Detailed explanation goes here

    properties (Constant)
        ConnectionTolerance = 1e-6; % 0.001 mm plenty small enough for films
        Extension = 1.33;
        MinimumDisplayLength = 0.1;
        MinimumDisplayWidth = 0.1;
        HighlightedColor = [0 1 0];
        NormalColor = [0 0 0];
    end

    properties (Dependent)
        isValid;
        Width;
        Height;
        ValidBorder;
        InvalidBorder;
        isDiscretized;
    end

    properties (Hidden)
        isStateValid logical = false;
        WidthState double;
        HeightState double;
        ValidBorderState Line2DChain;
        InvalidBorderState Line2DChain;
        isStateDiscretized logical = false;
        isEnvironmentCasted logical = false;
    end

    properties
        isChanged logical = true;
        Bodies Body;
        Connections Connection;
        RelationManagers RelationManager;

        GUIObjects;
        isActive = true;
        name = 'Default Group';
        Model Model;
        Position Position;

        Nodes Node;
        Faces Face;
    end

    methods

        %% Constructor Function
        function this = Group(inputModel,inputPosition,inputBodies)
            if nargin == 0; return; end
            this.RelationManagers(2) = ...
                RelationManager(this, enumOrient.Horizontal);
            this.RelationManagers(1) = ...
                RelationManager(this, enumOrient.Vertical);
            switch nargin
                case 1
                    % Only Model Provided
                    this.Model = inputModel;
                case 2
                    % A Model and positon is provided
                    this.Model = inputModel;
                    this.Position = inputPosition;
                case 3
                    % A Model, position and a bunch of bodies are provided
                    this.Model = inputModel;
                    this.Position = inputPosition;
                    this.addBody(inputBodies);
                    for iBody = inputBodies
                        this.addConnection(iBody.Connections);
                    end
            end
            this.Connections = [Connection(0,enumOrient.Vertical,this) ...
                Connection(0,enumOrient.Horizontal,this)];
            if ~isempty(this.Model)
                this.isActive = true;
                this.Model.switchHighLighting(this);
            end
            this.isChanged = true;
            fprintf('Created Group.\n');
        end
        function deReference(this)
            iModel = this.Model;
            iModel.isStateDiscretized = false;
            for i = length(iModel.Groups):-1:1
                if iModel.Groups(i) == this
                    iModel.Groups(i) = [];
                end
            end
            for iBody = this.Bodies
                iBody.deReference();
            end
            this.Bodies = [];
            for iCon = this.Connections
                iCon.deReference();
            end
            this.Connections = [];
            % Remove any visual remenant
            this.removeFromFigure(gca);
        end

        %% Get/Set Interface
        function Item = get(this,PropertyName)
            switch PropertyName
                case 'Name'
                    Item = this.name;
                case 'Position'
                    Item = this.Position;
                case 'Bodies'
                    Item = this.Bodies;
                case 'Connections'
                    Item = this.Connections;
                case 'Leak Connections'
                    Item = this.LeakConnections;
                case 'Relation Managers'
                    Item = this.RelationManagers;
                otherwise
                    fprintf(['XXX Group GET Inteface for ' PropertyName ...
                        ' is not found XXX\n']);
            end
        end
        function set(this,PropertyName,Item)
            switch PropertyName
                case 'Name'
                    this.name = Item;
                otherwise
                    fprintf(['XXX Group SET Inteface for ' PropertyName ...
                        ' is not found XXX\n']);
            end
        end

        %% Add Objects
        function addBody(this,inputBodies)
            if isrow(inputBodies)
                this.Bodies = [this.Bodies inputBodies];
            else
                this.Bodies = [this.Bodies inputBodies'];
            end
            for iBody = inputBodies
                if isempty(iBody.ID)
                    iBody.ID = this.Model.getBodyID();
                end
                this.addConnection(iBody.Connections);
                fprintf(['Added ' iBody.name ' to ' this.name '.\n']);
            end
            this.Bodies = unique(this.Bodies,'rows');
            this.isChanged = true;
            this.fixDatum();
        end
        function addConnection(this,inputobj)
            for RMan = this.RelationManagers
                RMan.isChanged = true;
            end
            if isrow(inputobj)
                this.Connections = [this.Connections inputobj];
            else
                this.Connections = [this.Connections inputobj'];
            end
            for iCon = inputobj
                if isempty(iCon.ID)
                    iCon.ID = this.Model.getConID();
                end
            end
            this.Connections = unique(this.Connections,'rows');
        end

        %% Clean up and Organization
        function cleanUpConnections(this)
            % Ensure Group.Connections Reflects the bodies within it
            keep = false(size(this.Connections));
            keep(1:2) = true;
            for iBody = this.Bodies
                for iCon = iBody.Connections
                    found = false;
                    for i = 1:length(this.Connections)
                        if iCon == this.Connections(i)
                            found = true;
                            keep(i) = true;
                            break;
                        end
                    end
                    if ~found
                        this.addConnection(iCon);
                        keep(length(this.Connections)) = true;
                    end
                end
            end
            if any(~keep); this.Connections = this.Connections(keep);
            end

            keep = true(size(this.Connections));
            for i = 1:length(this.Connections)
                if ~keep(i)
                    iCon = this.Connections(i);
                    if isempty(iCon.Bodies); keep(i) = false; end
                    for j = i+1:length(this.Connections)
                        if ~keep(j)
                            jCon = this.Connections(j);
                            if iCOn.isFunctionallyEqualTo(jCon)
                                for jBody = jCon.Bodies
                                    % Replace all references of j with i
                                    for k = 1:length(jBody.Connections)
                                        if jBody.Connections(k) == jCon
                                            jBody.Connections(k) = iCon;
                                        end
                                    end
                                    iCon.addBody(jBody);
                                end

                                for iBridge = this.Model.Bridges
                                    if iBridge.Connection1 == jCon
                                        iBridge.Connection1 = iCon;
                                    elseif iBridge.Connection2 == jCon
                                        iBridge.Connection2 = iCon;
                                    end
                                end

                                for iLeak = this.Model.LeakConnections
                                    if iLeak.Connection1 == jCon
                                        iLeak.Connection1 = iCon;
                                    elseif iLeak.Connection2 == jCon
                                        iLeak.Connection2 = iCon;
                                    end
                                end

                                jCon.removeFromFigure(gca);
                            end
                        end
                    end
                end
            end

            if any(~keep)
                for i = 1:length(this.Connections)
                    if ~keep(i)
                        this.Connections(i).delete();
                    end
                end
                this.Connections = this.Connections(keep);
            end

            for iCon = this.Connections
                keep = true(size(iCon.Bodies));
                for i = 1:length(iCon.Bodies)
                    if ~any(this.Bodies == iCon.Bodies(i))
                        keep(i) = false;
                    end
                end
                if any(~keep)
                    iCon.Bodies = iCon.Bodies(keep);
                end
            end

            count1 = false;
            count2 = false;
            for iCon = this.Connections
                if iCon.x == 0
                    if iCon.Orient == enumOrient.Vertical; count1 = true;
                    elseif iCon.Orient == enumOrient.Horizontal; count2 = true;
                    end
                end
            end
            if ~count1; this.addConnection(Connection(0,enumOrient.Vertical,this)); end
            if ~count2; this.addConnection(Connection(0,enumOrient.Horizontal,this)); end
            fprintf(['Cleaned up Connections in Group ' this.name '.\n']);
        end
        function fixDatum(this)
            offset = 0;
            for iCon = this.Connections
                if iCon.Orient == enumOrient.Horizontal && iCon.x < offset
                    offset = iCon.x;
                end
            end
            for iCon = this.Connections
                if iCon.Orient == enumOrient.Horizontal
                    iCon.x = iCon.x - offset;
                end
            end
        end
        function isit = isOverlaping(this,TheBody)
            % Determine if TheBody is interfering with any other body
            % Determine if its in the same column
            isit = false;
            for iBody = this.Bodies
                if TheBody.overlaps(iBody)
                    isit = true;
                    return;
                end
            end
        end

        %% Update on Demand
        function change(this)
            this.isChanged = true;
            this.Model.change();
        end
        function update(this)
            if isempty(this.RelationManagers)
                this.RelationManagers(2) = ...
                    RelationManager(this, enumOrient.Horizontal);
                this.RelationManagers(1) = ...
                    RelationManager(this, enumOrient.Vertical);
            end
            if length(this.Connections) > 2
                this.cleanUpConnections();
            end
            %% Update isValid
            varb = true;
            % Test to see if any bodies overlap
            for iBody = this.Bodies
                for jBody = this.Bodies
                    if iBody ~= jBody
                        [Ax1,Ax2,~,~] = iBody.limits(enumOrient.Vertical);
                        [Bx1,Bx2,~,~] = jBody.limits(enumOrient.Vertical);
                        if (Ax1 < Bx2 || Ax2 > Bx1) % overlap x's
                            [Ay1,Ay2,~,~] = iBody.limits(enumOrient.Horizontal);
                            [By1,By2,~,~] = jBody.limits(enumOrient.Horizontal);
                            if  (any(Ay1 < By2) || any(Ay2 > By1)) % overlap y's
                                varb = false;
                                fprintf(['XXX Overlap detected in Group ' ...
                                    this.name ' between Bodies ' ...
                                    iBody.name ' and ' jBody.name '. Please make sure ' ...
                                    'that connections are properly defined XXX \n']);
                                break;
                            end
                        end
                    end
                end
            end
            % Test to see if there are any islands within the border
            this.updateBorder(this.isEnvironmentCasted);
            if ~isempty(this.InvalidBorderState)
                varb = false;
                fprintf(['XXX Unfilled hollow space found in Group ' ...
                    this.name '. Please make sure to fill such spaces with a ' ...
                    'Gas or other material, or review how bodies are connected ' ...
                    'XXX \n']);
            end
            this.isStateValid = varb;

            %% Update Width
            % From each body get the maximum radius of the cylindrical connections
            vard = this.MinimumDisplayLength;
            for iConnection = this.Connections
                if iConnection.Orient == enumOrient.Vertical ...
                        && iConnection.x > vard
                    vard = iConnection.x;
                end
            end
            this.WidthState = vard*2;

            %% Update Height
            % From each body get the maximum radius of the cylindrical connections
            vard = this.MinimumDisplayWidth;
            for iConnection = this.Connections
                if iConnection.Orient == enumOrient.Horizontal ...
                        && iConnection.x > vard
                    vard = iConnection.x;
                end
            end
            this.HeightState = vard;

            %% Update isDiscretized
            varb = true;
            for iBody = this.Bodies
                if ~iBody.isDiscretized
                    varb = false;
                    break;
                end
            end
            if varb
                for iConnection = this.Connections
                    if ~iConnection.isDiscretized
                        varb = false;
                        break;
                    end
                end
            end
            this.isStateDiscretized = varb;

            this.isChanged = false;
        end
        function updateBorder(this,castToConnections)
            delete(this.ValidBorderState);
            delete(this.InvalidBorderState);
            if ~isempty(this.Bodies)
                %% Each connection must have a minimum of 2 bodies over all of its length
                if this.isChanged || (nargin > 1 && castToConnections)
                    Lines = Line2DChain.empty;
                    for iBody = this.Bodies
                        [~, ~, x1, x2] = iBody.limits(enumOrient.Vertical);
                        [~, ~, y1, y2] = iBody.limits(enumOrient.Horizontal);
                        if x1 > 0
                            Lines(end+4) = Line2DChain(x1, y1, x1, y2);
                            Lines(end-1) = Line2DChain(x1, y2, x2, y2);
                            Lines(end-2) = Line2DChain(x2, y1, x2, y2);
                            Lines(end-3) = Line2DChain(x1, y1, x2, y1);
                        else
                            Lines(end+3) = Line2DChain(x1, y2, x2, y2);
                            Lines(end-1) = Line2DChain(x2, y1, x2, y2);
                            Lines(end-2) = Line2DChain(x1, y1, x2, y1);
                        end
                    end
                    j = 0;
                    i = 0;
                    while (i < length(Lines))
                        i = i + 1;
                        while (j < length(Lines))
                            j = j + 1;
                            if i ~= j
                                [Lines,i,j] = intersects(i,j, Lines);
                            end
                        end
                        j = i + 1;
                    end

                    %% Decimate duplicate points and merge
                    Finished = Line2DChain.empty;
                    old_n = inf;
                    while ~isempty(Lines)
                        % Combine Step
                        n = length(Lines);

                        Eliminated = zeros(1,n);
                        for i = length(Lines):-1:2
                            for j = i-1:-1:1
                                if ~Eliminated(j)
                                    Eliminated(j) = Lines(i).attemptToMerge(Lines(j));
                                end
                            end
                        end
                        % Decimate Lines that have been added to others
                        for i = length(Lines):-1:1
                            if Eliminated(i)
                                Lines(i) = [];
                            end
                        end
                        % Pick out finished Lines
                        isDone = false(1,length(Lines));
                        for i = 1:length(Lines)
                            isDone(i) = Lines(i).isFinished;
                        end
                        Finished = [Finished Lines(isDone)];
                        Lines(isDone) = [];

                        if old_n == n
                            fprintf('XXX Infinite Loop detected, exiting XXX\n');
                            Finished = [Finished Lines];
                            Lines = [];
                        end
                        old_n = n;
                    end

                    if length(Finished) > 1
                        % There can only be one valid border
                        % Pick the one with the largest value of x
                        maxx = 0;
                        for i = 1:length(Finished)
                            ix = max(Finished(i).XData);
                            if ix > maxx
                                index = i;
                                maxx = ix;
                            end
                        end
                        this.ValidBorderState = Finished(index);
                        this.InvalidBorderState = Finished(Finished~=Finished(index));
                        if castToConnections
                            this.isEnvironmentCasted = false;
                            fprintf(['XXX Environmental Shell generation failed, ' ...
                                'there are internal volumes XXX\n']);
                        end
                    else
                        this.ValidBorderState = Finished;
                        this.InvalidBorderState = Line2DChain.empty;
                        if castToConnections
                            this.castEnvironmentToConnections();
                        end
                    end
                    %% fprintf(['Group ' this.name ' has been scanned for contact with surroundings.\n']);
                end
            end
        end
        function Valid = get.isValid(this)
            if ischanged
                this.update();
            end
            Valid = this.isStateValid;
        end
        function Width = get.Width(this)
            if this.isChanged; this.update(); end
            Width = this.WidthState;
        end
        function Height = get.Height(this)
            if this.isChanged
                this.update();
            end
            Height = this.HeightState;
        end
        function ValidBorder = get.ValidBorder(this)
            if this.isChanged
                this.update();
            end
            ValidBorder = this.ValidBorderState;
        end
        function InvalidBorder = get.InvalidBorder(this)
            if this.isChanged
                this.update();
            end
            InvalidBorder = this.InvalidBorderState;
        end
        function castEnvironmentToConnections(this)
            if ~this.Model.surroundings.isDiscretized
                this.Model.surroundings.discretize();
            end

            for iCon = this.Connections
                % Remove exising environment connections
                k = 1; keep = true(size(iCon.NodeContacts));
                for iNC = iCon.NodeContacts
                    if ~isvalid(iNC.Node) || ...
                            ~isvalid(iNC.Node.Body) || ...
                            isa(iNC.Node.Body,'Environment')
                        keep(k) = false;
                    end
                    k = k + 1;
                end
                iCon.NodeContacts = iCon.NodeContacts(keep);
            end

            % For each segment of pnts
            for i = 1:length(this.ValidBorderState.Pnts)-1
                Start = this.ValidBorderState.Pnts(i);
                End = this.ValidBorderState.Pnts(i+1);
                if Start.x ~= End.x % Horizontal
                    for iCon = this.Connections
                        if iCon.Orient == enumOrient.Horizontal && iCon.x == Start.y
                            iCon.addNodeContacts(NodeContact( ...
                                this.Model.surroundings.Node, ...
                                min([Start.x End.x]), ...
                                max([End.x Start.x]), ...
                                enumFType.Environment,iCon));
                        end
                    end
                else
                    for iCon = this.Connections
                        if iCon.Orient == enumOrient.Vertical && iCon.x == Start.x
                            iCon.addNodeContacts(NodeContact( ...
                                this.Model.surroundings.Node, ...
                                min([Start.y End.y]), ...
                                max([End.y Start.y]), ...
                                enumFType.Environment,iCon));
                        end
                    end
                end
            end
        end
        function Discretized = get.isDiscretized(this)
            if this.isChanged
                this.update();
            end
            Discretized = this.isStateDiscretized;
        end

        %% Discretizing
        function resetDiscretization(this)
            for iBody = this.Bodies
                iBody.resetDiscretization();
            end
            for iCon = this.Connections
                iCon.resetDiscretization();
            end
            this.Nodes(:) = [];
            this.Faces(:) = [];
            this.isChanged = true;
            this.isStateDiscretized = false;
        end
        function discretize(this, derefinement_factor)
            this.isStateDiscretized = false;
            this.Nodes(:) = [];
            this.Faces(:) = [];
            nn = 0;
            nf = 0;
            if isempty(this.Bodies)
                this.isStateDiscretized = true;
                return;
            end
            for iBody = this.Bodies
                if ~iBody.isDiscretized
                    if nargin == 2
                        backup_divisions = iBody.divides;
                        if iBody.matl.Phase == enumMaterial.Solid
                            iBody.divides = ceil(iBody.divides*derefinement_factor);
                        else
                            if any(iBody.divides ~= 1)
                                if iBody.divides(1) == 1
                                    iBody.divides(2) = ...
                                        max(2,ceil(iBody.divides(2)*derefinement_factor));
                                elseif iBody.divides(2) == 1
                                    iBody.divides(1) = ...
                                        max(2,ceil(iBody.divides(1)*derefinement_factor)); % Matthias: Corrected
                                    % Old (Steven)
                                    %                                         max(2,ceil(iBody.divides(2)*derefinement_factor));
                                    %
                                    %
                                end
                            end
                        end
                    end
                    iBody.discretize();
                    if ~iBody.isDiscretized
                        fprintf(['XXX Exited Discretization at Body: ' iBody.name '.XXX\n']);
                        if nargin == 2; iBody.divides = backup_divisions; end
                        return;
                    end
                    keep = true(size(iBody.Nodes));
                    for i = length(iBody.Nodes):-1:1
                        if ~isvalid(iBody.Nodes(i)) || ...
                                iBody.Nodes(i).xmin == iBody.Nodes(i).xmax
                            keep(i) = false;
                        end
                    end
                    if any(~keep); iBody.Nodes = iBody.Nodes(keep); end
                    keep = true(size(iBody.Faces));
                    for i = length(iBody.Faces):-1:1
                        if ~isvalid(iBody.Faces(i)) || isempty(iBody.Faces(i).Nodes)
                            keep(i) = false;
                        end
                    end
                    if any(~keep); iBody.Faces = iBody.Faces(keep); end
                    if nargin == 2; iBody.divides = backup_divisions; end
                end
                nn = nn + length(iBody.Nodes);
                nf = nf + length(iBody.Faces);
            end
            % Discretize the surroundings
            this.updateBorder(true);

            for iCon = this.Connections
                if ~iCon.isDiscretized
                    iCon.discretize();
                    if ~iCon.isDiscretized
                        fprintf(['XXX Exited Discretization at Connection: ' ...
                            iCon.name '.XXX\n']);
                        return;
                    end
                end
                keep = true(size(iCon.Faces));
                for i = length(iCon.Faces):-1:1
                    if ~isvalid(iCon.Faces(i))
                        keep(i) = false;
                    else
                        if isempty(iCon.Faces(i).Nodes)
                            keep(i) = false;
                        end
                    end
                end
                if any(~keep)
                    iCon.Faces = iCon.Faces(keep);
                end
                nf = nf + length(iCon.Faces);
            end
            if nn == 0
                return;
            end
            for i = nn:-1:1; this.Nodes(i) = Node(); end
            for i = nf:-1:1; this.Faces(i) = Face(); end
            if nf == 0
                nn = 1;
                for iBody = this.Bodies
                    this.Nodes(nn:nn-1+length(iBody.Nodes)) = iBody.Nodes;
                    nn = nn + length(iBody.Nodes);
                end
            else
                nn = 1; nf = 1;
                for iBody = this.Bodies
                    this.Nodes(nn:nn-1+length(iBody.Nodes)) = iBody.Nodes;
                    this.Faces(nf:nf-1+length(iBody.Faces)) = iBody.Faces;
                    nn = nn + length(iBody.Nodes);
                    nf = nf + length(iBody.Faces);
                end
                for iCon = this.Connections
                    this.Faces(nf:nf-1+length(iCon.Faces)) = iCon.Faces;
                    nf = nf + length(iCon.Faces);
                end
            end
            this.isStateDiscretized = true;
        end

        %% Finding things
        function Con = FindConnection(this,Pos,Orient,notCon)
            Pos = Pos(1,1:2);
            Pos(1) = Pos(1) - this.Position.x;
            Pos(2) = Pos(2) - this.Position.y;
            Con = [];
            distance = inf;
            if nargin == 4
                if Orient == enumOrient.Vertical
                    C = RotMatrix(pi/2 - this.Position.Rot)*Pos';
                    for iCon = this.Connections
                        if iCon ~= notCon && iCon.Orient == Orient
                            if abs(C(1,1)-iCon.x) < distance
                                distance = abs(C(1,1)-iCon.x);
                                Con = iCon;
                            end
                            if abs(C(1,1)+iCon.x) < distance
                                distance = abs(C(1,1)+iCon.x);
                                Con = iCon;
                            end
                        end
                    end
                else % Horizontal
                    C = RotMatrix(-this.Position.Rot)*Pos';
                    for iCon = this.Connections
                        if iCon ~= notCon && iCon.Orient == Orient
                            if abs(C(1,1)-iCon.x) < distance
                                distance = abs(C(1,1)-iCon.x);
                                Con = iCon;
                            end
                        end
                    end
                end
            end
            if nargin == 2
                CV = RotMatrix(pi/2 - this.Position.Rot)*Pos';
                CH = RotMatrix(-this.Position.Rot)*Pos';
                for iCon = this.Connections
                    switch iCon.Orient
                        case enumOrient.Vertical
                            if abs(CV(1,1)-iCon.x) < distance
                                distance = abs(CV(1,1)-iCon.x);
                                Con = iCon;
                            end
                            if abs(CV(1,1)+iCon.x) < distance
                                distance = abs(CV(1,1)+iCon.x);
                                Con = iCon;
                            end
                        case enumOrient.Horizontal
                            if abs(CH(1,1)-iCon.x) < distance
                                distance = abs(CH(1,1)-iCon.x);
                                Con = iCon;
                            end
                    end
                end
            end
        end
        function Pnt = TranslatePnt2D(this,center)
            Rot = RotMatrix(this.Position.Rot-pi/2);
            x = center.x*Rot(1,1) + center.y*Rot(1,2) + this.Position.x;
            y = center.x*Rot(2,1) + center.y*Rot(2,2) + this.Position.y;
            Pnt = Pnt2D(x,y);
        end

        %% Graphics
        function color = getColor(this)
            if this.isActive; color = Group.HighlightedColor;
            else; color = Group.NormalColor;
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
        function show(this,CODE,AxisReference,Inc,showOptions)
            switch CODE
                case 'all'
                    % Show everything in base state
                    this.removeFromFigure(AxisReference); % Group and Environmental
                    if showOptions(1) % Show Groups
                        color = this.getColor();

                        % Plot a single line
                        % Find horizontal extent of the Group
                        VectorLength = this.Width;
                        TotalVectorLength = 1.2*max(VectorLength,0.1);
                        OffsetRot = this.Position.Rot;
                        % Make a template vector
                        R = RotMatrix(OffsetRot);
                        VStart = [this.Position.x ; this.Position.y ] - ...
                            R * [(TotalVectorLength-VectorLength)/2; 0];
                        VEnd = R * [TotalVectorLength; 0] + VStart;

                        % Plot line
                        this.GUIObjects = line(...
                            [VStart(1) VEnd(1)],...
                            [VStart(2) VEnd(2)],...
                            'Userdata',this,...
                            'Color',color,...
                            'LineWidth',3,...
                            'LineStyle','--',...
                            'HitTest','off');
                    end
                    if showOptions(2) % Show Bodies
                        for iBody = this.Bodies
                            iBody.show(AxisReference);
                        end
                    else
                        for iBody = this.Bodies
                            iBody.removeFromFigure(AxisReference);
                        end
                    end
                    if showOptions(3) % Show Connections
                        for iCon = this.Connections
                            iCon.show(AxisReference);
                        end
                    else
                        for iCon = this.Connections
                            iCon.removeFromFigure(AxisReference);
                        end
                    end
                    if showOptions(7) % Show Environment Connections
                        shift = [this.Position.x; this.Position.y];
                        rotate = RotMatrix(this.Position.Rot - pi/2);
                        % Show the validBorder
                        if ~isempty(this.ValidBorder)
                            if ~isvalid(this.ValidBorder)
                                this.update();
                            end
                            [XData, YData] = ...
                                DistortPositionVectors(...
                                this.ValidBorder.XData, this.ValidBorder.YData, ...
                                shift, rotate);

                            this.GUIObjects(end+1) = line(...
                                'XData',XData,...
                                'YData',YData,...
                                'LineWidth',2,...
                                'Color',[0 0 1]);
                        end
                        % Show the invalidBorder
                        if ~isempty(this.InvalidBorder)
                            for LineChain = this.InvalidBorder
                                [XData, YData] = ...
                                    DistortPositionVectors(...
                                    LineChain.XData, LineChain.YData, ...
                                    shift, rotate);
                                this.GUIObjects(end+1) = line(...
                                    'XData',XData,...
                                    'YData',YData,...
                                    'LineWidth',2,...
                                    'LineStyle','--',...
                                    'Color',[1 0 0]);
                            end
                        end
                    end
                case 'Dynamic'
                    if showOptions(2) % Show Bodies
                        for iBody = this.Bodies
                            if iBody.MovingStatus ~= enumMove.Static
                                iBody.show(AxisReference,Inc);
                            end
                        end
                    end
                case 'Static'
                    if showOptions(1) % Show Groups
                        color = this.getColor();

                        % Plot a single line
                        % Find horizontal extent of the Group
                        VectorLength = max(...
                            [Group.MinimumDisplayLength this.Width]);
                        TotalVectorLength = VectorLength*Group.Extension;
                        OffsetRot = this.Position.Rot;
                        % Make a template vector
                        R = RotMatrix(OffsetRot);
                        VStart = [this.Position.x ;
                            this.Position.y ] - ...
                            R * [(TotalVectorLength-VectorLength)/2; 0];
                        VEnd = R * [TotalVectorLength; 0] + VStart;

                        % Plot line
                        this.GUIObjects = line(...
                            [VStart(1) VEnd(1)],...
                            [VStart(2) VEnd(2)],...
                            'Userdata',this,...
                            'Color',color,...
                            'LineWidth',3,...
                            'LineStyle','--',...
                            'HitTest','off');
                    end
                    if showOptions(2) % Show Bodies
                        for iBody = this.Bodies
                            if iBody.MovingStatus == enumMove.Static
                                iBody.show(AxisReference);
                            end
                        end
                    end
            end
        end
    end
end

function [Lines,i,j] = intersects(i,j,Lines)
    if i < 1 || j < 1 || i > length(Lines) || j > length(Lines)
        return;
    end
    kill_i = false;
    kill_j = false;
    istart = Lines(i).Pnts(1);
    iend = Lines(i).Pnts(end);
    jstart = Lines(j).Pnts(1);
    jend = Lines(j).Pnts(end);
    if all(Lines(i).XData == Lines(j).XData) && ~(istart.y == iend.y)
        % Both Vertical and may overlap
        if iend.y < jstart.y || istart.y > jend.y
            return;
        end
        x = istart.x;
        if istart.y <= jstart.y
            % i starts before j
            if iend.y <= jend.y
                % i is staggered with j
                temp = iend.y;
                if (istart == jstart)
                    kill_i = true;
                else
                    Lines(i).Pnts(end).y = jstart.y;
                end
                if (jend.y == temp)
                    kill_j = true;
                else
                    Lines(j).Pnts(1).y = temp;
                end
            else
                % j is within i
                if (iend ~= jend)
                    Lines(end+1) = Line2DChain(x,jend.y,x,iend.y);
                end
                if (istart == jstart)
                    kill_i = true;
                else
                    Lines(i).Pnts(end).y = jstart.y;
                end
                kill_j = true;
            end
        else
            % j starts before i
            if jend.y <= iend.y
                % j is staggered with i
                temp = jend.y;
                if (istart == jstart)
                    kill_j = true;
                else
                    Lines(j).Pnts(end).y = istart.y;
                end
                if (iend.y == temp)
                    kill_i = true;
                else
                    Lines(i).Pnts(1).y = temp;
                end
            else
                % i is within j
                if (iend ~= jend)
                    Lines(end+1) = Line2DChain(x,iend.y,x,jend.y);
                end
                if (istart == jstart)
                    kill_j = true;
                else
                    Lines(j).Pnts(end).y = istart.y;
                end
                kill_i = true;
            end
        end
    elseif all(Lines(i).YData == Lines(j).YData) && ~(istart.x == iend.x)
        % Both Horizontal and may overlap
        if iend.x < jstart.x || istart.x > jend.x
            return;
        end
        if istart.x == jstart.x && iend.x == jend.x
            kill_i = true;
            kill_j = true;
        else
            y = istart.y;
            if istart.x <= jstart.x
                % i starts before j
                if iend.x <= jend.x
                    % i is staggered with j
                    % i --|-|
                    % j   |-|--
                    temp = iend.x;
                    if (istart.x == jstart.x)
                        kill_i = true;
                    else
                        Lines(i).Pnts(end).x = jstart.x;
                    end
                    if (temp == jend.x)
                        kill_j = true;
                    else
                        Lines(j).Pnts(1).x = temp;
                    end
                else
                    % j is within i
                    % i -|--|-
                    % j  |--|
                    kill_j = true;
                    if (iend.x ~= jend.x)
                        Lines(end+1) = Line2DChain(jend.x,y,iend.x,y);
                    end
                    if (istart.x == jstart.x)
                        kill_i = true;
                    end
                    Lines(i).Pnts(end).x = jstart.x;
                end
            else
                % j starts before i
                if jend.x <= iend.x
                    % j is staggered with i
                    % i   |-|--
                    % j --|-|
                    temp = jend.x;
                    if (istart == jstart)
                        kill_j = true;
                    else
                        Lines(j).Pnts(end).x = istart.x;
                    end
                    if (iend.x == temp)
                        kill_i = true;
                    else
                        Lines(i).Pnts(1).x = temp;
                    end
                else
                    % i is within j
                    % i  |--|
                    % j -|--|-
                    kill_i = true;
                    if (iend ~= jend)
                        Lines(end+1) = Line2DChain(iend.x,y,jend.x,y);
                    end
                    if (istart == jstart)
                        kill_j = true;
                    else
                        Lines(j).Pnts(end).x = istart.x;
                    end
                end
            end
        end
    end
    if kill_i
        Lines(i) = [];
        if kill_j
            if (i > j)
                Lines(j) = [];
            else
                Lines(j-1) = [];
            end
        end
        j = i;
        i = i - 1;
    else
        if kill_j
            Lines(j) = [];
            j = j - 1;
        end
    end
end
