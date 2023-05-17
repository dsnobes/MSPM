function [ d ] = Dist2Rect( Px,Py,Cx,Cy,width,height )
    % 9 cases
    w = width/2;
    h = height/2;
    if Px < Cx+w
        if Px > Cx-w
            if Py < Cy+h
                if Py > Cy-h % Bounded, Bounded (Inside)
                    d = 0;
                else % Under, Bounded
                    d = ((Cy-h)-Py)^2;
                end
            else % Above, Bounded
                d = (Py-(Cy+h))^2;
            end
        else
            if Py < Cy+h % Under Top Surface, Left
                if Py > Cy-h % Bounded, Left
                    d = (Cx-w-Px)^2;
                else % Under, Left
                    d = ((Cx-w)-Px)^2+((Cy-h)-Py)^2;
                end
            else % Above, Left
                d = ((Cx-w)-Px)^2+(Py-(Cy+h))^2;
            end
        end
    else
        if Py < Cy+h
            if Py > Cy-h % Bounded, Right
                d = (Px-(Cx+w))^2;
            else % Under, Right
                d = ((Cy-h)-Py)^2+(Px-(Cx+w))^2;
            end
        else % Above, Right
            d = (Py-(Cy+h))^2+(Px-(Cx+w))^2;
        end
    end
end

