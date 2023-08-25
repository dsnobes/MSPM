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

function [oNodes,Interp] = findClosest4(loc,Body)
    % Find distance to all nodes
    % Find the members of the body who's material matches the phase of the
    % body material.
    iNodes = Body.Nodes;
    Phase = Body.matl.Phase;
    include = true(size(iNodes));
    for i = 1:length(iNodes)
        if ~isvalid(iNodes(i))
            include(i) = false;
            continue;
        end
        if isfield(iNodes(i).data,'matl') && iNodes(i).data.matl.Phase ~= Phase
            include(i) = false;
            continue;
        end
    end
    iNodes = iNodes(include);
    if isempty(iNodes)
        oNodes = [];
        Interp = [];
        return;
    end
    dist2 = zeros(length(iNodes),1);
    i = 1;
    for Nd = iNodes
        NodeCenter = Nd.minCenterCoords;
        dist2(i) = (NodeCenter.x-loc.x)^2+(NodeCenter.y-loc.y)^2;
        if dist2(i) == 0
            oNodes = Nd.index;
            Interp = 1;
            return;
        end
        i = i + 1;
    end
    
    % Sort the dist and node array
    tNodes = Node.empty;
    if length(iNodes) > 3
        limit = 4;
    else
        limit = 2;
    end
    if ~isempty(iNodes)
        notdone = true;
        while notdone
            d1 = min(dist2);
            if d1 == Inf || length(tNodes) == limit
                [Interp, tNodes] = interpCoefficients(loc,tNodes);
                oNodes = zeros(1,length(tNodes));
                for i = 1:length(tNodes)
                    oNodes(i) = tNodes(i).index;
                end
                return;
            end
            MinNodes = iNodes(dist2==d1);
            maxlen = min(length(MinNodes),limit - length(tNodes));
            tNodes(end+1:end+maxlen) = MinNodes(1:maxlen);
            dist2(dist2==d1) = Inf;
        end
    end
    Interp = [];
end