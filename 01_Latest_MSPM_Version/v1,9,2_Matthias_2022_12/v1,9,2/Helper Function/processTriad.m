function [ ] = processTriad( Triad, derefinement_factor, index_to_close)
target = Triad(index_to_close);
others = Triad(Triad ~= target);
modification = sqrt(derefinement_factor);
threshold = 0.1/modification;
count = Frame.NTheta-1;

canCloseTarget = canClose(target);

if ~canCloseTarget; return; end

for i = 1:Frame.NTheta-1
  At = getArea(target,i);
  if At == 0; count = count - 1; continue; end
  A1 = getArea(others(1),i);
  if A1 == 0; count = count - 1; continue; end
  A2 = getArea(others(2),i);
  if A2 == 0; count = count - 1; continue; end
  r = At/min(A1,A2);
  if r < threshold
    setArea(target,i,0);
  else
    count = count - 1;
  end
end

fprintf(['Edited ' num2str(count) ' Increments\n']);
end

