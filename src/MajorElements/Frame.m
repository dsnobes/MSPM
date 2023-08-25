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

classdef Frame < handle
    %FRAME Summary of this class goes here
    %   Detailed explanation goes here
    properties (Constant)
        NTheta = 200;
        DecimateFactor = 10;
    end

    properties
        % Kinematic frames can be precalculated
        isKinematic = true;
        %           = false; is for free piston designs
        % In these cases the position array simply defines a
        % uniformly spaced position array between the motion
        % extents

        Positions double = []; % no negative positions, pistons should be sketched at minimum, not center.
        Mechanism LinRotMechanism; % as MechanicalSystem; % Defines a reference to the mechanism output that defines the motion of this frame
        MechanismIndex int8 = 1; % By Default
        CustomName char = [];
    end

    properties (Dependent)
        CurrentPosition;
        name;
    end

    methods
        function name = get.name(this)
            if isvalid(this)
                if isempty(this.CustomName)
                    ii = this.MechanismIndex;
                    name = [this.Mechanism.Type ...
                        ' L= ' num2str(this.Mechanism.Stroke(ii)) ...
                        ' m , P= ' num2str(this.Mechanism.Phase(ii)) ' rad.\n'];
                end
            else
                name = '...';
            end
        end
    end

end

