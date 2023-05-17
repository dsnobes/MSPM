function [isit] = isStrNumeric(str)
    %ISSTRNUMERIC Summary of this function goes here
    %   Detailed explanation goes here
    isit = all(ismember(str, '0123456789+-.eEdD'));
end

