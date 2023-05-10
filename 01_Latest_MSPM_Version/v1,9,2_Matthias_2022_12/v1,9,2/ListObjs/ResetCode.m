function [Code] = ResetCode(Code)
if ~isempty(Code)
  if Code(1) == '1'
    % Model may maintain its expansion
    if length(Code) > 1
      if Code(2) == '['
        i = 3; lvlcount = -1;
        while i < length(Code) && lvlcount < 0
          switch Code(i)
            case '['; lvlcount = lvlcount - 1;
            case ']'; lvlcount = lvlcount + 1;
          end
          i = i + 1;
        end
        if length(Code) > i; Code(i+1:end) = ''; end
      end
    end
  else
    % Everything else is presumed to have changed
    Code = '';
  end
end
end

