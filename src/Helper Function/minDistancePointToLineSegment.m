function distance = minDistancePointToLineSegment(point, lineSegmentStart, lineSegmentEnd)
    % Calculate the vector representing the line segment
    lineSegmentVector = lineSegmentEnd - lineSegmentStart;
    
    % Calculate the vector from the line segment start point to the point
    pointVector = point - lineSegmentStart;
    
    % Calculate the parameter along the line segment for the closest point
    t = dot(pointVector, lineSegmentVector) / dot(lineSegmentVector, lineSegmentVector);
    
    % Clamp the parameter value to ensure the closest point is within the line segment
    t = max(0, min(t, 1));
    
    % Calculate the closest point on the line segment
    closestPoint = lineSegmentStart + t * lineSegmentVector;
    
    % Calculate the distance between the point and the closest point
    distance = norm(point - closestPoint);
end
