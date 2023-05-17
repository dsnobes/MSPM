function [x,v] = Func2Lookup(Func,xmin,xmax,vTol)
    tic;
    N = 200; n = 3;
    xs = zeros(N,1); vs = xs; edges = xs; active = xs;
    xs(1) = xmin; vs(1) = Func(xmin); edges(1) = 2; active(1) = true;
    xs(2) = xmax; vs(2) = Func(xmax); edges(2) = 0; %active(2) = false;
    while(any(active))
        for i = 1:n-1
            if active(i)
                % Test 5 points
                dx = (xs(edges(i))-xs(i))/6;
                m = (vs(edges(i))-vs(i))/(xs(edges(i))-xs(i));
                xs(n) = xs(i) + 3*dx;
                vs(n) = Func(xs(n));
                if abs(vs(n) - ((xs(n) - xs(i))*m + vs(i))) > vTol
                    edges(n) = edges(i);
                    edges(i) = n;
                    active(n) = true;
                    n = n + 1;
                    break;
                else
                    xs(n) = xs(i) + 2*dx;
                    vs(n) = Func(xs(n));
                    if abs(vs(n) - ((xs(n) - xs(i))*m + vs(i))) > vTol
                        edges(n) = edges(i);
                        edges(i) = n;
                        active(n) = true;
                        n = n + 1;
                        break;
                    else
                        xs(n) = xs(i) + 4*dx;
                        vs(n) = Func(xs(n));
                        if abs(vs(n) - ((xs(n) - xs(i))*m + vs(i))) > vTol
                            edges(n) = edges(i);
                            edges(i) = n;
                            active(n) = true;
                            n = n + 1;
                            break;
                        else
                            xs(n) = xs(i) + dx;
                            vs(n) = Func(xs(n));
                            if abs(vs(n) - ((xs(n) - xs(i))*m + vs(i))) > vTol
                                edges(n) = edges(i);
                                edges(i) = n;
                                active(n) = true;
                                n = n + 1;
                                break;
                            else
                                xs(n) = xs(i) + 5*dx;
                                vs(n) = Func(xs(n));
                                if abs(vs(n) - ((xs(n) - xs(i))*m + vs(i))) > vTol
                                    edges(n) = edges(i);
                                    edges(i) = n;
                                    active(n) = true;
                                    n = n + 1;
                                    break;
                                else
                                    active(i) = false;
                                end
                            end
                        end
                    end
                end
            end
            if n > N
                break;
            end
        end
        if n > N
            break;
        end
    end
    x = zeros(n-1,1);
    v = zeros(n-1,1);
    x(1) = xs(1);
    v(1) = vs(1);
    next = edges(1);
    for i = 2:n-1
        x(i) = xs(next);
        v(i) = vs(next);
        next = edges(next);
    end
    plot(x,v,'o',xmin:0.01:xmax,Func(xmin:0.01:xmax));
    toc;
end

