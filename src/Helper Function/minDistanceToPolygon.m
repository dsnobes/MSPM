function minDistance = minDistanceToPolygon(point, xcoords, ycoords)
    % Calculate the minimum distance between a point and the perimeter of a polygon
    % defined by its vertices.

    
    numVertices = length(xcoords);
    minDistance = Inf;

    % Check if the point is inside the polygon
    max_x = max(xcoords);
    min_x = min(xcoords);
    max_y = max(ycoords);
    min_y = min(ycoords);

    if (point(1) < max_x && point(1) > min_x) && (point(2) < max_y && point(2) > min_y)
        % Point in inside polygon
        minDistance = 0;
        return;
    end

    % If point is not inside polygon, find shortest distance
    % Add the first coordinate to the end
    xcoords(end+1) = xcoords(1);
    ycoords(end+1) = ycoords(1);
    
    % Iterate over each edge of the polygon
    for i = 1:numVertices
        
        % Get the first vertex and the next one
        x1 = xcoords(i);
        y1 = ycoords(i);

        x2 = xcoords(i+1);
        y2 = ycoords(i+1);

        % Calculate the distance between the point and the line segment defined by the edges of the polygon
        distance = minDistancePointToLineSegment(point', [x1, y1], [x2,y2]);

        % Update the minimum distance if needed
        if distance < minDistance
            minDistance = distance;
        end
    end
end

