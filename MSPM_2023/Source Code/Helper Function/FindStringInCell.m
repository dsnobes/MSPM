function [index] = FindStringInCell(iCell,iString)
    index = 0;
    for i = 1:length(iCell)
        if strcmp(iCell{i},iString)
            index = i;
            break;
        end
    end
end

