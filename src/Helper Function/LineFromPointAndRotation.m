function [A, B, C] = LineFromPointAndRotation(x0, y0, rotationAngle)
    % Translate the point to the origin
    translated_x0 = x0 - x0;
    translated_y0 = y0 - y0;
    
    % Calculate the direction cosines of the rotated line
    cosTheta = cos(rotationAngle);
    sinTheta = sin(rotationAngle);
    
    % Calculate the coefficients A, B, and C for the rotated line
    A_rotated = sinTheta;
    B_rotated = -cosTheta;
    C_rotated = -(A_rotated * translated_x0 + B_rotated * translated_y0);
    
    % Translate the rotated line equation back to the original position
    A = A_rotated;
    B = B_rotated;
    C = C_rotated - A_rotated * x0 - B_rotated * y0;
end