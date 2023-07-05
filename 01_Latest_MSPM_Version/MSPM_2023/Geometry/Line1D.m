classdef Line1D < handle
    %Line1D Summary of this class goes here
    %   Detailed explanation goes here

    properties
        bounds;
    end

    methods
        function this = Line1D(lb,ub)
            if nargin == 2
                this.bounds(1,1) = lb;
                this.bounds(1,2) = ub;
            end
        end

        function DestroyInterscept(this,other)
            n1 = 1; n2 = 1;
            s1 = 1; s2 = 1;
            notdone = true;
            while notdone

                notdone = false;

                for thisrow = s1:size(this.bounds,1)
                    lb1 = this.bounds(thisrow,1);
                    ub1 = this.bounds(thisrow,2);
                    for otherrow = s2:size(other.bounds,1)
                        lb2 = other.bounds(otherrow,1);
                        ub2 = other.bounds(otherrow,2);
                        if lb1 < lb2
                            if ub1 > ub2% && lb1 < lb2
                                % Split this, delete other
                                other.bounds(otherrow,1:2) = inf;
                                extra1(n1,1) = ub2;
                                extra1(n1,2) = this.bounds(thisrow,2);
                                this.bounds(thisrow,2) = lb2;
                                n1 = n1 + 1;
                            elseif ub1 < ub2% && lb1 < lb2
                                % this ------       ->  ----xx
                                % other    ------   ->      xx----
                                % Chop
                                this.bounds(thisrow,2) = lb2;
                                other.bounds(otherrow,1) = ub1;
                            else % ub1 == ub2 && lb1 < lb2
                                % chop this, delete other
                                other.bounds(otherrow,1:2) = inf;
                                this.bounds(thisrow,2) = lb2;
                            end
                        elseif lb1 > lb2
                            if ub1 > ub2% && lb1 > lb2
                                % this     ------   ->      xx----
                                % other------       ->  ----xx
                                % Chop
                                this.bounds(thisrow,1) = ub2;
                                other.bounds(otherrow,2) = lb1;
                            elseif ub1 < ub2% && lb1 > lb2
                                % Split other, delete this
                                this.bounds(thisrow,1:2) = inf;
                                extra2(n2,1) = ub1;
                                extra2(n2,2) = other.bounds(otherrow,2);
                                other.bounds(otherrow,2) = lb1;
                                n2 = n2 + 1;
                            else % ub1 == ub2 && lb1 > lb2
                                % chop other, delete this
                                this.bounds(thisrow,1:2) = inf;
                                other.bounds(otherrow,2) = lb1;
                            end
                        else % lb1 == lb2
                            if ub1 > ub2 % && lb1 == lb2
                                % Chop this, delete other
                                this.bounds(thisrow,1) = ub2;
                                other.bounds(otherrow,1:2) = inf;
                            elseif ub1 < ub2 % && lb1 == lb2
                                % Chop other, delete this
                                this.bounds(thisrow,1:2) = inf;
                                other.bounds(otherrow,1) = ub1;
                            else % ub1 == ub2 && lb1 == lb2
                                % delete other, delete this
                                this.bounds(thisrow,1:2) = inf;
                                other.bounds(otherrow,1:2) = inf;
                            end
                        end
                    end
                end

                % Clean up both
                r = 1:size(this.bounds,1);
                this.bounds(isinf(this.bounds(r,1)),:) = [];
                r = 1:size(other.bounds,1);
                other.bounds(isinf(other.bounds(r,1)),:) = [];

                if ~(size(this.bounds,1) == 0 || size(other.bounds,1) == 0)
                    if n1 > 1
                        s1 = size(this.bounds,1)+1;
                        s2 = 1;
                        this.bounds = [this.bounds; extra1];
                        notdone = true;
                    end

                    if ~notdone && n2 > 1
                        s1 = 1;
                        s2 = size(other.bounds,1)+1;
                        other.bounds = [other.bounds; extra2];
                        notdone = true;
                    end
                end

            end

        end

        function Subtract(this,other)
            n1 = 1;
            s1 = 1;
            notdone = true;
            while notdone

                notdone = false;

                for thisrow = s1:size(this.bounds,1)
                    lb1 = this.bounds(thisrow,1);
                    ub1 = this.bounds(thisrow,2);
                    for otherrow = 1:size(other.bounds,1)
                        lb2 = other.bounds(otherrow,1);
                        ub2 = other.bounds(otherrow,2);
                        if ~(lb1 > ub2 || lb2 > ub1)
                            if lb1 < lb2
                                if ub1 > ub2% && lb1 < lb2
                                    % Split this, delete other
                                    extra1(n1,1) = ub2;
                                    extra1(n1,2) = this.bounds(thisrow,2);
                                    this.bounds(thisrow,2) = lb2;
                                    n1 = n1 + 1;
                                elseif ub1 < ub2% && lb1 < lb2
                                    % this ------       ->  ----xx
                                    % other    ------   ->      xx----
                                    % Chop
                                    this.bounds(thisrow,2) = lb2;
                                else % ub1 == ub2 && lb1 < lb2
                                    % chop this, delete other
                                    this.bounds(thisrow,2) = lb2;
                                end
                            elseif lb1 > lb2
                                if ub1 > ub2% && lb1 > lb2
                                    % this     ------   ->      xx----
                                    % other------       ->  ----xx
                                    % Chop
                                    this.bounds(thisrow,1) = ub2;
                                elseif ub1 < ub2% && lb1 > lb2
                                    % Split other, delete this
                                    this.bounds(thisrow,1:2) = inf;
                                else % ub1 == ub2 && lb1 > lb2
                                    % chop other, delete this
                                    this.bounds(thisrow,1:2) = inf;
                                end
                            else % lb1 == lb2
                                if ub1 > ub2 % && lb1 == lb2
                                    % Chop this, delete other
                                    this.bounds(thisrow,1) = ub2;
                                elseif ub1 < ub2 % && lb1 == lb2
                                    % Chop other, delete this
                                    this.bounds(thisrow,1:2) = inf;
                                else % ub1 == ub2 && lb1 == lb2
                                    % delete other, delete this
                                    this.bounds(thisrow,1:2) = inf;
                                end
                            end
                        end
                    end
                end

                % Clean up both
                r = 1:size(this.bounds,1);
                this.bounds(isinf(this.bounds(r,1)),:) = [];

                if ~(size(this.bounds,1) == 0)
                    if n1 > 1
                        this.bounds = [this.bounds; extra1];
                    end
                end

            end
        end

        function MergeAndAppend(this,other)
            removeThis = false(1,length(this.bounds,1));
            removeOther = false(1,length(other.bounds,1));
            % See if the endpoints match up, then merge, it is assumed that the
            % lines have been subjected to DestroyInterscepts already
            % ... Add the merged lines to "this"
            for i = 1:length(this.bounds,1)
                for j = 1:length(other.bounds,1)
                    if ~removeOther(j)
                        if this.bounds(i,1) == other.bounds(j,2)
                            this.bounds(i,1) = other.bounds(j,1);
                            removeOther(j) = true;
                            i = i - 1; %#ok<FXSET>
                        elseif this.bounds(i,2) == other.bounds(j,1)
                            this.bounds(i,2) = other.bounds(j,2);
                            removeOther(j) = true;
                            i = i - 1; %#ok<FXSET>
                        end
                    end
                end
            end
            % See if the modified entries of "this" can be merged
            for i = 1:length(this.bounds,1)-1
                if ~removeThis(i)
                    for j = i+1:length(this.bounds,1)
                        if ~removeThis(j)
                            if this.bounds(i,1) == this.bounds(j,2)
                                this.bounds(i,1) = this.bounds(j,1);
                                removeThis(j) = true;
                                i = i - 1; %#ok<FXSET>
                            elseif this.bounds(i,2) == this.bounds(j,1)
                                this.bounds(i,2) = this.bounds(j,2);
                                removeThis(j) = true;
                                i = i - 1; %#ok<FXSET>
                            end
                        end
                    end
                end
            end
            % Remove entries
            this.bounds(removeOther,:) = [];
            this.bounds = [this.bounds; other.bounds];
        end

        function Line2DOutput = CreateLine2Ds(this,Orient,x)
            Line2DOutput(1,length(this.bounds,1)) = Line2DChain();
            if Orient == enumOrient.Vertical
                for i = 1:length(this.bounds,1)
                    Line2DOutput(i) = ...
                        Line2DChain(x,this.bounds(i,1),x,this.bounds(i,2));
                end
            else
                for i = 1:length(this.bounds,1)
                    Line2DOutput(i) = ...
                        Line2DChain(this.bounds(i,1),x,this.bounds(i,2),x);
                end
            end
        end
    end

end

