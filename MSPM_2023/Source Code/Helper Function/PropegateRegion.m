function [region] = PropegateRegion(Nd,region,n)
    if region(Nd.index) == 0
        region(Nd.index) = n;
        for Fc = Nd.Faces
            % Test if it is a gas face that does not close off
            if isfield(Fc.data,'dx') && all(Fc.data.Area > 0)
                if Fc.Nodes(1) == Nd
                    Nd2 = Fc.Nodes(2);
                else
                    Nd2 = Fc.Nodes(1);
                end
                if Nd2.index <= length(region)
                    region = PropegateRegion(Nd2,region,n);
                end
            end
        end
    end
end
