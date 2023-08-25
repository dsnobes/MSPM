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

function [ newListObjs ] = ReadCode( Code, ListObjs )
    i = 1;
    num = 0;
    newListObjs = ListObj.empty;
    close = false;
    while i <= length(Code)
        k = i+1;
        while k <= length(Code) ...
                && Code(k) ~= '[' ...
                && Code(k) ~= ']' ...
                && Code(k) ~= ','
            k = k + 1;
        end
        onum = num;
        num = int16(str2double(Code(i:k-1)));
        if num ~= onum + 1
            if length(ListObjs) >= num-1
                newListObjs = [newListObjs; ListObjs(onum+1:num-1)];
            else
                return;
            end
        end
        if num > length(ListObjs) || num < 1
            return;
        end
        Internals = ListObjs(num).getObjs(true);
        newListObjs = [newListObjs; Internals(1)];
        if length(Internals) > 1
            if k <= length(Code)
                switch Code(k)
                    case '['
                        % Enter Recursion on Contents with contents of element "num"
                        i = k + 1;
                        lvlcount = -1;
                        while i <= length(Code) && lvlcount < 0
                            switch Code(i)
                                case '['; lvlcount = lvlcount - 1;
                                case ']'; lvlcount = lvlcount + 1;
                            end
                            i = i + 1;
                        end
                        if i < length(Code)
                            if Code(i) == ','
                                i = i + 1;
                                newCode = Code(k+1:i-3);
                            else
                                newCode = Code(k+1:i-2);
                            end
                        else
                            newCode = Code(k+1:i-2);
                        end
                        newListObjs = [newListObjs; ReadCode(newCode,Internals(2:end))];
                    case ']'
                        % End of Recursion Layer
                        newListObjs = [newListObjs; Internals(2:end)];
                        return;
                    case (',')
                        % New expansion, add elements between expanded elements
                        newListObjs = [newListObjs; Internals(2:end)];
                end
            else
                newListObjs = [newListObjs; Internals(2:end)];
            end
        end
        i = max(i,k);
    end
    if num < length(ListObjs)
        newListObjs = [newListObjs; ListObjs(num+1:end)];
    end
end

