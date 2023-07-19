classdef Sensor < handle
    % models a Sensor in the Model,
    % which logs information throughout the cycle
    
    properties (Constant)
        ActiveColor = [0 1 0];
        NormalColor = [1 0 1]; % magenta
    end
    
    
    properties
        name;
        Body;
        Model;
        LocationStyle;
        averaging; % 1 for phase based, 2 for time based
        IndependentVariable; % May be time or angle
        DataType; % Cell Array
        Data; % Cell Array
        dimensions; % 1 for point, 2 for line
        PntCount; % Number of elements along a line
        Nodes; % Vector
        Interp; % Matrix
        
        % Derived Components
        PlotCoordinates; % Vector 1xN
        LocalCoordinates;
        
        isActive logical = false;
        
        index = 0; % adding to the data set
        GUIObjects;
    end
    
    methods
        function this = Sensor(Modelobj,Body)
            if nargin == 2
                this.Body = Body;
                this.Model = Modelobj;
                this.index = 0;
                
                % Define the name
                this.name = getProperName( 'Sensor' );
                
                % Define the location
                notdone = true;
                source = {...
                    'Body Center','Body xmax',...
                    'Body xmin','Body ymax',...
                    'Body ymin','Body xaxis',...
                    'Body yaxis'};
                while notdone
                    index = listdlg('PromptString','What is the position of this Sensor?',...
                        'SelectionMode','single',...
                        'ListString',source);
                    if index ~= 0
                        notdone = false;
                    end
                end
                this.LocationStyle = source{index};
                
                % Define the independent variable
                notdone = true;
                source = {'Phase','Time'};
                while notdone
                    index = listdlg('PromptString','What is the independent variable?',...
                        'SelectionMode','single',...
                        'ListString',source);
                    if index ~= 0
                        notdone = false;
                    end
                end
                this.averaging = index;
                
                % Define the dependent variable
                notdone = true;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Available variables
                source = {'T','P','turb','Re','U'};
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                while notdone
                    index = listdlg('PromptString','What is the dependent variable?',...
                        'SelectionMode','single',...
                        'ListString',source);
                    if index ~= 0
                        notdone = false;
                    end
                end
                this.DataType = source{index};
                
                % Define the point count
                switch this.LocationStyle
                    case {'Body xaxis','Body yaxis'}
                        notdone = true;
                        while notdone
                            answer = inputdlg('How many sample points along the line?',...
                                'Integer only',[1 200]);
                            test = str2double(answer);
                            if ~isnan(test)
                                if floor(test) == test
                                    this.PntCount = test-1;
                                    notdone = false;
                                end
                            end
                        end
                end
                Body.addSensor(this);
                this.update();
            end
        end
        function deReference(this)
            if ~isempty(this.Model) && isvalid(this.Model)
                for i = length(this.Model.Sensors):-1:1
                    if this.Model.Sensors(i) == this
                        this.Model.Sensors(i) = [];
                        break;
                    end
                end
            end
            if ~isempty(this.Body) && isvalid(this.Body)
                for i = length(this.Body.Sensors):-1:1
                    if this.Body.Sensors(i) == this
                        this.Body.Sensors(i) = [];
                        break;
                    end
                end
                this.Body.change();
            end
            this.removeFromFigure(gca);
            this.delete();
        end
        function isit = isValid(this)
            isit = isvalid(this) && ~isempty(this.Body) && ...
                ~isempty(this.Model) && isvalid(this.Body) && isvalid(this.Model);
        end
        function item = get(this,PropertyName)
            switch PropertyName
                case 'Name'
                    item = this.name;
                case 'Samples'
                    item = this.PntCount + 1;
                otherwise
                    fprintf(['XXX Sensor GET Inteface for ' PropertyName ...
                        ' is not found XXX\n']);
            end
        end
        function set(this,PropertyName,Item)
            switch PropertyName
                case 'Name'
                    this.name = Item;
                case 'Samples'
                    this.PntCount = Item - 1;
                    this.update();
                otherwise
                    fprintf(['XXX Sensor SET Inteface for ' PropertyName ...
                        ' is not found XXX\n']);
            end
        end
        function update(this)
            if ~this.Body.isDiscretized()
                this.Body.discretize();
                if ~this.Body.isDiscretized()
                    fprintf(['XXX Sensor: ' this.name ...
                        ' Update failed XXX\n'])
                    return;
                end
            end
            switch this.LocationStyle
                case 'Body Center'
                    % place the point right in the middle of the body volume and use
                    % the nodes as the interpolation points
                    this.dimensions = 1; % Point
                    [~,~,xmin,xmax] = this.Body.limits(enumOrient.Vertical);
                    [~,~,ymin,ymax] = this.Body.limits(enumOrient.Horizontal);
                    x = (xmin+xmax)/2; y = (ymin+ymax)/2;
                    this.LocalCoordinates = [x; y];
                case 'Body xmax'
                    % place the point right at the middle of the xmax edge.
                    this.dimensions = 1; % Point
                    [~,~,~,xmax] = this.Body.limits(enumOrient.Vertical);
                    [~,~,ymin,ymax] = this.Body.limits(enumOrient.Horizontal);
                    x = xmax; y = (ymin+ymax)/2;
                    this.LocalCoordinates = [x; y];
                case 'Body xmin'
                    % place the point right at the middle of the xmin edge.
                    this.dimensions = 1; % Point
                    [~,~,xmin,~] = this.Body.limits(enumOrient.Vertical);
                    [~,~,ymin,ymax] = this.Body.limits(enumOrient.Horizontal);
                    x = xmin; y = (ymin+ymax)/2;
                    this.LocalCoordinates = [x; y];
                case 'Body ymax'
                    % place the point right at the middle of the ymax edge.
                    this.dimensions = 1; % Point
                    [~,~,xmin,xmax] = this.Body.limits(enumOrient.Vertical);
                    [~,~,~,ymax] = this.Body.limits(enumOrient.Horizontal);
                    x = (xmin+xmax)/2; y = ymax;
                    this.LocalCoordinates = [x; y];
                case 'Body ymin'
                    % place the point right at the middle of the ymin edge.
                    this.dimensions = 1; % Point
                    [~,~,xmin,xmax] = this.Body.limits(enumOrient.Vertical);
                    [~,~,ymin,~] = this.Body.limits(enumOrient.Horizontal);
                    x = (xmin+xmax)/2; y = ymin;
                    this.LocalCoordinates = [x; y];
                case 'Body yaxis'
                    % Place the point along the xaxis align volume center
                    this.dimensions = 2; % Line
                    [~,~,xmin,xmax] = this.Body.limits(enumOrient.Vertical);
                    [~,~,ymin,ymax] = this.Body.limits(enumOrient.Horizontal);
                    x1 = (xmin+xmax)/2; y1 = ymin;
                    x2 = (xmin+xmax)/2; y2 = ymax;
                    this.PlotCoordinates = linspace(y1,y2,this.PntCount+1);
                    this.LocalCoordinates = [x1 y1; x2 y2];
                case 'Body xaxis'
                    % Place the point along the yaxis align volume center
                    this.dimensions = 2; % Line
                    [~,~,xmin,xmax] = this.Body.limits(enumOrient.Vertical);
                    [~,~,ymin,ymax] = this.Body.limits(enumOrient.Horizontal);
                    x1 = xmin; y1 = (ymin+ymax)/2;
                    x2 = xmax; y2 = (ymin+ymax)/2;
                    this.PlotCoordinates = linspace(x1,x2,this.PntCount+1);
                    this.LocalCoordinates = [x1 y1; x2 y2];
            end
            if this.dimensions == 1
                % Point
                loc = Pnt2D(x,y);
                [nds,intrp] = findClosest4(loc,this.Body);
                this.Nodes = nds;
                this.Interp = intrp;
            else
                % Line
                this.Nodes = zeros(this.PntCount+1,4);
                this.Interp = zeros(this.PntCount+1,4);
                loc(this.PntCount+1) = Pnt2D();
                for i = 1:this.PntCount+1
                    loc(i) = Pnt2D(...
                        x1*(this.PntCount-i+1)/(this.PntCount) + x2*(i-1)/this.PntCount,...
                        y1*(this.PntCount-i+1)/(this.PntCount) + y2*(i-1)/this.PntCount);
                    [nds, intrp] = findClosest4(loc(i),this.Body);
                    this.Nodes(i,1:length(nds)) = nds;
                    this.Interp(i,1:length(intrp)) = intrp;
                end
                % Simplify
                % Form the nodes array
                tempNodes = zeros(numel(this.Nodes),1);
                start = 1;
                len = 3;
                for i = 1:this.PntCount+1
                    tempNodes(start:start+len) = this.Nodes(i,:)';
                    start = start + len + 1;
                end
                tempNodes = unique(tempNodes(tempNodes>0));
                tempNodes = sort(tempNodes);
                tempInterp = zeros(length(tempNodes),this.PntCount+1);
                for i = 1:this.PntCount+1
                    for j = 1:length(tempNodes)
                        where = find(this.Nodes(i,:) == tempNodes(j));
                        if isempty(where)
                            tempInterp(j,i) = 0;
                        else
                            tempInterp(j,i) = this.Interp(i,where(1));
                        end
                    end
                end
                this.Interp = tempInterp;
                this.Nodes = tempNodes;
            end
            if this.Model.showSensors
                this.show(gca);
            end
        end
        function reset(this)
            this.IndependentVariable = [];
            this.index = 0;
            this.Data = [];
        end
        
        function SourceData = getData(this,Simulation) % Changed the getter to return SourceData based off the structure, function is only used if a model has no sensors
            property = this.DataType;
            switch property
                case 'T'
                    SourceData = Simulation.T(this.Nodes);
                case 'P'
                    SourceData = Simulation.P(this.Nodes);
                case 'turb'
                    SourceData = Simulation.turb(this.Nodes);
                    % Matthias: Added Re and U Sensor.
                    % 'U'not working, outputs only zeros
                case 'Re'
                    SourceData = Simulation.RE(this.Nodes);
                case 'U'
                    SourceData = Simulation.U(this.Nodes);
                    
                otherwise
                    fprintf(['XXX Property: ' property ...
                        ' not supported in the Sensor Class XXX\n']);
                    return;
            end
            % Get the data by interpolating the cells
            switch this.averaging
                case 1 % Angular Recording with overwrite
                    this.index = Simulation.Inc;
                    if isempty(this.IndependentVariable)
                        LEN = Frame.NTheta-1;
                        AInc = 2*pi/(Frame.NTheta-1);
                        this.IndependentVariable = linspace(0,AInc*LEN,LEN);
                    end
                case 2 % Temporal Recording
                    this.index = this.index + 1;
                    this.IndependentVariable(this.index) = Simulation.curTime;
            end
            switch this.dimensions
                case 1
                    % Grab a single point
                    this.Data(this.index) = sum(this.Interp(:).*SourceData(:));
                case 2
                    % Grab a vector of points
                    if isempty(this.Data)
                        this.Data(this.PntCount+1,1) = 0;
                    end
                    for j = 1:this.PntCount+1
                        this.Data(j,this.index) = sum(this.Interp(:,j).*SourceData(:));
                    end
            end
        end
        
        function plotData(this,is_saving,ModelName)
            oldfigure = gcf;
            oldaxes = gca;
            h = figure();
            set(h,'color','w');
            a = gca;
            switch this.DataType
                case 'T'
                    titleStr = [this.name ': Temperature vs '];
                    label2 = 'Temperature (K)';
                    switch this.dimensions
                        case 1
                            a.YAxis.TickLabelFormat = '%.1f';
                        case 2
                            a.YAxis.TickLabelFormat = '%.2f';
                    end
                case 'P'
                    titleStr = [this.name ': Pressure vs '];
                    label2 = 'Pressure (Pa)';
                    switch this.dimensions
                        case 1
                            a.YAxis.TickLabelFormat = '%.0f';
                        case 2
                            a.YAxis.TickLabelFormat = '%.2f';
                    end
                case 'turb'
                    titleStr = [this.name ': Turbulent Weight vs '];
                    label2 = 'Turbulence Weight (0-1 for static nodes)';
                    switch this.dimensions
                        case 1
                            a.YAxis.TickLabelFormat = '%.2f';
                        case 2
                            a.YAxis.TickLabelFormat = '%.2f';
                    end
                    
                    % Matthias: Added Re and U plot
                case 'Re'
                    titleStr = [this.name ': Reynolds Number vs '];
                    label2 = 'Re';
                    switch this.dimensions
                        case 1
                            a.YAxis.TickLabelFormat = '%.0f';
                        case 2
                            a.YAxis.TickLabelFormat = '%.2f';
                    end
                case 'U'
                    titleStr = [this.name ': Velocity vs '];
                    label2 = 'Velocity (m/s)';
                    switch this.dimensions
                        case 1
                            a.YAxis.TickLabelFormat = '%.2f';
                        case 2
                            a.YAxis.TickLabelFormat = '%.2f';
                    end
                    
            end
            switch this.dimensions
                case 1
                    % Make a line plot
                    if length(this.Data) == length(this.IndependentVariable)
                        plot(this.IndependentVariable,this.Data);
                    else
                        plot(this.Data);
                        fprintf('XXX Sensor could not plot due to unequal lengthed vectors. XXX\n');
                    end
                    switch this.averaging
                        case 1
                            % Make a plot in relation to angle
                            titleStr = [titleStr 'angle'];
                            title(titleStr, 'Interpreter','none');
                            xlabel('angle (rad)');
                            ylabel(label2);
                            a.XAxis.TickLabelFormat = '%.2f';
                        case 2
                            % Make a plot in relation to time
                            titleStr = [titleStr 'time'];
                            title(titleStr, 'Interpreter','none');
                            xlabel('time (s)');
                            ylabel(label2);
                            a.XAxis.TickLabelFormat = '%.0f';
                    end
                case 2
                    % Make a surface plot
                    [X,Y] = meshgrid(this.IndependentVariable,this.PlotCoordinates);
                    Z = this.Data;
                    s = surf(X,Y,Z);
                    s.EdgeColor = 'none';
                    view(0,90);
                    xlim([0, max(this.IndependentVariable)]);
                    ylim([min(this.PlotCoordinates), max(this.PlotCoordinates)]);
                    colormap jet;
                    hcb = colorbar;
                    switch this.DataType
                        case 'T'
                            yt=get(hcb,'Ticks');
                            set(hcb,'XTickLabel',strtrim(cellstr(num2str(yt','%.1f'))));
                        case 'P'
                            yt=get(hcb,'Ticks');
                            set(hcb,'XTickLabel',strtrim(cellstr(num2str(yt','%.2e'))));
                        case 'turb'
                            yt=get(hcb,'Ticks');
                            set(hcb,'XTickLabel',strtrim(cellstr(num2str(yt','%.2f'))));
                        case 'Re'
                            yt=get(hcb,'Ticks');
                            set(hcb,'XTickLabel',strtrim(cellstr(num2str(yt','%.0f'))));
                        case 'U'
                            yt=get(hcb,'Ticks');
                            set(hcb,'XTickLabel',strtrim(cellstr(num2str(yt','%.2f'))));
                    end
                    switch this.averaging
                        case 1
                            % Make a plot in relation to angle
                            titleStr = [titleStr 'angle'];
                            %               t = title(titleStr, 'Interpreter','none');
                            xlabel('angle (rad)');
                            ylabel('position (m)');
                            zlabel(label2);
                        case 2
                            % Make a plot in relation to time
                            titleStr = [titleStr 'time'];
                            %               t = title(titleStr, 'Interpreter','none');
                            xlabel('time (s)');
                            ylabel('position (m)');
                            zlabel(label2);
                    end
                    ylabel(hcb, titleStr, 'Interpreter','none');
            end
            
            if is_saving
                frame = getframe(h);
                im = frame2im(frame);
                [imind,cm] = rgb2ind(im,256);
                data = struct(...
                    'Name',this.name,...
                    'IndependentVariable',this.IndependentVariable,...
                    'DependentVariable',this.Data);
                if isempty(this.Body.Group.Model.outputPath)
                    str = [titleStr];
                else
                    str = [this.Body.Group.Model.outputPath '\' ...
                           titleStr];
                end
                str = [str(1:3), replace(str(4:end),':',' -')];
                save([str '.mat'],'data');
                imwrite(imind,cm,[str '.png']);
            end
            
            close(h);
            figure(oldfigure);
            axes(oldaxes);
        end
        
        function color = getColor(this)
            if this.isActive
                color = Sensor.ActiveColor;
            else
                color = Sensor.NormalColor;
            end
        end
        
        function updateColor(this)
            if ~isempty(this.GUIObjects)
                for iGraphicsObject = this.GUIObjects
                    set(iGraphicsObject,'FaceColor',this.getColor());
                end
            end
        end
        
        function removeFromFigure(this,AxisReference)
            if ~isempty(this.GUIObjects)
                children = get(AxisReference,'Children');
                for obj = this.GUIObjects
                    if isgraphics(obj)
                        for i = length(children):-1:1
                            if isgraphics(children(i)) && children(i) == obj
                                children(i).delete;
                                break;
                            end
                        end
                    end
                end
                this.GUIObjects = [];
            end
        end
        function show(this,AxisReference)
            this.removeFromFigure(AxisReference);
            if this.isActive
                color = Sensor.ActiveColor;
            else
                color = Sensor.NormalColor;
            end
            % Plot a yellow symbol where the sensor is
            if size(this.LocalCoordinates,2) == 2
                % It is a line
                pos1 = RotMatrix(this.Body.Group.Position.Rot-pi/2)*this.LocalCoordinates(1,:)';
                pos2 = RotMatrix(this.Body.Group.Position.Rot-pi/2)*this.LocalCoordinates(2,:)';

                % Offset by the group posiiton
                pos1(1) = pos1(1) +this.Body.Group.Position.x;
                pos2(1) = pos2(1) +this.Body.Group.Position.x;
                pos1(2) = pos1(2) +this.Body.Group.Position.y;
                pos2(2) = pos2(2) +this.Body.Group.Position.y;

                this.GUIObjects = line([pos1(1) pos2(1)],[pos1(2) pos2(2)],...
                    'Color',color,'Marker','o','MarkerSize',8);
            else
                % It is a point
                pos = RotMatrix(this.Body.Group.Position.Rot-pi/2)*this.LocalCoordinates(:);

                % Offset by the group posiiton
                pos(1) = pos(1) + this.Body.Group.Position.x;
                pos(2) = pos(2) +this.Body.Group.Position.y;

                this.GUIObjects = line(pos(1),pos(2),...
                    'Color',color,'Marker','o','MarkerSize',8);
            end
        end
    end
    
end

