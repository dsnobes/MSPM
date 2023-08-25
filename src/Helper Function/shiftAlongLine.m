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

function adjusted_point = shiftAlongLine(point, A, B, C, para_shift, perp_shift)
    % Function shifts a point along a line specified in the form Ax + By + C = 0
    % Shift distance is a scalar
    % Shift direction is a unit vector [x_shift_direction, y_shift_direction]
    % Given point coordinates

   % Calculate the direction vector along the given line
    line_direction = [-B, A];
    line_direction = line_direction / norm(line_direction);

    % Calculate the shift vector in the original coordinate system
    shift_vector = perp_shift * line_direction + para_shift * [A, B];

    % Calculate the new coordinates of the shifted point
    new_x = point(1) + shift_vector(1);
    new_y = point(2) + shift_vector(2);

    % Convert to a single vector
    adjusted_point = [new_x, new_y];
end