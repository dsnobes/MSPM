classdef NonConnection
    %NONCONNECTION Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Body1;
        Body2;
    end

    properties (Dependent)
        name;
    end

    methods
        function this = NonConnection(B1,B2)
            if nargin == 0
                return;
            end
            this.Body1 = B1;
            this.Body2 = B2;
        end

        function name = get.name(this)
            name = [this.Body1.name ' XXX ' this.Body2.name];
        end
    end

end

