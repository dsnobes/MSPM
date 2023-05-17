classdef ShearContact
    %FORCECONTACT Summary of this class goes here
    %   Detailed explanation goes here

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
                %FORCECONTACT Construct an instance of this class
                %   Detailed explanation goes here
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

