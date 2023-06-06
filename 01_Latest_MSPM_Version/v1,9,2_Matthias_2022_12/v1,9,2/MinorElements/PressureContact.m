classdef PressureContact
    %FORCECONTACT Summary of this class goes here
    %   Detailed explanation goes here

    properties
        ConverterIndex;
        MechanismIndex;
        Area;
        GasNode;
    end

    methods
        function this = PressureContact(ConverterIndex,MechanismIndex,Area,Node)
            this.ConverterIndex = ConverterIndex;
            this.MechanismIndex = MechanismIndex;
            this.Area = Area;
            this.GasNode = Node;
        end

        function iseq = equal(this,other)
            if this.MechanismIndex == other.MechanismIndex && ...
                    this.Area == other.Area && this.GasNode == other.GasNode
                iseq = true;
            else
                iseq = false;
            end
        end
    end
end

