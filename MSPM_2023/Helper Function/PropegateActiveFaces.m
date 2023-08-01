function [ k,Array,Visited ] = PropegateActiveFaces(Nd,Visited,k,Array)
    Visited(Nd.index) = true;
    if k == length(Array)
        return;
    end
    for Fc = Nd.Faces
        if Fc.Nodes(1).index <= length(Visited) && ...
                Fc.Nodes(2).index <= length(Visited) && ...
                isfield(Fc.data,'dx') && all(Fc.data.Area > 0)
            if ~Visited(Fc.Nodes(1).index)
                k = k + 1;
                Array(k) = Fc.index;
                [k,Array,Visited] = PropegateActiveFaces(Fc.Nodes(1),Visited,k,Array);
            elseif ~Visited(Fc.Nodes(2).index)
                k = k + 1;
                Array(k) = Fc.index;
                [k,Array,Visited] = PropegateActiveFaces(Fc.Nodes(2),Visited,k,Array);
            end
        end
    end
end

