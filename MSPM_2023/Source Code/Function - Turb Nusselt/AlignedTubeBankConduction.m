function [ Const, Exponent ] = AlignedTubeBankConduction( Xt,Xl,do )
    %ALIGNEDTUBEBANKCONDUCTION Const * Re ^ Exponent = Nst*Npr^(2/3)
    Xt_Xl = Xt/Xl;
    Xt_do = Xt/do;
    Xl_do = Xl/do;
    Const = (0.118*Xt_Xl+0.252);
    Exponent = (-0.0125*Xt_Xl-0.433*Xl+0.0765*Xt-0.0892);
end

