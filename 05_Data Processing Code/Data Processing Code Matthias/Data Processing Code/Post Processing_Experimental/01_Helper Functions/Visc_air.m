function mu = Visc_air(T)
% https://www.engineeringtoolbox.com/air-absolute-kinematic-viscosity-d_601.html#Units

Ts = [5 10 15 20 25 30 40 50 60 80 100 125 150];
mus = [1.74 1.764 1.789 1.813 1.837 1.86 1.907 1.953 1.999 2.088 2.174 2.279 2.38] *10^-5;

mu = interp1(Ts, mus, T);

