function [Work] = PowerFromPV(P,V)
    Pavg = (P(1:end-1)+P(2:end));
    dVol = (V(2:end)-V(1:end-1));
    Work = 0.5*sum(Pavg.*dVol);
end

