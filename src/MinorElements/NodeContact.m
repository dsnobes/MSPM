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

classdef NodeContact < handle
    % models the contact between adjacent nodes

    properties
        Node Node;
        Start double = 0;
        End double = 0;
        Type enumFType;
        Connection Connection;
        data struct;
    end

    methods
        function this = NodeContact(Node,Start,End,Type,Connection)
            if nargin == 0; return; end
            %NODECONTACT Construct an instance of this class
            %   Detailed explanation goes here
            this.Node = Node;
            this.Start = Start;
            this.End = End;
            this.Type = Type;
            this.Connection = Connection;
        end
        function ActiveTimes = activeTimes(NC1,NC2)
            ActiveTimes = ~((NC1.Start >= NC2.End) + (NC2.Start >= NC1.End));
            if ~any(ActiveTimes)
                ActiveTimes = logical([]);
                return;
            end
            if all(ActiveTimes)
                ActiveTimes = true;
                return;
            end
        end
        function [Area] = getArea(NC1,NC2,ActiveTimes)
            if nargin < 3
                ActiveTimes = NC1.activeTimes(NC2);
            end
            ActiveTimes = logical(ActiveTimes);
            if isscalar(ActiveTimes)
                % scalar: s1,e1,s2,e2
                if NC1.Connection.Orient == enumOrient.Vertical
                    if isscalar(NC1.Start)
                        if isscalar(NC2.Start)
                            TheStart = max([NC1.Start NC2.Start]);
                        else
                            TheStart = NC2.Start;
                            TheStart(TheStart<NC1.Start) = NC1.Start;
                        end
                    else
                        if isscalar(NC2.Start)
                            TheStart = NC1.Start;
                            TheStart(TheStart<NC2.Start) = NC2.Start;
                        else
                            TheStart = max([NC1.Start; NC2.Start]);
                        end
                    end
                    if isscalar(NC1.End)
                        if isscalar(NC2.End)
                            TheEnd = min([NC1.End NC2.End]);
                        else
                            TheEnd = NC2.End;
                            TheEnd(TheEnd>NC1.End) = NC1.End;
                        end
                    else
                        if isscalar(NC2.End)
                            TheEnd = NC1.End;
                            TheEnd(TheEnd>NC2.End) = NC2.End;
                        else
                            TheEnd = min([NC1.End; NC2.End]);
                        end
                    end
                    Area = 2*pi*NC1.Connection.x*(TheEnd-TheStart);
                else
                    Area = pi*(min([NC1.End NC2.End])^2-max([NC1.Start NC2.Start])^2);
                end
            else % This case will only include Vertical because Horizontal never changes activation
                % Vertical
                if isscalar(NC1.Start)
                    if isscalar(NC2.Start)
                        TheStart = max([NC1.Start NC2.Start]);
                    else
                        TheStart = NC2.Start;
                        TheStart(TheStart<NC1.Start) = NC1.Start;
                    end
                else
                    if isscalar(NC2.Start)
                        TheStart = NC1.Start;
                        TheStart(TheStart<NC2.Start) = NC2.Start;
                    else
                        TheStart = max([NC1.Start; NC2.Start]);
                    end
                end
                if isscalar(NC1.End)
                    if isscalar(NC2.End)
                        TheEnd = min([NC1.End NC2.End]);
                    else
                        TheEnd = NC2.End;
                        TheEnd(TheEnd>NC1.End) = NC1.End;
                    end
                else
                    if isscalar(NC2.End)
                        TheEnd = NC1.End;
                        TheEnd(TheEnd>NC2.End) = NC2.End;
                    else
                        TheEnd = min([NC1.End; NC2.End]);
                    end
                end
                Area = 2*pi*NC1.Connection.x*(TheEnd-TheStart);
                Area(~ActiveTimes) = 0;
            end
            if NC1.Node.Type ~= enumNType.SN && NC2.Node.Type ~= enumNType.SN
                P = 1;
                for NC = [NC1 NC2]
                    if isa(NC.Node.Body,'Body')
                        if ~isempty(NC.Node.Body.Matrix)
                            Mat = NC.Node.Body.Matrix;
                            if ~strcmp(Mat.name,'Undefined Matrix') && ...
                                    isfield(Mat.data,'Porosity')
                                P = min(P,Mat.data.Porosity);
                            end
                        end
                    end
                end
                if P ~= 1
                    Area = Area*P;
                    %             disp("Face area modified for matrix porosity in NodeContact.getArea")
                end
            end
        end
        function [U] = getConductance(NC1,NC2,ActiveTimes)
            U = 0;
            ActiveTimes = logical(ActiveTimes);
            % Material property of Node has priority over that of Body. Neccessary
            % for matrixes where nodes have different material than parent body.
            if isfield(NC1.Node.data,'matl'); matl1 = NC1.Node.data.matl;
            else; matl1 = NC1.Node.Body.matl;
            end
            if isfield(NC2.Node.data,'matl'); matl2 = NC2.Node.data.matl;
            else; matl2 = NC2.Node.Body.matl;
            end
            if isscalar(ActiveTimes)
                % Static
                % scalar: s1,e1,s2,e2
                L = abs(min([NC1.End NC2.End])-max([NC1.Start NC2.Start]));
                if NC1.Connection.Orient == enumOrient.Vertical
                    if NC1.Node.Type == enumNType.SN % Solid Node
                        U = AnnularConduction(...
                            NC1.Node,  NC1.Connection.x,...
                            L,         matl1);
                        if U == 0
                            return;
                        end
                        % Matthias: Added code to use custom heat transfer coefficient 'h_custom'
                        % [W/(m^2 K)] analogue to convective coefficient 'h' to be included in
                        % conductance calculation for solid faces if one of the parent bodies of
                        % the present nodes has such coefficient that is not NaN.
                        % Implemented for static faces only!
                        % Note: If the body with 'h_custom' is discretized, 'h_custom' will be
                        % applied at each face between nodes within the body! Only use with
                        % undiscretized bodies e.g. Constant Temperature sources. Should fix this
                        % to only apply 'h_custom' to faces with nodes from other bodies.
                        if ~isnan(NC1.Node.Body.h_custom) && NC2.Node.Type == enumNType.SN
                            U = 1/(1/U + 1/(2*pi*NC1.Connection.x*L *NC1.Node.Body.h_custom));
                        end

                    elseif NC1.Node.Type == enumNType.EN
                        U = 2*pi*NC1.Connection.x*L*NC1.Node.Body.h;
                    end
                    if NC2.Node.Type == enumNType.SN % Solid Node
                        if U ~= 0
                            U = 1/(1/U + 1/...
                                AnnularConduction(...
                                NC2.Node, NC2.Connection.x,...
                                L,        matl2));
                        else
                            U = AnnularConduction(...
                                NC2.Node, NC2.Connection.x,...
                                L,        matl2);
                        end
                        % Matthias (see above)
                        if ~isnan(NC2.Node.Body.h_custom) && NC1.Node.Type == enumNType.SN
                            if U ~= 0
                                U = 1/(1/U + 1/(2*pi*NC2.Connection.x*L *NC2.Node.Body.h_custom));
                            else
                                U = 2*pi*NC2.Connection.x*L *NC2.Node.Body.h_custom;
                            end
                        end

                    elseif NC2.Node.Type == enumNType.EN
                        if U ~= 0
                            U = 1/(1/U + 1/(2*pi*NC2.Connection.x*L*NC2.Node.Body.h));
                        else
                            U = 2*pi*NC2.Connection.x*L*NC2.Node.Body.h;
                        end
                    end
                else % Horizontal face
                    r1 = max([NC1.Start NC2.Start]);
                    r2 = r1 + L;
                    if NC1.Node.Type == enumNType.SN % Solid Node
                        U = LinearConduction(NC1.Node, r1, r2, matl1);
                        if U == 0; return; end
                        % Matthias (see above)
                        if ~isnan(NC1.Node.Body.h_custom) && NC2.Node.Type == enumNType.SN
                            % Matthias, 29 May 2022: Incorrect factor 2 removed. tested
                            % validity with simple model of const. temp. bodies.
                            %                 U = 1/(1/U + 1/(2*pi*(r2^2-r1^2) *NC1.Node.Body.h_custom));
                            U = 1/(1/U + 1/(pi*(r2^2-r1^2) *NC1.Node.Body.h_custom));
                        end

                    elseif NC1.Node.Type == enumNType.EN
                        %             U = 2*pi*(r2^2-r1^2)*NC1.Node.Body.h;
                        U = pi*(r2^2-r1^2)*NC1.Node.Body.h;
                    end
                    if NC2.Node.Type == enumNType.SN % Solid Node
                        if U ~= 0
                            U = 1/(1/U + 1/LinearConduction(NC2.Node, r1, r2, matl2));
                        else
                            U = LinearConduction(NC2.Node, r1, r2, matl2);
                        end
                        % Matthias (see above)
                        if ~isnan(NC2.Node.Body.h_custom) && NC1.Node.Type == enumNType.SN
                            if U ~= 0
                                %                     U = 1/(1/U + 1/(2*pi*(r2^2-r1^2) *NC2.Node.Body.h_custom));
                                U = 1/(1/U + 1/(pi*(r2^2-r1^2) *NC2.Node.Body.h_custom));
                            else
                                %                     U = 2*pi*(r2^2-r1^2) *NC2.Node.Body.h_custom;
                                U = pi*(r2^2-r1^2) *NC2.Node.Body.h_custom;
                            end
                        end

                    elseif NC2.Node.Type == enumNType.EN
                        if U ~= 0
                            %                 U = 1/(1/U + 1/(2*pi*(r2^2-r1^2)*NC2.Node.Body.h));
                            U = 1/(1/U + 1/(pi*(r2^2-r1^2)*NC2.Node.Body.h));
                        else
                            %                 U = 2*pi*(r2^2-r1^2)*NC2.Node.Body.h;
                            U = pi*(r2^2-r1^2)*NC2.Node.Body.h;
                        end
                    end
                end
                return;
            else
                % Dynamic - Vertical Only
                TheStart = zeros(1,Frame.NTheta);
                TheEnd = zeros(1,Frame.NTheta);
                if isscalar(NC1.Start)
                    if isscalar(NC2.Start)
                        TheStart = max([NC1.Start NC2.Start]);
                    else
                        TheStart = NC2.Start;
                        TheStart(ActiveTimes & TheStart<NC1.Start) = NC1.Start;
                    end
                else
                    if isscalar(NC2.Start)
                        TheStart = NC1.Start;
                        TheStart(ActiveTimes & TheStart<NC2.Start) = NC2.Start;
                    else
                        TheStart(ActiveTimes) = max([NC1.Start(ActiveTimes); NC2.Start(ActiveTimes)]);
                    end
                end
                if isscalar(NC1.End)
                    if isscalar(NC2.End)
                        TheEnd = min([NC1.End NC2.End]);
                    else
                        TheEnd = NC2.End;
                        TheEnd(ActiveTimes & TheEnd>NC1.End) = NC1.End;
                    end
                else
                    if isscalar(NC2.End)
                        TheEnd = NC1.End;
                        TheEnd(ActiveTimes & TheEnd>NC2.End) = NC2.End;
                    else
                        TheEnd(ActiveTimes) = min([NC1.End(ActiveTimes); NC2.End(ActiveTimes)]);
                    end
                end
                U = 2*pi*NC1.Connection.x*(TheEnd-TheStart);
                U(~ActiveTimes) = 0;
                % Actual Conduction Modifier
                r = NC1.Connection.x;
                L = U./(2*pi*r);
                if NC1.Node.Type == enumNType.SN
                    if NC2.Node.Type == enumNType.SN
                        % Both are solid
                        U = 1./(1./AnnularConduction(NC1.Node,r,L,matl1) + ...
                            1./AnnularConduction(NC2.Node,r,L,matl2));
                    else
                        % NC1 is the solid
                        U = AnnularConduction(NC1.Node,r,L,matl1);
                    end
                else
                    % NC2 must be solid
                    U = AnnularConduction(NC2.Node,r,L,matl2);
                end
            end
        end

        function [Dist] = getDistance(NC1,NC2,ActiveTimes)
            %       Get distance to center of face
            c = getCenterOfOverlapRegion(NC1.Start,NC2.Start,NC1.End,NC2.End);
            switch NC1.Connection.Orient
                case enumOrient.Vertical
                    Dist = 0;
                    for NC = [NC1 NC2]
                        if NC.Node.Type ~= enumNType.EN
                            cx = (NC.Node.xmin + NC.Node.xmax)./2;
                            cy = (NC.Node.ymin + NC.Node.ymax)./2;
                            Dist = Dist + sqrt(...
                                (cx - NC.Connection.x).^2 + ...
                                (cy - c).^2);
                        end
                    end
                case enumOrient.Horizontal
                    Dist = 0.0;
                    for NC = [NC1 NC2]
                        if NC.Node.Type ~= enumNType.EN
                            cx = (NC.Node.xmin + NC.Node.xmax)./2;
                            cy = (NC.Node.ymin + NC.Node.ymax)./2;
                            if ~isempty(NC.Connection.RefFrame)
                                Dist = Dist + sqrt(...
                                    (cx - c).^2 + ...
                                    (cy - NC.Connection.x - ...
                                    NC.Connection.RefFrame.Positions).^2);
                            else
                                Dist = Dist + sqrt(...
                                    (cx - c).^2 + ...
                                    (cy - NC.Connection.x).^2);
                            end
                        end
                    end
            end
            Dist(~ActiveTimes) = 1e8;
            Dist = CollapseVector(Dist);
        end
        function [Dist] = getStabilityDistance(NC1,NC2,ActiveTimes)
            Dist = getDistance(NC1,NC2,ActiveTimes);
        end
        function [Dh] = getDh(NC1,NC2,ActiveTimes)
            % Determine if it is a transition or not (if not, define Dh)
            if NC1.Connection.Orient == NC2.Connection.Orient
                if isscalar(ActiveTimes)
                    switch NC1.Connection.Orient
                        case enumOrient.Vertical
                            if all(NC1.Node.ymin == NC2.Node.ymin) && ...
                                    all(NC1.Node.ymax == NC2.Node.ymax)
                                Dh = 2*(NC1.End - NC1.Start);
                            else
                                if isscalar(NC1.End)
                                    if isscalar(NC2.End)
                                        D2 = min([NC1.End NC2.End]);
                                    else
                                        D2 = NC2.End;
                                        D2(D2 > NC1.End) = NC1.End;
                                    end
                                else
                                    if isscalar(NC2.End)
                                        D2 = NC1.End;
                                        D2(D2 > NC2.End) = NC2.End;
                                    else
                                        D2 = min([NC1.End; NC2.End]);
                                    end
                                end
                                if isscalar(NC1.Start)
                                    if isscalar(NC2.Start)
                                        D1 = max([NC1.Start NC2.Start]);
                                    else
                                        D1 = NC2.Start;
                                        D1(D1 < NC1.Start) = NC1.Start;
                                    end
                                else
                                    if isscalar(NC2.Start)
                                        D1 = NC1.Start;
                                        D1(D1 < NC2.Start) = NC2.Start;
                                    else
                                        D1 = max([NC1.Start; NC2.Start]);
                                    end
                                end
                                Dh = 2*(D2 - D1);
                            end
                        case enumOrient.Horizontal
                            if all(NC1.Node.xmin == NC2.Node.xmin) && ...
                                    all(NC1.Node.xmax == NC2.Node.xmax)
                                Dh = 2*(NC1.End - NC2.Start);
                            else
                                if isscalar(NC1.End)
                                    if isscalar(NC2.End)
                                        D2 = min([NC1.End NC2.End]);
                                    else
                                        D2 = NC2.End;
                                        D2(D2 > NC1.End) = NC1.End;
                                    end
                                else
                                    if isscalar(NC2.End)
                                        D2 = NC1.End;
                                        D2(D2 > NC2.End) = NC2.End;
                                    else
                                        D2 = min([NC1.End; NC2.End]);
                                    end
                                end
                                if isscalar(NC1.Start)
                                    if isscalar(NC2.Start)
                                        D1 = max([NC1.Start NC2.Start]);
                                    else
                                        D1 = NC2.Start;
                                        D1(D1 < NC1.Start) = NC1.Start;
                                    end
                                else
                                    if isscalar(NC2.Start)
                                        D1 = NC1.Start;
                                        D1(D1 < NC2.Start) = NC2.Start;
                                    else
                                        D1 = max([NC1.Start; NC2.Start]);
                                    end
                                end
                                Dh = 2*(D2 - D1);
                            end
                    end
                else
                    switch NC1.Connection.Orient
                        case enumOrient.Vertical
                            if isscalar(NC1.End)
                                if isscalar(NC2.End)
                                    D2 = min([NC1.End NC2.End]);
                                else
                                    D2 = NC2.End;
                                    D2(D2 > NC1.End) = NC1.End;
                                end
                            else
                                if isscalar(NC2.End)
                                    D2 = NC1.End;
                                    D2(D2 > NC2.End) = NC2.End;
                                else
                                    D2 = min([NC1.End; NC2.End]);
                                end
                            end
                            if isscalar(NC1.Start)
                                if isscalar(NC2.Start)
                                    D1 = max([NC1.Start NC2.Start]);
                                else
                                    D1 = NC2.Start;
                                    D1(D1 < NC1.Start) = NC1.Start;
                                end
                            else
                                if isscalar(NC2.Start)
                                    D1 = NC1.Start;
                                    D1(D1 < NC2.Start) = NC2.Start;
                                else
                                    D1 = max([NC1.Start; NC2.Start]);
                                end
                            end
                            Dh = 2*(D2 - D1);
                            Dh(Dh<0) = 0;
                        case enumOrient.Horizontal
                            if isscalar(NC1.End)
                                if isscalar(NC2.End)
                                    D2 = min([NC1.End NC2.End]);
                                else
                                    D2 = NC2.End;
                                    D2(D2 > NC1.End) = NC1.End;
                                end
                            else
                                if isscalar(NC2.End)
                                    D2 = NC1.End;
                                    D2(D2 > NC2.End) = NC2.End;
                                else
                                    D2 = min([NC1.End; NC2.End]);
                                end
                            end
                            if isscalar(NC1.Start)
                                if isscalar(NC2.Start)
                                    D1 = max([NC1.Start NC2.Start]);
                                else
                                    D1 = NC2.Start;
                                    D1(D1 < NC1.Start) = NC1.Start;
                                end
                            else
                                if isscalar(NC2.Start)
                                    D1 = NC1.Start;
                                    D1(D1 < NC2.Start) = NC2.Start;
                                else
                                    D1 = max([NC1.Start; NC2.Start]);
                                end
                            end
                            Dh = 2*(D2 - D1);
                            Dh(Dh<0) = 0;
                    end
                end
            else
                % This should never happen
                fprintf('XXX Perpendicular NodeContacts in Hydraulic Diameter Calc XXX\n');
            end
        end
        function [keep] = AlignedMask(M,T,b1,b2)
            Ms = M.Start;
            Me = M.End;
            N = max([length(Ms) length(Me) length(b1) length(b2)]);
            if nargin > 2
                % Test lower bounds of Mask
                for i = 1:N
                    msi = min(length(Ms),i);
                    mei = min(length(Me),i);
                    b1i = min(length(b1),i);
                    b2i = min(length(b2),i);
                    if Ms(msi) >= b2(b2i)
                        Ms(msi) = inf;
                        Me(mei) = inf;
                    else
                        if Ms(msi) < b1(b1i)
                            Ms(msi) = b1(b1i);
                        end
                    end
                end
                % Test upper bounds of Mask
                for i = 1:N
                    msi = min(length(Ms),i);
                    mei = min(length(Me),i);
                    b1i = min(length(b1),i);
                    b2i = min(length(b2),i);
                    if Me(mei) ~= inf
                        if Me(mei) <= b1(b1i)
                            Me(mei) = -inf;
                            Ms(msi) = -inf;
                        else
                            if Me(mei) > b2(b2i)
                                Me(mei) = b2(b2i);
                            end
                        end
                    end
                end
            end

            keep = true;
            ActiveTimes = ~((Ms >= T.End) + (T.Start >= Me));
            if any(ActiveTimes)
                if isscalar(ActiveTimes)
                    if Ms <= T.Start
                        T.Start = Me;
                    elseif Me >= T.End
                        T.End = Ms;
                    else
                        temp = T.End;
                        T.End = Ms;
                        NewNC = NodeContact(...
                            T.Node, Me, temp, T.Type, T.Connection);
                        if NewNC.Start < NewNC.End
                            T.Connection.addNodeContacts(NewNC);
                        end
                    end
                    if T.Start >= T.End
                        keep = false;
                        return;
                    end
                else
                    for i = 1:length(ActiveTimes)
                        ms = min(length(Ms),i);
                        me = min(length(Me),i);
                        ts = min(length(T.Start),i);
                        te = min(length(T.End),i);
                        if Ms(ms) <= T.Start(ts)
                            T.Start(ts) = Me(me);
                        elseif Me(me) >= T.End(te)
                            T.End(te) = Ms(ms);
                        else
                            temp = T.End(te);
                            T.End(te) = Ms(ms);
                            NewNC = NodeContact(...
                                T.Node, Me(me), temp, T.Type, T.Connection);
                            if NewNC.Start < NewNC.End
                                T.Connection.addNodeContacts(NewNC);
                            end
                        end
                        if T.Start(ts) >= T.End(te)
                            T.Start(ts) = T.End(te);
                        end
                    end
                    if all(T.Start == T.End)
                        keep = false;
                        return;
                    end
                end
            end
        end
        function [keep1, keep2] = MutualMask(M1,M2)
            Mask1 = CopyClass(M1);
            Mask2 = CopyClass(M2);
            keep1 = Mask1.AlignedMask(M2,-inf,inf);
            keep2 = Mask2.AlignedMask(M1,-inf,inf);
        end
    end
end

