function [ ] = FacesSummary( nd )
    fprintf([num2str(nd.Body.ID) '\n']);
    fprintf([num2str(nd.vol()) '\n']);
    for i = 1:length(nd.Faces)
        fc = nd.Faces(i);
        switch fc.Type
            case enumFType.Gas
                fprintf(['Gas Face: Area: ' num2str(fc.data.Area(1)) '\n'])
            case enumFType.Mix
                fprintf(['Mix Face: Area: ' num2str(fc.data.Area(1)) ' R: ' num2str(fc.data.R) '\n'])
        end
    end
end

