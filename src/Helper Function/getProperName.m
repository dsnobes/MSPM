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

% Displays a popup box to get a discriptive name for an object
function [ answer ] = getProperName( ObjectName, def)
    % Set answer to an invalid character to start the while loop
    answer{1} = '/';
    
    % Used to not show the illegal character dialog on the first loop
    trial = 0;
    % Check if there are illegal characters
    while regexp(answer{1},'[/\*:?"<>|]', 'once')
        % If there are show an error message and have the user try again
        if trial > 0
            msgbox(['You cannot have any of the following ' ...
                'characters [/\*:?"<>|] in a file name']);
        end
        trial = trial + 1;
        % Ask the user to enter a descriptive name
        if nargin == 2
            answer = inputdlg(['Enter a descriptive name for the ' ObjectName],...
                'Name(filename,title,etc...):',[1 200], def);
        else
            answer = inputdlg(['Enter a descriptive name for the ' ObjectName],...
                'Name(filename,title,etc...):',[1 200]);
        end
        
        % If the user does not enter a value, return an empty char array
        if isempty(answer) || isempty(answer{1})
            answer = '';
            return;
        end
    end
    % Remove the input text from the array and return as char array
    answer = answer{1};
end

