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

function [ vector ] = shiftVector( vector, Phase )
    N = length(vector);
    temp = N*(Phase/(2*pi));
    n1 = floor(temp);
    frac = temp-n1;
    n2 = ceil(temp);
    v1 = circshift(vector,-n1);
    v2 = circshift(vector,-n2);
    vector = (1-frac)*v1 + frac*v2;
end
%
% function array = shiftv(array,n)
%   while n > length(array); n = n - length(array); end
%   while n < 1; n = n + length(array); end
%   if n == length(array); return; end
%
%   % n is a number that lies between 1 and length(array)
%   % ... Shift elements towards the start
%   temp(end-n+1:end) = array(1:n);
%   temp(1:end-n) = array(end-n+1:end);
%   array = temp;
% end

