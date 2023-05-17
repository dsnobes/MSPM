AVG = 0;
COUNT = 0;
max = data.IndependentVariable(end);
for i = 1:length(data.IndependentVariable)
    if (data.IndependentVariable(i)>=max-1)
        AVG = AVG + data.DependentVariable(i);
        COUNT = COUNT + 1;
    end
end
AVG = AVG / COUNT;
NAME = data.Name;