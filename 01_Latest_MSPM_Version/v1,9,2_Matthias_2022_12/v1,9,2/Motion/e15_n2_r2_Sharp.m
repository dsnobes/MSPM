function [ pos ] = e15_n2_r2_Sharp( Nang, Phase )
    Phase = Phase + pi;
    e = 1/5;
    n = 2;
    con_cr_ratio = 2;
    TransferPhase = 0;
    pos = Ellipsoidal(Nang,Phase,e,n,con_cr_ratio,TransferPhase);
end

