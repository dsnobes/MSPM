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

function [C] = Cubehelix(N)
    %CUBEHELIX Returns the colormap corresponding to the cubehelix colormap by
    % Dave Green
    % Described in:
    % ... Green, D. A., 2011, `A colour scheme for the display of astronomical
    % ... intensity images', Bulletin of the Astronomical Society of India, 39,
    % ... 289. (2011BASI...39..289G at ADS.)
    % Chosen because it is readeable in both color and gray-scale. The
    % following is a fit to the colormap for simplicity
    C = zeros(N,3);
    inc = linspace(0,1,N);
    for i = 1:N
        C(i,1) = inc(i) + inc(i)*(1-inc(i))*(-0.89364167360231)*...
            sin(-9.42709701246915*inc(i)-2.17665661962626);
        C(i,2) = inc(i) + inc(i)*(1-inc(i))*0.476808544884337*...
            sin(9.41893653572546*inc(i)+4.92713139814227);
        C(i,3) = inc(i) + inc(i)*(1-inc(i))*0.986358536351536*...
            sin(-9.43408675851738*inc(i)+2.62243462096891);
    end
    C(C>1) = 1;
    C(C<0) = 0;
end

