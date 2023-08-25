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

function [ Code ] = MakeCode( ListObjs, ClickedIndex)
    Code = '';
    lvl = 0;
    n = ones(1,16); % Current Index on Level
    i = 1;
    while i <= length(ListObjs)
        % Handle Step downs and step ups
        if ListObjs(i).lvl > lvl
            % Step Down
            % ... Parent        n(lvl+1)
            % ... ... Child     n(lvl+2) = 1
            if isempty(Code); Code = [num2str(int8(n(lvl+1)-1)) '['];
            elseif Code(end) == '['; Code = [Code num2str(int8(n(lvl+1)-1)) '['];
            else; Code = [Code ',' num2str(int8(n(lvl+1)-1)) '['];
            end
            lvl = lvl + 1;
            % Iterate the "Child" node
            n(lvl+1) = 2;
        elseif ListObjs(i).lvl < lvl
            % Step Up
            % ... ... Child    n(lvl)
            % ... Next-Parent  n(lvl+1)
            while lvl > ListObjs(i).lvl
                Code = [Code ']'];
                n(lvl+1) = 1;
                lvl = lvl - 1;
            end
            % Iterate the "Next-Parent" node
            n(lvl+1) = n(lvl+1) + 1;
        else
            % Iterate the node
            n(lvl+1) = n(lvl+1) + 1;
        end
    
        % Handle the click
        if nargin == 2 && ClickedIndex == i
            if ListObjs(i).isExpandable()
                if i < length(ListObjs)
                    if ListObjs(i+1).lvl > ListObjs(i).lvl
                        % This one is already expanded, collapse
                        i = i + 1;
                        while i <= length(ListObjs) && ListObjs(i).lvl > lvl
                            i = i + 1;
                        end
                        % Iterate the level forward, we are skipping to another node
                        n(lvl+1) = n(lvl+1) + 1;
                    else
                        % This one should be expanded
                        if isempty(Code); Code = num2str(int8(n(lvl+1)-1));
                        elseif Code(end) == '['; Code = [Code num2str(int8(n(lvl+1)-1))];
                        else; Code = [Code ',' num2str(int8(n(lvl+1)-1))];
                        end
                    end
                else
                    % This one should be expanded
                    if isempty(Code); Code = num2str(int8(n(lvl+1)-1));
                    elseif Code(end) == '['; Code = [Code num2str(int8(n(lvl+1)-1))];
                    else; Code = [Code ',' num2str(int8(n(lvl+1)-1))];
                    end
                end
            end
        end
        i = i + 1;
    end
    while lvl > 0
        Code = [Code ']'];
        lvl = lvl - 1;
    end
    Code = strrep(Code,'[]','');
    if ~isempty(Code) && Code(end) == '['
        Code(end) = '';
    end
end

