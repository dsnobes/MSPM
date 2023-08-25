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


function startup()
    %{
    adds the necessary subdirectories of MSPM to MATLAB's PATH
    so that functions and code files can be called
    %}

    % Load in the paramaters file
if isfile('Config Files/parameters.mat')
    load('Config Files/parameters.mat', 'parameters')
    
    
    % Check if the save locations are valid and add location to path
    if isfolder(parameters.savelocation)
        addpath(genpath(parameters.savelocation));
    end
    
    if isfolder(parameters.runlocation)
        addpath(genpath(parameters.runlocation));
    end
    
end

% Add the files to the path
addpath(...
    genpath('src'),...
    genpath('Test_Running'),...
    genpath('Config Files'),...
    genpath('Saved Files')...
    );
end