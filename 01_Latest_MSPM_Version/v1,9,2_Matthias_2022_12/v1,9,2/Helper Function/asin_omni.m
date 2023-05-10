function [output] = asin_omni(input)
intermittent = zeros(size(input));
for i = 1:length(input)
  intermittent(i) = asin(input(i));
end
count = 0;
output = zeros(size(input));
i = 2;
output(1) = intermittent(1);
d = diff(intermittent);
while i < length(input)+1 && count < 100
  while i < length(input)+1 && d(i-1) >= 0
    output(i) = intermittent(i) + count*pi;
    i = i + 1;
  end
  count = count + 1;
  while i < length(input)+1 && d(i-1) <= 0
    output(i) = count*pi - intermittent(i);
    i = i + 1;
  end
  count = count + 1;
end
end

