classdef BodyData < handle

    properties
        ID;
        XData;
        YData;
        TData;
        PData;
        AltXData;
        AltYData;
        AltTData;
        TurbData;
    end

    methods
        function this = BodyData(...
                iID,iXData,iYData,...
                iTData,iPData,...
                iAltXData,iAltYData,...
                iAltTData,iTurbData)
            if nargin > 0; this.ID = iID; end
            if nargin > 1; this.XData = iXData; end
            if nargin > 2; this.YData = iYData; end
            if nargin > 3; this.TData = iTData; end
            if nargin > 4; this.PData = iPData; end
            if nargin > 5; this.AltXData = iAltXData; end
            if nargin > 6; this.AltYData = iAltYData; end
            if nargin > 7; this.AltTData = iAltTData; end
            if nargin > 8; this.TurbData = iTurbData; end
        end

        function [success] = applyBody(this,iBody)
            success = false;
            if isempty(this.TData) && isempty(this.AltTData)
                return;
            else
                if iBody.ID == this.ID
                    % It is a valid pair, Gas-Gas
                    % ... Over all the nodes of the body
                    if iBody.isDiscretized()
                        % Process the stored data into a grid
                        Xs = zeros(length(this.YData)+2,length(this.XData)+2);
                        Ys = Xs;
                        for r = 1:length(this.YData)+2; Xs(r,:) = [0; this.XData; 1]'; end
                        for c = 1:length(this.XData)+2; Ys(:,c) = [0; this.YData; 1]; end
                        PaddedT = CustExpandArray(this.TData);
                        FT = griddedInterpolant(Xs',Ys',PaddedT','linear','linear');
                        if ~isempty(this.TurbData)
                            PaddedTurb = CustExpandArray(this.TurbData);
                            FTurb = griddedInterpolant(...
                                Xs',Ys',PaddedTurb','linear','linear');
                        end
                        if ~isempty(this.AltXData)
                            AltXs = zeros(...
                                length(this.AltYData)+2,length(this.AltXData)+2);
                            AltYs = AltXs;
                            for r = 1:length(this.AltYData)+2
                                AltXs(r,:) = [0; this.AltXData; 1]';
                            end
                            for c = 1:length(this.AltXData)+2
                                AltYs(:,c) = [0; this.AltYData; 1];
                            end
                            PaddedAltT = CustExpandArray(this.AltTData);
                            %Matthias: Error occurs in next line if 'AltXs' has two identical columns.
                            %It appears that this means two points of the interpolation grid are
                            %identical, which is not valid for 'griddedInterpolant'.
                            % Solution: disable use of Snapshots (call to 'assignSnapShot') in Model.m
                            % Matteo: This function is only used for creating and assigning snapshots
                            % Issue has not come up again during either a single run or a running a test set
                            % Snapshots have been re-enabled
                            FAltT = griddedInterpolant(...
                                AltXs',AltYs',PaddedAltT','linear','linear');
                        end

                        success = true;
                        [~,~,x1,x2] = iBody.limits(enumOrient.Vertical);
                        [y1,y2,~,~] = iBody.limits(enumOrient.Horizontal);
                        y1 = y1(1);
                        y2 = y2(1);
                        for Nd = iBody.Nodes
                            % Consider what type of node it is
                            assignAltTemp = false;
                            assignTemp = false;
                            assignTurb = false;
                            if isfield(Nd.data,'matl')
                                if strcmp(Nd.data.matl.name,'Constant Temperature') || ...
                                        strcmp(Nd.data.matl.name,'Perfect Insulator')
                                    assignTemp = false;
                                elseif Nd.data.matl.Phase == iBody.matl.Phase
                                    assignTemp = true;
                                    if iBody.matl.Phase == enumMaterial.Gas
                                        if ~isempty(this.PData) && this.PData ~= 0
                                            Nd.data.P = this.PData;
                                        end
                                        assignTurb = ~isempty(this.TurbData);
                                    end
                                else
                                    if isempty(this.AltTData)
                                        assignTemp = true;
                                    else
                                        assignAltTemp = true;
                                    end
                                end
                            else
                                assignTemp = true;
                                if iBody.matl.Phase == enumMaterial.Gas
                                    if ~isempty(this.PData) && this.PData ~= 0
                                        Nd.data.P = this.PData;
                                    end
                                    assignTurb = ~isempty(this.TurbData);
                                end
                            end
                            cx = ((Nd.xmax + Nd.xmin)/2 - x1)/(x2-x1);
                            cy = ((Nd.ymin(1) + Nd.ymax(1))/2 - y1)/(y2-y1);
                            T = Nd.data.T;
                            Turb = 0;
                            if assignTemp && ~isempty(this.TData)
                                T = FT(cx,cy);
                                if assignTurb; Turb = FTurb(cx,cy); end
                                %{
                if length(this.XData) == 1
                  if length(this.YData) == 1
                    % No interpolation
                    T = this.TData(1,1);
                    if assignTurb
                      Turb = this.TurbData(1,1);
                    end
                  else
                    % Linear Interpolation
                    try
                      T = interp1(this.YData,this.TData,cy,'pchip','extrap');
                      if assignTurb
                        Turb = interp1(this.YData,this.TurbData,cy,'pchip','extrap');
                      end
                    catch
                      this.TData = [];
                      this.TurbData = [];
                      success = false;
                      return;
                    end
                  end
                else
                  if length(this.YData) == 1
                    % Linear Interpolation
                    try
                      T = interp1(this.XData,this.TData,cx,'pchip','extrap');
                      if assignTurb
                        Turb = interp1(this.XData,this.TurbData,cx,'pchip','extrap');
                      end
                    catch
                      this.TData = [];
                      this.TurbData = [];
                      success = false;
                      return;
                    end
                  else
                    % Double Linear Interpolation
                    try
                      T2 = interp1(this.YData,this.TData,cy,'pchip','extrap');
                      T = interp1(this.XData,T2',cx,'pchip','extrap');
                      if assignTurb
                        Turb2 = interp1(this.YData,this.TurbData,cy,'pchip','extrap');
                        Turb = interp1(this.XData,Turb2',cx,'pchip','extrap');
                      end
                    catch
                      this.TData = [];
                      this.TurbData = [];
                      success = false;
                      return;
                    end
                  end
                end
                                %}
                            elseif assignAltTemp && ~isempty(this.AltTData)
                                T = FAltT(cx,cy);
                                %{
                if length(this.AltXData) == 1
                  if length(this.AltYData) == 1
                    % No interpolation
                    T = this.AltTData(1,1);
                  else
                    % Linear Interpolation
                    try
                      T = interp1(this.AltYData,this.AltTData,cy,'pchip','extrap');
                    catch
                      this.AltTData = [];
                      success = false;
                      return;
                    end
                  end
                else
                  if length(this.AltYData) == 1
                    % Linear Interpolation
                    try
                      T = interp1(this.AltXData,this.AltTData,cx,'pchip','extrap');
                    catch
                      this.AltTData = [];
                      success = false;
                      return;
                    end
                  else
                    % Double Linear Interpolation
                    try
                      T2 = interp1(this.AltYData,this.AltTData,cy,'pchip','extrap');
                      T = interp1(this.AltXData,T2',cx,'pchip','extrap');
                    catch
                      this.AltTData = [];
                      success = false;
                      return;
                    end
                  end
                end
                                %}
                            end
                            if ~isnan(T)
                                Nd.data.T = T;
                                if assignTurb
                                    Nd.data.Turb = Turb;
                                end
                            else
                                fprintf('err');
                            end
                        end
                    end
                end
            end
        end

    end

end


