ENV = sum(abs(statistics.To_Environment));
SOR = sum(abs(statistics.To_Source));
SIK = sum(abs(statistics.To_Sink));
FLO = sum(abs(statistics.Flow_Loss));

if isfield(statistics,'ExergyLossShuttle')
  EXShuttle = sum(abs(statistics.ExergyLossShuttle));
end
if isfield(statistics,'ExergyLossStatic')
  EXStatic = sum(abs(statistics.ExergyLossStatic));
end
if isfield(statistics,'Power')
  POW = mean(statistics.Power);
end