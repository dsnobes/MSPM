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

classdef Mesher < handle
    % stores properties which are used by the smart discretizer
    % to discretize bodies

    properties
        % Solid Related
        oscillation_depth_N int16 = 6;
        maximum_thickness double = 0.02;
        maximum_growth double = 1.5;
        HeatExchangerFinDivisions int16 = 3;
        MinSolidTimeStep = 1e-4;

        % Gas Related
        Gas_Entrance_Exit_N int16 = 8;
        Gas_Maximum_Size double = 0.02;
        Gas_Minimum_Size double = 0.003;
        name = 'Universal Mesher';
    end

    methods
        function item = get(this,Property)
            switch Property
                case 'name'
                    item = this.name;
                case 'Nodes through Oscillation Depth'
                    item = this.oscillation_depth_N;
                case 'Maximum Node Thickness'
                    item = this.maximum_thickness;
                case 'Maximum Growth Rate'
                    item = this.maximum_growth;
                case 'Heat Exchanger Fin Divisions'
                    item = this.HeatExchangerFinDivisions;
                case 'Minimum Solid Time Step'
                    item = this.MinSolidTimeStep;
                case 'Gas Entrance Exit N'
                    item = this.Gas_Entrance_Exit_N;
                case 'Gas Maximum Size'
                    item = this.Gas_Maximum_Size;
                case 'Gas Minimum Size'
                    item = this.Gas_Minimum_Size;
                otherwise
                    fprintf(['XXX Mesher GET Inteface for ' Property ' is not found XXX\n']);
            end
        end
        function set(this,Property,item)
            switch Property
                case 'name'
                    this.name = item;
                case 'Nodes through Oscillation Depth'
                    this.oscillation_depth_N = item;
                case 'Maximum Node Thickness'
                    this.maximum_thickness = item;
                case 'Maximum Growth Rate'
                    this.maximum_growth = item;
                case 'Heat Exchanger Fin Divisions'
                    this.HeatExchangerFinDivisions = item;
                case 'Minimum Solid Time Step'
                    this.MinSolidTimeStep = item;
                case 'Gas Entrance Exit N'
                    this.Gas_Entrance_Exit_N = item;
                case 'Gas Maximum Size'
                    this.Gas_Maximum_Size = item;
                case 'Gas Minimum Size'
                    this.Gas_Minimum_Size = item;
                otherwise
                    fprintf(['XXX Mesher SET Inteface for ' Property ' is not found XXX\n']);
            end
        end
        function doesit = isInsideRadiiExposed(~,Body)
            [~,~,xmin,~] = Body.limits(enumOrient.Vertical);
            [ymin,ymax,~,~] = Body.limits(enumOrient.Horizontal);
            xdepth = 3*sqrt(2*Body.matl.thermaldiffusivity/...
                Body.Group.Model.engineSpeed) * 1.5;
            for iBody = Body.Group.Bodies
                if iBody ~= Body && iBody.matl.Phase == enumMaterial.Gas
                    % Get x limits and see if they could touch
                    [~,~,~,xmaxi] = iBody.limits(enumOrient.Vertical);
                    if abs(xmin - xmaxi) < xdepth
                        % Get y limits and see if they infact overlap at any time
                        [ymini,ymaxi,~,~] = iBody.limits(enumOrient.Horizontal);
                        if any(~((ymin >= ymaxi) + (ymini >= ymax)))
                            doesit = true;
                            return;
                        end
                    end
                end
            end
            doesit = false;
        end
        function doesit = isOutsideRadiiExposed(~,Body)
            [~,~,~,xmax] = Body.limits(enumOrient.Vertical);
            [ymin,ymax,~,~] = Body.limits(enumOrient.Horizontal);
            xdepth = 3*sqrt(2*Body.matl.thermaldiffusivity/...
                Body.Group.Model.engineSpeed) * 1.5;
            for iBody = Body.Group.Bodies
                if iBody ~= Body && iBody.matl.Phase == enumMaterial.Gas
                    % Get x limits and see if they could touch
                    [~,~,xmini,~] = iBody.limits(enumOrient.Vertical);
                    if abs(xmax - xmini) < xdepth
                        % Get y limits and see if they infact overlap at any time
                        [ymini,ymaxi,~,~] = iBody.limits(enumOrient.Horizontal);
                        if any(~((ymin >= ymaxi) + (ymini >= ymax)))
                            doesit = true;
                            return;
                        end
                    end
                end
            end
            doesit = false;
        end
        function doesit = isBottomExposed(~,Body)
            [~,~,xmin,xmax] = Body.limits(enumOrient.Vertical);
            xdepth = 3*sqrt(2*Body.matl.thermaldiffusivity/...
                Body.Group.Model.engineSpeed) * 1.5;
            for iBody = Body.Group.Bodies
                if iBody ~= Body && iBody.matl.Phase == enumMaterial.Gas
                    % Get x limits and see if they could touch
                    [~,~,xmini,xmaxi] = iBody.limits(enumOrient.Vertical);
                    if ~(xmax <= xmini) && ~(xmin >= xmaxi)
                        % See if they get close to each other
                        [ymin,~,~,~] = Body.limits(enumOrient.Horizontal);
                        [~,ymaxi,~,~] = iBody.limits(enumOrient.Horizontal);
                        if min(abs(ymin-ymaxi)) < xdepth
                            doesit = true;
                            return;
                        end
                    end
                end
            end
            doesit = false;
        end
        function doesit = isTopExposed(~,Body)
            [~,~,xmin,xmax] = Body.limits(enumOrient.Vertical);
            xdepth = 3*sqrt(2*Body.matl.thermaldiffusivity/...
                Body.Group.Model.engineSpeed) * 1.5;
            for iBody = Body.Group.Bodies
                if iBody ~= Body && iBody.matl.Phase == enumMaterial.Gas
                    % Get x limits and see if they could touch
                    [~,~,xmini,xmaxi] = iBody.limits(enumOrient.Vertical);
                    if ~(xmax <= xmini) && ~(xmin >= xmaxi)
                        % See if they get close to each other
                        [~,ymax,~,~] = Body.limits(enumOrient.Horizontal);
                        [ymini,~,~,~] = iBody.limits(enumOrient.Horizontal);
                        if min(abs(ymax-ymini)) < xdepth
                            doesit = true;
                            return;
                        end
                    end
                end
            end
            doesit = false;
        end
    end

end

