%{
   Modular Single Phase Model - MSPM. A program for simulating single phase cyclical thermodynamic machines.
   Copyright (C) 2023  David Nobes
      Mailing Address:
         University of Alberta
         Mechanical Engineering
         10-281 Donadeo Innovation Centre For Engineering
         9211-116 St
         Edmonton
         AB
         T6G 2H5
      Email: dnobes@ualberta.ca

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.
%}

classdef PVoutput < handle
    % contains the information about the PV loop,
    % and plots the PV loop during and after simulation

    properties
        Body Body;
        name;
        % A series of node indexes over
        % ... which the pressure and volume is calculated
        Nodes cell;
        RegionNodes;
        Region;
        Model Model;
        P double;
        V double;
        Power double;
        Fig = [];
        plot_axes;
    end

    methods
        function this = PVoutput(Body)
            if nargin == 1
                Body.addPVoutput(this);
                this.Body = Body;
                this.Model = Body.Group.Model;
                this.Nodes = [];
                this.P = zeros(1,Frame.NTheta-1);
                this.V = this.P;
                % Define the name
                this.name = getProperName( 'PV output' );
            end
        end

        function Item = get(this,PropertyName)
            switch PropertyName
                case 'name'
                    Item = this.name;
                case 'Source Body/Region'
                    Item = this.Body;
                otherwise
                    fprintf(['XXX PVoutput GET Inteface for ' PropertyName ' is not found XXX\n']);
            end
        end
        function set(this,PropertyName,Item)
            switch PropertyName
                case 'name'
                    this.name = Item;
                case 'Source Body/Nodes'
                    if ~isempty(Item)
                        this.Body = Item;
                        this.Body.change();
                    end
                otherwise
                    fprintf(['XXX Connection SET Inteface for ' PropertyName ' is not found XXX\n']);
                    return;
            end
        end

        function update(this,Region)
            % Grab a node from the body
            this.RegionNodes = [];
            this.Nodes = cell(0);
            if this.Body.isDiscretized()
                i = 1;
                this.Region = Region(this.Body.Nodes(1).index);
                consideredbodies = Body.empty;
                for iGroup = this.Model.Groups
                    for iBody = iGroup.Bodies
                        if ~any(consideredbodies == iBody) && ...
                                iBody.matl.Phase == enumMaterial.Gas && ...
                                iBody.isDiscretized() && ...
                                Region(iBody.Nodes(1).index) == this.Region
                            % get this.Nodes{i}(j)
                            j = 1;
                            otherbodies = iBody;
                            k = 1;
                            while k <= length(otherbodies)
                                for nd = otherbodies(k).Nodes % Search this body & any other bodies
                                    if nd.Type ~= enumNType.SN && ~isscalar(nd.vol())
                                        this.Nodes{i}(j) = nd.index; j = j + 1;
                                        for fc = nd.Faces
                                            if fc.Type == enumFType.Gas && ...
                                                    fc.Nodes(1).Body ~= fc.Nodes(2).Body
                                                if fc.Nodes(1) == nd
                                                    if ~isscalar(fc.Nodes(2).vol()) && ...
                                                            ~any(otherbodies == fc.Nodes(2).Body)
                                                        otherbodies(end+1) = fc.Nodes(2).Body;
                                                    end
                                                else
                                                    if ~isscalar(fc.Nodes(1).vol()) && ...
                                                            ~any(otherbodies == fc.Nodes(1).Body)
                                                        otherbodies(end+1) = fc.Nodes(1).Body;
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                                k = k + 1;
                            end
                            consideredbodies(end+1:end+length(otherbodies)) = otherbodies(:);
                            % get this.RegionNodes(this.Nodes{i}(:));
                            if j > 1
                                i = i + 1;
                            end
                        end
                    end
                end
                indexes = 1:length(Region);

                this.RegionNodes = indexes(Region(end) ~= this.Region);
            else
                this.Nodes = cell(0);
                return;
            end
        end

        function reset(this)
            this.P = [];
            this.V = [];
        end

        function deReference(this)
            iModel = this.Model;
            for i = length(iModel.PVoutputs):-1:1
                if iModel.PVoutputs(i) == this
                    iModel.PVoutputs(i) = [];
                    break;
                end
            end
            if ~isempty(this.Body) && isvalid(this.Body)
                for i = length(this.Body.PVoutputs):-1:1
                    if this.Body.PVoutputs(i) == this
                        this.Body.PVoutputs(i) = [];
                        break;
                    end
                end
                this.Body.change();
            end
            this.delete();
        end

        function isequal = equal(this,other)
            isequal = (this.Body == other.Body);
        end

        function getData(this,Sim)
            if isempty(this.P)
                this.P = zeros(Frame.NTheta-1,length(this.Nodes));
            end
            index = Sim.Inc;
            for i = 1:length(this.Nodes)
                indV = (Sim.vol(this.Nodes{i})' + Sim.old_vol(this.Nodes{i})')/2;
                sumV = sum(sum(indV));
                this.P(index,i) = sum(indV.*Sim.P(this.Nodes{i})')/sumV;
                this.V(index,i) = sumV;
            end
        end

        function updatePlot(this, fig_pos)
            if isempty(this.Fig) || ~isvalid(this.Fig) || this.Fig < 1
                this.Fig = figure();
                if nargin > 1
                    movegui(this.Fig, fig_pos)
                end
                this.plot_axes = gca;
                title(this.plot_axes, this.name);
                xlabel(this.plot_axes,'Volume (m^3)');
                ylabel(this.plot_axes,'Pressure (Pa)');
                set(this.Fig,'color','w');
                hold on;
            end
            % figure(this.Fig);
            cla(this.plot_axes)

            % a = this.Fig.CurrentAxes;
            WTotal = 0;
            Text = '';
            for i = 1:length(this.Nodes)
                pV = zeros(size(this.V,1)+1,1); pP = pV;
                pV(1:end-1) = this.V(:,i); pV(end) = this.V(1,i);
                pP(1:end-1) = this.P(:,i); pP(end) = this.P(1,i);
                W = PowerFromPV(pP,pV);
                WTotal = WTotal + W;
                if W > 0; Color = 'b'; % Color is Blue
                else; Color = 'r'; % Color is Red
                end

                plot(pV,pP,'Color',Color,'LineStyle','-', 'Parent', this.plot_axes);
                plot(pV(1),pP(1),'Color','k','Marker','o', 'Parent', this.plot_axes);
            end
            this.Power = WTotal;
            Text = [Text 'Total = ' num2str(WTotal,4) 'Joules/Cycle'];
            %fprintf([num2str(WTotal) '\n']);
            text(this.plot_axes.XLim(1)+0.01*(this.plot_axes.XLim(2)-this.plot_axes.XLim(1)),...
                this.plot_axes.YLim(2)-0.05*(this.plot_axes.YLim(2)-this.plot_axes.YLim(1)), Text, 'Parent', this.plot_axes, 'FontSize', 18);
            drawnow();

        end

        function plotData(this,is_saved,ModelName)
            if ~(isempty(this.Fig) || ~isvalid(this.Fig) || this.Fig < 1)
                close(this.Fig);
            end
            oldfigure = gcf;
            oldaxes = gca;
            updatePlot(this);
            a = gca;
            h = gcf;
            xlabel('Volume (m^3)');
            ylabel('Pressure (Pa)');
            title("Pressure vs Volume Diagram");

            if is_saved
                h.Position = [0, 0, 1000, 1000]; % won't go above screen resolution sadly, but want it to be square
                set(a, 'FontSize', 18)
                frame = getframe(h);
                im = frame2im(frame);
                [imind,cm] = rgb2ind(im,256);
                data = struct(...
                    'Name',this.name,...
                    'IndependentVariable',this.V,...
                    'DependentVariable',this.P);
                if isempty(this.Body.Group.Model.outputPath)
                    str = [this.name '_' ModelName];
                else
                    str = [this.Body.Group.Model.outputPath '\' ...
                        this.name '_' ModelName];
                end
                str = [str(1:3), replace(str(4:end),':',' -')];
                save([str '.mat'],'data');
                imwrite(imind,cm,[str '.png']);
            end

            close(h);
            figure(oldfigure);
            axes(oldaxes);
        end

        function WTotal = getIndicatedWork(this)
            % Calculate the indicated work
            WTotal = 0;
            for i = 1:length(this.Nodes)
                pV = zeros(size(this.V,1)+1,1); pP = pV;
                pV(1:end-1) = this.V(:,i); pV(end) = this.V(1,i);
                pP(1:end-1) = this.P(:,i); pP(end) = this.P(1,i);
                W = PowerFromPV(pP,pV);
                WTotal = WTotal + W;
            end
        end


    end
end

