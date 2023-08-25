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

function [ area_perc ] = GetAreaPercentHorizontal( x, r1, r2, d )
    %GETAREAPERCENTHORIZONTAL Summary of this function goes here
    %   Calculates the percentange that an offset circle covers a ring between
    %   r1 and r2
    x = abs(x);
    if d == 0 || x - d/2 > r2 || x + d/2 < r1; area_perc = 0; return; end
    if x-d/2 < -r2 && x+d/2 > r2; area_perc = 1; return; end
    
    c_r1 = max([x-d/2 r1]);
    c_r2 = min([x+d/2 r2]);
    
    N = 100;
    r = linspace(c_r1,c_r2,N);
    r = (r(1:end-1)+r(2:end))/2; % Center the radius's
    dr = (c_r2-c_r1)/(N-1);
    area = 0;
    
    if x > d/2
        for ri = r
            % Center is outside of circle, angle can never be larger than pi/2
            area = area + 2*dr*ri*acos((ri^2+x^2-(d/2)^2)/(2*ri*x));
        end
    else
        for ri = r
            if d/2 >= ri + x
                % Full Circle
                area = area + 2*dr*ri*pi;
            else
                % Center is insie of circle
                area = area + 2*dr*ri*acos((ri^2+x^2-(d/2)^2)/(2*ri*x));
            end
        end
    end
    area_perc = area/(pi*(r2^2-r1^2));
end

