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

function minDistance = minDistanceToPolygon(point, xcoords, ycoords)
    % Calculate the minimum distance between a point and the perimeter of a polygon
    % defined by its vertices.

    
    numVertices = length(xcoords);
    minDistance = Inf;

    % Check if the point is inside the polygon
    max_x = max(xcoords);
    min_x = min(xcoords);
    max_y = max(ycoords);
    min_y = min(ycoords);

    if (point(1) < max_x && point(1) > min_x) && (point(2) < max_y && point(2) > min_y)
        % Point in inside polygon
        minDistance = 0;
        return;
    end

    % If point is not inside polygon, find shortest distance
    % Add the first coordinate to the end
    xcoords(end+1) = xcoords(1);
    ycoords(end+1) = ycoords(1);
    
    % Iterate over each edge of the polygon
    for i = 1:numVertices
        
        % Get the first vertex and the next one
        x1 = xcoords(i);
        y1 = ycoords(i);

        x2 = xcoords(i+1);
        y2 = ycoords(i+1);

        % Calculate the distance between the point and the line segment defined by the edges of the polygon
        distance = minDistancePointToLineSegment(point', [x1, y1], [x2,y2]);

        % Update the minimum distance if needed
        if distance < minDistance
            minDistance = distance;
        end
    end
end

