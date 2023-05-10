function NType = getFaceType(Type1,Type2)
  if Type1 ~= Type2
    NType = enumFType.Mix;
  else
    NType = Type1;
  end
end