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

classdef CustomMinorLoss < handle
    % models some loss coefficient between some
    % two bodies.
    % contains two bodies and the loss coefficient in each
    % direction between them

    properties
        name string;
        Body1 Body;
        Body2 Body;
        K12 double;
        K21 double;
    end

    methods
        function this = CustomMinorLoss(B1,B2)
            answers = {'untitled', '1','1'};
            firstround = true;
            while firstround || ~isStrNumeric(answers{2}) || ~isStrNumeric(answers{3})
                if firstround; firstround = false;
                else; msgbox('Numeric Values only'); end
                answers = inputdlg( ...
                    {'Descriptive Name', ...
                    'Loss Coefficient 1 - 2', ...
                    'Loss Coefficient 2 - 1'}, ...
                    ['Define a minor loss from: ' B1.name ...
                    ' to ' B2.name '.'],[1 100], ...
                    answers);
                if isempty(answers)
                    this.K12 = 0;
                    this.K21 = 0;
                    return;
                end
            end
            this.Body1 = B1;
            this.Body2 = B2;
            this.name = answers{1};
            this.K12 = str2double(answers{2});
            this.K21 = str2double(answers{3});
        end

        function isit = isValid(this)
            isit = ~isempty(this.Body1) && ...
                ~isempty(this.Body2) && ...
                isa(this.Body1,'Body') && ...
                isa(this.Body2,'Body') && (this.K12 > 0 || this.K21 > 0);
        end
    end
end

