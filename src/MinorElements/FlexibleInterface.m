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

classdef FlexibleInterface < handle
    % holds data about a mobile interface between two bodies

    properties
        Body1 Body;
        Body2 Body;
        Connection Connection;
        PressureExpansionFunc function_handle;
        WallThickness;
        matl Material;
        Area;
    end

    methods
        function this = FlexibleInterface(...
                iBody1,iBody2,iConnection,...
                iPressureExpansionFunc,iWallThickness,...
                iWallMaterial,iWallSurfaceArea)
            if nargin > 6
                this.Body1 = iBody1;
                this.Body2 = iBody2;
                this.Connection = iConnection;
                this.PressureExpansionFunc = iPressureExpansionFunc;
                this.WallThickness = iWallThickness;
                this.matl = iWallMaterial;
                this.Area = iWallSurfaceArea;
            end
        end

        function item = get(this,propertyName)
            switch propertyName
                case 'InnerBody'
                    item = this.Body1;
                case 'OuterBody'
                    item = this.Body2;
                case 'Connection'
                    item = this.Connection;
                case 'Pressure Expansion Function'
                    item = this.PressureExpansionFunction;
                case 'Unstretched Wall Thickness'
                    item = this.WallThickness;
                case 'Wall Material'
                    item = this.matl;
                case 'Nominal Wall Area'
                    item = this.Area;
            end
        end

        function set(this,propertyName,item)
            switch propertyName
                case 'InnerBody'
                    this.Body1 = item;
                case 'OuterBody'
                    this.Body2 = item;
                case 'Connection'
                    this.Connection = item;
                case 'Pressure Expansion Function'
                    this.PressureExpansionFunction = item;
                case 'Unstretched Wall Thickness'
                    this.WallThickness = item;
                case 'Wall Material'
                    this.matl = item;
                case 'Nominal Wall Area'
                    this.Area = item;
            end
        end

        function isit = isvalid(this)
            isit = false;
            if ~isempty(this.Body1) && ...
                    ~isempty(this.Body2) && ...
                    ~isempty(this.Connection) && ...
                    ~isempty(this.PressureExpansionFunc) && ...
                    ~isempty(this.WallThickness) && ...
                    ~isempty(this.matl) && ...
                    ~isempty(this.Area)
                for iBodies = this.Connection.Bodies
                    if this.Body1 == iBody
                        one = true;
                    elseif this.Body2 == iBody
                        two = true;
                    end
                end
                isit = one && two;
            end
        end
    end
end

