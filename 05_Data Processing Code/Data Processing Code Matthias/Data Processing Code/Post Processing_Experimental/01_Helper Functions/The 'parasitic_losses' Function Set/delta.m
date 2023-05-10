function [ DELTA ] = delta( Vector)
% This function calculates the wrapping derivative of each element in the
% Array (assumes cyclic)
%   Takes an vector, Outputs an vector of the same size

if (isvector(Vector))
    DELTA = Vector*0;
    DELTA(2:end-1) = (Vector(3:end)-Vector(1:end-2));
    DELTA(1) = (Vector(2)-Vector(end));
    DELTA(end) = (Vector(1)-Vector(end-1));
    DELTA = DELTA/2;
else
    % Array is not a vector
    fprintf('Provided number to delta function is not a vector');
    
end
end

