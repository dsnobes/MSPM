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

function [ Triad ] = GetTriad( n1 )
    %GETTRIAD Summary of this function goes here
    %   Detailed explanation goes here
    Triad = cell(0);
    count = 1;
    for f1 = n1.Faces
        if isGasFace(f1)
            if f1.Nodes(1) == n1; n2 = f1.Nodes(2); else; n2 = f1.Nodes(1); end
            for f2 = n2.Faces
                if isGasFace(f2) && f2 ~= f1
                    if f2.Nodes(1) == n2; n3 = f2.Nodes(2); else; n3 = f2.Nodes(1); end
                    if n1 == n3
                        fprintf('XXX Reversing Face Found XXX\n');
                        continue;
                    end
                    for f3 = n3.Faces
                        if isGasFace(f3) && f3 ~= f2
                            if f3.Nodes(1) == n1 || f3.Nodes(2) == n1
                                Triad{count} = [f1 f2 f3];
                                count = count + 1;
                                break;
                            end
                        end
                    end
                end
            end
        end
    end
end

function isit = isGasFace(fc)
    isit = fc.Type == enumFType.Gas || fc.Type == enumFType.MatrixTransition;
end

