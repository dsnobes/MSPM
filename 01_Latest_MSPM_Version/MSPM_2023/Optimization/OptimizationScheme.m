classdef OptimizationScheme < handle

    properties
        Model;
        name;
        ID;
        Names;
        Classes;
        IDs;
        Fields;
        History;
    end

    methods
        function this = OptimizationScheme(Model)
            if nargin > 0
                this.name = getProperName('Optimization Study');
                this.Model = Model;
                this.ID = Model.getOptimizationStudyID();
            end
        end
        function AddObj(this, obj, field)
            len = length(this.Names)+1;
            this.Names{len} = getProperName('Degree of Freedom');
            if strcmp(this.Names{len},'')
                this.Names{len} = [...
                    class(obj) ' - ' num2str(obj.ID) ' - ' field];
            end
            this.Classes{len} = class(obj);
            this.IDs{len} = obj.ID;
            this.Fields{len} = field;
        end
        function Item = get(this,PropertyName)
            switch PropertyName
                case 'Name'
                    Item = this.name;
                case 'DOFs'
                    Item = this.Names;
                otherwise
                    fprintf(['XXX Optimization Study GET Inteface for ' PropertyName ...
                        ' is not found XXX\n']);
            end
        end
        function set(this,PropertyName,Item)
            switch PropertyName
                case 'Name'
                    this.name = Item;
                case 'DOFs'
                    for i = length(Item):-1:1
                        if Item(i)
                            this.Names(i) = [];
                            this.Classes(i) = [];
                            this.IDs(i) = [];
                            this.Fields(i) = [];
                        end
                    end
                otherwise
                    fprintf(['XXX Optimization Study SET Inteface for ' PropertyName ...
                        ' is not found XXX\n']);
            end
        end
    end
end

