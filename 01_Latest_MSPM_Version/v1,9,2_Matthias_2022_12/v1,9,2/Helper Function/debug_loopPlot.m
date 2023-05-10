function [ ] = debug_loopPlot( Model, Closed)
h = figure();
if nargin > 1
  if length(Closed) == 1
    if ~Closed
      for fc = Model.Faces
        if fc.Type == enumFType.Gas || fc.Type == enumFType.MatrixTransition
          c1 = fc.Nodes(1).minCenterCoords();
          c2 = fc.Nodes(2).minCenterCoords();
          line([c1.x; c2.x], [c1.y; c2.y]);
        end
      end
    end
  else
    for fc = Model.Faces
      if fc.Type == enumFType.Gas || fc.Type == enumFType.MatrixTransition
        if ~Closed(fc.index)
          c1 = fc.Nodes(1).minCenterCoords();
          c2 = fc.Nodes(2).minCenterCoords();
          line([c1.x; c2.x], [c1.y; c2.y]);
        end
      end
    end
  end
else
  for fc = Model.Faces
    if fc.Type == enumFType.Gas || fc.Type == enumFType.MatrixTransition
      if all(fc.data.Area > 0)
        c1 = fc.Nodes(1).minCenterCoords();
        c2 = fc.Nodes(2).minCenterCoords();
        line([c1.x; c2.x], [c1.y; c2.y]);
      end
    end
  end
end
close(h);
end

