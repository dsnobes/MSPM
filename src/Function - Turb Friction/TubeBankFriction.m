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

function [ Cf ] = TubeBankFriction( Xt,Xl,do )
    %TUBEBANKFRICTION 300 -> Re -> 15,000
    %   f = Cf*Re^-0.18
    Xt_Xl = Xt/Xl;
    Xl_do = Xl/do;
    a = -0.108*Xt_Xl^2+0.3137*Xt_Xl-0.2335;
    b = 0.7298*Xt_Xl^2-1.296*Xt_Xl+1.0343;
    c = -0.2129*Xt_Xl^2+0.5613*Xt_Xl-0.7471;
    Cf = a*Xl_do^2+b*Xl_do+c;
end

