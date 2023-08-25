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

function [c] = getCenterOfOverlapRegion(min1,min2,max1,max2)
    if isscalar(min1)
        if isscalar(min2)
            temp1 = max(min1,min2);
        else
            temp1 = max([min1(ones(size(min2))); min2]);
        end
    else
        if isscalar(min2)
            temp1 = max([min2(ones(size(min1))); min1]);
        else
            temp1 = max([min1; min2]);
        end
    end
    if isscalar(max1)
        if isscalar(max2)
            temp2 = min(max1,max2);
        else
            temp2 = min([max1(ones(size(max2))); max2]);
        end
    else
        if isscalar(max2)
            temp2 = min([max2(ones(size(max1))); max1]);
        else
            temp2 = min([max1; max2]);
        end
    end
    c = (temp1 + temp2)/2;
end

