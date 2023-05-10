function [Var] = getSecondDer(Pos)
  Var(length(Pos)) = (Pos(2)-2*Pos(end)+Pos(end-1));
  Var(2:end-1) = (Pos(3:end)-2*Pos(2:end-1)+Pos(1:end-2));
  Var(1) = Var(end);
  denominator = ((2*pi)/(Frame.NTheta-1))^2;
  Var = (Var/denominator)';
end

