function [p_dev_max, p_dev_mean, PV_overlap_ratio] = Data_PVcompare(plotPVs,figure_purpose,iPV_exp,iPV_mod, DATA_EXP,DATA_MOD)

% if length(iPV_mod) > 1; plotPVs = false; end

% This code will compare PVs of the datasets that are listed in the same
% position in iPV_mod and iPV_exp.

n_sets = length(iPV_mod);

if n_sets ~= length(iPV_exp)
    error("iPV_mod and iPV_exp must have equal length.")
end

% Initialize outputs. May change size during loop.
p_dev_max = cell(n_sets, 1);
p_dev_mean = cell(n_sets, 1);
PV_overlap_ratio = cell(n_sets, 1);

% loop through pairs of model and exp datasets given in iPV_mod and iPV_exp
% using index i_set
for i_set = 1:n_sets
    
    nPV = length( DATA_EXP(iPV_exp(i_set)).data );

    if nPV ~= length( DATA_MOD(iPV_mod(i_set)).data )
        error("Datasets for PV comparison must have equal number of data points.")
    end
    
    close all
    
    % loop through datapoints of one set using index i
    for i = 1:nPV
        % import experiment PV
        Vexp = DATA_EXP(iPV_exp(i_set)).data(i).Vtotal_rounded;
        pexp = DATA_EXP(iPV_exp(i_set)).data(i).p_PC_avg;
        
        % import model PV
        Vmod = DATA_MOD(iPV_mod(i_set)).data(i).PV_PP.V;
        pmod = DATA_MOD(iPV_mod(i_set)).data(i).PV_PP.p;
        
        fig_count = 1; % reset counter so that old plots are overwritten
        % show plots in curent iteration if following conditions are true
        show_this_plot = plotPVs > 0  &&  (rem(i,plotPVs)==0 || i==1 || i==nPV); % always show 1st and last plot
        
        %plot PV curves for testing
        if show_this_plot
            figure(fig_count);
            fig_count = fig_count+1;
            plot(Vexp,pexp,Vmod,pmod)
            legend('exp','mod')
            title('PV curves BEFORE interpolation and normalization')
            nicefigure(figure_purpose);
            movegui('west')
        end
        
        % usually experiment has 360 angle increments, MSPM has 200.
        % Interpolate MPSM data to 360 points and shift by 180deg to match
        % experiment data format.
        target_range = linspace(0,360,length(Vexp))'; % ususally 360
        orig_range = linspace(0,360,length(Vmod)); % ususally 200
        pmod = interp1(orig_range, pmod, target_range);
        Vmod = interp1(orig_range, Vmod, target_range);
        pmod = circshift(pmod,180);
        Vmod = circshift(Vmod,180);
        
        % Shift data: Min volume of Vmod equals that of Vexp, mean
        % pressures equal to experiment pmean
