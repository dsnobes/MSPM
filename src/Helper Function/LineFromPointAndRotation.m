function [A, B, C] = LineFromPointAndRotation(x0, y0, rotationAngle)
    % Calculate the direction cosines of the rotated line
    cosTheta = cos(rotationAngle);
    sinTheta = sin(rotationAngle);
    
    % Calculate the coefficients A, B, and C
    A = cosTheta;
    B = sinTheta;
    C = -(A * x0 + B * y0);
end