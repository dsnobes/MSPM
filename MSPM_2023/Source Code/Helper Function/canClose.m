function [itcan] = canClose( fc )
    if isfield(fc.data,'Area')
        if all(fc.data.Area > 0)
            % Path from one side to the other
            [itcan] = canPathTo(fc, fc.Nodes(1), fc.Nodes(2));
        else; itcan = true;
        end
    else
        itcan = false;
    end
end

function [canPath, visited] = canPathTo(visited, target, start)
    canPath = false;
    for fc = start.Faces
        if (fc.Type == enumFType.Gas || ...
                fc.Type == enumFType.MatrixTransition) && ...
                ~any(fc == visited)
            % Make sure the face is traversible
            if all(fc.data.Area > 0)
                if fc.Nodes(1) == start; i = 2; else; i = 1; end
                % Test for completion
                if fc.Nodes(i) == target
                    canPath = true; return;
                else
                    % Continue Searching
                    for fci = fc.Nodes(i).Faces
                        [canPath, visited] = ...
                            canPathTo([visited fc], target, fc.Nodes(i));
                        if canPath; return; end
                    end
                end
            end
        end
    end
end

