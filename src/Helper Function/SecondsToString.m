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