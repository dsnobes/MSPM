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

classdef OptimizationScheme < handle

    properties
        Model;
        name;
        ID;
        Names;
        Classes;
        IDs;
        Fields;
        History;
    end

    methods
        function this = OptimizationScheme(Model)
            if nargin > 0
                this.name = getProperName('Optimization Study');
                this.Model = Model;
                this.ID = Model.getOptimizationStudyID();
            end
        end
        function AddObj(this, obj, field)
            len = length(this.Names)+1;
            this.Names{len} = getProperName('Degree of Freedom');
            if strcmp(this.Names{len},'')
                this.Names{len} = [...
                    class(obj) ' - ' num2str(obj.ID) ' - ' field];
            end
            this.Classes{len} = class(obj);
            this.IDs{len} = obj.ID;
            this.Fields{len} = field;
        end
        function Item = get(this,PropertyName)
            switch PropertyName
                case 'Name'
                    Item = this.name;
                case 'DOFs'
                    Item = this.Names;
                otherwise
                    fprintf(['XXX Optimization Study GET Inteface for ' PropertyName ...
                        ' is not found XXX\n']);
            end
        end
        function set(this,PropertyName,Item)
            switch PropertyName
                case 'Name'
                    this.name = Item;
                case 'DOFs'
                    for i = length(Item):-1:1
                        if Item(i)
                            this.Names(i) = [];
                            this.Classes(i) = [];
                            this.IDs(i) = [];
                            this.Fields(i) = [];
                        end
                    end
                otherwise
                    fprintf(['XXX Optimization Study SET Inteface for ' PropertyName ...
                        ' is not found XXX\n']);
            end
        end
    end
end

