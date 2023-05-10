function [ pos ] = e15_n2_r2_Box( Nang, Phase )
  if nargin == 0
    Nang = 200;
    Phase = 0;
  end
  Phase = Phase + pi/2;
  e = 1/4;
  n = 2;
  con_cr_ratio = 2;
  TransferPhase = pi/2;
  pos = Ellipsoidal(Nang,Phase,e,n,con_cr_ratio,TransferPhase);
  
  plot(1:Nang, pos)
  
  legend('Dwelled','Sine','Sawtooth')
  xlabel('Crank Angle [/circ]')
  ylabel('Position')
  xlim([0,360])
  
  hold on
  pos_sin=(-sind(1:Nang)+1)./2;
  
  plot(1:Nang, pos_sin)
  
  pos_sin=pos_sin-0.5;
   pos_sin=-pos_sin;
end

