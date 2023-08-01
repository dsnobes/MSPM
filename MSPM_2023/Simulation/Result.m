classdef Result < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        % For Display
        Model Model;

        XDATA
        YDATA
        Cmap
        Data
        % Data.t
        % Data.T
        % Data.P
        % Data.rho
        % Data.U

        OriginalAxes;
        Fig;
        Axes;
        GraphicsObjects;
    end

    methods

        function this = Result()
        end

        % Plot
        function animateNode(this,propertyname,cornerpnts,bodypnts,frequency,~,~,input_title,oldaxes)
            %% Currently this is restricted to constructs lying on the vertical axis

            if isfield(this.Data,propertyname)
                data = this.Data.(propertyname);

                start = 1;
                % With Each column in data
                % Get coordinates

                h = figure();
                try
                    set(h,'color','w');
                    a = gca;
                    axis tight manual;
                    a.XLim = oldaxes.XLim;
                    a.YLim = oldaxes.YLim;
                    a.XAxis.TickLabelFormat = '%.2f';
                    a.YAxis.TickLabelFormat = '%.2f';
                    switch propertyname
                        case 'T'; colorLabel = 'Temperature (K)';
                        case 'P'; colorLabel = 'Pressure (Pa)';
                        case 'dP'; colorLabel = 'Pressure Buildup (Pa)';
                        case 'turb'; colorLabel = 'Proportion of Fully Turbulence (0-1)';
                        case 'cond'
                            colorLabel = 'Natural Logarithm of Sum of absolute Power Exchange per unit Volume (ln(W/m^3))';
                            data = log(data+1);
                            % Matthias: Other option for log scale is to set axis to 'log'
                            %                   set(a,'ColorScale','log');
                        case 'RE'; colorLabel = 'Reynolds Number';
                    end
                    xlabel('X (m)');
                    ylabel('Y (m)');
                    timepnts = this.Data.t;

                    if nargin > 7
                        if ~isempty(this.Model.outputPath)
                            filename = [this.Model.outputPath '\' input_title '_Animated ' propertyname '.gif'];
                        else
                            filename = [input_title '_Animated ' propertyname '.gif'];
                        end
                    else
                        if ~isempty(this.Model.outputPath)
                            filename = [this.Model.outputPath '\' this.Model.name '_Animated ' propertyname '.gif'];
                        else
                            filename = [this.Model.name '_Animated ' propertyname '.gif'];
                        end
                    end
                    cmap = jet(100);
                    colormap(cmap);
                    data(data==0) = NaN();
                    vals = linspace(min(min(data(start:end,:))),max(max(data(start:end,:))),7);
                    mapper = linspace(min(min(data(start:end,:))),max(max(data(start:end,:))),size(cmap,1));
                    if vals(1) == vals(end)
                        fprintf('ERR: minimum == maximum (in result.animateNode) \n');
                        fprintf(['... Error occured with property: ' propertyname '\n']);
                        try
                            close(h);
                        catch
                        end
                        return;
                    end
                    if isnan(vals(1)) || isnan(vals(end))
                        try
                            close(h);
                        catch
                        end
                        return;
                    end
                    caxis([vals(1) vals(end)]);

                    if mapper(1) ~= mapper(2)
                        data(isnan(data)) = 0;
                        N_XData = zeros(4,size(data,1));
                        N_YData = N_XData;
                        B_XData = zeros(4,length(bodypnts));
                        B_YData = B_XData;
                        TextHandle = text(a.XLim(1)+0.01*(a.XLim(2)-a.XLim(1)),...
                            a.YLim(2)-0.05*(a.YLim(2)-a.YLim(1)),'');
                        hcb = colorbar('Ticks',vals, 'Limits',[vals(1) vals(end)]);
                        ylabel(hcb, colorLabel);
                        yt=get(hcb,'Ticks');
                        switch propertyname
                            case 'T'
                                set(hcb,'XTickLabel',strtrim(cellstr(num2str(yt','%.1f'))));
                            case 'P'
                                set(hcb,'XTickLabel',strtrim(cellstr(num2str(yt','%.2e'))));
                            case 'turb'
                                set(hcb,'XTickLabel',strtrim(cellstr(num2str(yt','%.2f'))));
                            case 'cond'
                                set(hcb,'XTickLabel',strtrim(cellstr(num2str(yt','%.2f'))));
                            case 'dP'
                                set(hcb,'XTickLabel',strtrim(cellstr(num2str(yt','%.1e'))));
                            case 'RE'
                                set(hcb,'XTickLabel',strtrim(cellstr(num2str(yt','%.2e'))));
                        end
                        C = zeros(size(data,1),1);
                        %C = zeros(size(data,1),1,3);
                        for i = 1:size(data,2)-1
                            angindex = 1+mod(i,Frame.NTheta-1);
                            if i == 1
                                proceed = true;
                                FirstTime = true;
                            else
                                FirstTime = false;
                                t = t + timepnts(i) - timepnts(i-1);
                                if t > frequency
                                    proceed = true;
                                else
                                    proceed = false;
                                end
                            end
                            if proceed
                                if true || ~any(data(:,i)==0) || strcmp(propertyname,'turb')
                                    t = 0;
                                    n = 1;
                                    if FirstTime
                                        for item = start:size(data,1)
                                            %C(n,1,:) = interp1(mapper,cmap,data(item,i));
                                            C(n) = data(item,i);
                                            switch cornerpnts{item}(1,1)
                                                case 1 % Static Position
                                                    % Cut off the first column
                                                    p = cornerpnts{item}(:,2:5);
                                                    N_XData(:,n) = [p(1,4) - p(1,1); p(1,4) + p(1,2); ...
                                                        p(1,4) + p(1,1); p(1,4) - p(1,2)];
                                                    N_YData(:,n) = [p(2,4) - p(2,1); p(2,4) + p(2,2); ...
                                                        p(2,4) + p(2,1); p(2,4) - p(2,2)];
                                                    if all(p(:,3) == 0)
                                                        % Origin Centered
                                                        n = n + 1;
                                                    else
                                                        % Ring Shaped
                                                        N_XData(:,n+1) = N_XData(:,n) + p(1,3);
                                                        N_YData(:,n+1) = N_YData(:,n) + p(2,3);
                                                        C(n+1) = C(n);
                                                        n = n + 2;
                                                    end
                                                case 2 % One Dimension Stretch
                                                    % Cut off the first column
                                                    temp = 4+angindex;
                                                    p = [cornerpnts{item}(:,2:4) ...
                                                        cornerpnts{item}(:,temp)];
                                                    N_XData(:,n) = [p(1,1); ...
                                                        p(1,1) + p(1,2); ...
                                                        p(1,1) + p(1,2) + p(1,4); ...
                                                        p(1,1) + p(1,4)];
                                                    N_YData(:,n) = [p(2,1); p(2,1) + p(2,2); ...
                                                        p(2,1) + p(2,2) + p(2,4); ...
                                                        p(2,1) + p(2,4)];
                                                    if all(p(:,3) == 0)
                                                        % Origin Centered
                                                        n = n + 1;
                                                    else
                                                        % Ring Shaped
                                                        N_XData(:,n+1) = N_XData(:,n) + p(1,3);
                                                        N_YData(:,n+1) = N_YData(:,n) + p(2,3);
                                                        C(n+1) = C(n);
                                                        n = n + 2;
                                                    end
                                                case 3 % Two Dimension Stretch
                                                    temp = 2+angindex;
                                                    p = [cornerpnts{item}(1:2,temp) ...
                                                        cornerpnts{item}(1:2,2) ...
                                                        cornerpnts{item}(3:4,2) ...
                                                        cornerpnts{item}(3:4,temp)];
                                                    N_XData(:,n) = [p(1,1); p(1,1) + p(1,2); ...
                                                        p(1,1) + p(1,2) + p(1,4); ...
                                                        p(1,1) + p(1,4)];
                                                    N_YData(:,n) = [p(2,1); p(2,1) + p(2,2); ...
                                                        p(2,1) + p(2,2) + p(2,4); ...
                                                        p(2,1) + p(2,4)];
                                                    if all(p(:,3) == 0)
                                                        % Origin Centered
                                                        n = n + 1;
                                                    else
                                                        % Ring Shaped
                                                        N_XData(:,n+1) = N_XData(:,n) + p(1,3);
                                                        N_YData(:,n+1) = N_YData(:,n) + p(2,3);
                                                        C(n+1) = C(n);
                                                        n = n + 2;
                                                    end
                                                case 4 % Translation
                                                    temp = 4+angindex;
                                                    p = [cornerpnts{item}(:,2:4) ...
                                                        cornerpnts{item}(:,temp)];
                                                    N_XData(:,n) = [p(1,4) - p(1,1); p(1,4) + p(1,2); ...
                                                        p(1,4) + p(1,1); p(1,4) - p(1,2)];
                                                    N_YData(:,n) = [p(2,4) - p(2,1); p(2,4) + p(2,2); ...
                                                        p(2,4) + p(2,1); p(2,4) - p(2,2)];
                                                    if all(p(:,3) == 0)
                                                        % Origin Centered
                                                        n = n + 1;
                                                    else
                                                        % Ring Shaped
                                                        N_XData(:,n+1) = N_XData(:,n) + p(1,3);
                                                        N_YData(:,n+1) = N_YData(:,n) + p(2,3);
                                                        C(n+1) = C(n);
                                                        n = n + 2;
                                                    end
                                            end
                                        end
                                        for b = 1:length(bodypnts)
                                            if ndims(bodypnts{b}) == 2 %#ok<ISMAT>
                                                B_XData(:,b) = bodypnts{b}(1,:);
                                                B_YData(:,b) = bodypnts{b}(2,:);
                                            else
                                                B_XData(:,b) = bodypnts{b}(1,:,angindex);
                                                B_YData(:,b) = bodypnts{b}(2,:,angindex);
                                            end
                                        end
                                        C(n+1:end) = [];
                                        %C(n+1:end,1,:) = zeros(0,1,3);
                                        N_XData(:,n+1:end) = zeros(4,0);
                                        N_YData(:,n+1:end) = zeros(4,0);
                                        PatchHandle = patch(N_XData,N_YData,real(C),'LineStyle','none');
                                        PatchHandleBodies = patch(B_XData,B_YData,zeros(length(bodypnts),1),'EdgeColor','k',...
                                            'FaceColor','none','LineWidth',1);
                                    else
                                        for item = start:size(data,1)
                                            C(n) = data(item,i);
                                            switch cornerpnts{item}(1,1)
                                                case 1 % Static Position
                                                    if all(cornerpnts{item}(:,4) == 0)
                                                        % Origin Centered
                                                        n = n + 1;
                                                    else
                                                        % Ring Shaped
                                                        C(n+1) = C(n);
                                                        n = n + 2;
                                                    end
                                                case 2 % One Dimension Stretch
                                                    % Cut off the first column
                                                    temp = 5+mod(i,Frame.NTheta-1);
                                                    p = [cornerpnts{item}(:,2:4) ...
                                                        cornerpnts{item}(:,temp)];
                                                    N_XData(3:4,n) = [p(1,1) + p(1,2) + p(1,4); ...
                                                        p(1,1) + p(1,4)];
                                                    N_YData(3:4,n) = [p(2,1) + p(2,2) + p(2,4); ...
                                                        p(2,1) + p(2,4)];
                                                    if all(p(:,3) == 0)
                                                        % Origin Centered
                                                        n = n + 1;
                                                    else
                                                        % Ring Shaped
                                                        N_XData(:,n+1) = N_XData(:,n) + p(1,3);
                                                        N_YData(:,n+1) = N_YData(:,n) + p(2,3);
                                                        C(n+1) = C(n);
                                                        n = n + 2;
                                                    end
                                                case 3 % Two Dimension Stretch
                                                    temp = 3+mod(i,Frame.NTheta-1);
                                                    p = [cornerpnts{item}(1:2,temp) ...
                                                        cornerpnts{item}(1:2,2) ...
                                                        cornerpnts{item}(3:4,2) ...
                                                        cornerpnts{item}(3:4,temp)];
                                                    N_XData(:,n) = [p(1,1); p(1,1) + p(1,2); ...
                                                        p(1,1) + p(1,2) + p(1,4); ...
                                                        p(1,1) + p(1,4)];
                                                    N_YData(:,n) = [p(2,1); p(2,1) + p(2,2); ...
                                                        p(2,1) + p(2,2) + p(2,4); ...
                                                        p(2,1) + p(2,4)];
                                                    if all(p(:,3) == 0)
                                                        % Origin Centered
                                                        n = n + 1;
                                                    else
                                                        % Ring Shaped
                                                        N_XData(:,n+1) = N_XData(:,n) + p(1,3);
                                                        N_YData(:,n+1) = N_YData(:,n) + p(2,3);
                                                        C(n+1) = C(n);
                                                        n = n + 2;
                                                    end
                                                case 4 % Translation
                                                    temp = 5+mod(i,Frame.NTheta-1);
                                                    p = [cornerpnts{item}(:,2:4) ...
                                                        cornerpnts{item}(:,temp)];
                                                    N_XData(:,n) = [p(1,4) - p(1,1); p(1,4) + p(1,2); ...
                                                        p(1,4) + p(1,1); p(1,4) - p(1,2)];
                                                    N_YData(:,n) = [p(2,4) - p(2,1); p(2,4) + p(2,2); ...
                                                        p(2,4) + p(2,1); p(2,4) - p(2,2)];
                                                    if all(p(:,3) == 0)
                                                        % Origin Centered
                                                        n = n + 1;
                                                    else
                                                        % Ring Shaped
                                                        N_XData(:,n+1) = N_XData(:,n) + p(1,3);
                                                        N_YData(:,n+1) = N_YData(:,n) + p(2,3);
                                                        C(n+1) = C(n);
                                                        n = n + 2;
                                                    end
                                            end
                                        end
                                        for b = 1:length(bodypnts)
                                            if ndims(bodypnts{b}) == 2 %#ok<ISMAT>
                                                %B_XData(:,b) = bodypnts{b}(1,:);
                                                %B_YData(:,b) = bodypnts{b}(2,:);
                                            else
                                                temp = 1 + mod(i,Frame.NTheta-1);
                                                B_XData(:,b) = bodypnts{b}(1,:,temp);
                                                B_YData(:,b) = bodypnts{b}(2,:,temp);
                                            end
                                        end
                                    end
                                    set(PatchHandle,'XData',N_XData);
                                    set(PatchHandle,'YData',N_YData);
                                    set(PatchHandleBodies,'XData',B_XData);
                                    set(PatchHandleBodies,'YData',B_YData);
                                    set(PatchHandle,'CData',real(C));
                                    set(TextHandle,'String',[num2str(round(timepnts(i),2)) ' seconds'], 'FontSize', 18);
                                    drawnow;

                                    % Capture the plot as an image
                                    %                 try
                                    h.Position = [0, 0, 1000, 1000]; % won't go above screen resolution sadly, but want it to be square
                                    set(a, 'FontSize', 18)                    
                                    frame = getframe(h);
                                    %                 catch
                                    %                   return;
                                    %                 end
                                    im = frame2im(frame);
                                    [imind,cm] = rgb2ind(im,256);

                                    % Write to the GIF File
                                    try
                                        if i == 1
                                            imwrite(imind,cm,filename,'gif','Loopcount',inf,'DelayTime',0);
                                        else
                                            imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0);
                                        end
                                    catch
                                        fprintf('XXX GIF write error XXX\n');
                                        fprintf(['... propertyname = ' propertyname 'XXX\n']);
                                    end
                                else
                                    fprintf('XXX: Not ~any(data(:,i)==0) || strcmp(propertyname,"turb") in Result.AnimateNode\n');
                                    fprintf('... Error occured in the animation generation, where it is expected that ... \n');
                                    fprintf('... properties, other than Turbulence should not have a value of 0. \n');
                                    fprintf(['... propertyname = ' propertyname 'XXX\n']);
                                    break;
                                end
                            end
                        end
                    end
                catch
                end
                try
                    close(h);
                catch
                end
            end
        end

        function animateFace(this,propertyname,cornerpnts,bodypnts,frequency,~,~,input_title,oldaxes)
            %% Currently this is restricted to constructs lying on the vertical axis
            if isfield(this.Data,propertyname)
                data = this.Data.(propertyname);
                start = 1;
                % With Each column in data
                % Get coordinates

                h = figure();
                try
                    set(h,'color','w');
                    a = gca;
                    axis tight manual;
                    a.XLim = oldaxes.XLim;
                    a.YLim = oldaxes.YLim;
                    xlabel('X (m)');
                    ylabel('Y (m)');
                    timepnts = this.Data.t;

                    if nargin > 7
                        if ~isempty(this.Model.outputPath)
                            filename = [this.Model.outputPath '\' input_title '_Animated ' propertyname '.gif'];
                        else
                            filename = [input_title '_Animated ' propertyname '.gif'];
                        end
                    else
                        if ~isempty(this.Model.outputPath)
                            filename = [this.Model.outputPath '\' this.Model.name '_Animated ' propertyname '.gif'];
                        else
                            filename = [this.Model.name '_Animated ' propertyname '.gif'];
                        end
                    end
                    minimum = 0;
                    var = abs(data(start:end,:));
                    maximum = prctile(var(:),100);
                    %vals = linspace(min(min(data(start:end,:))),max(max(data(start:end,:))),7);
                    %mapper = linspace(min(min(data(start:end,:))),max(max(data(start:end,:))),size(cmap,1));
                    if minimum == maximum
                        fprintf('ERR: minimum == maximum (in result.animateFace) \n');
                        fprintf(['... Error occured with property: ' propertyname '\n']);
                        try
                            close(h);
                        catch
                        end
                        return;
                    end

                    data(isnan(data)) = 0;
                    F_XData = zeros(1,size(data,1));
                    F_YData = F_XData;
                    F_UxData = F_XData;
                    F_UyData = F_XData;
                    B_XData = zeros(4,length(bodypnts));
                    B_YData = B_XData;
                    TextHandle = text(a.XLim(1)+0.01*(a.XLim(2)-a.XLim(1)),...
                        a.YLim(2)-0.05*(a.YLim(2)-a.YLim(1)),'');
                    hold on;
                    switch propertyname
                        case 'U'
                            base_size = 0.1;
                        case 'dP'
                            base_size = 20;
                    end
                    for i = 1:size(data,2)-1
                        angindex = 1+mod(i,Frame.NTheta-1);
                        if i == 1; proceed = true; FirstTime = true;
                        else
                            FirstTime = false;
                            t = t + timepnts(i) - timepnts(i-1);
                            if t > frequency; proceed = true;
                            else; proceed = false;
                            end
                        end
                        if proceed
                            t = 0;
                            if FirstTime
                                for item = start:size(data,1)
                                    value = data(item,i)*base_size/maximum;
                                    p = cornerpnts{item};
                                    if size(p,2) < 3
                                        % It is a static face
                                        F_UxData(item) = p(1,1)*value;
                                        F_UyData(item) = p(2,1)*value;
                                        F_XData(item) = p(1,2);
                                        F_YData(item) = p(2,2);
                                    else
                                        % It is a dynamic face
                                        F_UxData(item) = p(1,1)*value;
                                        F_UyData(item) = p(2,1)*value;
                                        F_XData(item) = p(1,1+angindex);
                                        F_YData(item) = p(2,1+angindex);
                                    end
                                end
                                for b = 1:length(bodypnts)
                                    if ndims(bodypnts{b}) == 2 %#ok<ISMAT>
                                        B_XData(:,b) = bodypnts{b}(1,:);
                                        B_YData(:,b) = bodypnts{b}(2,:);
                                    else
                                        B_XData(:,b) = bodypnts{b}(1,:,angindex);
                                        B_YData(:,b) = bodypnts{b}(2,:,angindex);
                                    end
                                end
                                switch propertyname
                                    case 'U'
                                        QuiverHandle = quiver(...
                                            F_XData,F_YData,...
                                            F_UxData,F_UyData,...
                                            'Color','k');
                                    case 'dP'
                                        if exist('QuiverHandle','var')

                                        end
                                        for x = 1:length(F_XData)
                                            QuiverHandle(x) = plot(...
                                                F_XData(x),...
                                                F_YData(x),...
                                                'Marker','o',...
                                                'MarkerEdgeColor','b',...
                                                'MarkerFaceColor','b',...
                                                'MarkerSize',sqrt(F_UxData(x)^2 + F_UyData(x)^2)+1e-8,...
                                                'LineStyle','none');
                                        end
                                end
                                PatchHandleBodies = patch(...
                                    B_XData,B_YData,zeros(length(bodypnts),1),...
                                    'EdgeColor','k',...
                                    'FaceColor','none',...
                                    'LineWidth',1);
                            else
                                for item = start:size(data,1)
                                    value = data(item,i)*base_size/maximum;
                                    p = cornerpnts{item};
                                    if size(p,2) < 3
                                        % It is a static face
                                        F_UxData(item) = p(1,1)*value;
                                        F_UyData(item) = p(2,1)*value;
                                    else
                                        % It is a dynamic face
                                        F_UxData(item) = p(1,1)*value;
                                        F_UyData(item) = p(2,1)*value;
                                        F_XData(item) = p(1,1+angindex);
                                        F_YData(item) = p(2,1+angindex);
                                    end
                                end
                                for b = 1:length(bodypnts)
                                    if ndims(bodypnts{b}) == 2 %#ok<ISMAT>
                                        %B_XData(:,b) = bodypnts{b}(1,:);
                                        %B_YData(:,b) = bodypnts{b}(2,:);
                                    else
                                        temp = 1 + mod(i,Frame.NTheta-1);
                                        B_XData(:,b) = bodypnts{b}(1,:,temp);
                                        B_YData(:,b) = bodypnts{b}(2,:,temp);
                                    end
                                end
                            end
                            switch propertyname
                                case 'U'
                                    set(QuiverHandle,'XData',F_XData);
                                    set(QuiverHandle,'YData',F_YData);
                                    set(QuiverHandle,'UData',F_UxData);
                                    set(QuiverHandle,'VData',F_UyData);
                                case 'dP'
                                    for x = 1:length(F_XData)
                                        set(QuiverHandle(x),'XData',F_XData(x));
                                        set(QuiverHandle(x),'YData',F_YData(x));
                                        set(QuiverHandle(x),'MarkerSize',...
                                            sqrt(F_UxData(x)^2 + F_UyData(x)^2)+1e-8);
                                    end
                            end
                            set(PatchHandleBodies,'XData',B_XData);
                            set(PatchHandleBodies,'YData',B_YData);
                            set(TextHandle,'String',[num2str(round(timepnts(i),2)) ' seconds'], 'FontSize', 18);
                            drawnow;

                            % Capture the plot as an image
                            h.Position = [0, 0, 1000, 1000]; % won't go above screen resolution sadly, but want it to be square
                            set(a, 'FontSize', 18)            
                            try
                                frame = getframe(h);
                            catch
                                fprintf('ERR: Failed to Get Frame in Result.AnimateFace \n')
                                fprintf(['... Error occured with property: ' ...
                                    propertyname '\n']);
                                try
                                    close(h);
                                catch
                                end
                                return;
                            end
                            im = frame2im(frame);
                            [imind,cm] = rgb2ind(im,256);

                            % Write to the GIF File
                            try
                                if i == 1
                                    imwrite(imind,cm,filename,'gif','Loopcount',inf,'DelayTime',0);
                                else
                                    imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0);
                                end
                            catch
                                fprintf('XXX GIF write error XXX\n');
                                fprintf(['... propertyname = ' propertyname 'XXX\n']);
                            end
                        end
                    end
                catch
                end
                try
                    close(h);
                catch
                end
            end
        end

        function Start2DPlot(this,property,t)
            if isempty(this.Axes)
                this.OriginalAxes = gca;
            else
                this.Close2DPlot();
            end
            this.Fig = figure();
            this.Axes = gca;
            this.GraphicsObjects(length(XData,1)) = patch();
            this.Cmap = colormap();
            differences = abs(this.Data.t - t);
            [value1, index1] = min(differences);
            [value2, index2] = min(differences ~= value1);
            if index1 < index2
                index2 = index2 + 1;
            end
            scalar = abs(value1/(value1-value2))*this.Data.(property)(index2,:) + abs(value2/(value1-value2))*this.Data.(property)(index1,:);
            ulimit = max(scalar);
            llimit = min(scalar);
            mapper = linspace(llimit,ulimit,size(cmap,1));

            %% LOOP
            for i = 1:length(this.XDATA,1)
                rgb = interp1(mapper,cmap,scalar(i));
                this.GraphicsObjects(i) = fill(this.XDATA(i,:),this.YDATA(i,:),rgb);
            end
        end

        function Close2DPlot(this)
            % Delete the current figure
            close(this.Fig);
            delete(this.Fig);
            delete(this.Axes);
        end

        function SnapShot = getSnapShot(this,Model,name, doSave)
            if isempty(name); return; end
            if ~isfield(this.Data,'T'); return; end
            % Find Snapshot position
            N = Frame.NTheta-1;
            LEN = size(this.Data.T,2);
            if LEN == N
                ind = LEN;
            else
                if mod(LEN,N) == 0
                    ind = LEN;
                else
                    ind = LEN - mod(LEN,N) + 1;
                end
            end

            while all(this.Data.T(:,ind) == 0)
                ind = ind - 1;
                if ind == 0
                    return;
                end
            end

            % Define number of cells
            n = 0;
            for iGroup = Model.Groups
                n = n + length(iGroup.Bodies);
            end
            BData(n) = BodyData();
            SnapShot = struct('Name',name,'Data',BData);
            index = 1;
            for iGroup = Model.Groups
                for iBody = iGroup.Bodies
                    % Get a new ID for bodies without one
                    if iBody.ID == 0; iBody.ID = Model.getBodyID(); end

                    %% Create XData and YData vectors
                    XData = zeros(length(iBody.Nodes),1);
                    YData = XData;
                    AltXData = XData;
                    AltYData = YData;

                    %% Get X & Y Data
                    i = 1;
                    Alti = 1;
                    for k = 1:length(iBody.Nodes)
                        Nd = iBody.Nodes(k);
                        if isfield(Nd.data,'matl') && ...
                                Nd.data.matl.Phase ~= iBody.matl.Phase
                            AltXData(Alti) = (Nd.xmin + Nd.xmax)/2;
                            Alti = Alti + 1;
                        else
                            XData(i) = (Nd.xmin + Nd.xmax)/2;
                            i = i + 1;
                        end
                    end
                    XData = unique(XData(1:i-1));
                    AltXData = unique(AltXData(1:Alti-1));
                    i = 1;
                    Alti = 1;
                    for k = 1:length(iBody.Nodes)
                        Nd = iBody.Nodes(k);
                        if isfield(Nd.data,'matl') && ...
                                Nd.data.matl.Phase ~= iBody.matl.Phase
                            AltYData(Alti) = (Nd.ymin(1) + Nd.ymax(1))/2;
                            Alti = Alti + 1;
                        else
                            YData(i) = (Nd.ymin(1) + Nd.ymax(1))/2;
                            i = i + 1;
                        end
                    end
                    YData = unique(YData(1:i-1));
                    AltYData = unique(AltYData(1:Alti-1));

                    %% Assign T array
                    TData = zeros(length(YData),length(XData));
                    AltTData = zeros(length(AltYData),length(AltXData));
                    if iBody.matl.Phase == enumMaterial.Gas
                        TurbData = TData;
                    else
                        TurbData = zeros(0,0);
                    end
                    PData = 0;
                    for k = 1:length(iBody.Nodes)
                        Nd = iBody.Nodes(k);
                        if isfield(Nd.data,'matl') && ...
                                Nd.data.matl.Phase ~= iBody.matl.Phase
                            i = find(AltYData == (Nd.ymin(1) + Nd.ymax(1))/2);
                            j = find(AltXData == (Nd.xmin + Nd.xmax)/2);
                            AltTData(i, j) = this.Data.T(Nd.index,ind);
                        else
                            i = find(YData == (Nd.ymin(1) + Nd.ymax(1))/2);
                            j = find(XData == (Nd.xmin + Nd.xmax)/2);
                            TData(i, j) = this.Data.T(Nd.index,ind);
                            if ~isempty(TurbData) && isfield(this.Data,'turb')
                                TurbData(i,j) = this.Data.turb(Nd.index,ind);
                            end
                            if iBody.matl.Phase == enumMaterial.Gas
                                if isfield(this.Data,'SnapShot_P')
                                    PData = this.Data.SnapShot_P(Nd.index);
                                end
                            end
                        end
                    end

                    if length(XData) > 1 && XData(1) > XData(2)
                        XData = flip(XData); TData = flip(TData,2);
                        TurbData = flip(TurbData,2);
                    end
                    if length(YData) > 1 && YData(1) > YData(2)
                        YData = flip(YData); TData = flip(TData,1);
                        TurbData = flip(TurbData,1);
                    end
                    if length(AltXData) > 1 && AltXData(1) > AltXData(2)
                        AltXData = flip(AltXData); AltTData = flip(AltTData,2);
                    end
                    if length(AltYData) > 1 && AltYData(1) > AltYData(2)
                        AltYData = flip(AltYData); AltTData = flip(AltTData,1);
                    end

                    %% Normalize positions
                    [~,~,x1,x2] = iBody.limits(enumOrient.Vertical);
                    [y1,y2,~,~] = iBody.limits(enumOrient.Horizontal);
                    XData = (XData - x1)/(x2-x1);
                    YData = (YData - y1(1))/(y2(1)-y1(1));
                    AltXData = (AltXData - x1)/(x2-x1);
                    AltYData = (AltYData - y1(1))/(y2(1)-y1(1));

                    % Assign the Body
                    SnapShot.Data(index) = BodyData(iBody.ID,XData,YData,TData,PData,AltXData,AltYData,AltTData,TurbData);
                    % End
                    index = index + 1;
                end
            end
            if doSave
                this.Model.addSnapShot(SnapShot);
            end
        end

    end

end

