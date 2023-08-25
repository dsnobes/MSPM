%{
   Modular Single Phase Model - MSPM. A program for simulating single phase cyclical thermodynamic machines.
   Copyright (C) 2023  David Nobes
      Mailing Address:
         University of Alberta
         Mechanical Engineering
         10-281 Donadeo Innovation Centre For Engineering
         9211-116 St
         Edmonton
         AB
         T6G 2H5
      Email: dnobes@ualberta.ca

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.
%}

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

