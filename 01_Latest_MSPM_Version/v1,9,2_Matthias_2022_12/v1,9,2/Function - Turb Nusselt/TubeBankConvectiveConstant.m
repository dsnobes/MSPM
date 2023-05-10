function [ Ch ] = TubeBankConvectiveConstant(Xt,Xl,do,Nr)
%TUBEBANKNUSSELT Nst*NPr^0.667 = [Ch]*NRe^-0.4
Xt_Xl = Xt/Xl;
Xt_do = Xt/do;
a = -0.1548*Xt_Xl+0.0591;
b = 0.5437*Xt_Xl-0.0373;
c = -1.9244*Xt_Xl^3+0.68562*Xt_Xl^2-7.9841*Xt_Xl+2.772;
Ch = a*Xt_do^2 + b*Xt_do + c;
if nargin > 3
  Ch = Ch*(1-1/(Nr^1.112+0.918353));
end
end

