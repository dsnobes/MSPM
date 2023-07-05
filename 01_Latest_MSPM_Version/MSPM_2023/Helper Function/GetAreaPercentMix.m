function [ PercArea ] = GetAreaPercentMix(r, x, y1, y2, d )
    %GETAREAPERCENTMIX Summary of this function goes here
    %   Calculates the percentage that an circle at x of diameter d covers a
    %   strip between y1 and y2

    % Calculate the total area of the node contact on the vertical connection
    Total_Area = 2*pi*r*(y2-y1);

    % Get the lowest point (either the circle or the line)
    c_y1 = max([x-d/2 y1]);

    % Get the highest point (either the circle or the line)
    c_y2 = min([x+d/2 y2]);

    %
    if c_y1 >= c_y2; PercArea = 0; return; end
    N = max([2 floor(100*(c_y2-c_y1)/d)]);
    y = linspace(c_y1,c_y2,N);
    y = (y(1:end-1)+y(2:end))/2;
    dy = (c_y2-c_y1)/(N-1);
    area = 0;
    for yi = y
        area = area + 2*dy*min([r sqrt((d/2)^2-(x-yi)^2)]);
    end
    PercArea = area/Total_Area;

% r,this.x,s,e,SCont.End


    function coveredArea = circleCoverageArea(x, d, y1, y2)
        radius = d / 2;

        % Calculate the intersection between the circle and the strip
        y_top = max(y1, x - radius);
        y_bottom = min(y2, x + radius);

        % Calculate the length of the strip
        strip_length = y_bottom - y_top;

        % Calculate the covered area of the circle
        if strip_length >= d
            % The strip completely covers the circle
            coveredArea = pi * radius^2;
        elseif strip_length <= 0
            % The strip does not intersect with the circle
            coveredArea = 0;
        else
            % Calculate the angle subtended by the strip on the circle
            theta = 2 * acos((radius - strip_length) / radius);

            % Calculate the area of the circular segment
            segmentArea = (theta - sin(theta)) * radius^2 / 2;

            % Calculate the area of the covered part within the strip
            coveredArea = segmentArea - strip_length * (radius - strip_length);
        end
    end

    










end

