function [oXData,oYData] = DistortPositionVectors(iXData,iYData,shift,rotate)
  if nargin > 3 && all(size(rotate) == [2 2])
    oXData = rotate(1,1)*iXData + rotate(1,2)*iYData;
    oYData = rotate(2,1)*iXData + rotate(2,2)*iYData;
    if length(shift) == 2
      oXData = shift(1) + oXData;
      oYData = shift(2) + oYData;
    end
    return;
  end
  if nargin > 2 && length(shift) == 2
    oXData = shift(1) + iXData;
    oYData = shift(2) + iYData;
  end
end

