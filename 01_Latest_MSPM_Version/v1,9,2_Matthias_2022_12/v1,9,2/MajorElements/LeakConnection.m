classdef LeakConnection < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        isChanged logical = true;
        isDiscretized logical = false;
        LeakFunc function_handle;
        obj1 = []; % Body or Environment
        obj2 = []; % Body or Environment
        Connection1 Connection;
        Connection2 Connection;
        Model Model;
    end

    properties (Hidden)
        customname;
    end

    properties (Dependent)
        name;
        isValid;
    end

    methods (Static)
        function [N,E] = getParameters()
            answer = {'0.2','0.5'};
            prompt = {'C1: ', 'C2: '};
            dlgtitle = 'What parameters are part of the leak equation Flow Rate [m^3/s] = C1*(dP)^C2?';
            dims = [1 100];
            trial = 1;
            while trial == 1 || ~isStrNumeric(answer{1}) || ~isStrNumeric(answer{2})
                answer = inputdlg(prompt,dlgtitle,dims,answer);
                trial = 2;
            end
            N = str2double(answer{1});
            E = str2double(answer{2});
        end
    end

    methods
        %% Constructor
        function this = LeakConnection(obj1,obj2,N,E)
            this.LeakFunc = @(P1,P2) sign(P1-P2).*N.*abs(P1-P2).^E;
            if isa(obj1,'Body')
                this.obj1 = obj1;
                this.Model = this.obj1.Group.Model;
            else; this.obj1 = obj1;
            end
            if isa(obj2,'Body')
                this.obj2 = obj2;
                this.Model = this.obj2.Group.Model;
            else; this.obj2 = obj2;
            end
        end



        function deReference(this)
            iModel = this.Model;
            for i = length(iModel.LeakConnections):-1:1
                if iModel.LeakConnections(i) == this
                    iModel.LeakConnections(i) = [];
                    break;
                end
            end
            if isa(this.obj1,'Body')
                this.obj1.change();
            end
            if isa(this.obj2,'Body')
                this.obj2.change();
            end
            this.removeFromFigure(gca);
            this.delete();
        end

        %% Get/Set Interface
        function Item = get(this,PropertyName)
            switch PropertyName
                case 'Name'
                    Item = this.name;
                case 'Connection 1'
                    Item = this.Connection1;
                case 'Connection 2'
                    Item = this.Connection2;
                case 'Object 1'
                    Item = this.obj1;
                case 'Object 2'
                    Item = this.obj2;
                case 'LeakFunc'
                    Item = this.LeakFunc;
                otherwise
                    fprintf(['XXX LeakConnection GET Inteface for ' PropertyName ' is not found XXX\n']);
            end
        end
        function set(this,PropertyName,Item)
            switch PropertyName
                case 'Name'
                    if Item ~= this.name
                        this.customname = Item;
                        this.change();
                    end
                case 'LeakFunc'
                    this.LeakFunc = Item;
                    this.change();
                otherwise
                    fprintf(['XXX LeakConnection SET Inteface for ' PropertyName ' is not found XXX\n']);
            end
        end
        function name = get.name(this)
            name = ['btw: ' this.obj1.name ' & ' this.obj2.name];
        end
        function change(this)
            this.isChanged = true;
            this.isDiscretized = false;
            fprintf('XXX Update Function for LeakConnection is Not written. XXX\n');
        end

        %% Generate Nodes
        function leakfaces = getleakface(this)
            n1 = this.obj1.Nodes(1);
            n2 = this.obj2.Nodes(1);
            leakfaces = struct(...
                'Node1',n1,...
                'Node2',n2,...
                'LeakFunc',this.LeakFunc);
            this.isDiscretized = true;
        end

        %% Testing
        function Valid = get.isValid(this)
            Valid = true;
            if isempty(this.obj1)
                Valid = false;
                fprintf(['Missing reference for Leak Connection: ' ...
                    this.name '.\n']);
            end
            if isempty(this.obj2)
                Valid = false;
                fprintf(['Missing reference for Leak Connection: ' ...
                    this.name '.\n']);
            end
            if (class(this.obj1) == 'Body')
                Valid = false;
                fprintf(['Missing end descriptor for connection 1 of Leak ' ...
                    'Connection: ' this.name '.\n']);
            end
            if (class(this.obj2) == 'Body')
                Valid = false;
                fprintf(['Missing end descriptor for connection 2 of Leak ' ...
                    'Connection: ' this.name '.\n']);
            end
        end


        function resetDiscretization(this)

        end
        %% Graphics
        function removeFromFigure(this,AxisReference)
            %       if ~isempty(this.GUIObjects)
            %         children = get(AxisReference,'Children');
            %         for obj = this.GUIObjects
            %           if isgraphics(obj)
            %             for i = length(children):-1:1
            %               if isgraphics(children(i)) && children(i) == obj
            %                 children(i).delete;
            %                 break;
            %               end
            %             end
            %           end
            %         end
            %         this.GUIObjects = [];
            %       end
        end
        function show(this,AxisReference)
            this.removeFromFigure(AxisReference);
            %       % Plot a dotted line between the middle of the Connection1's Overlap
            %       % with Body1 to the middle of Connection2's Overlap with Body2
            %
            %       % Find P1;
            %       if isa(this.obj1,'Body')
            %         Ax = this.Connection1.Group;
            %         R = RotMatrix(Ax.Position.Rot);
            %         x = this.Connection1.x;
            %         switch this.Connection1.Orient
            %           case enumOrient.Vertical
            %             [~,~,y1,y2] = this.obj1.limits(enumOrient.Horizontal);
            %             A = [Ax.Position.x; Ax.Position.y] + ...
            %               R*[(y1+y2)/2; x];
            %             B = [Ax.Position.x; Ax.Position.y] + ...
            %               R*[(y1+y2)/2; -x];
            %           case enumOrient.Horizontal
            %             [~,~,y1,y2] = this.obj1.limits(enumOrient.Horizontal);
            %             A = [Ax.Position.x; Ax.Position.y] + ...
            %               R*[x; (y1+y2)/2];
            %             B = [Ax.Position.x; Ax.Position.y] + ...
            %               R*[x; -(y1+y2)/2];
            %         end
            %       elseif isa(this.obj1,'Environment')
            %         [x,y] = this.Model.EnvironmentPosition(this.obj1);
            %         A = [x; y];
            %         B = [x; y];
            %       else
            %         return;
            %       end
            %
            %       % Find P2;
            %       if isa(this.obj2,'Body')
            %         Ax = this.Connection2.Group;
            %         R = RotMatrix(Ax.Position.Rot);
            %         x = this.Connection2.x;
            %         switch this.Connection1.Orient
            %           case enumOrient.Vertical
            %             [~,~,y1,y2] = this.obj2.limits(enumOrient.Vertical);
            %             C = [Ax.Position.x; Ax.Position.y] + ...
            %               R*[(y1+y2)/2; x];
            %             D = [Ax.Position.x; Ax.Position.y] + ...
            %               R*[(y1+y2)/2; -x];
            %           case enumOrient.Horizontal
            %             [~,~,y1,y2] = this.obj2.limits(enumOrient.Horizontal);
            %             C = [Ax.Position.x; Ax.Position.y] + ...
            %               R*[x; (y1+y2)/2];
            %             D = [Ax.Position.x; Ax.Position.y] + ...
            %               R*[x; -(y1+y2)/2];
            %         end
            %       elseif isa(this.obj2,'Environment')
            %         [x,y] = this.Model.EnvironmentPosition(this.obj2);
            %         C = [x; y];
            %         D = [x, y];
            %       else
            %         return;
            %       end
            %
            %       % Find minimum pair
            %       % pair = zeros(2,2);
            %       if Dist4Compare(A,C) < Dist4Compare(B,D)
            %         pair = [A C];
            %         dmin = Dist4Compare(A,C);
            %       else
            %         pair = [B D];
            %         dmin = Dist4Compare(B,D);
            %       end
            %       if Dist4Compare(A,D) < dmin
            %         pair = [A D];
            %         dmin = Dist4Compar(A,D);
            %       end
            %       if Dist4Compare(B,C) < dmin
            %         pair = [B C];
            %       end
            %
            %       % Find the closest blank space in the model and drag the label there
            %       [x, y, h] = this.Model.findInterSpace(pair);
            %       newpair = [pair(:,1) [x; y+h/2] [x; y-h/2] pair(:,2)];
            %
            %       % Two points in pair are minimum distance
            %       this.GUIObjects = line(...
            %         newpair(1,:),newpair(2,:),...
            %         'Color',[0.5 0.5 0.5]);
        end
    end

end

