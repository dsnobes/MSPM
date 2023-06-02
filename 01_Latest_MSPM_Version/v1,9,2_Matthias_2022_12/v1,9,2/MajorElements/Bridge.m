classdef Bridge < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Body1 Body;
        Body2 Body;
        Connection1 Connection;
        Connection2 Connection;
        x double;

        GUIObjects;
        isActive logical = false;

        isChanged logical = true;
        isDiscretized logical = false;

        Faces Face;
    end

    properties (Dependent)
        isValid;
        name;
    end

    methods
        %% Constructor
        function this = Bridge(Body1,Body2,C1,C2,x)
            if nargin > 3
                this.Body1 = Body1;
                this.Body2 = Body2;
                this.Connection1 = C1;
                this.Connection2 = C2;
                if nargin > 4
                    this.x = x;
                else
                    this.x = 0;
                end
                fprintf('Bridge Created Successfully.\n');
            end
        end
        function deReference(this)
            if isvalid(this.Body1)
                iModel = this.Body1.Group.Model;
            elseif isvalid(this.Body2)
                iModel = this.Body2.Group.Model;
            end
            for i = length(iModel.Bridges):-1:1
                if iModel.Bridges(i) == this
                    iModel.Bridges(i) = [];
                    break;
                end
            end
            for iBody = [this.Body1 this.Body2]
                if isvalid(iBody); iBody.change(); end
            end
            for iCon = [this.Connection1 this.Connection2]
                if isvalid(iCon); iCon.change(); end
            end
            this.Faces(:) = [];
            if isvalid(gca)
                this.removeFromFigure(gca);
            end
            this.delete();
        end

        %% Get/Set Interface
        function Item = get(this,PropertyName)
            switch PropertyName
                case 'Connection 1'
                    Item = this.Connection1;
                case 'Connection 2'
                    Item = this.Connection2;
                case 'Body 1'
                    Item = this.Body1;
                case 'Body 2'
                    Item = this.Body2;
                otherwise
                    fprintf(['XXX Bridge GET Inteface for ' PropertyName ' is not found XXX\n']);
            end
        end
        function set(~,PropertyName,~)
            switch PropertyName
                otherwise
                    fprintf(['XXX Bridge SET Inteface for ' PropertyName ' is not found XXX\n']);
                    return;
            end
            this.change(); % literally useless setter function that does nothing...
        end

        %% (Update on Demand)
        function change(this)
            this.isChanged = true;
            this.isDiscretized = false;
        end
        function name = get.name(this)
            if this.Connection1.Orient == enumOrient.Vertical
                [~,~,x1,~] = this.Body1(1).limits(enumOrient.Vertical);
                if this.Connection1.x == x1; descriptor1 = 'Inside';
                else; descriptor1 = 'Outside'; end
            else
                [~,~,y1,~] = this.Body1(1).limits(enumOrient.Horizontal);
                if this.Connection1.x == y1; descriptor1 = 'Bottom';
                else; descriptor1 = 'Top'; end
            end
            if this.Connection2.Orient == enumOrient.Vertical
                [~,~,x1,~] = this.Body2(1).limits(enumOrient.Vertical);
                if this.Connection2.x == x1; descriptor2 = 'Inside';
                else; descriptor2 = 'Outside'; end
            else
                [~,~,y1,~] = this.Body2(1).limits(enumOrient.Horizontal);
                if this.Connection2.x == y1; descriptor2 = 'Bottom';
                else; descriptor2 = 'Top'; end
            end
            name1 = [];
            for iBody = this.Body1
                for i = 1:length(iBody.Group.Bodies)
                    if iBody.Group.Bodies(i) == iBody
                        break;
                    end
                end
                name1 = [name1 num2str(i) ' '];
            end
            name1 = ['Bodies ' name1 ' of Group' this.Body1(1).Group.name];
            name2 = [];
            for iBody = this.Body2
                for i = 1:length(iBody.Group.Bodies)
                    if iBody.Group.Bodies(i) == iBody
                        break;
                    end
                end
                name2 = [name2 num2str(i) ' '];
            end
            name1 = ['Bodies ' name1 ' of Group' this.Body1(1).Group.name];
            name = ['Bridge btwn. ' descriptor1 ' of ' name1 ' and ' ...
                descriptor2 ' of ' name2];
        end
        function Valid = get.isValid(this)
            Valid = true;
            if isempty(this.Body1) ...
                    || isempty(this.Body2) ...
                    || isempty(this.Connection1) ...
                    || isempty(this.Connection2)
                Valid = false;
                fprintf('XXX Bridge is created but not fully defined XXX');
                return;
            end
            for iBody = this.Body1
                if ~any(iBody.Connections == this.Connection1)
                    Valid = false;
                    fprintf(['XXX Bridge ' this.name ...
                        'has invalid, body and connection pairs']);
                    return;
                end
            end
            for iBody = this.Body2
                if ~any(iBody.Connections == this.Connection2)
                    Valid = false;
                    fprintf(['XXX Bridge ' this.name ...
                        'has invalid, body and connection pairs']);
                    return;
                end
            end
        end

        %% Face Generation
        function resetDiscretization(this)
            this.Faces(:) = [];
            this.isDiscretized = false;
            this.isChanged = true;
        end
        function discretize(this)
            this.isDiscretized = false;
            Con1 = this.Connection1;
            Con2 = this.Connection2;
            for iBody = [Con1.Bodies Con2.Bodies]
                if ~iBody.isDiscretized
                    iBody.discretize();
                    if ~iBody.isDiscretized
                        fprintf(['XXX Exited Discretization at Body: ' iBody.name '.XXX\n']);
                        return;
                    end
                end
            end

            if Con1.Orient == Con2.Orient && this.x == 0
                %% Standard, same Orientation
                % Validity Check
                if Con1.Orient == enumOrient.Vertical
                    if Con1.x ~= Con2.x
                        fprintf(['XXX Bridge: ' this.name ...
                            ' Failed to discretize due to incompatible radii']);
                        this.isDiscretized = false;
                        return;
                    end
                end

                % Occlude non-B1 Con1 with B2 Con2
                i = 1;
                keep = true(size(Con1.NodeContacts));
                for Others = Con1.NodeContacts
                    if Others.Node.Body ~= this.Body1
                        for B2 = Con2.NodeContacts
                            if B2.Node.Body == this.Body2
                                keep(i) = B2.AlignedMask(Others,-inf,inf);
                            end
                            if ~keep(i); break; end
                        end
                    end
                    i = i + 1;
                end
                Con1.NodeContacts = Con1.NodeContacts(keep);

                % Add B2 Con2 copies to Con1
                % ... Copy B2 Con2
                B2C2 = NodeContact.empty;
                for NC = Con2.NodeContacts
                    if NC.Node.Body == this.Body2
                        B2C2(end+1) = CopyClass(NC);
                    end
                end

                % Occlude B2 Con2 with B1 Con1
                i = 1;
                keep = true(size(Con2.NodeContacts));
                for B2 = Con2.NodeContacts
                    if B2.Node.Body == this.Body2
                        for B1 = Con1.NodeContacts
                            if B1.Node.Body == this.Body1
                                keep(i) = B1.AlignedMask(B2,-inf,inf);
                            end
                            if ~keep(i); break; end
                        end
                    end
                    i = i + 1;
                end
                Con2.NodeContacts = Con2.NodeContacts(keep);

                % ... Add to Con1
                Con1.addNodeContacts(B2C2);

            elseif Con1.Orient == enumOrient.Vertical && Con1.Orient == Con2.Orient
                %% Both Vertical, Offset

                % Validity Check
                if Con1.x ~= Con2.x
                    fprintf(['XXX Bridge: ' this.name ...
                        ' Failed to discretize due to incompatible radii']);
                    this.isDiscretized = true;
                    return;
                end

                %% Both Vertical

                % Get node contacts from Con2 and shift them
                for NC = Con2.NodeContacts
                    NC.Start = NC.Start + this.x;
                    NC.End = NC.End + this.x;
                end

                % Con1 mask other of Con2 within bounds of B2
                keep = true(size(Con2.NodeContacts));
                switch Con1.Orient
                    case enumOrient.Vertical
                        [b1,b2,~,~] = this.Body2.limits(enumOrient.Horizontal);
                    case enumOrient.Horizontal
                        [b1,b2,~,~] = this.Body2.limits(enumOrient.Vertical);
                end
                for mask = Con1.NodeContacts
                    if mask.Node.Body == this.Body1
                        for i = 1:length(Con2.NodeContacts)
                            if keep(i)
                                target = Con2.NodeContacts(i);
                                if target.Node.Body ~= this.Body2
                                    keep(i) = mask.AlignedMask(target,b1,b2);
                                end
                            end
                        end
                    end
                end
                Con2.NodeContacts = Con2.NodeContacts(keep);

                % Con2 mask other of Con1 within bounds of B1
                keep = true(size(Con1.NodeContacts));
                switch Con1.Orient
                    case enumOrient.Vertical
                        [b1,b2,~,~] = this.Body1.limits(enumOrient.Horizontal);
                    case enumOrient.Horizontal
                        [b1,b2,~,~] = this.Body1.limits(enumOrient.Vertical);
                end
                for mask = Con2.NodeContacts
                    if mask.Node.Body == this.Body2
                        for i = 1:length(Con1.NodeContacts)
                            if keep(i)
                                target = Con1.NodeContacts(i);
                                if target.Node.Body ~= this.Body1
                                    keep(i) = mask.AlignedMask(target,b1,b2);
                                end
                            end
                        end
                    end
                end
                Con1.NodeContacts = Con1.NodeContacts(keep);

                % Copy NContacts of B1 from C1 onto C2
                MoveContacts = NodeContact.empty;
                for NC = Con1.NodeContacts
                    if NC.Node.Body == this.Body1
                        MoveContacts(end+1) = NodeContact(...
                            NC.Node,NC.Start,NC.End,NC.Type,NC.Connection);
                    end
                end
                Con2.addNodeContacts(MoveContacts);

                % Unshift Node Contacts in Con2
                for NC = Con2.NodeContacts
                    NC.Start = NC.Start - this.x;
                    NC.End = NC.End - this.x;
                end

            elseif Con1.Orient == enumOrient.Horizontal && ...
                    Con2.Orient == enumOrient.Horizontal
                %% Both Horizontal, Offset
                % Determine which one to take from, it would be the smaller of the
                % two
                r1 = 0;
                r2 = 0;
                for NContact = this.Connection1.NodeContacts
                    if any(NContact.Node.Body == this.Body1)
                        if r1 < NContact.End
                            r1 = NContact.End;
                        end
                    end
                end
                for NContact = this.Connection2.NodeContacts
                    if any(NContact.Node.Body == this.Body2)
                        if r2 < NContact.End; r2 = NContact.End; end
                    end
                end
                if r1 > r2
                    Source = this.Connection2;
                    Destination = this.Connection1;
                    DestinationBody = this.Body1;
                    SourceBody = this.Body2;
                    max_r = r2;
                else
                    Source = this.Connection1;
                    Destination = this.Connection2;
                    DestinationBody = this.Body2;
                    SourceBody = this.Body1;
                    max_r = r1;
                end
                min_r = 10000;
                for NContact = Source.NodeContacts
                    if NContact.Node.Body == SourceBody
                        if min_r > NContact.Start
                            min_r = NContact.Start;
                            if min_r == 0; break; end
                        end
                    end
                end


                % Gather Node Contacts from Source for comparison with Destination
                SContacts(length(Source.NodeContacts)) = NodeContact; n = 1;
                keep = true(size(Source.NodeContacts));
                for i = 1:length(Source.NodeContacts)
                    NContact = Source.NodeContacts(i);
                    if NContact.Node.Body == SourceBody
                        SContacts(n) = NContact; n = n + 1;
                        keep(i) = false;
                    end
                end
                Source.NodeContacts = Source.NodeContacts(keep);
                SContacts = SContacts(1:n-1);
                Ss = zeros(size(SContacts));
                Es = zeros(size(SContacts));
                i = 1;
                for NContact = SContacts
                    Es(i) = NContact.End;
                    Ss(i) = NContact.Start;
                    i = i + 1;
                end

                keep = true(size(Destination.NodeContacts));
                keep2 = true(size(SContacts));
                for i = 1:length(Destination.NodeContacts)
                    if Destination.NodeContacts(i).Node.Body == DestinationBody
                        DCont = Destination.NodeContacts(i);
                        s = DCont.Start;
                        e = DCont.End;
                        for j = 1:length(SContacts)
                            if keep2(j)
                                % Calculate Percentange that the segment covers
                                P = ...
                                    GetAreaPercentHorizontal(this.x,s,e,2*Es(j)) - ...
                                    GetAreaPercentHorizontal(this.x,s,e,2*Ss(j));
                                if P == 0; continue; end
                                if isempty(DCont.data)
                                    DCont.data = struct('Perc',1);
                                end
                                if isfield(DCont.data,'Perc')
                                    DCont.data.Perc = DCont.data.Perc - P;
                                else; DCont.data.Perc = 1 - P;
                                end

                                % Calculate the Percentage of the source that the segment
                                % ... covers
                                P2 = ...
                                    GetAreaPercentHorizontal(this.x,Ss(j),Es(j),2*e) - ...
                                    GetAreaPercentHorizontal(this.x,Ss(j),Es(j),2*s);
                                if isempty(SContacts(j).data)
                                    SContacts(j).data = struct('Perc',1);
                                end
                                if isfield(SContacts(j).data,'Perc')
                                    SContacts(j).data.Perc = SContacts(j).data.Perc - P2;
                                else; SContacts(j).data.Perc = 1 - P2;
                                end

                                % Make Faces
                                P1 = DCont.data.Perc;
                                DCont.data.Perc = 1;
                                NewFace = Face(...
                                    NodeContact(SContacts(j).Node,...
                                    SContacts(j).Start + this.x,SContacts(j).End + this.x,...
                                    SContacts(j).Type,SContacts(j).Connection),DCont,true);
                                DCont.data.Perc = P1;

                                % Modify Properties
                                if isfield(NewFace.data,'Area')
                                    NewFace.data.Area = NewFace.data.Area*P;
                                    if isfield(NewFace.data,'R')
                                        NewFace.data.R = NewFace.data.R/P;
                                    elseif isfield(NewFace.data,'Dh')
                                        NewFace.data.Dh = 2*(max_r - min_r);
                                    end
                                elseif isfield(NewFace.data,'U')
                                    NewFace.data.U = NewFace.data.U*P;
                                end
                                this.Faces = [this.Faces NewFace];

                                if ~keep(i); break; end
                            end
                        end
                    end
                end
                for i = 1:length(Destination.NodeContacts)
                    if isfield(Destination.NodeContacts(i).data,'Perc')
                        if Destination.NodeContacts(i).data.Perc <= 1e-6
                            keep(i) = false;
                        end
                    end
                end
                Destination.NodeContacts = Destination.NodeContacts(keep);
                for i = 1:length(SContacts)
                    if isfield(SContacts(i).data,'Perc')
                        if SContacts(i).data.Perc <= 1e-6
                            keep2(i) = false;
                        end
                    end
                end
                Source.addNodeContacts(SContacts(keep2));

            else
                fprintf(['XXX The Bridge Discretization method has not been ' ...
                    'updated to improved standards. It may not work as expected XXX\n']);
                %% Mix, Offset
                % Move Node Contacts from Connection2 that are associated with
                % Body 2 and add them to Connection1 in range of Body1
                if this.Connection1.Orient == enumOrient.Horizontal
                    Source = this.Connection1;
                    SourceBody = this.Body1;
                    Destination = this.Connection2;
                    DestinationBody = this.Body2;
                else
                    Source = this.Connection2;
                    SourceBody = this.Body2;
                    Destination = this.Connection1;
                    DestinationBody = this.Body1;
                end
                max_r = 0;
                min_r = 10000;
                for NContact = Source.NodeContacts
                    if max_r < NContact.End
                        max_r = NContact.End;
                    end
                    if min_r > NContact.Start
                        min_r = NContact.Start;
                    end
                end
                Dh = 2*max_r - 2*min_r;
                DontKeep = false(size(Source.NodeContacts));
                for i = 1:length(Source.NodeContacts)
                    if Source.NodeContacts(i).Node.Body == SourceBody
                        SContacts = Source.NodeContacts(i);
                        DontKeep(i) = true;
                    end
                end
                Source.NodeContacts(DontKeep) = [];
                for i = 1:length(Destination.NodeContacts)
                    if Destination.NodeContacts(i).Node.Body == DestinationBody
                        r = Destination.x;
                        DCont = Destination.NodeContacts(i);
                        s = DCont.Start;
                        e = DCont.End;
                        for j = 1:length(SContacts)
                            SCont = SContacts(j);
                            % Calculate Percentange that the segment covers
                            if isscalar(s)
                                if isscalar(e)
                                    % Both scalars
                                    P = GetAreaPercentMix(r,this.x,s,e,SCont.End) - ...
                                        GetAreaPercentMix(r,this.x,s,e,SCont.Start);
                                else
                                    % just "s" is a scalar
                                    for k = 1:length(e)
                                        P(k) = GetAreaPercentMix(r,this.x,s,e(k),SCont.End) - ...
                                            GetAreaPercentMix(r,this.x,s,e(k),SCont.Start);
                                    end
                                end
                            else
                                if isscalar(e)
                                    % just "e" is a scalar
                                    for k = 1:length(s)
                                        P(k) = GetAreaPercentMix(r,this.x,s(k),e,SCont.End) - ...
                                            GetAreaPercentMix(r,this.x,s(k),e,SCont.Start);
                                    end
                                else
                                    % Both vectors
                                    for k = 1:length(s)
                                        P(k) = GetAreaPercentMix(r,this.x,s(k),e(k),SCont.End) - ...
                                            GetAreaPercentMix(r,this.x,s(k),e(k),SCont.Start);
                                    end
                                end
                            end
                            if ~isempty(DCont.data) && isfield(DCont.data,'Perc')
                                DCont.data.Perc = DCont.data.Perc - P;
                            else
                                DCont.data.Perc = 1 - P;
                            end
                            if any(P > 0)
                                % Make Faces
                                % Precondition
                                SCont.Start = this.x - max_r;
                                SCont.End = this.x + max_r;
                                P1 = DCont.data.Perc;
                                DCont.data.Perc = 1;
                                NewFace = Face(SCont,DCont);
                                % Recondition
                                DCont.data.Perc = P1;
                                if isfield(NewFace.data,'Area')
                                    NewFace.data.Area = NewFace.data.Area.*P;
                                    if isfield(NewFace.data,'Dh')
                                        NewFace.data.Dh = Dh;
                                    elseif isfield(NewFace.data,'R')
                                        NewFace.data.R = NewFace.data.R./P;
                                    end
                                elseif isfield(NewFace.data,'U')
                                    NewFace.data.U = NewFace.data.U.*P;
                                end
                                this.Faces = [this.Faces NewFace];
                            end
                            if DontKeep(i)
                                break;
                            end
                        end
                    end
                end
                Destination.NodeContacts(DontKeep) = [];

            end
            this.isDiscretized = true;
        end

        %% Graphics
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
        function show(this,AxisReference)
            this.removeFromFigure(AxisReference);
            % Plot a dotted line between the middle of the Connection1's Overlap
            % with Body1 to the middle of Connection2's Overlap with Body2

            % Find P1;
            Ax = this.Connection1.Group;
            R = RotMatrix(Ax.Position.Rot - pi/2);
            d = this.Connection1.x;
            switch this.Connection1.Orient
                case enumOrient.Vertical
                    [~,~,y1,y2] = this.Body1.limits(enumOrient.Horizontal);
                    A = [Ax.Position.x; Ax.Position.y] + R*[d; (y1+y2)/2];
                    B = [Ax.Position.x; Ax.Position.y] + R*[-d; (y1+y2)/2];
                case enumOrient.Horizontal
                    [~,~,x1,x2] = this.Body1.limits(enumOrient.Vertical);
                    A = [Ax.Position.x; Ax.Position.y] + R*[(x1+x2)/2; d];
                    B = [Ax.Position.x; Ax.Position.y] + R*[-(x1+x2)/2; d];
            end

            % Find P2;
            Ax = this.Connection2.Group;
            R = RotMatrix(Ax.Position.Rot - pi/2);
            d = this.Connection2.x;
            switch this.Connection1.Orient
                case enumOrient.Vertical
                    [~,~,y1,y2] = this.Body2.limits(enumOrient.Horizontal);
                    C = [Ax.Position.x; Ax.Position.y] + R*[d; (y1+y2)/2];
                    D = [Ax.Position.x; Ax.Position.y] + R*[-d; (y1+y2)/2];
                case enumOrient.Horizontal
                    [~,~,x1,x2] = this.Body2.limits(enumOrient.Vertical);
                    C = [Ax.Position.x; Ax.Position.y] + R*[(x1+x2)/2; d];
                    D = [Ax.Position.x; Ax.Position.y] + R*[-(x1+x2)/2; d];
            end

            % Find minimum pair
            % pair = zeros(2,2);
            dAC = Dist4Compare(A,C);
            dAD = Dist4Compare(A,D);
            dmin = Dist4Compare(B,D);
            if dAC < dmin; pair = [A C]; dmin = dAC;
            else; pair = [B D];
            end
            if dAD < dmin; pair = [A D]; dmin = dAD; end
            if Dist4Compare(B,C) < dmin; pair = [B C]; end

            % Find the closest blank space in the model and drag the label there
            %[d, y, h] = this.Body1.Group.Model.findInterSpace(pair);
            %newpair = [pair(:,1) [d; y+h/2] [d; y-h/2] pair(:,2)];

            % Two points in pair are minimum distance
            this.GUIObjects = line(...
                pair(1,:),pair(2,:),...
                'Color',[0.5 0.5 0.5]);
        end
    end
end

