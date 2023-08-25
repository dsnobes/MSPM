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

function [ iNodes ] = findClosest2(loc, iNodes )
    selection = zeros(1,2);
    d = zeros(1,4);
    for i = 1:length(iNodes)
        pnts = iNodes.minCenterCoords;
        d(i) = (pnts.x - loc.x)^2 + (pnts.y - loc.y)^2;
    end
    n = 1;
    while true
        dmin = d(1);
        k = 1;
        for i = 2:length(d)
            if dmin > d(i)
                dmin = d(i);
                k = i;
            end
        end
        if dmin == inf
            iNodes = iNodes(selection(1:n));
            return;
        end
        d(k) = inf;
        selection(n) = k;
        n = n + 1;
        if n == 3
            iNodes = iNodes(selection);
            return;
        end
    end
end

