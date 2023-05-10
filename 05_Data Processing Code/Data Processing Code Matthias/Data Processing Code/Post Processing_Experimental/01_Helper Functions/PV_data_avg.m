function [avg_pressures] = PV_data_avg(angles,pressures)
% Written by Connor Speer, March 2017
% Matthias 2022: Fixed 'NaN' output in case of no matching angle

% Inputs: 
% angles --> angles corresponding to pressures in [radians].

% Round angles to the nearest whole number and convert to degrees
rounded_angles = round(angles*180/pi);

% Average all pressures which share the same angle

% Initialize vectors
avg_pressures = zeros(360,1);
% Matthias: p_log to log how pressure samples are assigned to angles for plot
% p_log = cell(360,1);

for current_angle = 0:1:359
indices = rounded_angles == current_angle;
% p_log{current_angle+1} = pressures(indices);
% In case there is no datapoint that matches the current angle, take the previous value
if isempty(indices) 
    avg_press = avg_pressures(current_angle);
else
    avg_press = mean(pressures(indices));
end
avg_pressures(current_angle+1) = avg_press;
end
% disp('done')