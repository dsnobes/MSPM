classdef ShearContact
    % used in Face.m to model the shear force between two faces

    properties
        ConverterIndex;
        MechanismIndex;
        Area;
        LowerNode;
        UpperNode;
        ActiveTimes;
    end

    methods
        function this = ShearContact(...
                ConverterIndex,MechanismIndex,Area,Node1,Node2,ActiveTimes)
            if nargin == 6
                this.ConverterIndex = ConverterIndex;
                this.MechanismIndex = MechanismIndex;
                this.Area = Area;
                this.LowerNode = Node1;
                this.UpperNode = Node2;
                this.ActiveTimes = ActiveTimes;
            end
        end
        function iseq = equal(this,other)
            if this.ConverterIndex == other.ConverterIndex && ...
                    this.MechanismIndex == other.MechanismIndex && ...
                    this.LowerNode == other.LowerNode && ...
                    this.UpperNode == other.UpperNode
                iseq = true;
            else
                iseq = false;
            end
        end
    end
end

