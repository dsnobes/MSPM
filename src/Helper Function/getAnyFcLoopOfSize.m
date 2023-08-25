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

function [success, visited] = getAnyFcLoopOfSize(visited, target, start, max_length)
    success = false;
    for fc = start.Faces
        if visited(end) ~= fc && (fc.Type == enumFType.Gas || ...
                fc.Type == enumFType.MatrixTransition)
            % Make sure the face is traversible
            if fc.Nodes(1) == start; i = 2; else; i = 1; end
            % Test for completion
            if fc.Nodes(i) == target
                success = true; visited = [visited fc]; return;
            else
                % Length Check
                if length(visited) + 1 == max_length
                    success = false; return;
                else
                    % Continue Searching
                    for fci = fc.Nodes(i).Faces
                        [success, new_visited] = getAnyFcLoopOfSize(...
                            [visited fc], target, fc.Nodes(i), max_length);
                        if success
                            visited = new_visited;
                            return;
                        end
                    end
                end
            end
        end
    end
end
