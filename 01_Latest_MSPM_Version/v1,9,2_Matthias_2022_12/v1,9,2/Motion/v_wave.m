function [ pos ] = v_wave( Nang, Phase )
Phase = Phase + pi/2;
%r = 5;
%L = sqrt((1-2*r)^2+(Nang-1)^2);
%theta = r*sin(asin((Nang-1)/L)-asin(2*r/L));
%d = r*sin(theta);
%offset = r*cos(theta);
pos = zeros(1,Nang);
%%
for i = 1:Nang
  x = mod(i-1 + (-Phase)/(2*pi)*(Nang-1),Nang-1);
  if x < 0.5*(Nang-1)
    % Within First Top Circle
    pos(i) = 1 - 2*x/(Nang-1);
  else
    pos(i) = 2*(x-(Nang-1))/(Nang-1) + 1;
  end
  %{
  if x < 0.5*(Nang-1)-offset
    % Within Downward Diagonal
    y2 = 0 - d + r;
    y1 = 1 + d - r;
    x2 = 0.5*(Nang-1);
    pos(i) = x*(y2-y1)/x2 + y1;
  elseif x < 0.5*(Nang-1)+offset
    % Within Bottom Circle
    x = x - 0.5*(Nang-1);
    pos(i) = sqrt(r^2 - x^2) + r;
  elseif x < (Nang-1)-offset
    % Within Upward Diagonal
    x = x - 0.5*(Nang-1);
    y2 = 1 + d - r;
    y1 = 0 - d + r;
    x2 = 0.5*(Nang-1);
    pos(i) = x*(y2-y1)/x2 + y1;
  else
    % Within Next Top Cicle
    x = x - (Nang-1);
    pos(i) = sqrt(r^2 - x^2) + 1 - r;
  end
  %}
end
%%
ends = zeros(1,4);
for i = 1:100
  ends(1:2) = pos(1:2);
  ends(3:4) = pos(end-1:end);
  pos(2:end-1) = (pos(1:end-2) + pos(3:end))/2;
  pos(1) = (ends(2) + ends(4))/2;
  pos(end) = (ends(1) + ends(3))/2;
end
pos = pos - min(pos);
pos = pos / max(pos);
end

