function [date,time_of_day,hot_bath_setpoint,cold_bath_setpoint,...
    hot_liquid_flowrate,cold_liquid_flowrate,pmean_setpoint,...
    torque_setpoint,teknic_setpoint,RTD_time,RTD_0,RTD_1,RTD_2,RTD_3,...
    RTD_4,RTD_5,RTD_6,RTD_7] = importfile_RTD(filename, startRow, endRow)

% Import numeric data from a text file as column vectors. This RTD specific
% file import function also collects information from the file header.
%
% Example:
% [RTD_time,RTD_0,RTD_1,RTD_2,RTD_3,RTD_4,RTD_5,RTD_6,RTD_7] = importfile_RTD('T:\Engineering\07_MATLAB Codes\06_Post Processing\00_File Import Functions\TH0_TC0_p0_L0.0_1_RTD.txt',19, 37);

%% Initialize variables.
delimiter = '\t';
if nargin<=2
    startRow = 19;
    endRow = inf;
end

%% Format for each line of text:
formatSpec = '%f%f%f%f%f%f%f%f%f%[^\n\r]';

%% Error if incorrect type of file opened
token = "RTD.txt";
if ~contains(filename,token)
    error("File name"+newline+filename+newline+"must contain '"+token+"'");
end

%% Open the text file.
fileID = fopen(filename,'r');

%% Read setpoints from file header
date = fgetl(fileID); % date string
time_of_day = fgetl(fileID); % time of day string
fgetl(fileID); % skip a line
hot_bath_setpoint = str2double(fgetl(fileID)); % Hot liquid bath setpoint in (degrees Celsius)
fgetl(fileID); % skip a line
cold_bath_setpoint = str2double(fgetl(fileID)); % Cold liquid bath setpoint in (degrees Celsius)
fgetl(fileID); % skip a line
hot_liquid_flowrate = str2double(fgetl(fileID)); % Hot liquid flow rate in (m^3/s)
fgetl(fileID); % skip a line
cold_liquid_flowrate = str2double(fgetl(fileID)); % Cold liquid flow rate in (m^3/s)
fgetl(fileID); % skip a line
pmean_setpoint = str2double(fgetl(fileID)); % Mean pressure setpoint in (Pa)
fgetl(fileID); % skip a line
torque_setpoint = str2double(fgetl(fileID)); % Load torque setpoint in (Nm)
fgetl(fileID); % skip a line
teknic_setpoint = str2double(fgetl(fileID)); % Teknic motor setpoint in (RPM)
% Matthias: Added following line to rewind to first row of file, so that
% all data rwos will be scanned by 'textscan' below.
frewind(fileID);

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
textscan(fileID, '%[^\n\r]', startRow(1)-1, 'WhiteSpace', '', 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'TextType', 'string', 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
    frewind(fileID);
    textscan(fileID, '%[^\n\r]', startRow(block)-1, 'WhiteSpace', '', 'ReturnOnError', false);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'TextType', 'string', 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Allocate imported array to column variable names
RTD_time = dataArray{:, 1};
RTD_0 = dataArray{:, 2};
RTD_1 = dataArray{:, 3};
RTD_2 = dataArray{:, 4};
RTD_3 = dataArray{:, 5};
RTD_4 = dataArray{:, 6};
RTD_5 = dataArray{:, 7};
RTD_6 = dataArray{:, 8};
RTD_7 = dataArray{:, 9};
