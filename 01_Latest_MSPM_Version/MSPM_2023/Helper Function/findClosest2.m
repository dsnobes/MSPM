function [ iNodes ] = findClosest2(loc, iNodes )
    selection = zeros(1,2);
    d = zeros(1,4);
    for i = 1:length(iNodes)
        pnts = iNodes.minCenterCoords;
        d(i) = (pnts.x - loc.x)^2 + (pnts.y - loc.y)^2;
    end
    n = 1;
    while true
        dmin = d(1);
        k = 1;
        for i = 2:length(d)
            if dmin > d(i)
                dmin = d(i);
                k = i;
            end
        end
        if dmin == inf
            iNodes = iNodes(selection(1:n));
            return;
        end
        d(k) = inf;
        selection(n) = k;
        n = n + 1;
        if n == 3
            iNodes = iNodes(selection);
            return;
        end
    end
end

