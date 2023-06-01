% Determines if a face is a mixed face
function NType = getFaceType(Type1,Type2)
    % If the face types are not the same is a mixed face
    if Type1 ~= Type2
        NType = enumFType.Mix;
    % If the face types are the same, the type is the same as the first face
    else
        NType = Type1;
    end
end