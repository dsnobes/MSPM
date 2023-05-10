function [ pos ] = box_wave( Nang, Phase )
  if nargin == 0
    Nang = 200;
    Phase = 0;
  end
  Phase = Phase + pi/2;
  e = 0.8;
  n = 2;
  con_cr_ratio = 2;
  TransferPhase = pi/2;
  pos = Ellipsoidal(Nang,Phase,e,n,con_cr_ratio,TransferPhase);


plot(1:Nang, pos)


