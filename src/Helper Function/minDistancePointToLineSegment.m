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

function distance = minDistancePointToLineSegment(point, lineSegmentStart, lineSegmentEnd)
    % Calculate the vector representing the line segment
    lineSegmentVector = lineSegmentEnd - lineSegmentStart;
    
    % Calculate the vector from the line segment start point to the point
    pointVector = point - lineSegmentStart;
    
    % Calculate the parameter along the line segment for the closest point
    t = dot(pointVector, lineSegmentVector) / dot(lineSegmentVector, lineSegmentVector);
    
    % Clamp the parameter value to ensure the closest point is within the line segment
    t = max(0, min(t, 1));
    
    % Calculate the closest point on the line segment
    closestPoint = lineSegmentStart + t * lineSegmentVector;
    
    % Calculate the distance between the point and the closest point
    distance = norm(point - closestPoint);
end
