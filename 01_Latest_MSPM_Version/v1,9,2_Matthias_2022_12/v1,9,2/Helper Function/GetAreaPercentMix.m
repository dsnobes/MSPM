function [ PercArea ] = GetAreaPercentMix(r, x, y1, y2, d )
%GETAREAPERCENTMIX Summary of this function goes here
%   Calculates the percentage that an circle at x of diameter d covers a
%   strip between y1 and y2
Total_Area = 2*pi*r*(y2-y1);
c_y1 = max([x-d/2 y1]);
c_y2 = min([x+d/2 y2]);
if c_y1 >= c_y2; PercArea = 0; return; end
N = max([2 floor(100*(c_y2-c_y1)/d)]);
y = linspace(c_y1,c_y2,N);
y = (y(1:end-1)+y(2:end))/2;
dy = (c_y2-c_y1)/(N-1);
area = 0;
for yi = y
  area = area + 2*dy*min([r sqrt((d/2)^2-(x-yi)^2)]);
end
PercArea = area/Total_Area;
end

