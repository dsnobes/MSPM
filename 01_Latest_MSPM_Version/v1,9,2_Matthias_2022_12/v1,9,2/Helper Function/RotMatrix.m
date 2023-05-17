function [ R ] = RotMatrix( THETA )
    %ROTMATRIX Defines the rotation matrix for a vector by the angle THETA
    R = [cos(THETA) -sin(THETA); sin(THETA) cos(THETA)];
end

