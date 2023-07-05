function [ Cf ] = TubeBankFriction( Xt,Xl,do )
    %TUBEBANKFRICTION 300 -> Re -> 15,000
    %   f = Cf*Re^-0.18
    Xt_Xl = Xt/Xl;
    Xl_do = Xl/do;
    a = -0.108*Xt_Xl^2+0.3137*Xt_Xl-0.2335;
    b = 0.7298*Xt_Xl^2-1.296*Xt_Xl+1.0343;
    c = -0.2129*Xt_Xl^2+0.5613*Xt_Xl-0.7471;
    Cf = a*Xl_do^2+b*Xl_do+c;
end

