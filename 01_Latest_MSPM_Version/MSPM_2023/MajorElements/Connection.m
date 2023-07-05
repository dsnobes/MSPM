classdef Connection < handle
    % models a Connection between bodies in a group,
    % contains faces
    properties (Constant)
        Extension = 1.1;
        MinimumDisplayLength = 0.4;
        ActiveColor = [0 1 0];
        NormalColor = [0.2 0.2 0.2];
    end

    properties (Access = public)
        ID;
        Group Group;
        Bodies Body;
        isActive = false;
        x double = 0;
        Orient enumOrient = enumOrient.Horizontal;

        RefFrame Frame;
        GUIObjects;
        NodeContacts NodeContact;
        Faces Face;

        isDiscretized logical = false;
        isChanged logical = true;

        BodiesToNotJoin Body;
    end

    properties (Dependent)
        name;
        index;
        id;
    end

    methods
        %% Constructor
        function this = Connection(x,Orient,Group)
            switch nargin
                % case 0
                % obj.x = 0;
                % obj.Orient = enumOrient.Horizontal;
                case 1
                    this.x = x;
                    % this.Orient = enumOrient.Horizontal;
                case 2
                    this.x = x;
                    this.Orient = Orient;
                case 3
                    this.x = x;
                    this.Orient = Orient;
                    this.Group = Group;
                    this.ID = Group.Model.getConID();
            end
        end

        function deReference(this)
            % Remove Reference from Group
            iGroup = this.Group;
            for i = length(iGroup.Connections):-1:1
                if iGroup.Connections(i) == this
                    iGroup.Connections(i) = [];
                    iGroup.isChanged = true;
                end
            end

            % Remove relations from the relationship managers
            for RMan = iGroup.RelationManagers
                if RMan.Orient == this.Orient
                    RMan.isChanged = true;
                    for i = length(RMan.Relations):-1:1
                        if RMan.Relations(i).con1 == this || ...
                                RMan.Relations(i).con2 == this
                            RMan.Relations(i).deReference();
                        end
                    end
                    RMan.update();
                end
            end

            if ~isempty(this.Bodies) % i.e. Body/deReference has not been called already
                % Remove Reference from any Bodies
                for iBody = this.Bodies
                    iBody.deReference();
                    iBody.delete();
                end
                % Remove Reference from any Bridges
                iModel = iGroup.Model;
                for i = length(iModel.Bridges):-1:1
                    if iModel.Bridges(i).Connection1 == this || iModel.Bridges(i).Connection2 == this
                        iModel.Bridges(i).deReference();
                        iModel.Bridge(i).delete();
                        iModel.Bridges(i) = [];
                    end
                end
                % Remove Reference from any Leaks
                for i = length(iModel.LeakConnections):-1:1
                    if iModel.LeakConnections(i).Connection1 == this ...
                            || iModel.LeakConnections(i).Connection2 == this
                        iModel.LeakConnections(i).deReference();
                        iModel.LeakConnections(i).delete();
                        iModel.LeakConnections(i) = [];
                    end
                end
                % Remove any visual remenant
                this.show();
                this.removeFromFigure(gca);
            end
            this.Group.Model.update();
            this.Group.Model.show();
            this.delete();
            drawnow();
        end
        function change(this)
            this.isChanged = true;
            this.Faces(:) = [];
            this.NodeContacts(:) = [];
            for iBody = this.Bodies; iBody.change(); end
            this.isDiscretized = false;
        end
        function CleanUpBodies(this)
            for i = length(this.Bodies):-1:1
                if ~isvalid(this.Bodies(i))
                    this.Bodies(i) = [];
                end
            end
        end
        function update(this)
            if isempty(this.ID)
                this.ID = this.Group.Model.getConID();
            end
            if any(~isvalid(this.Bodies))
                this.Bodies = this.Bodies(isvalid(this.Bodies));
            end
            if ~isvalid(this.RefFrame)
                this.RefFrame = [];
            end
            this.isChanged = false;
        end
        function [yesno] = IsFixedTo(this, other)
            yesno = false;
            for iRM = this.Group.RelationManagers
                if iRM.Orient == this.Orient && iRM.Orient == other.Orient
                    iRM.update();
                    for row = 1:size(iRM.Grid,1)
                        if iRM.Grid(row,this.index) && ...
                                iRM.Grid_modes{row} == enumRelation.Constant
                            if iRM.Grid(row,other.index)
                                yesno = true;
                                return;
                            end
                        end
                    end
                end
            end
        end

        %% Get/Set Interface
        function Item = get(this,PropertyName)
            if this.isChanged; this.update(); end
            switch PropertyName
                case 'x'
                    Item = this.x;
                case 'RefFrame'
                    Item = this.RefFrame;
                case 'Bodies'
                    Item = this.Bodies;
                case 'Isolated Bodies'
                    Item = this.BodiesToNotJoin;
                case 'isStationary'
                    if isempty(this.RefFrame)
                        Item = true;
                    else
                        Item = false;
                    end
                otherwise
                    fprintf(['XXX Connection GET Inteface for ' PropertyName ' is not found XXX\n']);
            end
        end

        %% (Update on Demand) Triggers
        function name = get.name(this)
            switch this.Orient
                case enumOrient.Vertical
                    name = ['Vertical Connection at x = ' num2str(this.x,3)];
                case enumOrient.Horizontal
                    name = ['Horizontal Connection at y = ' num2str(this.x,3)];
            end
        end
        function index = get.index(this)
            i = 1;
            for iCon = this.Group.Connections
                if iCon == this
                    index = i;
                    return;
                end
                i = i + 1;
            end
            index = 0;
        end


        function set(this,PropertyName,Item)
            switch PropertyName
                case 'x'
                    % Check all Relationships
                    for iCon = this.Group.Connections
                        if iCon.x == Item && ...
                                iCon.Orient == this.Orient
                            % This kind of shift can't result in a merge.
                            return;
                        end
                    end
                    for RMan = this.Group.RelationManagers
                        if RMan.Orient == this.Orient
                            RMan.Edit(this,Item-this.x);
                            break;
                        end
                    end
                case 'RefFrame'
                    if isempty(Item); this.RefFrame = Frame.empty;
                    else; this.RefFrame = Item;
                    end
                otherwise
                    fprintf(['XXX Connection SET Inteface for ' ...
                        PropertyName ' is not found XXX\n']);
                    return;
            end
            this.change();
        end

        function set.isActive(this,value)
            if islogical(value)
                if isvalid(this)
                    this.isActive = value;
                end
            else
                fprintf('Input to isActive must be a boolean value.\n');
            end
        end

        function functions(this,FunctionName)
            switch FunctionName
                case 'Add Bodies To Not Join'
                    [cx,cy] = ginput(1);
                    TheBody = findConnectedBody(this,[cx cy]);
                    this.addBodyToNotJoin(TheBody);
                case 'Remove Bodies To Not Join'
                    if ~isempty(this.BodiesToNotJoin)
                        objects = cell(1,length(this.BodiesToNotJoin));
                        names = objects;
                        i = 1;
                        for iBody = this.BodiesToNotJoin
                            objects{i} = iBody;
                            names{i} = iBody.name;
                            i = i + 1;
                        end
                        [indx,tf] = listdlg(...
                            'PromptString','Which one are you going to remove?',...
                            'SelectionMode','single',...
                            'ListString',names);
                        if tf; this.BodiesToNotJoin(indx) = []; end
                    end
                otherwise

            end
        end

        %% Operators
        function isequal = isFunctionallyEqualTo(this,otherConnection)
            if this.x == otherConnection.x && ...
                    this.Orient == otherConnection.Orient && ...
                    ((isempty(this.RefFrame) && isempty(otherConnection.RefFrame)) || ...
                    (isempty(this.RefFrame) == isempty(otherConnection.RefFrame) && ...
                    this.RefFrame == otherConnection.RefFrame))
                isequal = true;
            else
                isequal = false;
            end
        end

        %% Interating
        function addBody(this,BodiesToAdd)
            try
                count = length(this.Bodies);
                if isrow(BodiesToAdd)
                    this.Bodies = [this.Bodies BodiesToAdd];
                else
                    this.Bodies = [this.Bodies BodiesToAdd'];
                end
                this.Bodies = unique(this.Bodies);
                if count ~= length(this.Bodies)
                    this.removeFaces();
                end
                return;
            catch
                fprintf('XXX Error in Connection/AddBody XXX\n');
            end
        end
        function addBodyToNotJoin(this,BodiesToNotJoin)
            len = length(this.BodiesToNotJoin);
            this.BodiesToNotJoin(len+length(BodiesToNotJoin)) = Body();
            this.BodiesToNotJoin(length(len+1:end)) = BodiesToNotJoin;
            this.BodiesToNotJoin = unique(this.BodiesToNotJoin);
        end
        function TheBody = findConnectedBody(this,Pnt)
            if this.isChanged; this.update(); end
            % Find a body in this Group that is selected and closest
            Pntmod = (RotMatrix(pi/2-this.Group.Position.Rot)*Pnt')...
                - [this.Group.Position.x; this.Group.Position.y];
            mindist = inf;
            for iBody = this.Bodies
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
                    dist = Dist2Rect(Pntmod(1),Pntmod(2),R.Cx,R.Cy,R.Width,R.Height);
                    if dist < mindist
                        if dist == 0
                            TheBody = iBody;
                            return;
                        end
                        mindist = dist;
                        TheBody = iBody;
                    end
                end
            end
        end

        %% Working with nodes
        function deleteNodeContactsFromObj(this,Obj)
            for iBridge = this.Group.Model.Bridges
                if iBridge.Connection1 == this
                    iBridge.change();
                elseif iBridge.Connection2 == this
                    iBridge.change();
                end
            end
            this.cleanUpNodeContacts();
            LEN = length(this.NodeContacts);
            if LEN == 0; return; end
            if this.isDiscretized; this.removeFaces(); end
            i = 1;
            while (i < LEN+1 && this.NodeContacts(i).Node.Body ~= Obj); i = i + 1; end
            START = i - 1;
            while (i < LEN+1 && this.NodeContacts(i).Node.Body == Obj); i = i + 1; end
            END = i;
            if START ~= 0
                if END ~= LEN+1
                    this.NodeContacts = [this.NodeContacts(1:START) this.NodeContacts(END:LEN)];
                else
                    this.NodeContacts = this.NodeContacts(1:START);
                end
            else
                if END ~= LEN+1
                    this.NodeContacts = this.NodeContacts(END:LEN);
                else
                    this.NodeContacts = NodeContact.empty;
                end
            end
        end
        function addNodeContacts(this,newContacts)
            this.NodeContacts = [this.NodeContacts newContacts];
            if this.isDiscretized
                this.removeFaces();
            end
        end
        function removeFaces(this)
            this.Faces = Face.empty;
            this.isDiscretized = false;
        end
        function cleanUpNodeContacts(this)
            dontkeep = true(size(this.NodeContacts));
            for i = 1:length(this.NodeContacts)
                if isvalid(this.NodeContacts(i)) && ...
                        isvalid(this.NodeContacts(i).Node) && ...
                        isvalid(this.NodeContacts(i).Node.Body)
                    dontkeep(i) = false;
                end
            end
            if any(dontkeep)
                this.NodeContacts = this.NodeContacts(~dontkeep);
            end
        end
        function resetDiscretization(this)
            if isvalid(this)
                this.NodeContacts(:) = [];
                this.Faces(:) = [];
                this.isDiscretized = false;
                this.isChanged = true;
            end
        end
        function discretize(this)
            if this.isChanged; this.update(); end
            this.Faces = Face.empty;
            if isempty(this.Bodies) || ...
                    (this.Orient == enumOrient.Vertical && this.x == 0)
                this.isDiscretized = true;
                this.Faces = Face.empty;
                return;
            end

            % Remove Bodies that should not conduct
            keep = true(1,length(this.NodeContacts));
            for iBody = this.BodiesToNotJoin
                for i = 1:length(this.NodeContacts)
                    if this.NodeContacts(i).Node.Body == iBody
                        keep(i) = false;
                    end
                end
            end
            this.NodeContacts = this.NodeContacts(keep);

            if ~this.isDiscretized
                for iBody = this.Bodies
                    if ~iBody.isDiscretized
                        iBody.discretize();
                        if ~iBody.isDiscretized
                            return;
                        end
                    end
                end
                if this.Group.isChanged
                    this.Group.isEnvironmentCasted = true;
                    this.Group.update();
                elseif ~this.Group.isEnvironmentCasted
                    this.Group.isEnvironmentCasted = true;
                    this.Group.updateBorder(true);
                end
                %% INITIALIZE
                this.Faces(2*length(this.NodeContacts)) = Face();
                n = 1;
                % Clean Up
                keep = true(size(this.NodeContacts));
                for i = 1:length(this.NodeContacts)
                    if ~isvalid(this.NodeContacts(i)) || ...
                            ~isvalid(this.NodeContacts(i).Node) || ...
                            ~isvalid(this.NodeContacts(i).Node.Body)
                        keep(i) = false;
                    end
                end
                if any(~keep); this.NodeContacts = this.NodeContacts(keep); end

                % Sort the environmental connections to the end
                members = false(size(this.NodeContacts)); i = 1;
                for nc = this.NodeContacts
                    members(i) = this.NodeContacts(i).Node.Type == enumNType.EN;
                    i = i + 1;
                end
                envNC = this.NodeContacts(members);
                this.NodeContacts(members) = [];
                this.addNodeContacts(envNC);

                %% GO THROUGH EACH NODE COMBINATION
                keep = true(length(this.NodeContacts),1);
                %         len = length(keep);
                for i = 1:length(this.NodeContacts)
                    if length(keep) >= i && keep(i)
                        for j = i+1:length(this.NodeContacts)
                            if length(keep) >= j && keep(j)
                                if this.NodeContacts(i).Node.Body ~= this.NodeContacts(j).Node.Body
                                    activeTimes = this.NodeContacts(i).activeTimes(this.NodeContacts(j));
                                    if ~isempty(activeTimes)
                                        this.Faces(n) = Face(this.NodeContacts(i),this.NodeContacts(j),activeTimes);
                                        if ~isempty(this.Faces(n).ActiveTimes)
                                            fc = this.Faces(n);
                                            switch fc.Type
                                                case enumFType.Solid
                                                    if isempty(this.RefFrame) || ...
                                                            fc.Nodes(1).Type == enumNType.SN && ...
                                                            fc.Nodes(2).Type == enumNType.SN
                                                        if ~any(fc.data.U > 0)
                                                            n = n - 1;
                                                        end
                                                    end
                                                case enumFType.Mix
                                                    if ~any(fc.data.Area > 0)
                                                        n = n - 1;
                                                    end
                                                case enumFType.Environment
                                                    if isempty(this.RefFrame) && ~any(fc.data.U > 0)
                                                        n = n - 1;
                                                    end
                                                case enumFType.Gas
                                                    if ~any(fc.data.Area > 0)
                                                        n = n - 1;
                                                    end
                                            end
                                            n = n + 1;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                this.Faces = this.Faces(1:n-1);
                this.isDiscretized = true;
            end
        end

        %% Display this Connection on the screen
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
            end
            this.GUIObjects = [];
        end
        function color = getColor(this)
            color = [0.5 0.5 0.5];
            if isempty(this.Group)
                if isempty(this.Bodies)
                    fprinf(['XXX Connection '
                        this.name ' does not know what its group is XXX\n']);
                    return;
                else
                    found = false;
                    for i = 1:length(this.Bodies)
                        if ~isempty(this.Bodies(i).Group)
                            this.Group = this.Bodies(i).Group;
                            found = true;
                            break;
                        end
                    end
                    if ~found
                        fprinf(['XXX Connection '
                            this.name ' does not know what its group is XXX\n']);
                        return;
                    end
                end
            end
            if this.Group.Model.showRelations
                for RMan = this.Group.RelationManagers
                    if RMan.Orient == this.Orient
                        ind = this.index;
                        if isempty(RMan.Grid) || ind > size(RMan.Grid,2)
                            RMan.update();
                        end
                        rows = find(RMan.Grid(:,ind) == true);
                        if ~isempty(rows)
                            max_count = 0;
                            max_index = 0;
                            for i = rows
                                count = sum(RMan.Grid(i,:));
                                if count > max_count
                                    max_index = i;
                                    max_count = count;
                                end
                            end
                            color = RMan.getColor(max_index);
                            break;
                        end
                        if this.isActive
                            color = Connection.ActiveColor;
                        else
                            color = Connection.NormalColor;
                        end
                        break;
                    end
                end
            else
                if this.isActive
                    color = Connection.ActiveColor;
                else
                    color = Connection.NormalColor;
                end
            end
        end
        function updateColor(this)
            if ~isempty(this.GUIObjects)
                for iGraphicsObject = this.GUIObjects
                    set(iGraphicsObject,'Color',this.getColor());
                end
            end
        end
        function show(this, AxisReference)
            if this.isChanged; this.update(); end
            color = this.getColor();
            switch this.Orient
                case enumOrient.Vertical
                    % Plot two lines on equal sides of the Group
                    % Find vertical extent of the Group
                    VectorLength = Connection.Extension*max(this.Group.Height,0.1);
                    OffsetRot = this.Group.Position.Rot;
                    Offset = (VectorLength-this.Group.Height)/2;
                    % Make a template vector
                    R = RotMatrix(OffsetRot);
                    templateVector = R * [VectorLength; 0];
                    Trans = [this.Group.Position.x; this.Group.Position.y];
                    LeftStart = R * [-Offset; this.x] + Trans;
                    RightStart = R * [-Offset; -this.x] + Trans;

                    % Plot line
                    if this.x == 0
                        %             if length(this.GUIObjects) == 1 && isgraphics(this.GUIObjects(1))
                        %               % Plot line
                        %               try
                        %                 set(this.GUIObjects,'Color',color);
                        %                 set(this.GUIObjects,'XData',...
                        %                   [LeftStart(1) LeftStart(1)+templateVector(1)]);
                        %                 set(this.GUIObjects,'YData',...
                        %                   [LeftStart(2) LeftStart(2)+templateVector(2)]);
                        %               catch
                        %                 this.removeFromFigure(AxisReference);
                        %                 this.GUIObjects(1) = line(...
                        %                   [LeftStart(1) LeftStart(1)+templateVector(1)],...
                        %                   [LeftStart(2) LeftStart(2)+templateVector(2)],...
                        %                   'Userdata',this,'Color',color,'LineStyle','--',...
                        %                   'HitTest','off');
                        %               end
                        %             else
                        this.removeFromFigure(AxisReference);
                        this.GUIObjects(1) = line(...
                            [LeftStart(1) LeftStart(1)+templateVector(1)],...
                            [LeftStart(2) LeftStart(2)+templateVector(2)],...
                            'Userdata',this,'Color',color,'LineStyle','--',...
                            'HitTest','off');
                        %             end
                    else
                        %             if length(this.GUIObjects) == 2 && ...
                        %                 isgraphics(this.GUIObjects(1)) && isgraphics(this.GUIObjects(2))
                        %               set(this.GUIObjects(1),'Color',color);
                        %               set(this.GUIObjects(1),'XData',...
                        %                 [LeftStart(1) LeftStart(1)+templateVector(1)]);
                        %               set(this.GUIObjects(1),'YData',...
                        %                 [LeftStart(2) LeftStart(2)+templateVector(2)]);
                        %               set(this.GUIObjects(2),'Color',color);
                        %               set(this.GUIObjects(2),'XData',...
                        %                 [RightStart(1) RightStart(1)+templateVector(1)]);
                        %               set(this.GUIObjects(2),'YData',...
                        %                 [RightStart(2) RightStart(2)+templateVector(2)]);
                        %             else
                        this.removeFromFigure(AxisReference);
                        this.GUIObjects(2) = line(...
                            [RightStart(1) RightStart(1)+templateVector(1)],...
                            [RightStart(2) RightStart(2)+templateVector(2)],...
                            'Userdata',this,'Color',color,'LineStyle','--',...
                            'HitTest','off');
                        this.GUIObjects(1) = line(...
                            [LeftStart(1) LeftStart(1)+templateVector(1)],...
                            [LeftStart(2) LeftStart(2)+templateVector(2)],...
                            'Userdata',this,'Color',color,'LineStyle','--',...
                            'HitTest','off');
                        %             end
                    end
                case enumOrient.Horizontal
                    % Plot a single line
                    % Find horizontal extent of the Group
                    VectorLength = Connection.Extension*this.Group.Width/2;
                    OffsetRot = this.Group.Position.Rot;
                    % Make a template vector
                    R = RotMatrix(OffsetRot);
                    Trans = [this.Group.Position.x ;
                        this.Group.Position.y ];
                    LeftPoint = R * [this.x; 0.5*VectorLength] + Trans;
                    RightPoint = R * [this.x; -0.5*VectorLength] + Trans;

                    % Plot line
                    if length(this.GUIObjects) == 1 && isgraphics(this.GUIObjects)
                        set(this.GUIObjects,'Color',color);
                        set(this.GUIObjects,'XData',[LeftPoint(1) RightPoint(1)]);
                        set(this.GUIObjects,'YData',[LeftPoint(2) RightPoint(2)]);
                    else
                        this.GUIObjects = line(...
                            [LeftPoint(1) RightPoint(1)],[LeftPoint(2) RightPoint(2)],...
                            'Userdata',this,'Color',color,'LineStyle','--',...
                            'HitTest','off');
                    end
            end
            % fprintf(['Plotted Connection ' this.name '.\n']);
        end
    end
end

% Helper functions - UNUSED
function face = appendDynamicFaceVert(face,k,T1,s,e,Area)
    % Face.
    %     .isDynamic - DONE
    %     .Node1 - DONE
    %     .Node2 - DONE
    %     .A                  - Mix/Gas Append
    %     .dh - Static
    %     .Type - DONE
    %     .value              - Solid/Mix/Gas Append
    %     .K                  - Gas Append
    %     .ActiveTimes        - Always Append
    if s < e
        switch face.Type
            case enumFType.Solid
                % Combine resistances and store as a conductance
                face.value = [face.value Area(n,s,e)/(n1.value+n2.value)];
            case enumFType.Mix
                % Store only the resistance as a conductance
                if T1 == enumFType.Solid
                    face.A = [face.A Area(n,s,e)];
                    face.value = [face.value (face.A(end)/(n1.value))];
                else
                    face.A = [face.A Area(n,s,e)];
                    face.value = [face.value (face.A(end)/(n2.value))];
                end
            case enumFType.Gas
                % Record the combined distance stored in Ri
                face.A = [face.A Area(n,s,e)];
                face.value = [face.value n1.value + n2.value];
        end
        face.ActiveTimes = [face.ActiveTimes k];
    end
end

function face = genStaticFace(n1,n2,Area)
    face.Node1 = n1.node;
    face.Node2 = n2.node;
    face.isDynamic = false;
    face.K = 0;
    face.ActiveTimes = [];
    face.Type = getFaceType(n1.Type,n2.Type);
    switch face.Type
        case enumFType.Solid
            % Combine resistances and store as a conductance
            face.value = ...
                (Area(n,max([n1.Start n2.Start]),min([n1.End n2.End]))...
                /(n1.value + n2.value));
        case enumFType.Mix
            % Store only the resistance as a conductance
            if n1.Type == enumFType.Solid
                face.dh = n2.dh;
                face.A = Area(n,max([n1.Start n2.Start]),min([n1.End n2.End]));
                face.value = (face.A/(n1.value));
            else
                face.dh = n1.dh;
                face.A = Area(n,max([n1.Start n2.Start]),min([n1.End n2.End]));
                face.value = (face.A/(n2.value));
            end
        case enumFType.Gas
            % Record the combined distance stored in value
            face.value = n1.value + n2.value;
    end
end


