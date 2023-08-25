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

classdef Position < handle
    % contains the position information for anything (X, Y, Angle)

    properties
        x double = 0;
        y double = 0;
        Rot double = pi/2;
    end

    properties (Dependent)
        name;
    end

    methods
        function this = Position(x,y,Rot)
            switch nargin
                case 1
                    this.x = x;
                case 2
                    this.x = x;
                    this.y = y;
                case 3
                    this.x = x;
                    this.y = y;
                    this.Rot = Rot;
            end
        end
        function newPosition = plus(base,offset)
            newPosition.x = base.x + offset.x;
            newPosition.y = base.y + offset.y;
            newPosition.Rot = base.Rot;
            newPosition.Model = base.Model;
        end
        function name = get.name(this)
            name = sprintf('x: %f y: %f Rot: %f',this.x,this.y,this.Rot);
        end
        function Item = get(this,PropertyName)
            switch PropertyName
                case 'x'
                    Item = this.x;
                case 'y'
                    Item = this.y;
                case 'Theta'
                    Item = this.Rot;
                otherwise
                    fprintf(['XXX Position GET Inteface for ' PropertyName ' is not found XXX\n']);
            end
        end
        function set(this,PropertyName,Item)
            switch PropertyName
                case 'x'
                    this.x = Item;
                case 'y'
                    this.y = Item;
                case 'Theta'
                    this.Rot = Item;
                otherwise
                    fprintf(['XXX Position SET Inteface for ' PropertyName ' is not found XXX\n']);
            end
        end
    end

end

