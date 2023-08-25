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

function [ ] = processTriad( Triad, derefinement_factor, index_to_close)
    target = Triad(index_to_close);
    others = Triad(Triad ~= target);
    modification = sqrt(derefinement_factor);
    threshold = 0.1/modification;
    count = Frame.NTheta-1;
    
    canCloseTarget = canClose(target);
    
    if ~canCloseTarget; return; end
    
    for i = 1:Frame.NTheta-1
        At = getArea(target,i);
        if At == 0; count = count - 1; continue; end
        A1 = getArea(others(1),i);
        if A1 == 0; count = count - 1; continue; end
        A2 = getArea(others(2),i);
        if A2 == 0; count = count - 1; continue; end
        r = At/min(A1,A2);
        if r < threshold
            setArea(target,i,0);
        else
            count = count - 1;
        end
    end
    
    fprintf(['Edited ' num2str(count) ' Increments\n']);
end

