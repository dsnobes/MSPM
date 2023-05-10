function [c] = getCenterOfOverlapRegion(min1,min2,max1,max2)
if isscalar(min1)
  if isscalar(min2)
    temp1 = max(min1,min2);
  else
    temp1 = max([min1(ones(size(min2))); min2]);
  end
else
  if isscalar(min2)
    temp1 = max([min2(ones(size(min1))); min1]);
  else
    temp1 = max([min1; min2]);
  end
end
if isscalar(max1)
  if isscalar(max2)
    temp2 = min(max1,max2);
  else
    temp2 = min([max1(ones(size(max2))); max2]);
  end
else
  if isscalar(max2)
    temp2 = min([max2(ones(size(max1))); max1]);
  else
    temp2 = min([max1; max2]);
  end
end
c = (temp1 + temp2)/2;
end

