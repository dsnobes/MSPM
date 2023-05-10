function newObj = CopyClass(existingObj)
  newObj = feval(class(existingObj));
  props = properties(existingObj);
  for i = 1:length(props)
    newObj.(props{i}) = existingObj.(props{i});
  end
end