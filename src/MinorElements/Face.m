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

classdef Face < handle
    % models a physical boundary between two nodes (which belong to bodies),
    % contains the relevant functions to model thermodynamics
    % between the nodes, depending on their phase (fluid or solid)

    properties
        Nodes Node;
        Type enumFType;
        Connection Connection;
        Orient enumOrient = enumOrient.Vertical;
        %Gas-Gas [Area Dh Dist K]
        %Solid-Solid [R]
        %Mix [Area dh value R]
        data struct;

        % data.Area double;
        % data.Dist double;
        % data.Dh double;
        % data.K double;
        % data.R double;
        % data.U double;

        isEdge logical;

        ActiveTimes int16;

        isDynamic logical;

        index int32;
    end

    methods
        %% Constructor
        function this = Face(NC1_Nodes,NC2_Type,Orient)
            if nargin == 2 || (nargin == 3 && isa(Orient,'logical'))
                NC1 = NC1_Nodes;
                NC2 = NC2_Type;
                % if any of the points overlap
                if nargin == 3; this.ActiveTimes = Orient;
                else; this.ActiveTimes = NC1.activeTimes(NC2);
                end
                if isempty(this.ActiveTimes); return; end
                % There is an overlap
                this.Nodes = [NC1.Node NC2.Node];
                this.isEdge = true; % Meaning that a K is used instead of a Dh
                this.Orient = NC1.Connection.Orient;
                this.Connection = NC1.Connection;
                %         if (isa(NC1.Node.Body, 'Body') && NC1.Node.Body.ID == 17) || ...
                %             (isa(NC2.Node.Body, 'Body') && NC2.Node.Body.ID == 17)
                %           fprintf('here');
                %         end
                switch NC1.Type
                    case enumFType.Gas
                        switch NC2.Type
                            case enumFType.Gas % Gas-Gas
                                this.Type = enumFType.Gas;
                                % Calculate area, distance
                                this.data = struct('Area',[],'Dist',[],'dx',[],'Dh',[]);
                                this.data.Area = getArea(NC1,NC2,this.ActiveTimes);
                                this.data.Dist = getDistance(NC1,NC2,this.ActiveTimes);
                                this.data.dx = getStabilityDistance(NC1,NC2,this.ActiveTimes);
                                if NC1.Connection.Orient == NC2.Connection.Orient
                                    this.data.Dh = getDh(NC1,NC2,this.ActiveTimes);
                                end


                                if NC1.Node.Type ~= enumNType.EN && ...
                                        ~isempty(NC1.Node.Body.Matrix)
                                    this.Type = enumFType.MatrixTransition;
                                    this.data.NkFunc_l = @(Re) 1;
                                    this.data.NkFunc_t = @(Re) 1;
                                else
                                    % No matrix
                                    if ~isfield(this.data,'K12')
                                        % No Matrix
                                        iModel = this.Nodes(1).Body.Group.Model;
                                        if this.Orient == enumOrient.Horizontal
                                            if this.Nodes(1).xmin == 0
                                                % Cylindrical
                                                C = 64;
                                            else
                                                % Annuluar
                                                C = 96; % Assume thin
                                            end
                                        else % Horizontal
                                            C = 96;
                                        end
                                        this.data.fFunc_l = @(Re) C./Re;
                                        this.data.fFunc_t = @(Re) 0.11*...
                                            (iModel.roughness/this.data.Dh+68./Re).^0.25;
                                    end

                                    % Streamwise conduction enhancement
                                    this.data.NkFunc_l = @(Re) 1;
                                    this.data.NkFunc_t = @(Re,Pr) 0.022*(Re.^0.75).*(Pr);
                                end
                                if ~isscalar(this.data.Area); this.data.Area = CollapseVector(this.data.Area); end
                                if ~isscalar(this.data.Dist); this.data.Dist = CollapseVector(this.data.Dist); end
                                if ~isscalar(this.data.dx); this.data.dx = CollapseVector(this.data.dx); end
                                if NC1.Connection.Orient == NC2.Connection.Orient
                                    if ~isscalar(this.data.Dh); this.data.Dh = CollapseVector(this.data.Dh); end
                                end

                                this.isDynamic = ~(isscalar(this.data.Area) && ...
                                    isscalar(this.data.Dist) && ...
                                    isscalar(this.data.Dh));
                            case enumFType.Solid % Gas-Solid
                                this.Nodes = flip(this.Nodes); % To be Solid-Gas
                                this.Type = enumFType.Mix;
                                % Calculate area
                                this.data = struct('Area',[],'R',[]);
                                this.data.Area = getArea(NC1,NC2,this.ActiveTimes);
                                this.data.R = this.data.Area./getConductance(NC1,NC2,this.ActiveTimes);
                                if isfield(NC1.Node.data,'NuiFunc_l')
                                    % Determine if this is an inside or outside
                                    if NC2.Connection.Orient == enumOrient.Vertical
                                        if NC2.Connection.x < NC2.Node.xmax
                                            % Outside Side of the gas
                                            this.data.NuFunc_l = NC1.Node.data.NuoFunc_l;
                                        else
                                            % Inside Side of the gas
                                            this.data.NuFunc_l = NC1.Node.data.NuiFunc_l;
                                        end
                                    elseif NC1.Connection.Orient == enumOrient.Vertical
                                        if NC1.Connection.x < NC1.Node.xmax
                                            % Inside Side of the gas
                                            this.data.NuFunc_l = NC1.Node.data.NuiFunc_l;
                                        else
                                            % Outside Side of the gas
                                            this.data.NuFunc_l = NC1.Node.data.NuoFunc_l;
                                        end
                                    end
                                else
                                    try
                                        this.data.NuFunc_l = NC1.Node.data.NuFunc_l;
                                    catch
                                        fprintf('err');
                                    end
                                end
                                this.data.NuFunc_t = NC1.Node.data.NuFunc_t;
                                if ~isscalar(this.data.Area); this.data.Area = CollapseVector(this.data.Area); end
                                if ~isscalar(this.data.R); this.data.R = CollapseVector(this.data.R); end
                                this.isDynamic = ~(isscalar(this.data.Area) && isscalar(this.data.R));
                            case enumFType.Environment % Gas-Environment
                                this.Type = enumFType.Gas;
                                % Calculate area
                                this.data = struct('Area',[]);
                                this.data.Area = getArea(NC1,NC2,this.ActiveTimes);
                                this.data.Dh = 2*(NC1.End - NC1.Start);
                                this.data.dx = getStabilityDistance(NC1,NC2,this.ActiveTimes);
                                this.data.Dist = this.data.dx;
                                this.data.NkFunc_l = @(Re) 1;
                                this.data.NkFunc_t = @(Re) 1;
                                if ~isscalar(this.data.Area); this.data.Area = CollapseVector(this.data.Area); end
                                if ~isscalar(this.data.Dist); this.data.Dist = CollapseVector(this.data.Dist); end
                                if ~isscalar(this.data.dx); this.data.dx = CollapseVector(this.data.dx); end
                                if ~isscalar(this.data.Dh); this.data.Dh = CollapseVector(this.data.Dh); end
                                this.isDynamic = ~isscalar(this.data.Area) || ~isscalar(this.data.dx);
                        end
                    case enumFType.Solid
                        switch NC2.Type
                            case enumFType.Gas % Solid-Gas
                                this.Type = enumFType.Mix;
                                % Calculate area
                                this.data = struct('Area',[],'R',[]);
                                this.data.Area = getArea(NC1,NC2,this.ActiveTimes);
                                this.data.R = this.data.Area./getConductance(NC1,NC2,this.ActiveTimes);
                                if isfield(NC2.Node.data,'NuiFunc_l')
                                    % Determine if this is an inside or outside
                                    if NC1.Connection.Orient == enumOrient.Vertical
                                        if NC1.Connection.x < NC1.Node.xmax
                                            % Outside Side of the gas
                                            this.data.NuFunc_l = NC2.Node.data.NuoFunc_l;
                                        else
                                            % Inside Side of the gas
                                            this.data.NuFunc_l = NC2.Node.data.NuiFunc_l;
                                        end
                                    elseif NC2.Connection.Orient == enumOrient.Vertical
                                        if NC2.Connection.x < NC2.Node.xmax
                                            % Inside Side of the gas
                                            this.data.NuFunc_l = NC2.Node.data.NuiFunc_l;
                                        else
                                            % Outside Side of the gas
                                            this.data.NuFunc_l = NC2.Node.data.NuoFunc_l;
                                        end
                                    end
                                else
                                    this.data.NuFunc_l = NC2.Node.data.NuFunc_l;
                                end
                                this.data.NuFunc_t = NC2.Node.data.NuFunc_t;
                                if ~isscalar(this.data.Area); this.data.Area = CollapseVector(this.data.Area); end
                                if ~isscalar(this.data.R); this.data.R = CollapseVector(this.data.R); end
                                this.isDynamic = ~(isscalar(this.data.Area) && isscalar(this.data.R));
                            case enumFType.Solid % Solid-SOlid
                                this.Type = enumFType.Solid;
                                % Calculate resistance between
                                this.data = struct('U',[]);
                                this.data.U = getConductance(NC1,NC2,this.ActiveTimes);
                                if ~isscalar(this.data.U); this.data.U = CollapseVector(this.data.U); end
                                this.isDynamic = ~isscalar(this.data.U);
                            case enumFType.Environment % Solid-Environment
                                this.Type = enumFType.Solid;
                                % Calculate Conductance
                                this.data = struct('U',[]);
                                this.data.Area = getArea(NC1,NC2,this.ActiveTimes);
                                this.data.U = getConductance(NC1,NC2,this.ActiveTimes);
                                if ~isscalar(this.data.U); this.data.U = CollapseVector(this.data.U); end
                                this.isDynamic = ~isscalar(this.data.U);
                        end
                    case enumFType.Environment
                        switch NC2.Type
                            case enumFType.Gas % Environment-Gas
                                this.Nodes(1:2) = this.Nodes(2:-1:1);
                                this.Type = enumFType.Gas;
                                % Calculate area
                                this.data = struct('Area',[]);
                                this.data.Area = getArea(NC1,NC2,this.ActiveTimes);
                                this.data.Dh = 2*(NC2.End - NC2.Start);
                                this.data.dx = getStabilityDistance(NC1,NC2,this.ActiveTimes);
                                this.data.Dist = this.data.dx;
                                this.data.NkFunc_l = @(Re) 1;
                                this.data.NkFunc_t = @(Re) 1;
                                if ~isscalar(this.data.Area); this.data.Area = CollapseVector(this.data.Area); end
                                if ~isscalar(this.data.Dist); this.data.Dist = CollapseVector(this.data.Dist); end
                                if ~isscalar(this.data.dx); this.data.dx = CollapseVector(this.data.dx); end
                                if ~isscalar(this.data.Dh); this.data.Dh = CollapseVector(this.data.Dh); end
                                this.isDynamic = ~isscalar(this.data.Area) || ~isscalar(this.data.dx);
                            case enumFType.Solid % Environment-Solid
                                % Calculate Conductance
                                this.Type = enumFType.Solid;
                                this.data = struct('U',[]);
                                this.data.Area = getArea(NC1,NC2,this.ActiveTimes);
                                this.data.U = getConductance(NC1,NC2,this.ActiveTimes);
                                if ~isscalar(this.data.U); this.data.U = CollapseVector(this.data.U); end
                                this.isDynamic = ~isscalar(this.data.U);
                        end
                    otherwise
                        fprintf('XXX Unhandled FType in Face from Node Contact XXX\n');
                end
                if isfield(NC1.data,'Perc')
                    if isfield(NC2.data,'Perc')
                        if isscalar(NC1.data.Perc)
                            if isscalar(NC2.data.Perc)
                                Perc = min(NC1.data.Perc,NC2.data.Perc);
                            else
                                Perc = NC2.data.Perc;
                                Perc(Perc>NC1.data.Perc) = NC1.data.Perc;
                            end
                        else
                            if isscalar(NC2.data.Perc)
                                Perc = NC1.data.Perc;
                                Perc(Perc>NC2.data.Perc) = NC2.data.Perc;
                            else
                                first = NC1.data.Perc > NC2.data.Perc;
                                Perc = NC2.data.Perc;
                                Perc(first) = NC1.data.Perc(first);
                            end
                        end
                    else
                        Perc = NC1.data.Perc;
                    end
                else
                    if isfield(NC2.data,'Perc')
                        Perc = NC2.data.Perc;
                    else
                        return;
                    end
                end

                if all(Perc == 0); this.ActiveTimes = []; return; end

                if isfield(this.data,'Area')
                    this.data.Area = this.data.Area.*Perc;
                    if all(this.data.Area == 0); this.ActiveTimes = []; return; end
                    if isfield(this.data,'R')
                        if all(this.data.R > 1e8); this.ActiveTimes = []; return; end
                    end
                elseif isfield(this.data,'U')
                    this.data.U = this.data.U.*Perc;
                    if ~isscalar(this.data.U); this.data.U = CollapseVector(this.data.U); end
                    if all(this.data.U < 1e-8); this.ActiveTimes = []; return; end
                end

            elseif nargin == 3
                % Created Straight up
                % no Gas-Solid, no Gas-Enviro, no Solid-Enviro
                this.isEdge = false;
                this.Nodes = NC1_Nodes;
                this.Type = NC2_Type;
                this.Orient = Orient;
                this.ActiveTimes = true;
                this.calcData();
            end
        end
        function name = name(this)
            switch this.Type
                case enumFType.Mix
                    name = 'Mix Face';
                case enumFType.Gas
                    name = 'Gas Face';
                case enumFType.Leak
                    name = 'Leak Face';
                case enumFType.Solid
                    name = 'Solid Face';
                case enumFType.Environment
                    name = 'Solid-Environment Face';
                case enumFType.MatrixTransition
                    name = 'Matrix Transition Face';
                otherwise
                    name = 'Undefined Face Type';
            end
        end
        function PContact = getPressureContact(this)
            PContact = PressureContact.empty;
            Con = this.Connection;
            if ~isempty(Con) && Con.Orient == enumOrient.Horizontal
                if ~isempty(Con.RefFrame)
                    Converters = Con.Group.Model.Converters;
                    for conv_index = 1:length(Converters)
                        if Con.RefFrame.Mechanism == Converters(conv_index); break; end
                    end
                    sign = 1;
                    if this.Nodes(1).Type == enumNType.SN
                        nd1 = this.Nodes(1); nd2 = this.Nodes(2);
                    else
                        nd1 = this.Nodes(2); nd2 = this.Nodes(1);
                    end
                    for iCon = nd1.Body.Connections
                        if iCon.Orient == enumOrient.Horizontal && iCon.x < Con.x
                            sign = -1; % SN is pushed downward by the gas
                        end
                    end
                    PContact = PressureContact(...
                        conv_index,...
                        Con.RefFrame.MechanismIndex,...
                        this.data.Area*sign,...
                        nd2);
                end
            end
        end

        %% Data Calculation
        % Used for simple faces
        function calcData(this)
            switch this.Type
                case enumFType.Solid
                    this.data = struct('U',[]);
                    % Matthias: Added below if statement to ensure 'k' is found. If exists,
                    % Node material should have priority over Body material.?
                    if isfield(this.Nodes(1).data, 'matl')
                        k = this.Nodes(1).data.matl.ThermalConductivity; % Matthias
                    else
                        k = this.Nodes(1).Body.matl.ThermalConductivity;
                    end
                    %             if ~isempty(this.Nodes(1).Body)
                    %                 k = this.Nodes(1).Body.matl.ThermalConductivity;
                    %             else
                    %                 k = this.Nodes(1).data.matl.ThermalConductivity; % Matthias
                    %             end

                    if this.Orient == enumOrient.Vertical
                        L = this.Nodes(1).ymax(1) - this.Nodes(1).ymin(1);
                        mid_r1 = sqrt(this.Nodes(1).xmax*this.Nodes(1).xmin);
                        mid_r2 = sqrt(this.Nodes(2).xmax*this.Nodes(2).xmin);
                        if mid_r1 > mid_r2
                            if mid_r2 == 0
                                this.data = struct('U',(2*pi*k*L/log(2*mid_r1/(this.Nodes(2).xmax + this.Nodes(2).xmin))));
                            else
                                this.data = struct('U',(2*pi*k*L/log(mid_r1/mid_r2)));
                            end
                        else
                            if mid_r1 == 0
                                this.data = struct('U',(2*pi*k*L/log(2*mid_r2/(this.Nodes(1).xmax + this.Nodes(1).xmin))));
                            else
                                this.data = struct('U',(2*pi*k*L/log(mid_r2/mid_r1)));
                            end
                        end
                    else
                        r1 = this.Nodes(1).xmin;
                        r2 = this.Nodes(1).xmax;
                        L = (this.Nodes(1).ymax(1) + this.Nodes(2).ymax(1) - ...
                            this.Nodes(1).ymin(1) - this.Nodes(2).ymin(1))/2;
                        this.data = struct('U',pi*(r2*r2 - r1*r1)*k/L);
                    end
                    if ~isscalar(this.data.U); this.data.U = CollapseVector(this.data.U); end
                    this.isDynamic = isscalar(this.data.U);
                case {enumFType.Gas, enumFType.MatrixTransition}
                    % They are always 100% Active %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if this.Orient == enumOrient.Vertical
                        % Vertical
                        this.data = struct('Area',[],'Dist',[],'Dh',[]);
                        this.data.Dist = (this.Nodes(1).xmax + this.Nodes(2).xmax - ...
                            this.Nodes(1).xmin - this.Nodes(2).xmin)/2;
                        this.data.Area = 2*pi*...
                            min([this.Nodes(1).xmax this.Nodes(2).xmax]).*...
                            (this.Nodes(1).ymax - this.Nodes(1).ymin);
                        this.data.Dh = 2*(this.Nodes(1).ymax-this.Nodes(1).ymin);
                        this.data.dx = this.data.Dist;
                    else
                        % Horizontal
                        this.data = struct('Area',[],'Dist',[],'Dh',[]);
                        this.data.Dist = (this.Nodes(1).ymax + this.Nodes(2).ymax - ...
                            this.Nodes(1).ymin - this.Nodes(2).ymin)/2;
                        this.data.Area = pi*(this.Nodes(1).xmax^2-this.Nodes(1).xmin^2);
                        this.data.Dh = 2*(this.Nodes(1).xmax-this.Nodes(1).xmin);
                        this.data.dx = this.data.Dist;
                    end
                    if ~isempty(this.Nodes(1).Body.Matrix) && ...
                            ~isempty(this.Nodes(1).Body.Matrix.Dh)
                        % Nodes(2) would also have it too
                        iMatrix = this.Nodes(1).Body.Matrix;
                        % Adjust Area and Dh
                        this.data.Area = this.data.Area*iMatrix.data.Porosity;
                        %             disp("Face area modified for matrix porosity in Face.calcData")
                        this.data.Dh = iMatrix.Dh;
                        % Friction Function from Matrix
                        this.data.fFunc_l = iMatrix.fFunc_l;
                        % Streamwise conduction enhancement
                        this.data.NkFunc_l = iMatrix.NkFunc_l;
                        if ~iMatrix.isFullyLaminar
                            this.data.fFunc_t = iMatrix.fFunc_t;
                            this.data.NkFunc_t = iMatrix.NkFunc_t;
                        else
                            this.data.fFunc_t = this.data.fFunc_l;
                            this.data.NkFunc_t = this.data.NkFunc_l;
                        end
                    else
                        % No Matrix
                        iModel = this.Nodes(1).Body.Group.Model;
                        % Friction Function
                        if this.Orient == enumOrient.Horizontal
                            if this.Nodes(1).xmin == 0
                                % Cylindrical
                                C = 64;
                            else
                                % Annuluar
                                C = 96; % Assume thin
                            end
                        else % Horizontal
                            C = 96;
                        end
                        this.data.fFunc_l = @(Re) C./Re;
                        % this.data.fFunc_t = @(Re) 0.11*(iModel.roughness/this.data.Dh+68/Re)^0.25;
                        Temp = iModel.roughness/mean(this.data.Dh);
                        this.data.fFunc_t = @(Re) 0.11*(Temp+68./Re).^0.25;

                        % Streamwise conduction enhancement
                        this.data.NkFunc_l = @(Re) 1;
                        this.data.NkFunc_t = @(Re,Pr) 0.022*(Re.^0.75).*(Pr);
                    end
                    if ~isscalar(this.data.Dist)
                        this.data.Dist = CollapseVector(this.data.Dist);
                    end
                    if ~isscalar(this.data.Area); this.data.Area = CollapseVector(this.data.Area); end
                    if ~isscalar(this.data.Dh); this.data.Dh = CollapseVector(this.data.Dh); end
                    if ~isscalar(this.data.dx); this.data.dx = CollapseVector(this.data.dx); end
                    this.isDynamic = ...
                        ~isscalar(this.data.Dist) || ~isscalar(this.data.Area) || ...
                        ~isscalar(this.data.Dh) || ~isscalar(this.data.dx);
                otherwise
                    fprintf('XXX Unhandled FType in Face.CalcData() XXX\n');
            end
        end
        function isactive = isActive(this,inc)
            if nargin == 2
                switch this.Type
                    case enumFType.Solid
                        isactive = isscalar(this.data.U) || this.data.U(inc) > 0;
                    case enumFType.Environment
                        isactive = isscalar(this.data.Area) || this.data.Area(inc) > 0;
                    case enumFType.Mix
                        isactive = isscalar(this.data.Area) || this.data.Area(inc) > 0;
                    case enumFType.Gas
                        isactive = isscalar(this.data.Area) || this.data.Area(inc) > 0;
                    case enumFType.Leak
                        isactive = true;
                    case enumFType.MatrixTransition
                        isactive = isscalar(this.data.Area) || this.data.Area(inc) > 0;
                end
            end
        end
        function value = LargestStaticSolidNdCond(this)
            value = 0;
            for Nd = this.Nodes
                if Nd.Type == enumNType.SN
                    for Fc = Nd.Faces
                        if Fc.Type == enumFType.Solid || Fc.Type == enumFType.Environment
                            if isscalar(Fc.data.U)
                                if Fc.data.U > value
                                    value = Fc.data.U;
                                    if Fc.Nodes(1).Type == enumNType.SN
                                        this.data.LargestStaticSolidNd = Fc.Nodes(1).index;
                                    else
                                        this.data.LargestStaticSolidNd = Fc.Nodes(2).index;
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if value == 0
                this.data.LargestStaticSolidNd = 1;
            end

        end
        function value = TotalGasSurfaceArea(this)
            value = 0;
            if this.Nodes(1).Type == enumNType.SN
                n = 1;
            else
                n = 2;
            end
            for Fc = this.Nodes(n).Faces
                if isfield(Fc.data,'R')
                    value = value + Fc.data.Area;
                end
            end
            value = max(value);
        end
        function value = getArea(this,ind)
            if isfield(this.data,'Area')
                if isscalar(this.data.Area)
                    value = this.data.Area;
                else
                    if ind == 0
                        value = this.data.Area(end);
                    else
                        value = this.data.Area(ind);
                    end
                end
            else
                value = 0;
            end
        end
        function setArea(this,ind,value)
            if isfield(this.data,'Area')
                if isscalar(this.data.Area)
                    if value ~= this.data.Area
                        this.data.Area = this.data.Area(ones(1,Frame.NTheta));
                    else
                        return;
                    end
                end
                if ind == 0
                    this.data.Area(end) = value;
                else
                    this.data.Area(ind) = value;
                end
            end
        end
        function recalc_Area_Dh(this)
            if isfield(this.data,'Area')
                for i = 1:2
                    iBody = this.Nodes(i).Body;
                    if isa(iBody,'Body')
                        if ~isempty(iBody.Matrix) && ...
                                ~strcmp(iBody.Matrix.name,'Undefined Matrix')
                            Mat = iBody.Matrix;
                            if isfield(Mat.data,'Porosity')
                                this.Nodes(i).recalc_Dh();
                                if i == 2
                                    this.data.Dh = min(this.data.Dh,this.Nodes(1).data.Dh);
                                else
                                    this.data.Dh = this.Nodes(1).data.Dh;
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

