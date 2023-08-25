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

function [ scores ] = assessTriad( Triad, derefinement_factor)
    a = Triad(1);
    b = Triad(2);
    c = Triad(3);
    modification = sqrt(derefinement_factor);
    threshold = 0.1/modification;
    
    scores = [0, 0, 0];
    
    canCloseA = canClose(a);
    canCloseB = canClose(b);
    canCloseC = canClose(c);
    
    if canCloseA
        for i = 1:Frame.NTheta-1
            Aa = getArea(a,i);
            if Aa == 0; continue; end
            Ab = getArea(b,i);
            if Ab == 0; continue; end
            Ac = getArea(c,i);
            if Ac == 0; continue; end
            r_a = Aa/min(Ab,Ac);
            if r_a < threshold; scores(1) = scores(1) + 1; end
        end
    end
    
    if canCloseB
        for i = 1:Frame.NTheta-1
            Aa = getArea(a,i);
            if Aa == 0; continue; end
            Ab = getArea(b,i);
            if Ab == 0; continue; end
            Ac = getArea(c,i);
            if Ac == 0; continue; end
            r_b = Ab/min(Aa,Ac);
            if r_b < threshold; scores(2) = scores(2) + 1; end
        end
    end
    
    if canCloseC
        for i = 1:Frame.NTheta-1
            Aa = getArea(a,i);
            if Aa == 0; continue; end
            Ab = getArea(b,i);
            if Ab == 0; continue; end
            Ac = getArea(c,i);
            if Ac == 0; continue; end
            r_c = Ac/min(Aa,Ab);
            if r_c < threshold; scores(3) = scores(3) + 1; end
        end
    end
end

