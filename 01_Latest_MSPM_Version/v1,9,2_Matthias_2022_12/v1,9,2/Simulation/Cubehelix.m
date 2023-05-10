function [C] = Cubehelix(N)
%CUBEHELIX Returns the colormap corresponding to the cubehelix colormap by
% Dave Green
% Described in:
% ... Green, D. A., 2011, `A colour scheme for the display of astronomical 
% ... intensity images', Bulletin of the Astronomical Society of India, 39,
% ... 289. (2011BASI...39..289G at ADS.)
% Chosen because it is readeable in both color and gray-scale. The
% following is a fit to the colormap for simplicity
C = zeros(N,3);
inc = linspace(0,1,N);
for i = 1:N
    C(i,1) = inc(i) + inc(i)*(1-inc(i))*(-0.89364167360231)*...
        sin(-9.42709701246915*inc(i)-2.17665661962626);
    C(i,2) = inc(i) + inc(i)*(1-inc(i))*0.476808544884337*...
        sin(9.41893653572546*inc(i)+4.92713139814227);
    C(i,3) = inc(i) + inc(i)*(1-inc(i))*0.986358536351536*...
        sin(-9.43408675851738*inc(i)+2.62243462096891);
end
C(C>1) = 1;
C(C<0) = 0;
end

