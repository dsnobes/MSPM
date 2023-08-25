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

function [ U ] = AnnularConduction(Node,r,L,matl)
    %ANNULARCONDUCTION Summary of this function goes here
    %   Detailed explanation goes here
    if Node.xmin ~= 0
        mid_r = sqrt(Node.xmin*Node.xmax);
        %Matthias: Replaced 'if' statement with 'r_ratio'
        r_ratio = max([r/mid_r, mid_r/r]);
        U = (2*pi*matl.ThermalConductivity/log(r_ratio)).*L;
    
        %     if mid_r < r
        %       U = (2*pi*matl.ThermalConductivity/log(r/mid_r)).*L;
        %     else
        %       U = ((2*pi*matl.ThermalConductivity)/log(mid_r/r)).*L;
        %     end
    else
        % The Constant comes from 1/log(1/0.570524), which is the center
        % ... Non-dimensional radius of: Resistance*Area of a cylinder.
        U = 2*pi*matl.ThermalConductivity*1.781896.*L;
    end
end


