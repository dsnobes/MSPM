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

function [NumberOutput] = SymbolicMath(StringInput)
    % Initialize
    StringInput(StringInput==' ') = [];
    Intermediates = zeros(3,1);
    collapsed = false(size(StringInput));
    count = 1;
    
    % Brackets & Basic Numbers
    level = 0; basic_number_start = 0;
    for i = 1:length(StringInput)
        if strcmp(StringInput(i),'(')
            if level == 0
                start = i;
            end
            level = level + 1;
        elseif strcmp(StringInput(i),')')
            level = level - 1;
            if level == 0
                Intermediates(1,count) = start;
                Intermediates(2,count) = i;
                Intermediates(3,count) = SymbolicMath(StringInput((start+1):(i-1)));
                collapsed(start:i) = true;
                count = count + 1;
            end
        end
        if level == 0 && ismember(StringInput(i), '0123456789.eE')
            if basic_number_start == 0
                basic_number_start = i;
            end
            if i == length(StringInput)
                Intermediates(1,count) = basic_number_start;
                Intermediates(2,count) = i;
                Intermediates(3,count) = ...
                    str2double(StringInput(basic_number_start:i));
                collapsed(basic_number_start:i) = true;
                basic_number_start = 0;
                count = count + 1;
            end
        else
            if basic_number_start ~= 0
                Intermediates(1,count) = basic_number_start;
                Intermediates(2,count) = i - 1;
                Intermediates(3,count) = ...
                    str2double(StringInput(basic_number_start:(i-1)));
                collapsed(basic_number_start:(i-1)) = true;
                basic_number_start = 0;
                count = count + 1;
            end
        end
    end
    if level ~= 0
        NumberOutput = NaN;
        return;
    end
    
    % Exponents
    if strcmp(StringInput(1),'^') || strcmp(StringInput(end),'^')
        NumberOutput = NaN;
        return;
    end
    for i = 2:(length(StringInput)-1)
        if ~collapsed(i)
            if strcmp(StringInput(i),'^')
                % Find the intermediate before and after and merge them
                before = 0;
                after = 0;
                for ind = 1:(count-1)
                    if Intermediates(2,ind) == i-1
                        before = ind;
                    elseif Intermediates(1,ind) == i+1
                        after = ind;
                    end
                end
                if before > 0 && after > 0
                    Intermediates(3,before) = Intermediates(3,before) ^ ...
                        Intermediates(3,after);
                    Intermediates(2,before) = Intermediates(2,after);
                    Intermediates(1,after) = -1;
                    Intermediates(2,after) = -1;
                else
                    NumberOutput = NaN;
                    return;
                end
                collapsed(i) = true;
            end
        end
    end
    
    % Division
    if strcmp(StringInput(1),'/') || strcmp(StringInput(end),'/')
        NumberOutput = NaN;
        return;
    end
    for i = 2:(length(StringInput)-1)
        if ~collapsed(i)
            if strcmp(StringInput(i),'/')
                % Find the intermediate before and after and merge them
                before = 0;
                after = 0;
                for ind = 1:(count-1)
                    if Intermediates(2,ind) == i-1
                        before = ind;
                    elseif Intermediates(1,ind) == i+1
                        after = ind;
                    end
                end
                if before > 0 && after > 0
                    Intermediates(3,before) = Intermediates(3,before) / ...
                        Intermediates(3,after);
                    Intermediates(2,before) = Intermediates(2,after);
                    Intermediates(1,after) = -1;
                    Intermediates(2,after) = -1;
                else
                    NumberOutput = NaN;
                    return;
                end
                collapsed(i) = true;
            end
        end
    end
    
    % Multiplication
    if strcmp(StringInput(1),'*') || strcmp(StringInput(end),'*')
        NumberOutput = NaN;
        return;
    end
    for i = 2:(length(StringInput)-1)
        if ~collapsed(i)
            if strcmp(StringInput(i),'*')
                % Find the intermediate before and after and merge them
                before = 0;
                after = 0;
                for ind = 1:(count-1)
                    if Intermediates(2,ind) == i-1
                        before = ind;
                    elseif Intermediates(1,ind) == i+1
                        after = ind;
                    end
                end
                if before > 0 && after > 0
                    Intermediates(3,before) = Intermediates(3,before) * ...
                        Intermediates(3,after);
                    Intermediates(2,before) = Intermediates(2,after);
                    Intermediates(1,after) = -1;
                    Intermediates(2,after) = -1;
                else
                    NumberOutput = NaN;
                    return;
                end
                collapsed(i) = true;
            end
        end
    end
    
    % Addition
    if strcmp(StringInput(end),'+')
        NumberOutput = NaN;
        return;
    end
    for i = 1:(length(StringInput)-1)
        if ~collapsed(i)
            if strcmp(StringInput(i),'+')
                % Find the intermediate before and after and merge them
                before = 0;
                after = 0;
                for ind = 1:(count-1)
                    if Intermediates(2,ind) == i-1
                        before = ind;
                    elseif Intermediates(1,ind) == i+1
                        after = ind;
                    end
                end
                if after > 0
                    if before > 0
                        Intermediates(3,before) = Intermediates(3,before) + ...
                            Intermediates(3,after);
                        Intermediates(2,before) = Intermediates(2,after);
                        Intermediates(1,after) = -1;
                        Intermediates(2,after) = -1;
                    else
                        % Intermediates(3,after) = Intermediates(3,after);
                        Intermediates(1,after) = i;
                    end
                else
                    NumberOutput = NaN;
                    return;
                end
                collapsed(i) = true;
            end
        end
    end
    
    % Subtraction
    if strcmp(StringInput(end),'-')
        NumberOutput = NaN;
        return;
    end
    for i = 1:(length(StringInput)-1)
        if ~collapsed(i)
            if strcmp(StringInput(i),'-')
                % Find the intermediate before and after and merge them
                before = 0;
                after = 0;
                for ind = 1:(count-1)
                    if Intermediates(2,ind) == i-1
                        before = ind;
                    elseif Intermediates(1,ind) == i+1
                        after = ind;
                    end
                end
                if after > 0
                    if before > 0
                        Intermediates(3,before) = Intermediates(3,before) - Intermediates(3,after);
                        Intermediates(2,before) = Intermediates(2,after);
                        Intermediates(1,after) = -1;
                        Intermediates(2,after) = -1;
                    else
                        Intermediates(3,after) = - Intermediates(3,after);
                        Intermediates(1,after) = i;
                    end
                else
                    NumberOutput = NaN;
                    return;
                end
                collapsed(i) = true;
            end
        end
    end
    
    % Assess conclusion
    if ~all(collapsed)
        NumberOutput = NaN;
        return;
    end
    for i = 1:count-1
        if Intermediates(1,i) ~= -1
            NumberOutput = Intermediates(3,i);
            return;
        end
    end
end

