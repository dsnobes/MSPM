function [success, visited] = getAnyFcLoopOfSize(visited, target, start, max_length)
  success = false;
  for fc = start.Faces
    if visited(end) ~= fc && (fc.Type == enumFType.Gas || ...
        fc.Type == enumFType.MatrixTransition)
      % Make sure the face is traversible
      if fc.Nodes(1) == start; i = 2; else; i = 1; end
      % Test for completion
      if fc.Nodes(i) == target
        success = true; visited = [visited fc]; return;
      else
        % Length Check
        if length(visited) + 1 == max_length
          success = false; return;
        else
          % Continue Searching
          for fci = fc.Nodes(i).Faces
            [success, new_visited] = getAnyFcLoopOfSize(...
              [visited fc], target, fc.Nodes(i), max_length);
            if success
              visited = new_visited;
              return;
            end
          end
        end
      end
    end
  end
end
