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

function [ Ch ] = TubeBankConvectiveConstant(Xt,Xl,do,Nr)
    %TUBEBANKNUSSELT Nst*NPr^0.667 = [Ch]*NRe^-0.4
    Xt_Xl = Xt/Xl;
    Xt_do = Xt/do;
    a = -0.1548*Xt_Xl+0.0591;
    b = 0.5437*Xt_Xl-0.0373;
    c = -1.9244*Xt_Xl^3+0.68562*Xt_Xl^2-7.9841*Xt_Xl+2.772;
    Ch = a*Xt_do^2 + b*Xt_do + c;
    if nargin > 3
    Ch = Ch*(1-1/(Nr^1.112+0.918353));
    end
end

