function [pos] = Ellipsoidal(Nang,Phase,e,n,con_cr_ratio,TransferPhase)
  ang = mod(linspace(0,2*pi,Nang),2*pi);
  C = (sqrt(1+(n^2-1)*(1-e^2)) + e)/(n*(1-e));
  % Pass ang through the transfer function
  ang = atanSmooth(C*tan(ang)) + TransferPhase;
  l_cr = 0.5;
  l_con = l_cr*con_cr_ratio;
  ang2 = asin((-l_cr*sin(ang))/l_con);
  pos = l_con*(cos(ang2) - 1) + l_cr*(cos(ang) + 1);
  pos(1:end-1) = shiftVector(pos(1:end-1),Phase);
  pos(end) = pos(1);
end

