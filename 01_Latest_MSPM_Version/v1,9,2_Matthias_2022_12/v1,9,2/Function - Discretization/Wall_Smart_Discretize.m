function [x] = Wall_Smart_Discretize(Body,Mesher,Orient)
  %UNTITLED2 Summary of this function goes here
  %   Detailed explanation goes here
  material = Body.matl;
  if Body.matl.Phase == enumMaterial.Gas
    % Gas Body
    N_entrance = Mesher.Gas_Entrance_Exit_N;
    maximum_growth = Mesher.maximum_growth;
    maximum_thickness = Mesher.Gas_Maximum_Size;
    minimum_thickness = Mesher.Gas_Minimum_Size;
    % Derived Values
    shifti = [];
    switch Orient
      case enumOrient.Vertical
        [~,~,inside_dim, outside_dim] = Body.limits(Orient);
      case enumOrient.Horizontal
        [inside_dim,outside_dim,~,~] = Body.limits(Orient);
        if ~isscalar(inside_dim)
          shifti = inside_dim - inside_dim(1);
          inside_dim = inside_dim(1);
        end
        if ~isscalar(outside_dim)
          %shifto = outside_dim - outside_dim(1);
          outside_dim = outside_dim(1);
        end
    end
    Distance = outside_dim - inside_dim;
    Transition_Distance = Distance * 0.15;
    x = inside_dim;
    thickness = Transition_Distance / double(N_entrance);
    if thickness > maximum_thickness
      N = ceil(Distance/maximum_thickness);
      x = linspace(inside_dim,outside_dim,N+1);
    else
      while thickness < minimum_thickness && N_entrance > 1
        N_entrance = N_entrance - 1;
        thickness = Transition_Distance / double(N_entrance);
      end
      if N_entrance == 1
          thickness = min(minimum_thickness, Distance/2);
          if Distance/2 - thickness < thickness
              x = [inside_dim (inside_dim + outside_dim)/2 outside_dim];
          else
              x = [inside_dim inside_dim + thickness];
              marker = 2;
              while (x(end) < Distance/2 + inside_dim)
                thickness = min(maximum_thickness, maximum_growth * thickness);
                x(end+1) = x(end) + thickness;
              end
              % Adjust it at the end
              Current_Distance = x(end) - x(marker);
              Expected_Distance = Distance/2 + inside_dim - x(marker);
              x((marker+1):end) = (x((marker+1):end) - x(marker))*...
                (Expected_Distance/Current_Distance) + x(marker);
              % Flip it
              x = [x outside_dim-(flip(x(1:end-1))-inside_dim)];
          end
      else
          for i = 1:N_entrance
            x(end+1) = x(end) + thickness;
          end
          marker = length(x);
          while (x(end) < Distance/2 + inside_dim)
            thickness = min(maximum_thickness, maximum_growth * thickness);
            x(end+1) = x(end) + thickness;
          end
          % Adjust it at the end
          Current_Distance = x(end) - x(marker);
          Expected_Distance = Distance/2 + inside_dim - x(marker);
          x((marker+1):end) = (x((marker+1):end) - x(marker))*...
            (Expected_Distance/Current_Distance) + x(marker);
          % Flip it
          x = [x outside_dim-(flip(x(1:end-1))-inside_dim)];
      end
    end
  else
    % Solid Body
    min_ang_frequency = Body.Group.Model.engineSpeed;
    oscillation_depth_N = Mesher.oscillation_depth_N;
    maximum_thickness = Mesher.maximum_thickness;
    maximum_growth = Mesher.maximum_growth;
    shifti = [];
    switch Orient
      case enumOrient.Vertical
        [~,~,inside_dim, outside_dim] = Body.limits(Orient);
        inside_exp = Mesher.isInsideRadiiExposed(Body);
        outside_exp = Mesher.isOutsideRadiiExposed(Body);
      case enumOrient.Horizontal
        [inside_dim,outside_dim,~,~] = Body.limits(Orient);
        inside_exp = Mesher.isBottomExposed(Body);
        outside_exp = Mesher.isTopExposed(Body);
        if ~isscalar(inside_dim)
          shifti = inside_dim - inside_dim(1);
          inside_dim = inside_dim(1);
        end
        if ~isscalar(outside_dim)
          %shifto = outside_dim - outside_dim(1);
          outside_dim = outside_dim(1);
        end
    end
    if Body.matl.dT_du == -1
      alpha = 1000000;
    else
      % output requirements, x must have the min and maximum point
      alpha = material.thermaldiffusivity;
    end

    % Using the 5% amplitude condition
    xdepth = 3*sqrt(2*alpha/min_ang_frequency);
    xtotal = outside_dim - inside_dim;
    if inside_exp
      if outside_exp
        if xtotal < 2*xdepth
          % Discretize the entire depth to the near wall standards
          N = ceil(xtotal/(xdepth/double(oscillation_depth_N)));
          x = linspace(inside_dim,outside_dim,N+1);
        else
          % Grow from both ends (calc with half then mirror)
          N_max = ceil(0.5*xtotal/(xdepth/double(oscillation_depth_N)));
          x = [linspace(inside_dim,inside_dim + xdepth,oscillation_depth_N+1) ...
            zeros(1,N_max-oscillation_depth_N)];
          i = oscillation_depth_N+1;
          while x(i) < inside_dim + xtotal/2
            i = i + 1;
            x(i) = x(i-1) + min([maximum_growth*(x(i-1)-x(i-2)) ...
              maximum_thickness]);
          end
          x(i) = inside_dim + xtotal/2;
          x(i+1:2*i-1) = outside_dim - (flip(x(1:i-1))-inside_dim);
          if length(x) > 2*i - 1
            x(2*i:end) = [];
          end
        end
      else
        if xtotal < xdepth
          % Discretize the entire depth to the near wall standards
          N = ceil(xtotal/(xdepth/double(oscillation_depth_N)));
          x = linspace(inside_dim,outside_dim,N+1);
        else
          % Grow from inside end
          N_max = ceil(xtotal/(xdepth/double(oscillation_depth_N)));
          x = [linspace(inside_dim,inside_dim + xdepth,oscillation_depth_N+1) ...
            zeros(1,N_max-oscillation_depth_N)];
          i = oscillation_depth_N+1;
          while x(i) < outside_dim
            i = i + 1;
            x(i) = x(i-1) + min([maximum_growth*(x(i-1)-x(i-2)) ...
              maximum_thickness]);
          end
          x(i) = outside_dim;
          if length(x) > i
            x(i+1:end) = [];
          end
        end
      end
    else
      if outside_exp
        if xtotal < xdepth
          % Discretize the entire depth to the near wall standards
          N = ceil(xtotal/(xdepth/double(oscillation_depth_N)));
          x = linspace(inside_dim,outside_dim,N+1);
        else
          % Grow from outside end, use mathematics from the other
          % direction, then flip afterwards
          N_max = ceil(xtotal/(xdepth/double(oscillation_depth_N)));
          x = [linspace(inside_dim,inside_dim + xdepth,oscillation_depth_N+1) ...
            zeros(1,N_max-oscillation_depth_N)];
          i = oscillation_depth_N+1;
          while x(i) < outside_dim
            i = i + 1;
            x(i) = x(i-1) + min([maximum_growth*(x(i-1)-x(i-2)) ...
              maximum_thickness]);
          end
          x(i) = outside_dim;
          if length(x) > i
            x(i+1:end) = [];
          end
          % Flip
          x = inside_dim + (outside_dim - x);
        end
      else
        % Discretize the entire depth to the minimum stardards
        N = ceil(xtotal/maximum_thickness);
        x = linspace(inside_dim,outside_dim,N+1);
      end
    end
  end
  if isempty(shifti)
    x = transpose(x);
  else
    temp = transpose(x);
    x = zeros(length(x),length(shifti));
    for r = 1:length(temp)
      x(r,:) = shifti(:);
    end
    for c = 1:length(shifti)
      x(:,c) = x(:,c) + temp;
    end
  end
end

