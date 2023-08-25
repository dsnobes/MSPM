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

function [itcan] = canClose( fc )
    if isfield(fc.data,'Area')
        if all(fc.data.Area > 0)
            % Path from one side to the other
            [itcan] = canPathTo(fc, fc.Nodes(1), fc.Nodes(2));
        else; itcan = true;
        end
    else
        itcan = false;
    end
end

function [canPath, visited] = canPathTo(visited, target, start)
    canPath = false;
    for fc = start.Faces
        if (fc.Type == enumFType.Gas || ...
                fc.Type == enumFType.MatrixTransition) && ...
                ~any(fc == visited)
            % Make sure the face is traversible
            if all(fc.data.Area > 0)
                if fc.Nodes(1) == start; i = 2; else; i = 1; end
                % Test for completion
                if fc.Nodes(i) == target
                    canPath = true; return;
                else
                    % Continue Searching
                    for fci = fc.Nodes(i).Faces
                        [canPath, visited] = ...
                            canPathTo([visited fc], target, fc.Nodes(i));
                        if canPath; return; end
                    end
                end
            end
        end
    end
end

