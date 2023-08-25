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

function [ d ] = Dist2Rect( Px,Py,Cx,Cy,width,height )
    % 9 cases
    w = width/2;
    h = height/2;
    if Px < Cx+w
        if Px > Cx-w
            if Py < Cy+h
                if Py > Cy-h % Bounded, Bounded (Inside)
                    d = 0;
                else % Under, Bounded
                    d = ((Cy-h)-Py)^2;
                end
            else % Above, Bounded
                d = (Py-(Cy+h))^2;
            end
        else
            if Py < Cy+h % Under Top Surface, Left
                if Py > Cy-h % Bounded, Left
                    d = (Cx-w-Px)^2;
                else % Under, Left
                    d = ((Cx-w)-Px)^2+((Cy-h)-Py)^2;
                end
            else % Above, Left
                d = ((Cx-w)-Px)^2+(Py-(Cy+h))^2;
            end
        end
    else
        if Py < Cy+h
            if Py > Cy-h % Bounded, Right
                d = (Px-(Cx+w))^2;
            else % Under, Right
                d = ((Cy-h)-Py)^2+(Px-(Cx+w))^2;
            end
        else % Above, Right
            d = (Py-(Cy+h))^2+(Px-(Cx+w))^2;
        end
    end
end

