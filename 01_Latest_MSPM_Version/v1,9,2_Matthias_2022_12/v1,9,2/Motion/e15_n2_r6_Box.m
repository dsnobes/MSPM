function [ pos ] = e15_n2_r6_Box( Nang, Phase )
    if nargin == 0
        Nang = 200;
        Phase = 0;
    end
    Phase = Phase + pi/2;
    e = 1/5;
    n = 2;
    con_cr_ratio = 6;
    TransferPhase = pi/2;
    pos = Ellipsoidal(Nang,Phase,e,n,con_cr_ratio,TransferPhase);
end

