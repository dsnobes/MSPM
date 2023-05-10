function FW = FW_Subfunction_v4(P_engine, P_buffer, V_engine)
% Modified Nov 2021 by Matthias for FW calculation only. Original:
% function [W_ind, FW, W_shaft] = FW_Subfunction_v3(P_engine,P_buffer,V_engine,effect, wantPlot)

% Forced Work subfunction updated to run faster without plotting
% functionality

% Forced Work 2 - Written by Connor Speer, November 2016
% *** Forced Work modificiations - April 2017 - Calynn Stumpf

% *** Modified in June 2017 to work as a subfunction.

% Modified August 2017 by Steven Middleton and Shahzeb Mirza

% See Senft Pg 17 for a definition of forced work.

% Inputs:
% theta --> Vector of engine crank angles, Vmax = 0 deg, [deg]
% P_engine --> Vector of engine pressures corresponding to theta vector [Pa]
% P_buffer --> Vector of buffer pressures corresponding to theta vector [Pa]
% V_engine --> Vector of engine volumes corresponding to theta vector [m^3]
% effect --> Constant mechanism effectiveness
% wantPlot --> True or False

% Outputs:
% W_ind --> Indicated work in [J]
% FW --> Forced work in [J]
% W_shaft --> Shaft work out in [J]

% Notes:
% Orientation of Pressure and Volume arrays must be correct (Indicator
% diagram must 'turn' the desired way

% % E = effect; % Mechanism effectiveness

% % W_ind = polyarea(Vtotal,P_cycle); % Calculate Indicated Work by Integrating the Indicator Diagram

% % %% Plot Set-Up
% % set(0,'defaultfigurecolor',[1 1 1])
% % 
% % % Location of Figures
% % x = 500;
% % y = 500;
% % 
% % % Size of Figures
% % width = 550;
% % height = 400;
% % 
% % % Font For Figures
% % font = 'Arial';
% % font_size = 11;
% % 
% To change line width for plots, say "'LineWidth',2"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Forced Work Calculations    
% Calculate the difference b/w cycle and buffer pressure at each point
P_diff = P_engine - P_buffer;

dV = delta(V_engine);

FW = 0;

% % if wantPlot
% %     figure('Position', [x y width height]); 
% %     hold on;
% % end
% % 
% % nLines = 350;
% % spacing = floor(length(dV)/nLines);

% Use DEFINITION of Forced work and Riemann Sums to find final FW
for i = 1:length(dV)
    if (sign(dV(i)) ~= sign(P_diff(i))) % If they are of opposite sign
        FW = FW + abs(P_diff(i)*dV(i));
% %         if (wantPlot) && (mod(i,spacing) == 0)
% %             plot([V_engine(i) V_engine(i)],[P_engine(i)./1000 P_buffer(i)./1000], 'r','LineWidth',3);
% %         end
    end
end
% % W_shaft = (E*W_ind) - (((1/E) - E)*FW); % Shaft Work

% % if wantPlot
% %     P1 = plot(V_engine, P_engine./1000,'b','LineWidth',2);
% %     P2 = plot(V_engine, P_buffer./1000,'k','LineWidth',2);
% %     xlabel('Engine Volume (m^3)','FontName',font,'FontSize',font_size)
% %     ylabel('Pressure (kPa)','FontName',font,'FontSize',font_size)
% %     legend([P1 P2],{'Engine Pressure','Buffer Pressure'})
% %     set(gca,'fontsize',font_size);
% %     set(gca,'FontName',font)
% % %     xlim([1.34e-3 1.8e-3])
% % %     ylim([800 1250])
% %     hold off
% % 
% % 
% % % Display Indicated Work
% % Text1 = ['Indicated Cycle Work: ',num2str(W_ind),' J'];
% % disp(Text1);
% % 
% % % Total Forced Work
% % Text2 = ['Total Forced Work:    ',num2str(FW),' J'];
% % disp(Text2);
% % 
% % % Display Shaft Work (See Senft pg 106)
% % Text3 = ['Shaft Work:           ',num2str(W_shaft),' J'];
% % disp(Text3);
% % end
end

