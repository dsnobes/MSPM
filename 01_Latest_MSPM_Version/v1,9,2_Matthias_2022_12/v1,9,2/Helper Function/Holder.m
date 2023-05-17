classdef Holder < handle
    %HOLDER Summary of this class goes here
    %   Detailed explanation goes here

    properties
        vars cell;
    end

    methods
        function obj = Holder(ivars)
            obj.vars = ivars;
        end
    end
end

