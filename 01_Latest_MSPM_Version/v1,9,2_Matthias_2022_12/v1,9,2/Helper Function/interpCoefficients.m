function [ Interp, iNodes ] = interpCoefficients(loc, iNodes)
%INTERPCOEFFICIENTS Summary of this function goes here
%   Detailed explanation goes here

% Given 4 or less nodes
notdone = true;
while notdone
  switch length(iNodes)
    case 0
      fprintf('ERR: No nodes provided for interpolation into interpCoefficients.m');
      Interp = [];
      iNodes = Node.empty;
      notdone = false;
    case 3
      fprintf('ERR: Invalid number of nodes provided for interpolation into interpCoefficients.m');
      Interp = [];
      iNodes = Node.empty;
      notdone = false;
    case 1
      Interp = 1;
      notdone = false;
    case 2
      % Ratio of distances
      NC1 = iNodes(1).minCenterCoords;
      NC2 = iNodes(2).minCenterCoords;
      if iNodes(1).xmin == 0; NC1.x = 0; end
      if iNodes(2).xmin == 0; NC2.x = 0; end
      vec = Pnt2D(NC2.x-NC1.x,NC2.y-NC1.y);
      mag = sqrt(vec.x^2+vec.y^2);
      vec.x = vec.x/mag;
      vec.y = vec.y/mag;
      pnt = Pnt2D(loc.x-NC1.x,loc.y-NC1.y);
      dot = pnt.x*vec.x + pnt.y*vec.y;
      d1 = dot; % Distance to NC1
      d2 = mag - dot; % Distance to NC2
      Interp(2) = d1/(d1+d2);
      Interp(1) = d2/(d1+d2);
      notdone = false;
    case 4
      % Bilinear Interpolation
      % Determine if it is between any two points and pick the pair with the
      % lowest collective distance
      pairs = zeros(3,6);
      P(4) = iNodes(4).minCenterCoords;
      P(1) = iNodes(1).minCenterCoords;
      P(2) = iNodes(2).minCenterCoords;
      P(3) = iNodes(3).minCenterCoords;
      if iNodes(1).xmin == 0; P(1).x = 0; end
      if iNodes(2).xmin == 0; P(2).x = 0; end
      if iNodes(3).xmin == 0; P(3).x = 0; end
      if iNodes(4).xmin == 0; P(4).x = 0; end
      isvertical = true;
      x = P(1).x;
      for i = 2:4
         if P(i).x ~= x
             isvertical = false;
             break;
         end
      end
      
      % If they are all vertical then pick one on either side
      if isvertical
          
          % They are all vertically aligned, pick 2
          % Find the closest that is greater than
          greaterthan = 0;
          d = inf;
          for i = 1:4
             if loc.y <= P(i).y
                if P(i).y - loc.y < d
                    d = P(i).y - loc.y;
                    greaterthan = i;
                end
             end
          end
          
          % Find the closest that is less than
          lessthan = 0;
          d = inf;
          for i = 1:4
              if loc.y >= P(i).y
                 if loc.y - P(i).y < d
                     d = loc.y - P(i).y;
                     lessthan = i;
                 end
              end
          end
          
          % Fill in the gaps with a next closest
          if lessthan ~= 0 && greaterthan ~= 0
              [ Interp, iNodes ] = interpCoefficients(loc, iNodes([lessthan; greaterthan]));
          else
              if lessthan == 0
                  greaterthan2 = 0;
                  d = inf;
                  for i = 1:4
                      if i ~= greaterthan
                          if loc.y <= P(i).y
                            if P(i).y - loc.y < d
                                d = P(i).y - loc.y;
                                greaterthan2 = i;
                            end
                         end
                      end
                  end
                  
                  [ Interp, iNodes ] = interpCoefficients(loc, iNodes([greaterthan2; greaterthan]));
              else
                  lessthan2 = 0;
                  d = inf;
                  for i = 1:4
                      if i ~= lessthan
                          if loc.y >= P(i).y
                            if loc.y - P(i).y < d
                                d = loc.y - P(i).y;
                                lessthan2 = i;
                            end
                         end
                      end
                  end
                  [ Interp, iNodes ] = interpCoefficients(loc, iNodes([lessthan2; lessthan]));
              end
          end
      else
         ishorizontal = true;
         y = P(1).y;
         for i = 2:4
            if P(i).y ~= y
                ishorizontal = false;
                break;
            end
         end
         if ishorizontal
              % They are all horizontally aligned, pick 2
              
              % They are all vertically aligned, pick 2
              % Find the closest that is greater than
              greaterthan = 0;
              d = inf;
              for i = 1:4
                 if loc.x <= P(i).x
                    if P(i).x - loc.x < d
                        d = P(i).x - loc.x;
                        greaterthan = i;
                    end
                 end
              end

              % Find the closest that is less than
              lessthan = 0;
              d = inf;
              for i = 1:4
                  if loc.x >= P(i).x
                     if loc.x - P(i).x < d
                         d = loc.x - P(i).x;
                         lessthan = i;
                     end
                  end
              end

              % Fill in the gaps with a next closest
              if lessthan ~= 0 && greaterthan ~= 0
                  [ Interp, iNodes ] = interpCoefficients(loc, iNodes([lessthan; greaterthan]));
              else
                  if lessthan == 0
                      greaterthan2 = 0;
                      d = inf;
                      for i = 1:4
                          if i ~= greaterthan
                              if loc.x <= P(i).x
                                if P(i).x - loc.x < d
                                    d = P(i).x - loc.x;
                                    greaterthan2 = i;
                                end
                             end
                          end
                      end
                      [ Interp, iNodes ] = interpCoefficients(loc, iNodes([greaterthan2; greaterthan]));
                  else
                      lessthan2 = 0;
                      d = inf;
                      for i = 1:4
                          if i ~= lessthan
                              if loc.x >= P(i).x
                                if loc.x - P(i).x < d
                                    d = loc.x - P(i).x;
                                    lessthan2 = i;
                                end
                             end
                          end
                      end
                      [ Interp, iNodes ] = interpCoefficients(loc, iNodes([lessthan2; lessthan]));
                  end
              end
         else
         	% Linear Interpolate/extrapolate between all 4
            Interp = zeros(1,4);
            % https://en.wikipedia.org/wiki/Bilinear_interpolation#:~:text=In%20mathematics%2C%20bilinear%20interpolation%20is,again%20in%20the%20other%20direction.
            x1 = min([P(1).x P(2).x P(3).x P(4).x]);
            x2 = max([P(1).x P(2).x P(3).x P(4).x]);
            y1 = min([P(1).y P(2).y P(3).y P(4).y]);
            y2 = max([P(1).y P(2).y P(3).y P(4).y]);
            Qs = 1:4;
            for i = 1:4
               if P(i).x == x1 && P(i).y == y1; Qs = take(1, i, Qs); break; end
            end
            for i = 1:4
               if P(i).x == x1 && P(i).y == y2; Qs = take(2, i, Qs); break; end 
            end
            for i = 1:4
               if P(i).x == x2 && P(i).y == y1; Qs = take(3, i, Qs); break; end 
            end
            factor = (1/((x2-x1)*(y2-y1)));
            Interp(Qs(1)) = factor * (x2 - loc.x) * (y2 - loc.y);
            Interp(Qs(2)) = factor * (x2 - loc.x) * (loc.y - y1);
            Interp(Qs(3)) = factor * (loc.x - x1) * (y2 - loc.y);
            Interp(Qs(4)) = factor * (loc.x - x1) * (loc.y - y1);
         end
      end
      notdone = false;
      
      %{
      k = 1;
      % Get pairs of points that are aligned with either the horizontal or
      % ... verical axis with respect to loc.
      for i = 1:3
        for j = i+1:4
          if (P(i).y == P(j).y && loc.y == P(i).y) || ...
              (P(i).x == P(j).x && loc.x == P(i).x)
            pairs(1:3,k) = [i;j;...
              sqrt((loc.x-P(i).x)^2+(loc.y-P(i).y)^2)+...
              sqrt((loc.x-P(j).x)^2+(loc.y-P(j).y)^2)];
            k = k + 1;
          end
        end
      end
      if k > 2
        d = Inf;
        for i = 1:k-1
          if d > pairs(3,i)
            d = pairs(3,i);
            k = i;
          end
        end
        iNodes = iNodes(pairs(1:2,k)');
      else
        % Bilinear Interpolation
        % Find the pair that is horizontal
        pairs = zeros(2,2);
        Interp = ones(1,4);
        k = 1;
        for i = 1:3
          for j = i+1:4
            if P(i).y == P(j).y
              pairs(1:2,k) = [i;j];
              k = k + 1;
              if k == 3; break; end
            end
          end
        end
        if k < 3
          % Pick the closest 2
          iNodes = findClosest2(loc,iNodes);
        else
          % Distances
          d(1) = loc.y-P(pairs(1,1)).y;
          d(2) = P(pairs(1,2)).y - loc.y;
          for i = 1:2
            for j = 1:2
              interp(pairs(j,i)) = interp(pairs(j,i))*(sum(d)-d(i))/sum(d);
            end
          end
          % Find the pairs that are vertical
          pairs = zeros(2,2);
          Interp = ones(1,4);
          k = 1;
          for i = 1:3
            for j = i+1:4
              if P(i).x == P(j).x
                pairs(1:2,k) = [i;j];
                k = k + 1;
                if k == 3; break; end
              end
            end
          end
          if k < 3
            % Pick the closest 2
            iNodes = findClosest2(loc, iNodes);
          else
            % Distances
            d(1) = loc.x-P(pairs(1,1)).x;
            d(2) = P(pairs(1,2)).x - loc.x;
            for i = 1:2
              for j = 1:2
                Interp(pairs(j,i)) = Interp(pairs(j,i))*(sum(d)-d(i))/sum(d);
              end
            end
            notdone = false;
          end
        end
      end
      %}
  end
end
end

function [input] = swap(index1, index2, input)
    temp = input(index1);
    input(index1) = input(index2);
    input(index2) = temp;
end

function [input] = take(value, index, input)
    for i = 1:length(input)
        if input(i) == value
           input = swap(i, index, input); 
           return;
        end
    end
end

