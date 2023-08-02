function [ vector ] = shiftVector( vector, Phase )
    N = length(vector);
    temp = N*(Phase/(2*pi));
    n1 = floor(temp);
    frac = temp-n1;
    n2 = ceil(temp);
    v1 = circshift(vector,-n1);
    v2 = circshift(vector,-n2);
    vector = (1-frac)*v1 + frac*v2;
end
%
% function array = shiftv(array,n)
%   while n > length(array); n = n - length(array); end
%   while n < 1; n = n + length(array); end
%   if n == length(array); return; end
%
%   % n is a number that lies between 1 and length(array)
%   % ... Shift elements towards the start
%   temp(end-n+1:end) = array(1:n);
%   temp(1:end-n) = array(end-n+1:end);
%   array = temp;
% end

