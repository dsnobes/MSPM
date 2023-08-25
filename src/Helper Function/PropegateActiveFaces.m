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

function [ k,Array,Visited ] = PropegateActiveFaces(Nd,Visited,k,Array)
    Visited(Nd.index) = true;
    if k == length(Array)
        return;
    end
    for Fc = Nd.Faces
        if Fc.Nodes(1).index <= length(Visited) && ...
                Fc.Nodes(2).index <= length(Visited) && ...
                isfield(Fc.data,'dx') && all(Fc.data.Area > 0)
            if ~Visited(Fc.Nodes(1).index)
                k = k + 1;
                Array(k) = Fc.index;
                [k,Array,Visited] = PropegateActiveFaces(Fc.Nodes(1),Visited,k,Array);
            elseif ~Visited(Fc.Nodes(2).index)
                k = k + 1;
                Array(k) = Fc.index;
                [k,Array,Visited] = PropegateActiveFaces(Fc.Nodes(2),Visited,k,Array);
            end
        end
    end
end

