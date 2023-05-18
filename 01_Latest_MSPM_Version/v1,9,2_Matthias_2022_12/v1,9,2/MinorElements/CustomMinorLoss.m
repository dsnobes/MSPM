classdef CustomMinorLoss < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

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

