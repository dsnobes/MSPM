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

function [ ] = debug_loopPlot( Model, Closed)
    h = figure();
    if nargin > 1
        if length(Closed) == 1
            if ~Closed
                for fc = Model.Faces
                    if fc.Type == enumFType.Gas || fc.Type == enumFType.MatrixTransition
                        c1 = fc.Nodes(1).minCenterCoords();
                        c2 = fc.Nodes(2).minCenterCoords();
                        line([c1.x; c2.x], [c1.y; c2.y]);
                    end
                end
            end
        else
            for fc = Model.Faces
                if fc.Type == enumFType.Gas || fc.Type == enumFType.MatrixTransition
                    if ~Closed(fc.index)
                        c1 = fc.Nodes(1).minCenterCoords();
                        c2 = fc.Nodes(2).minCenterCoords();
                        line([c1.x; c2.x], [c1.y; c2.y]);
                    end
                end
            end
        end
    else
        for fc = Model.Faces
            if fc.Type == enumFType.Gas || fc.Type == enumFType.MatrixTransition
                if all(fc.data.Area > 0)
                    c1 = fc.Nodes(1).minCenterCoords();
                    c2 = fc.Nodes(2).minCenterCoords();
                    line([c1.x; c2.x], [c1.y; c2.y]);
                end
            end
        end
    end
    close(h);
end