%         Vexp = Vexp - min(Vexp);
        Vmod = Vmod - min(Vmod) + min(Vexp);
        pmod = pmod + mean(pexp) - mean(pmod);
        
        % Normalize axes
        Vexp = Vexp / max(Vexp); % rel. to Vmax
        Vmod = Vmod / max(Vmod);
        pexp = pexp - mean(pexp); % difference from pmean
        pmod = pmod - mean(pmod);
        
        
        % Method 1: Average and maximum deviation between pressure data.
        % Relative to mean pressure.
        p_dev = abs(pexp - pmod) ./ mean(pexp);
        p_dev_max{i_set}(i) = max(p_dev);
        p_dev_mean{i_set}(i) = mean(p_dev);
        %p_dev_rms(i_set,i) = rms(p_dev);
        
        % Method 2: Area of overlap between both PV loops, relative to both PV
        % areas (smallest ratio is the overlap ratio).
        % Could calculate all areas between the curves: True positive
        % (overlapping), false positive (covered by model but not by exp), false
        % negative (covered by exp but not by model).
        % For now, just the overlap area will do.
        p_overlap = [];
        V_overlap = [];
        no_overlap_indexes = [];
        p_overlap_2 = [];
        V_overlap_2 = [];
        no_overlap_indexes_2 = [];
        %     i_max_bot = [];
        %     i_min_top = [];
        
        V_deviation = NaN(4, length(Vexp)/2);
        % Starting at V=Vmax, beginning of compression
        for a = 1 : length(Vexp)/2
            % list the pressure values at current volume point (compression and
            % expansion curves), and corresponding voluem values
            p1 = [pexp(a), pexp(end-a+1)];
            p2 = [pmod(a), pmod(end-a+1)];
            
            V = [Vexp(a), Vexp(end-a+1)]; % The experiment volume value will be used from here
            V2 = V;
            % Deviation between Vexp(a) and the other 3 volume values, relative to
            % maximum volume. For purpose of checking and correcting this
            % deviation.
            V_deviation(:,a) = ([V';  Vmod(a); Vmod(end-a+1)] - V(1)) ./ max(Vexp);
            
            %      p_values = [pexp(a), pexp(end-a+1), pmod(a), pmod(end-a+1)];
            %      % determine ascending order of values
            %      [~,order] = sort(p_values);
            %      switch order
            %          case [1 2 3 4] || [3 4 1 2] || [2 1 3 4]
            %      end
            
            % work at this instance is positive if 1st p value < 2nd p value.
            p1_pos = issorted(p1);
            if p1_pos ~= issorted(p2)
                warning("Data point i = "+ i + newline +"Index a = "+ a ...
                    + newline +"One curve positive while the other is negative!")
            end
            
            if min(p1) > max(p2) || min(p2) > max(p1) % case 1: no overlap.
                no_overlap_indexes(end+1) = a;
            else % cases 2 and 3: There is overlap.
                
                if min(p1)>min(p2) && max(p1)>max(p2) % case 2: partial overlap.
                    vals = [min(p1), max(p2)];
                    %          p_overlap(1, end+1) = min(p1);
                    %          p_overlap(2, end+1) = max(p2);
                elseif min(p1)<min(p2) && max(p1)<max(p2) % case 2, reversed
                    vals = [min(p2), max(p1)];
                elseif min(p1)>min(p2) && max(p1)<max(p2) % case 3: full overlap
                    vals = [min(p1), max(p1)];
                elseif min(p1)<min(p2) && max(p1)>max(p2) % case 3 reversed
                    vals = [min(p2), max(p2)];
                else
                    error("Index a = "+ a + newline +"No valid overlap case between PV curves.")
                end
                % in case of negative work, flip order of values. This is because
                % in the cases above we are assuming that the smaller p value
                % occurs during compression (1st half of data), analogue to a
                % positive cycle work.
                if ~p1_pos
                    vals = flip(vals);
                    V = flip(V);
                end
                % add to list of points in 'overlap' data. In 1st column store values
                % from 1st half of the curves (compression), in 2nd column
                % values from 2nd half (expansion, which will need to be reversed in order).
                p_overlap(end+1, :) = vals;
                V_overlap(end+1, :) = V;
                
            end
            
            
            %         % alternative, simpler code for above 'if' section:
            %         % the overlap area is always between the max of the two bottom
            %         % p-values and the min of the two top p values.
            %         if min(p1) > max(p2) || min(p2) > max(p1) % case 1: no overlap.
            %             no_overlap_indexes_2(end+1) = a;
            %         else
            %             % list the bottom and top values
            %             p_bot = [min(p1), min(p2)];
            %             p_top = [max(p1), max(p2)];
            %             % assign as described above
            %             [max_bot, i_max_bot(end+1)] = max(p_bot);
            %             [min_top, i_min_top(end+1)] = min(p_top);
            %             vals2 = [max_bot, min_top];
            %             if ~p1_pos
            %                 vals2 = flip(vals2);
            %                 V2 = flip(V2);
            %             end
            %             p_overlap_2(end+1, :) = vals2;
            %             V_overlap_2(end+1, :) = V2;
            %
            %         end
            
            % alternative, simpler code for above 'if' section:
            % the overlap area is always between the max of the two bottom
            % p-values and the min of the two top p values.
            if min(p1) > max(p2) || min(p2) > max(p1) % case 1: no overlap.
                no_overlap_indexes_2(end+1) = a;
            else
                % list the bottom and top values
                p_bot = [min(p1), min(p2)];
                p_top = [max(p1), max(p2)];
                % assign as described above
                vals2 = [max(p_bot), min(p_top)];
                if ~p1_pos
                    vals2 = flip(vals2);
                    V2 = flip(V2);
                end
                p_overlap_2(end+1, :) = vals2;
                V_overlap_2(end+1, :) = V2;
                
            end
            
        end
        
        % find max deviation between any of the 4 volume values for each angle
        [V_deviation_max, V_deviation_max_i] = max(abs(V_deviation));
        [V_deviation_max_overall, V_deviation_max_overall_i] = max(V_deviation_max);
        msg = "Max deviation " + V_deviation_max_overall*100 + "% at angle " +  V_deviation_max_overall_i;
        %plot Volume over crank angle
        if show_this_plot
            figure(fig_count);
            fig_count = fig_count+1;
            
            plot(1:360,Vexp,'k', 1:360,Vmod,':r')
            text(V_deviation_max_overall_i, Vexp(V_deviation_max_overall_i), msg)
            legend('Experiment','Model')
            title('Volume vs crank angle comparison')
            xlabel('Crank [\circ]')
            ylabel('V [m^3]')
            nicefigure(figure_purpose);
            movegui('center')
        end
        
        
        % Compile overlap curve and calculate overlap ratio
        if any(p_overlap-p_overlap_2)
            error("Index i = "+ i + newline +"Different results between overlap calc methods.")
        end
        % Reshape overlap data into one column, flip 2nd half (expansion) data
        p_overlap = [p_overlap(:,1); flip(p_overlap(:,2))];
        V_overlap = [V_overlap(:,1); flip(V_overlap(:,2))];
        % Close the PV loop for accurate area calculation
        p_overlap = [p_overlap; p_overlap(1)];
        V_overlap = [V_overlap; V_overlap(1)];
        % Integrate for area
        A_overlap = trapz(V_overlap,p_overlap);
        A_exp = trapz(Vexp,pexp);
        A_mod = trapz(Vmod,pmod);
        % overlap ratios relative to exp and mod PV areas
        rel_overlap = A_overlap ./ [A_exp, A_mod];
        rel_overlap(rel_overlap>1) = 1; %Prevent values greater than 100%
%          rel_overlap = A_overlap ./ [DATA_EXP(iPV_exp(i_set)).data(i).Wind_exp, DATA_MOD(iPV_mod(i_set)).data(i).PV_PP.Wind];
       % smaller ratio is the relevant ratio
        PV_overlap_ratio{i_set}(i) = min(rel_overlap);
        
        % plot PV curves, overlap curve, overlap percentage label if wanted
        if show_this_plot
            figure(fig_count);
            fig_count = fig_count+1;
            
            plot(Vexp,pexp/1000,'-k', Vmod,pmod/1000,'-b', V_overlap,p_overlap/1000,'--r' ,'LineWidth',1)
            
                        ovmsg = "Overlap with" +newline+ "Experiment: "...
                +round((rel_overlap(1)*100),1) + " %"...
                +newline+ "Model: " + round((rel_overlap(2)*100),1) + " %";
            %         hold on
            text(0.05, 0.13, ovmsg, 'Units','normalized', 'FontSize',10, 'FontName','Arial')
            ovmsg = "\itp_{set}\rm = " + DATA_EXP(iPV_exp(i_set)).data(i).pmean_setpoint/1000 + "kPa"+newline+ "\itf\rm = " + round(DATA_EXP(iPV_exp(i_set)).data(i).encoder_speed) + "rpm";
            text(0.05, 0.35, ovmsg, 'Units','normalized', 'FontSize',10, 'FontName','Arial')

            
%             ovmsg = "\itp_{set}\rm = " + DATA_EXP(iPV_exp(i_set)).data(i).pmean_setpoint/1000 + "kPa"+newline+ "\itf\rm = " + round(DATA_EXP(iPV_exp(i_set)).data(i).encoder_speed) + "rpm" +newline+newline+...
%             "Overlap with" +newline+ "Experiment: "...
%                 +round((rel_overlap(1)*100),1) + " %"...
%                 +newline+ "Model: " + round((rel_overlap(2)*100),1) + " %";
%             text(0.05, 0.2, ovmsg, 'Units','normalized', 'FontSize',10, 'FontName','Arial')
            legend('Experiment','Model','Overlap')
            
            % Display first 20 characters of file name (until '_') in plot title
            name_start = DATA_MOD(iPV_mod(i_set)).data(i).filename(1:20);
            %         name_start = strtok(name_start, '_');
            
            title(("Index " + i + " ("+ name_start +"...), PV curves"), 'Interpreter','none')
            ylabel('\itp_{PC}\rm - mean(\itp_{PC}\rm) [kPa]')
            xlabel('\itV_{total}\rm / \itV_{max}')
            nicefigure(figure_purpose);
            movegui('east')

            % Ask user if to continue or cancel
            quest = "Showing dataset " + i_set + ", data point " + i + newline + "Press ENTER to continue to next data point, any other input to cancel.";
            answer = input(quest,'s');
            if ~isempty(answer); break; end
            
            %             box = msgbox(quest);
            %             waitfor(box);
            
            %             answer = uigetpref('one','one','', ("Showing data point " + i + newline + "Continue to next data point?"), 'Next|Cancel');
            
            %             answer = questdlg(("Showing data point " + i + newline + "Continue to next data point?"),...
            %                 "", "Next", "Cancel", "Next");
            %             set(gcf ,'WindowStyle','normal');
            
            %             switch answer
            %                 case 'next'
            %                     % just continue
            %                 case 'cancel'
            %                     break;
            %             end
        end
    end
end