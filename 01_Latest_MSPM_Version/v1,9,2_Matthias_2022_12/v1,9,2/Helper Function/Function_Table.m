function [Indexes, Lookups] = Function_Table(...
    Tol, min_x, max_x, Functions, N)
    LEN = length(Functions);
    Lookups = zeros(LEN,N,2);
    Indexes = zeros(LEN,1);
    isUnique = false(size(Indexes));
    n = 1;
    for i = 1:LEN
        if ~isempty(Functions{i}) && Indexes(i) == 0
            isUnique(i) = true;
            Indexes(i) = n;
            for j = i+1:LEN
                if ~isempty(Functions{j}) && Indexes(j) == 0
                    if Indexes(j) == 0 && Functions{i}(0.5) == Functions{j}(0.5) && Functions{i}(1) == Functions{j}(1)
                        Indexes(j) = n;
                    end
                end
            end
            n = n + 1;
        end
    end
    
    for i = 1:LEN
        f = Functions{i};
        if ~isempty(f)
            if isUnique(i)
                n = Indexes(i);
                entry = 2;
                delta = 1;
                Lookups(n,1,1) = min_x;
                Lookups(n,1,2) = f(min_x);
                x2 = 1e-8;
                y2 = Lookups(n,1,2);
                while x2 < max_x && entry <= N
                    % Use the Tolerance to construct a lookup table from the function
                    x1 = x2;
                    y1 = y2;
                    max_delta = inf;
                    min_delta = 1e-8;
                    delta = delta * 1.1;
                    locating = true;
                    Tries = 1;
                    while locating && Tries < 10
                        x2 = Lookups(n,entry-1,1) + delta;
                        y2 = f(x2);
                        if delta == min_delta || delta == max_delta
                            locating = false;
                        else
                            ymid = f((x1 + x2)/2);
                            err = ((y1 + y2) - 2*ymid)/ymid;
                            if abs(err) > Tol
                                factor = 0.99*sqrt(Tol/abs(err));
                                max_delta = delta*(1 + factor)/2;
                                delta = max(min_delta,delta*factor);
                            elseif abs(err) < Tol*0.9
                                factor = sqrt(Tol/abs(err));
                                min_delta = delta*(1 + factor)/2;
                                delta = min(max_delta,delta*factor);
                            else
                                locating = false;
                            end
                            Tries = Tries + 1;
                        end
                    end
                    if Tries == 10
                        x2 = (min_delta + max_delta)/2;
                        y2 = f(x2);
                    end
                    Lookups(n,entry,1) = x2;
                    Lookups(n,entry,2) = y2;
                    entry = entry + 1;
                end
            end
        end
    end
    if n < LEN
        Lookups = Lookups(1:n,:,:);
    end
end

