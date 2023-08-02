function [newarray] = CustExpandArray(array)
    newarray = zeros(size(array) + [2 2]);
    % Identical core of the array
    newarray(2:(1+size(array,1)),2:(1+size(array,2))) = array(:,:);
    % Four Edges
    newarray(1,2:(1+size(array,2))) = array(1,:);
    newarray(end,2:(1+size(array,2))) = array(end,:);
    newarray(2:(1+size(array,1)),1) = array(:,1);
    newarray(2:(1+size(array,1)),end) = array(:,end);
    % Four Corners
    newarray(1,1) = newarray(1,2);
    newarray(1,end) = newarray(1,end-1);
    newarray(end,1) = newarray(end,2);
    newarray(end,end) = newarray(end,end-1);
end

