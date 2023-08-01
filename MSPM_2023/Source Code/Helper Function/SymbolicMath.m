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

