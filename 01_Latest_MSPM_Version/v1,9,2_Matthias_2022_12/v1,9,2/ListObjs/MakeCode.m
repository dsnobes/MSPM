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

