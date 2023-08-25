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

function [Code] = ResetCode(Code)
    if ~isempty(Code)
        if Code(1) == '1'
            % Model may maintain its expansion
            if length(Code) > 1
                if Code(2) == '['
                    i = 3; lvlcount = -1;
                    while i < length(Code) && lvlcount < 0
                        switch Code(i)
                            case '['; lvlcount = lvlcount - 1;
                            case ']'; lvlcount = lvlcount + 1;
                        end
                        i = i + 1;
                    end
                    if length(Code) > i; Code(i+1:end) = ''; end
                end
            end
        else
            % Everything else is presumed to have changed
            Code = '';
        end
    end
end

