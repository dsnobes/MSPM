function [ pos ] = Raphael_Crank_PP( Nang, Phase )
    %% General Motion function inputs & outputs
    % Nang = number of angle increments per cycle. (scalar)
    % Phase = phase shift
    % of motion [rad] (scalar)
    % pos = motion profile output (vector). Values should have range [0,1].
    % pos(1) = pos(end).
    % Will have dimensions (1 x Nang). Stroke is a separate input and does NOT
    % affect the motion function!
    
    % Motion with Sinusoid:
    % PP: phase 0, starts at TDC (modeled in BDC position)
    % DP: phase pi/2, starts at mid stroke going down (modeled in BDC position)
    
    %% User Inputs
    S = 0.075; % Stroke
    R = S/2; %Crank radius
    L = 0.146; % Connecting rod length
    
    %%
    % Phase = Phase + pi;
    % pos = zeros(1,Nang);
    
    theta = linspace(0+Phase,2*pi+Phase, Nang);
    pos = sqrt( L^2 - (R*sin(theta)).^2 ) + R*cos(theta);
    % Normalize to range [0,1]
    pos = pos - min(pos);
    pos = pos ./ max(pos);
    
    % for i = 1:Nang
    %   x = mod(i-1 + (-Phase)/(2*pi)*(Nang-1),Nang-1);
    %   if x < 0.5*(Nang-1)
    %     % Within First Top Circle
    %     pos(i) = 1 - 2*x/(Nang-1);
    %   else
    %     pos(i) = 2*(x-(Nang-1))/(Nang-1) + 1;
    %   end
    % end
    %
    % ends = zeros(1,4);
    % for i = 1:100
    %   ends(1:2) = pos(1:2);
    %   ends(3:4) = pos(end-1:end);
    %   pos(2:end-1) = (pos(1:end-2) + pos(3:end))/2;
    %   pos(1) = (ends(2) + ends(4))/2;
    %   pos(end) = (ends(1) + ends(3))/2;
    % end
    % pos = pos - min(pos);
    % pos = pos / max(pos);
end


