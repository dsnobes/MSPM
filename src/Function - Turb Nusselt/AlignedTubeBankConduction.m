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

function [ Const, Exponent ] = AlignedTubeBankConduction( Xt,Xl,do )
    %ALIGNEDTUBEBANKCONDUCTION Const * Re ^ Exponent = Nst*Npr^(2/3)
    Xt_Xl = Xt/Xl;
    Xt_do = Xt/do;
    Xl_do = Xl/do;
    Const = (0.118*Xt_Xl+0.252);
    Exponent = (-0.0125*Xt_Xl-0.433*Xl+0.0765*Xt-0.0892);
end

