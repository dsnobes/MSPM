classdef RelationManager < handle
    %{
    handles relations, checks that properties are valid
    and is the main way to change properties of relations
    %}
    properties
        Group Group; % Group that this relation grid refers to
        Orient enumOrient;
        Relations Relation;
        Grid logical = [];
        Grid_modes cell;

        isChanged logical = false;
    end

    properties (Dependent)
        name;
    end

    methods
        %% Relation - Class
        % ... -> name - String
        % ... -> mode - enumRelation
        % ... -> con1 - Connection
        % ... -> con2 - Connection
        % ... -> frame - Frame, associated with a mechanism with stroke

        %% Grid Construction
        function this = RelationManager(Group, Orient)
            if nargin > 1
                this.Group = Group;
                this.Orient = Orient;
            end
        end
        function Item = get(this,PropertyName)
            switch PropertyName
                case 'Name'
                    Item = this.name;
                case 'Relations'
                    Item = this.Relations;
                otherwise
                    fprintf(['XXX Group GET Inteface for ' PropertyName ...
                        ' is not found XXX\n']);
            end
        end
        function set(this,PropertyName,Item) %#ok<INUSD,INUSL>
            switch PropertyName
                otherwise
                    fprintf(['XXX Group SET Inteface for ' PropertyName ...
                        ' is not found XXX\n']);
            end
        end
        function name = get.name(this)
            switch this.Orient
                case enumOrient.Horizontal
                    name = 'Rel. Man. handling horizontal connections';
                case enumOrient.Vertical
                    name = 'Rel. Man. handling vertical connections';
            end
        end

        function update(this)
            this.isChanged = false;
            % In essence, recreate the grid from the number of connections
            % ... in group, then append each relation one by one into the
            % ... grid
            this.Grid = false(1,length(this.Group.Connections));
            this.Grid_modes = cell(0);
            keep = true(size(this.Relations));
            for i = 1:length(this.Relations)
                if keep(i)
                    for j = i+1:length(this.Relations)
                        if keep(j)
                            if this.Relations(i).con1 == ...
                                    this.Relations(j).con1 && ...
                                    this.Relations(i).con2 == ...
                                    this.Relations(j).con2
                                keep(j) = false;
                            end
                        end
                    end
                end
            end
            this.Relations(~keep) = [];
            for relation = this.Relations
                this.appendGrid(relation);
            end
        end

        function appendGrid(this, new_relation)
            % this.Relations(end+1) = new_relation;
            % So to make it here, there are no invalidities.
            ind1 = new_relation.con1.index;
            ind2 = new_relation.con2.index;

            % Adding to each other's groups
            group1 = find(this.Grid(:,ind1)==true);
            group2 = find(this.Grid(:,ind2)==true);
            allready = false;
            previous = 0;
            for i = 1:length(group2)
                group1(end+1) = group2(i);
            end
            if ~isempty(group1)
                for i = group1(:).'
                    if this.Grid_modes{i} == new_relation.mode
                        if allready
                            this.merge_rows(i,previous);
                            return;
                        end
                        % Simply append ind2 to this group
                        this.Grid(i,ind1) = true;
                        this.Grid(i,ind2) = true;
                        allready = true;
                        previous = i;
                    end
                end
                if allready; return; end
            end

            % Forming new groups
            % To make it here, both entities are not part of a group that
            % ... has the same mode, thus, it forms a new group
            row = this.get_new_group_row();
            this.Grid(row,ind1) = true;
            this.Grid(row,ind2) = true;
            this.Grid_modes{row} = new_relation.mode;
        end

        function merge_rows(this,row1,row2)
            for i = 1:size(this.Grid,2)
                this.Grid(row1,i) = this.Grid(row1,i) || ...
                    this.Grid(row2,i);
            end
            this.Grid(row2,:) = false;
            this.Grid_modes{row2} = enumRelation.empty;
        end

        function index = get_new_group_row(this)
            % See if there is an empty row
            for i = 1:size(this.Grid,1)
                if all(this.Grid(i,:)==false)
                    index = i;
                    return;
                end
            end
            % else make a new row
            index = size(this.Grid,1) + 1;
        end

        %% Relationship Adding
        function yesno = isNewRelationValid(this, ind1, ind2)
            yesno = true;
            % Make sure that grid is actually large enough
            if ~(size(this.Grid,2) >= ind1 && size(this.Grid,2) >= ind2)
                this.update();
            end
            % If one of the connections does not have any existing
            % ... relations then it is an automatic pass
            if ~any(this.Grid(:,ind1)); yesno = true; return; end
            if ~any(this.Grid(:,ind2)); yesno = true; return; end
            % If we got to this point then we have to find if the two
            % ... indexes are connected in some way
            groups1 = find(this.Grid(:,ind1)==true);
            groups2 = find(this.Grid(:,ind2)==true);
            for i = groups1
                for j = groups2
                    % Test to see if "i" is patheable to "j"
                    target = j;
                    start = i;
                    [found, ~] = are_rows_connected(...
                        this.Grid,target,start,false(size(this.Grid,1),1));
                    if found
                        yesno = false; return;
                    end
                end
            end
        end

        function success = addRelation(this, name, mode, con1, con2, frame)
            success = false;
            if this.isChanged; this.update(); end
            if this.Orient ~= con1.Orient; return; end
            if con1.Orient ~= con2.Orient; return; end
            % There cannot be an existing thing between con1 and con2
            if ~this.isNewRelationValid(con1.index, con2.index)
                return;
            end
            if nargin > 5
                newRelation = Relation(this,name,mode,con1,con2,frame);
            else
                newRelation = Relation(this,name,mode,con1,con2);
            end
            this.Relations(end+1) = newRelation;
            this.update();
            success = true;
        end

        %% Relationship Editing
        function [success, visitedgroups, shifts, data] = Edit(...
                this, con, shift, visitedgroups, shifts, data)
            if this.isChanged; this.update(); end
            %% Get all the shifts that happened due to this edit
            if isa(con,'Connection')
                ind = con.index;
            else
                ind = con;
            end
            if isempty(this.Grid)
                this.update();
            end
            if nargin < 4
                visitedgroups = false(size(this.Grid,1),1);
                shifts = zeros(size(this.Group.Connections));
                shifts(ind) = shift;
                data = struct();
            end
            groups = find(this.Grid(:,ind)==true);
            for i = groups'
                if ~visitedgroups(i)
                    cons = find(this.Grid(i,:)==true);
                    [var, data] = this.getShifts(cons, i, ind, shift, data);
                    if isempty(var); success = false; return; end
                    shifts(cons) = var;
                    visitedgroups(i) = true;
                    for j = cons
                        if shifts(j) ~= 0
                            [success, visitedgroups, shifts, data] = ...
                                this.Edit(j,shifts(j),visitedgroups,...
                                shifts, data);
                            if ~success; return; end
                        end
                    end
                end
            end
            success = true;

            if ~(nargin < 4)
                return;
            end

            %% Apply all those shifts and test each body
            for i = 1:length(this.Group.Connections)
                this.Group.Connections(i).x = ...
                    this.Group.Connections(i).x + shifts(i);
            end
            if isfield(data,'frames') && isfield(data,'frameshift')
                for i = 1:length(data.frames)
                    for iLRM = this.Group.Model.Converters
                        for RefFrame = iLRM.Frames
                            if RefFrame == data.frames(i)
                                Mech = RefFrame.Mechanism;
                                Mech.dont_propegate = true;
                                Mech.set('Stroke',...
                                    Mech.get('Stroke')+data.frameshift(i));
                            end
                        end
                    end
                end
            end
            for iBody = this.Group.Bodies; iBody.update(); end
            for iBody = this.Group.Bodies
                if ~iBody.isValid
                    for i = 1:length(this.Group.Connections)
                        this.Group.Connections(i).x = ...
                            this.Group.Connections(i).x - shifts(i);
                    end
                    if isfield(data,'frames') && isfield(data,'frameshift')
                        for i = 1:length(data.frames)
                            for iLRM = this.Group.Model.Converters
                                for RefFrame = iLRM.Frames
                                    if RefFrame == data.frames(i)
                                        Mech = RefFrame.Mechanism;
                                        Mech.dont_propegate = true;
                                        Mech.set('Stroke',Mech.get('Stroke')-data.frameshift(i));
                                    end
                                end
                            end
                        end
                    end
                    for iBody2 = this.Group.Bodies
                        iBody2.update();
                    end
                    fprintf(['XXX Connection shift failed because ' ...
                        'it caused overlapping bodies XXX\n']);
                    success = false;
                    return;
                end
            end
        end

        function [shifts, data] = getShifts(this, cons, group, root, shift, data)
            shifts = zeros(size(cons));
            if isnan(shift); return; end
            shifts(cons==root) = shift;
            if shift == 0; return; end
            if this.Group.Model.RelationOn
                switch this.Grid_modes{group}
                    case enumRelation.Constant
                        % Since we are not comming from the mechanism, these
                        % ... behave as if they were constant
                        shifts = shift * ones(size(cons));
                    case enumRelation.StackedShift
                        for i = length(cons):-1:1
                            if this.Group.Connections(cons(i)).x > ...
                                    this.Group.Connections(root).x
                                shifts(i) = shift;
                            else
                                shifts(i) = 0;
                            end
                        end
                    case enumRelation.Fixed
                        shifts = [];
                    case enumRelation.AreaConstant
                        if this.Orient == enumOrient.Vertical
                            for i = length(cons):-1:1
                                C1o = this.Group.Connections(root).x;
                                C2o = this.Group.Connections(cons(i)).x;
                                shifts(i) = ...
                                    sqrt(C2o^2 + ...
                                    shift * (2*C1o + shift)) - C2o;
                            end
                        else
                            % Behaves as if it were constant
                            shifts = shift * ones(size(cons));
                        end
                    case enumRelation.Scaled
                        if this.Group.Connections(root).x == 0
                            C1o = this.Group.Connections(root).x + shift/2;
                            for i = length(cons):-1:1
                                C2o = this.Group.Connections(cons(i)).x;
                                shifts(i) = shift * C2o / C1o;
                            end
                        else
                            C1o = this.Group.Connections(root).x;
                            for i = length(cons):-1:1
                                C2o = this.Group.Connections(cons(i)).x;
                                shifts(i) = shift * C2o / C1o;
                            end
                        end
                    case enumRelation.LowestScaled, ...
                            enumRelation.Stroke, ...
                            enumRelation.Piston
                        curmin = inf;
                        baseind = root;
                        for i = length(cons):-1:1
                            if this.Group.Connections(cons(i)).x < curmin
                                curmin = this.Group.Connections(cons(i)).x;
                                baseind = i;
                            end
                        end
                        if baseind == root
                            % Compacts to the other side
                            curmax = -inf;
                            for i = length(cons):-1:1
                                if this.Group.Connections(cons(i)).x > curmax
                                    curmax = this.Group.Connections(cons(i)).x;
                                end
                            end
                            for i = length(cons):-1:1
                                C1o = this.Group.Connections(root).x;
                                C2o = this.Group.Connections(cons(i)).x;
                                shifts(i) = shift * ...
                                    (curmax - C2o)/(curmax - C1o);
                            end
                        else
                            % Scale everything relative to the base
                            for i = length(cons):-1:1
                                C1o = this.Group.Connections(root).x;
                                C2o = this.Group.Connections(cons(i)).x;
                                shifts(i) = shift * ...
                                    (C2o - curmin) / (C1o - curmin);
                            end
                        end
                        switch this.Grid_modes{group}
                            case enumRelation.LowestScaled
                                return;
                            case enumRelation.Stroke
                                % Get largest shift and edit the value of the
                                % ... stroke in the same direction
                                sgn = 1;
                            case enumRelation.Piston
                                % Get largest shift and edit the value of the
                                % ... stroke in the opposite direction
                                sgn = -1;
                        end
                        curmax = max(shifts);
                        for rel = this.Relations
                            if rel.mode == enumRelation.Stroke || ...
                                    any(cons == rel.con1.index) || ...
                                    any(cons == rel.con2.index)
                                if isfield(data,'frame')
                                    data.frame(end+1) = rel.frame;
                                    data.frameshift(end+1) = sgn * curmax;
                                else
                                    data.frame = rel.frame;
                                    data.frameshift = sgn * curmax;
                                end
                            end
                        end
                    case enumRelation.Width
                        switch length(cons)
                            case 4
                                xvals = zeros(4,1);
                                for i = 1:4
                                    xvals(i) = ...
                                        this.Group.Connections(cons(i)).x;
                                end
                                % Determine order translation
                                % location of first connection
                                try
                                    indexes = zeros(4,1);
                                    temp = min(xvals);
                                    indexes(1) = find(xvals==temp);
                                    temp = min(xvals(xvals>temp));
                                    indexes(2) = find(xvals==temp);
                                    temp = min(xvals(xvals>temp));
                                    indexes(3) = find(xvals==temp);
                                    temp = max(xvals);
                                    indexes(4) = find(xvals==temp);
                                    if root == cons(indexes(1))
                                        % Middle should remain the same but shift up or
                                        % ... down
                                        shifts(indexes(1)) = shift;
                                        shifts(indexes(2)) = shift/2;
                                        shifts(indexes(3)) = shift/2;
                                        shifts(indexes(4)) = 0;
                                    elseif root == cons(indexes(2))
                                        % Boundaries should remain the same, but the
                                        % center should stretch
                                        shifts(indexes(1)) = 0;
                                        shifts(indexes(2)) = shift;
                                        shifts(indexes(3)) = -shift;
                                        shifts(indexes(4)) = 0;
                                    elseif root == cons(indexes(3))
                                        % Boundaries should remain the same, but the
                                        % center should stretch
                                        shifts(indexes(1)) = 0;
                                        shifts(indexes(2)) = -shift;
                                        shifts(indexes(3)) = shift;
                                        shifts(indexes(4)) = 0;
                                    else
                                        % Middle should remain the same but shift up or
                                        % ... down
                                        shifts(indexes(1)) = 0;
                                        shifts(indexes(2)) = shift/2;
                                        shifts(indexes(3)) = shift/2;
                                        shifts(indexes(4)) = shift;
                                    end
                                catch
                                    fprintf('err');
                                end
                            case 6
                                xvals = zeros(6,1);
                                for i = 1:6
                                    xvals(i) = ...
                                        this.Group.Connections(cons(i)).x;
                                end
                                % Determine order translation
                                % location of first connection
                                indexes = zeros(6,1);
                                temp = min(xvals);
                                indexes(1) = find(xvals==temp);
                                temp = min(xvals(xvals>temp));
                                indexes(2) = find(xvals==temp);
                                temp = min(xvals(xvals>temp));
                                indexes(3) = find(xvals==temp);
                                temp = min(xvals(xvals>temp));
                                indexes(4) = find(xvals==temp);
                                temp = min(xvals(xvals>temp));
                                indexes(5) = find(xvals==temp);
                                temp = max(xvals);
                                indexes(6) = find(xvals==temp);
                                if root == cons(indexes(1))
                                    shifts(indexes(1)) = shift;
                                    shifts(indexes(2)) = shift/2;
                                    shifts(indexes(3)) = shift/2;
                                    shifts(indexes(4)) = shift/2;
                                    shifts(indexes(5)) = shift/2;
                                    shifts(indexes(6)) = 0;
                                elseif root == cons(indexes(2))
                                    shifts(indexes(1)) = 0;
                                    shifts(indexes(2)) = shift;
                                    shifts(indexes(3)) = 0;
                                    shifts(indexes(4)) = 0;
                                    shifts(indexes(5)) = -shift;
                                    shifts(indexes(6)) = 0;
                                elseif root == cons(indexes(3))
                                    shifts(indexes(1)) = 0;
                                    shifts(indexes(2)) = 0;
                                    shifts(indexes(3)) = shift;
                                    shifts(indexes(4)) = -shift;
                                    shifts(indexes(5)) = 0;
                                    shifts(indexes(6)) = 0;
                                elseif root == cons(indexes(4))
                                    shifts(indexes(1)) = 0;
                                    shifts(indexes(2)) = 0;
                                    shifts(indexes(3)) = -shift;
                                    shifts(indexes(4)) = shift;
                                    shifts(indexes(5)) = 0;
                                    shifts(indexes(6)) = 0;
                                elseif root == cons(indexes(5))
                                    shifts(indexes(1)) = 0;
                                    shifts(indexes(2)) = -shift;
                                    shifts(indexes(3)) = 0;
                                    shifts(indexes(4)) = 0;
                                    shifts(indexes(5)) = shift;
                                    shifts(indexes(6)) = 0;
                                elseif root == cons(indexes(6))
                                    shifts(indexes(1)) = 0;
                                    shifts(indexes(2)) = shift/2;
                                    shifts(indexes(3)) = shift/2;
                                    shifts(indexes(4)) = shift/2;
                                    shifts(indexes(5)) = shift/2;
                                    shifts(indexes(6)) = shift;
                                end
                            otherwise
                                fprintf(['XXX A width mate is not working ' ...
                                    'because it does not contain 4' ...
                                    'elements XXX\n']);
                        end
                end
            end
            if any(isnan(shifts))
                fprintf('err');
            end
        end

        function color = getColor(this, index)
            if this.Group.isChanged; this.Group.update(); end
            count = 1;
            colors = ...
                [0.67, 0, 0; ...
                1, 0.33, 0.33; ...
                1, 0.67, 0; ...
                1, 1, 0.33; ...
                0, 0.67, 0; ...
                0.33, 1, 0.33; ...
                0.33, 1, 1; ...
                0, 0.67, 0.67; ...
                0, 0.67, 0; ...
                0.33, 0.33, 1; ...
                1, 0.33, 1; ...
                0.67, 0, 0.67; ...
                0.67, 0.67, 0.67; ...
                0.33, 0.33, 0.33];
            color = [0, 0, 0];
            for iGroup = this.Group.Model.Groups
                for RMan = iGroup.RelationManagers
                    if RMan.isChanged; RMan.update(); end
                    if RMan ~= this
                        for i = 1:size(RMan.Grid,1)
                            if any(RMan.Grid(i,:) == true)
                                count = count + 1;
                            end
                        end
                    else
                        for i = 1:size(RMan.Grid,1)
                            if i == index
                                while (count > 14)
                                    count = count - 14;
                                end
                                color = colors(count,:);
                                return;
                            end
                            if any(RMan.Grid(i,:) == true)
                                count = count + 1;
                            end
                        end
                    end
                end
            end
        end

        function Label = getLabel(this, mode, con1, con2)
            Label = '';
            for i = 1:length(this.Grid_modes)
                if this.Grid_modes{i} == mode
                    % Find a relation that matches
                    for Rel = this.Relations
                        if Rel.mode == mode && (con1 == Rel.con1 || con1 == Rel.con2 || ...
                                con2 == Rel.con1 || con2 == Rel.con2)
                            Label = Rel.name;
                            return;
                        end
                    end
                end
            end
        end
    end
end

function [yesno, checked] = are_rows_connected(grid,target,start,checked)
    if target == start; yesno = true; return; end
    yesno = false;
    cols = find(grid(start,:)==true);
    for i = cols
        rows = find(grid(:,i)==true);
        rows(checked(rows)) = [];
        for j = rows
            if j ~= start
                checked(j) = true;
                [yesno, checked] = are_rows_connected(grid,target,j,checked);
                if yesno; return; end
            end
        end
    end
end

function [el] = custmink(array,k)
    el = -inf;
    for i = 1:k
        el = min(array(array>el));
    end
end

function [el] = custmaxk(array,k)
    el = +inf;
    for i = 1:k
        el = max(array(array<el));
    end
end