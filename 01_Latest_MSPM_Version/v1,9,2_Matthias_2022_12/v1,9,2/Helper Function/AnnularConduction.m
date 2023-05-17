function [ U ] = AnnularConduction(Node,r,L,matl)
    %ANNULARCONDUCTION Summary of this function goes here
    %   Detailed explanation goes here
    if Node.xmin ~= 0
        mid_r = sqrt(Node.xmin*Node.xmax);
        %Matthias: Replaced 'if' statement with 'r_ratio'
        r_ratio = max([r/mid_r, mid_r/r]);
        U = (2*pi*matl.ThermalConductivity/log(r_ratio)).*L;
    
        %     if mid_r < r
        %       U = (2*pi*matl.ThermalConductivity/log(r/mid_r)).*L;
        %     else
        %       U = ((2*pi*matl.ThermalConductivity)/log(mid_r/r)).*L;
        %     end
    else
        % The Constant comes from 1/log(1/0.570524), which is the center
        % ... Non-dimensional radius of: Resistance*Area of a cylinder.
        U = 2*pi*matl.ThermalConductivity*1.781896.*L;
    end
end


