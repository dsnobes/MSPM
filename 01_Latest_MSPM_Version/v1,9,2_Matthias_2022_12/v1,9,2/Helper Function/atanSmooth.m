function [input] = atanSmooth(input)
input = atan(input);
for i = 2:length(input)
  if abs(input(i-1) - input(i)) > 3
    input(i:end) = input(i:end) + sign(input(i-1)-input(i))*pi;
  end
end
end