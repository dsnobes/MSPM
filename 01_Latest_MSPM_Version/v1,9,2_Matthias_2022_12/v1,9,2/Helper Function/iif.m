function out = iif(cond,a,b)
%IIF implements a ternary operator

% pre-assign out
out = repmat(b,size(cond));

out(cond) = a;

