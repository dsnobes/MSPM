function timestr = SecondsToString(sec)
    % Convert a time measurement from seconds into a human readable string.
    % Convert seconds to other units
    w = floor(sec/604800); % Weeks
    sec = sec - w*604800;
    d = floor(sec/86400); % Days
    sec = sec - d*86400;
    h = floor(sec/3600); % Hours
    sec = sec - h*3600;
    m = floor(sec/60); % Minutes
    sec = sec - m*60;
    s = floor(sec); % Seconds

    % Create time string
    if w > 0
        timestr = sprintf('%d week, %d day, %d hr, %d min, %d sec', w, d, h, m, s);
    elseif d > 0
        timestr = sprintf('%d day, %d hr, %d min, %d sec', d, h, m, s);
    elseif h > 0
        timestr = sprintf('%d hr, %d min, %d sec', h, m, s);
    elseif m > 0
        timestr = sprintf('%d min, %d sec', m, s);
    else
        timestr = sprintf('%d sec', s);
    end
end