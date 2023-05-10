function [ pos ] = e0_n2_r2( Nang, Phase )
  Phase = Phase + pi;
  e = 0;
  n = 2;
  con_cr_ratio = 2;
  TransferPhase = 0;
  pos = Ellipsoidal(Nang,Phase,e,n,con_cr_ratio,TransferPhase);
end

