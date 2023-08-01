classdef Relation < handle
    %{
    holds the properties of a relation:
    the name, the mode, and two connections.
    it is handled by a RelationManager
    %}
    % Relation - Class
    % ... -> name - String
    % ... -> mode - enumRelation
    % ... -> con1 - Connection
    % ... -> con2 - Connection
    % ... -> frame - Frame, associated with a mechanism with stroke

    properties
        name;
        mode enumRelation;
        con1 Connection;
        con2 Connection;
        frame Frame;
        manager RelationManager;
    end

    methods
        function this = Relation(manager,name,mode,con1,con2,frame)
            this.manager = manager;
            this.name = name;
            this.mode = mode;
            this.con1 = con1;
            this.con2 = con2;
            if nargin > 5
                this.frame = frame;
            end
        end
        function deReference(this)
            for i = length(this.manager.Relations):-1:1
                if this.manager.Relations(i).con1 == this.con1 && ...
                        this.manager.Relations(i).con2 == this.con2
                    this.manager.Relations(i) = [];
                end
            end
            this.manager.isChanged = true;
        end
        function Item = get(this,PropertyName)
            switch PropertyName
                case 'Name'
                    Item = this.name;
                case 'Connection1'
                    Item = this.con1;
                case 'Connection2'
                    Item = this.con2;
                case 'Frame'
                    Item = this.frame;
                otherwise
                    fprintf(['XXX Relation GET Inteface for ' PropertyName ...
                        ' is not found XXX\n']);
            end
        end
        function set(this,PropertyName,Item)
            switch PropertyName
                case 'Name'
                    this.name = Item;
                otherwise
                    fprintf(['XXX Relation SET Inteface for ' PropertyName ...
                        ' is not found XXX\n']);
            end
        end
    end
end

