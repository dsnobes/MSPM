function [Var] = getFirstDer(Pos)
  Var(length(Pos)) = (Pos(2)-Pos(end-1));
  Var(2:end-1) = (Pos(3:end)-Pos(1:end-2));
  Var(1) = Var(end);
  denominator = (4*pi/(Frame.NTheta-1));
  Var = (Var/denominator)';
end

