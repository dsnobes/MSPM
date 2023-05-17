function Output = AddRow(Input,N)
    Output = Input;
    for i = size(Output,1)+1:N+size(Output,1)
        for j = 1:size(Output,2)
            Output{i,j} = '';
        end
    end
end

