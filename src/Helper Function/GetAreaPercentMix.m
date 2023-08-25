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

function [ PercArea ] = GetAreaPercentMix(r, x, y1, y2, d )
    %GETAREAPERCENTMIX Summary of this function goes here
    %   Calculates the percentage that an circle at x of diameter d covers a
    %   strip between y1 and y2

    % Calculate the total area of the node contact on the vertical connection
    Total_Area = 2*pi*r*(y2-y1);

    % Get the lowest point (either the circle or the line)
    c_y1 = max([x-d/2 y1]);

    % Get the highest point (either the circle or the line)
    c_y2 = min([x+d/2 y2]);

    %
    if c_y1 >= c_y2; PercArea = 0; return; end
    N = max([2 floor(100*(c_y2-c_y1)/d)]);
    y = linspace(c_y1,c_y2,N);
    y = (y(1:end-1)+y(2:end))/2;
    dy = (c_y2-c_y1)/(N-1);
    area = 0;
    for yi = y
        area = area + 2*dy*min([r sqrt((d/2)^2-(x-yi)^2)]);
    end
    PercArea = area/Total_Area;

% r,this.x,s,e,SCont.End


    function coveredArea = circleCoverageArea(x, d, y1, y2)
        radius = d / 2;

        % Calculate the intersection between the circle and the strip
        y_top = max(y1, x - radius);
        y_bottom = min(y2, x + radius);

        % Calculate the length of the strip
        strip_length = y_bottom - y_top;

        % Calculate the covered area of the circle
        if strip_length >= d
            % The strip completely covers the circle
            coveredArea = pi * radius^2;
        elseif strip_length <= 0
            % The strip does not intersect with the circle
            coveredArea = 0;
        else
            % Calculate the angle subtended by the strip on the circle
            theta = 2 * acos((radius - strip_length) / radius);

            % Calculate the area of the circular segment
            segmentArea = (theta - sin(theta)) * radius^2 / 2;

            % Calculate the area of the covered part within the strip
            coveredArea = segmentArea - strip_length * (radius - strip_length);
        end
    end

    










end

