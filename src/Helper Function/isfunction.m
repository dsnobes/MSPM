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

function [TF, ID] = isfunction(FUN)
    % ISFUNCTION - true for valid matlab functions
    %
    %   TF = ISFUNCTION(FUN) returns 1 if FUN is a valid matlab function, and 0
    %   otherwise. Matlab functions can be strings or function handles.
    %
    %   [TF, ID] = ISFUNCTION(FUN) also returns an identier ID. ID can take the
    %   following values:
    %      1  : FUN is a function string
    %      2  : FUN is a function handle
    %      0  : FUN is not a function, but no further specification
    %     -1  : FUN is not a function but a script
    %     -2  : FUN is not a valid function m-file (e.g., a matfile)
    %     -3  : FUN does not exist (as a function)
    %     -4  : FUN is not a function but something else (a variable)
    %
    %   FUN can be a cell array, TF and ID will then be arrays, the same size
    %   as FUN
    %
    %   Examples:
    %     tf = isfunction('lookfor')
    %        % tf = 1
    %     [tf, id] = isfunction({@isfunction, 'sin','qrqtwrxxy',1:4, @clown.jpg})
    %        % -> tf = [ 1  1  0  0  0 ]
    %        %    id = [ 2  1 -2 -4 -3 ]
    %
    %   See also FUNCTION, SCRIPT, EXIST,
    %            ISA, WHICH, NARGIN, FUNCTION_HANDLE
    
    % version 3.2 (apr 2018)
    % (c) Jos van der Geest
    % Matlab File Exchange Author ID: 10584
    % email: samelinoa@gmail.com
    %
    % History:
    % 1.0 (dec 2011) created for strings only
    % 2.0 (apr 2013) accepts cell arrays
    % 3.0 (feb 2014) implemented identier based on catched error
    % 3.1 (feb 2014) added lots of help and documentation, inspired to post on
    %                FEX by a recent Question/Answer thread
    % 3.2 (apr 2018) spell check and contact info
    
    if ~iscell(FUN)
        % we use cellfun, so convert to cells
        FUN = {FUN} ;
    end
    ID = cellfun(@local_isfunction,FUN) ; % get the identifier for each "function"
    TF = ID > 0 ; % valid matlab functions have a positive identifier
end

% = = = = = = = = = = = = = = = = = = = = =

function ID = local_isfunction(FUNNAME)
    try
        nargin(FUNNAME) ; % nargin errors when FUNNAME is not a function
        ID = 1  + isa(FUNNAME, 'function_handle') ; % 1 for m-file, 2 for handle
    catch ME
        % catch the error of nargin
        switch (ME.identifier)
            case 'MATLAB:nargin:isScript'
                ID = -1 ; % script
            case 'MATLAB:narginout:notValidMfile'
                ID = -2 ; % probably another type of file, or it does not exist
            case 'MATLAB:narginout:functionDoesnotExist'
                ID = -3 ; % probably a handle, but not to a function
            case 'MATLAB:narginout:BadInput'
                ID = -4 ; % probably a variable or an array
            otherwise
                ID = 0 ; % unknown cause for error
        end
    end
end