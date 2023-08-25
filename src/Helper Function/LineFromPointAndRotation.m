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

function [A, B, C] = LineFromPointAndRotation(x0, y0, rotationAngle)
    % Translate the point to the origin
    translated_x0 = x0 - x0;
    translated_y0 = y0 - y0;
    
    % Calculate the direction cosines of the rotated line
    cosTheta = cos(rotationAngle);
    sinTheta = sin(rotationAngle);
    
    % Calculate the coefficients A, B, and C for the rotated line
    A_rotated = sinTheta;
    B_rotated = -cosTheta;
    C_rotated = -(A_rotated * translated_x0 + B_rotated * translated_y0);
    
    % Translate the rotated line equation back to the original position
    A = A_rotated;
    B = B_rotated;
    C = C_rotated - A_rotated * x0 - B_rotated * y0;
end