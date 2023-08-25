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

