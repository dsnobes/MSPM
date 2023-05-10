function [ Input ] = CollapseVector( Input )
  if all(Input(1) - 1e-8 < Input) && all(Input(1) + 1e-8 > Input)
    Input = Input(1);
  end
end

