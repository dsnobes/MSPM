classdef Pnt2D < handle
    %PNT2D Summary of this class goes here
    %   Detailed explanation goes here

    properties
        x double;
        y double;
    end

    methods
        function this = Pnt2D(x,y)
            if nargin == 0
                return;
            end
            this.x = x;
            this.y = y;
        end

        function isequal = eq(Pnt1,Pnt2)
            isequal = (Pnt1.x == Pnt2.x && Pnt1.y == Pnt2.y);
        end

        function rotate(this, RotationMatrix)
            newx = RotationMatrix(1,1)*this.x + RotationMatrix(1,2)*this.y;
            this.y = RotationMatrix(2,1)*this.x + RotationMatrix(2,2)*this.y;
            this.x = newx;
        end

        function shift(this, PositionVector)
            this.x = PositionVector(1) + this.x;
            this.y = PositionVector(2) + this.y;
        end
    end
end

