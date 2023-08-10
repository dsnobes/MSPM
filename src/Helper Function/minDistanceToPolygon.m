function minDistance = minDistanceToPolygon(point, polygon)
    % Calculate the minimum distance between a point and the perimeter of a polygon
    % defined by its vertices.
    
    % point: [x, y] coordinates of the point
    % polygon: 2x4 matrix containing [x; y] coordinates of the polygon vertices
    
    numVertices = size(polygon, 2);
    minDistance = Inf;
    
    % Iterate over each edge of the polygon
    for i = 1:numVertices
        
        % Get the first vertex and the next one
        p1 = polygon(:, i); % Starting vertex of the edge
        p2 = polygon(:, mod(i, numVertices) + 1); % Ending vertex of the edge

        % Find the projection of the point on the line segment
        t = max(0, min(1, dot(point-p1, p2-p1)));
        projection = p1 + t * (p2-p1);

        % Find the distance from the projected point to the point
        distance = Dist4Compare(point, projection);

        % Update the minimum distance if needed
        if distance < minDistance
            minDistance = distance;
        end
    end
end

