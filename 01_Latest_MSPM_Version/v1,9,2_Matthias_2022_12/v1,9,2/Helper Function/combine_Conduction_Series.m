function [ U ] = combine_Conduction_Series( U1, U2 )
if U1 == 0
  U = U2;
else
  if U2 == 0
    U = 0;
  else
    U = 1/(1/U1+1/U2);
  end
end

