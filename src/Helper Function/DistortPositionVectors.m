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

function [oXData,oYData] = DistortPositionVectors(iXData,iYData,shift,rotate)
    if nargin > 3 && all(size(rotate) == [2 2])
        oXData = rotate(1,1)*iXData + rotate(1,2)*iYData;
        oYData = rotate(2,1)*iXData + rotate(2,2)*iYData;
        if length(shift) == 2
            oXData = shift(1) + oXData;
            oYData = shift(2) + oYData;
        end
        return;
    end
    if nargin > 2 && length(shift) == 2
        oXData = shift(1) + iXData;
        oYData = shift(2) + iYData;
    end
end

