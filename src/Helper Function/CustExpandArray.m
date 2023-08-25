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

function [newarray] = CustExpandArray(array)
    newarray = zeros(size(array) + [2 2]);
    % Identical core of the array
    newarray(2:(1+size(array,1)),2:(1+size(array,2))) = array(:,:);
    % Four Edges
    newarray(1,2:(1+size(array,2))) = array(1,:);
    newarray(end,2:(1+size(array,2))) = array(end,:);
    newarray(2:(1+size(array,1)),1) = array(:,1);
    newarray(2:(1+size(array,1)),end) = array(:,end);
    % Four Corners
    newarray(1,1) = newarray(1,2);
    newarray(1,end) = newarray(1,end-1);
    newarray(end,1) = newarray(end,2);
    newarray(end,end) = newarray(end,end-1);
end

