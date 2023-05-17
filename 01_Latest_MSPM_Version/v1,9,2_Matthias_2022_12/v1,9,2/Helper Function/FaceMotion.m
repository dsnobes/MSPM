function [ V, S, SContact ] = FaceMotion(Fc)
    V = [];
    S = [];
    SContact = ShearContact.empty;
    % Only if the face is horizontal and is gas
    if Fc.Orient ~= enumOrient.Horizontal; return; end
    n1 = Fc.Nodes(1);
    n2 = Fc.Nodes(2);
    if n1.Type == enumNType.SN || n2.Type == enumNType.SN; return; end
    
    % factor = omega/N [rad/step]
    h = 2*pi/(Frame.NTheta-1);
    
    %% Self Motion
    % Produce V_middle - of units [m/rad]
    if all(n1.ymin == n2.ymax)
        % Oriented towards the negative
        sgn = 1;
        V_middle = zeros(1,Frame.NTheta);
        y = n1.ymin;
        if ~isscalar(y)
            V_middle(1) = (y(2)-y(end-1))/(2*h);
            V_middle(2:end) = (y(3:end)-y(1:end-2))/(2*h);
        end
    elseif all(n1.ymax == n2.ymin)
        % Oriented towards the positive
        sgn = -1;
        V_middle = zeros(1,Frame.NTheta);
        y = n2.ymin;
        if ~isscalar(y)
            V_middle(1) = (y(2)-y(end-1))/(2*h);
            V_middle(2:end-1) = (y(3:end)-y(1:end-2))/(2*h);
            V_middle(end) = V_middle(1);
        end
    else
        % They are connected, but through a bridge.
        return;
    end
    
    %% Adjacent Motion
    % Find the adjacent surfaces motion
    % For each frame of motion detect whether or not the face is adjacent to a
    % ... solid surface.
    Bodies_1_inside = Body.empty;
    Area_1_inside = cell_of_zeros(length(n1.Faces));
    Bodies_1_outside = Body.empty;
    Area_1_outside = cell_of_zeros(length(n1.Faces));
    Bodies_2_inside = Body.empty;
    Area_2_inside = cell_of_zeros(length(n2.Faces));
    Bodies_2_outside = Body.empty;
    Area_2_outside = cell_of_zeros(length(n2.Faces));
    
    % Test the connections of node 1
    for fc = n1.Faces
        if fc.Orient == enumOrient.Vertical
            % Only if it is a mixed face will it populate "nd"
            nd = [];
            if fc.Nodes(1).Type == enumNType.SN; nd = fc.Nodes(1);
            elseif fc.Nodes(2).Type == enumNType.SN; nd = fc.Nodes(2);
            end
            if ~isempty(nd)
                found = false;
    
                if nd.xmin < n1.xmin % It is closer to the axis than the original node
                    for i = 1:length(Bodies_1_inside)
                        if Bodies_1_inside(i) == nd.Body
                            Area_1_inside{i} = Area_1_inside{i} + fc.data.Area;
                            found = true;
                        end
                    end
                    if ~found
                        Bodies_1_inside(end+1) = nd.Body;
                        Area_1_inside{length(Bodies_1_inside)} = ...
                            Area_1_inside{length(Bodies_1_inside)} + fc.data.Area;
                    end
                else % It is farther from the axis than the original node
                    for i = 1:length(Bodies_1_outside)
                        if Bodies_1_outside(i) == nd.Body
                            Area_1_outside{i} = Area_1_outside{i} + fc.data.Area;
                            found = true;
                        end
                    end
                    if ~found
                        Bodies_1_outside(end+1) = nd.Body;
                        Area_1_outside{length(Bodies_1_outside)} = ...
                            Area_1_outside{length(Bodies_1_outside)} + fc.data.Area;
                    end
                end
            end
        end
    end
    
    % Test the connections of node 2
    for fc = n2.Faces
        if fc.Orient == enumOrient.Vertical
            % Only if it is a mixed face will it populate "nd"
            nd = [];
            if fc.Nodes(1).Type == enumNType.SN
                nd = fc.Nodes(1);
            elseif fc.Nodes(2).Type == enumNType.SN
                nd = fc.Nodes(2);
            end
            if ~isempty(nd)
                found = false;
                if nd.xmin < n2.xmin % It is closer to the axis than the original node
                    for i = 1:length(Bodies_2_inside)
                        if Bodies_2_inside(i) == nd.Body
                            Area_2_inside{i} = Area_2_inside{i} + fc.data.Area;
                            found = true;
                        end
                    end
                    if ~found
                        Bodies_2_inside(end+1) = nd.Body;
                        Area_2_inside{length(Bodies_2_inside)} = ...
                            Area_2_inside{length(Bodies_2_inside)} + fc.data.Area;
                    end
                else % It is farther from the axis than the original node
                    for i = 1:length(Bodies_2_outside)
                        if Bodies_2_outside(i) == nd.Body
                            Area_2_outside{i} = Area_2_outside{i} + fc.data.Area;
                            found = true;
                        end
                    end
                    if ~found
                        Bodies_2_outside(end+1) = nd.Body;
                        Area_2_outside{length(Bodies_2_outside)} = ...
                            Area_2_outside{length(Bodies_2_outside)} + fc.data.Area;
                    end
                end
            end
        end
    end
    
    % Determine inner absolute speeds
    % ... If no bodies are shared, then speed is equal to the face velocity to
    % ... represent a low shear condition.
    V_inner = V_middle; i = 1;
    shared_inner = false(size(Bodies_1_inside));
    for iBody = Bodies_1_inside
        j = 1;
        for oBody = Bodies_2_inside
            if iBody == oBody
                shared_inner(i) = true;
                overlap = and(Area_1_inside{i} > 0, Area_2_inside{j} > 0);
                motion = get_motion(iBody);
                if length(overlap) == 1 && overlap
                    V_inner = motion;
                    break;
                else
                    V_inner(overlap) = motion(overlap);
                end
            end
            j = j + 1;
        end
        i = i + 1;
    end
    
    
    % Determine outer absolute speeds
    % ... If no bodies are shared, then speed is equal to the face velocity to
    % ... represent a low shear condition.
    shared_outer = false(size(Bodies_1_outside));
    V_outer = V_middle; i = 1;
    for iBody = Bodies_1_outside
        j = 1;
        for oBody = Bodies_2_outside
            if iBody == oBody
                shared_outer(i) = true;
                overlap = and(Area_1_outside{i} > 0, Area_2_outside{j} > 0);
                motion = get_motion(iBody);
                if length(overlap) == 1 && overlap
                    V_outer = motion;
                    break;
                else
                    V_outer(overlap) = motion(overlap);
                end
            end
            j = j + 1;
        end
        i = i + 1;
    end
    
    % Assign V and S vectors
    if n1.xmin == 0 && n2. xmin == 0
        V = (V_middle - V_outer);
        S = [];
    else
        V = V_middle - (V_inner + V_outer)/2;
        S = abs(V_inner - V_outer);
    end
    
    Frames = Frame.empty;
    N = length(Bodies_1_inside(shared_inner)) + ...
        length(Bodies_1_outside(shared_outer));
    ActiveTimes = cell(N, 1);
    for i = 1:N; ActiveTimes{i} = 0; end
    for i = 1:length(Bodies_1_inside)
        if shared_inner(i)
            Frm = Bodies_1_inside(i).get('RefFrame');
            if ~isempty(Frm)
                found = false;
                for j = 1:length(Frames)
                    if Frames(j) == Frm
                        found = true;
                        % Add active Points to array
                        ActiveTimes{j} = or(ActiveTimes{j}, ...
                            and(Area_1_inside{i} > 0, Area_2_inside{i} > 0));
                        break;
                    end
                end
                if ~found
                    Frames(end+1) = Frm;
                    ActiveTimes{length(ActiveTimes),1} = ...
                        and(Area_1_inside{i} > 0, Area_2_inside{i} > 0);
                end
            end
        end
    end
    for i = 1:length(Bodies_1_outside)
        if shared_outer(i)
            Frm = Bodies_1_outside(i).get('RefFrame');
            if ~isempty(Frm)
                found = false;
                for j = 1:length(Frames)
                    if Frames(j) == Frm
                        found = true;
                        % Add active Points to array
                        ActiveTimes{j} = or(ActiveTimes{j}, ...
                            and(Area_1_outside{i} > 0, Area_2_outside{i} > 0));
                        break;
                    end
                end
                if ~found
                    Frames(end+1) = Frm;
                    ActiveTimes{length(ActiveTimes),1} = ...
                        and(Area_1_outside{i} > 0, Area_2_outside{i} > 0);
                end
            end
        end
    end
    
    % So we now have the reference frames that move past the face, as well as
    % ... the times that they are active for.
    if isempty(Frames)
        SContact = ShearContact.empty;
    else
        SContact(length(Frames)) = ShearContact(0);
        Converters = n1.Body.Group.Model.Converters;
        i = 1;
        for Frm = Frames
            for Converter_id = 1:length(Converters)
                if Frm.Mechanism == Converters(Converter_id)
                    break;
                end
            end
            if n1.ymin(1) < n2.ymin(1)
                SContact(i) = ShearContact(...
                    Converter_id, Frm.MechanismIndex, Fc.data.Area/2, n1, n2, ActiveTimes{i});
            else
                SContact(i) = ShearContact(...
                    Converter_id, Frm.MechanismIndex, Fc.data.Area/2, n2, n1, ActiveTimes{i});
            end
            i = i + 1;
        end
    end
    
    % Currently the gas velocity is oriented towards the negative direction
    % ... Correct
    if all(V < 1e-4) && all(V > -1e-4)
        V = [];
    else
        V = sgn*V;
    end
    
    if all(S < 1e-4)
        S = [];
    end
end

function [a] = cell_of_zeros(len)
    a = cell(len,1);
    for i = 1:len; a{i} = 0; end
end

function [motion] = get_motion(iBody)
    [y, ~, ~, ~] = iBody.limits(enumOrient.Horizontal);
    % factor = omega/N [rad/step]
    h = 2*pi/(Frame.NTheta-1);
    motion = zeros(1,Frame.NTheta);
    if ~isscalar(y)
        motion(1) = (y(2)-y(end-1))/(2*h);
        motion(2:end-1) = (y(3:end)-y(1:end-2))/(2*h);
        motion(end) = motion(1);
    end
end
