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

classdef NonConnection
    % contains two Bodies which should be assumed to not be connected
    % to each other

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

