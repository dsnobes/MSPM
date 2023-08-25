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

function [output] = asin_omni(input)
    intermittent = zeros(size(input));
    for i = 1:length(input)
        intermittent(i) = asin(input(i));
    end
    count = 0;
    output = zeros(size(input));
    i = 2;
    output(1) = intermittent(1);
    d = diff(intermittent);
    while i < length(input)+1 && count < 100
        while i < length(input)+1 && d(i-1) >= 0
            output(i) = intermittent(i) + count*pi;
            i = i + 1;
        end
        count = count + 1;
        while i < length(input)+1 && d(i-1) <= 0
            output(i) = count*pi - intermittent(i);
            i = i + 1;
        end
        count = count + 1;
    end
end

