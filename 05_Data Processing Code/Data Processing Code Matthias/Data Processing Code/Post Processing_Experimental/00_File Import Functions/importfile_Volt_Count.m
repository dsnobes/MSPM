function [VC_time,ctr0,V_0,V_1,V_2,V_3,V_4,V_5,V_6,V_7,...
    V_16,V_17,V_18,V_19,V_20,V_21,V_22,V_23] = ...
    importfile_Volt_Count(filename, startRow, endRow)

% Import numeric data from a text file as column vectors.
% Example:
% [VC_time,ctr0,V_0,V_1,V_2,V_3,V_4,V_5,V_6,V_7,V_16,V_17,V_18,V_19,V_20,V_21,V_22,V_23] = importfile_Volt_Count('T:\Engineering\07_MATLAB Codes\06_Post Processing\00_File Import Functions\TH0_TC0_p0_L0.0_1_VoltCount.txt');

%% Initialize variables.
delimiter = '\t';
if nargin<=2
    startRow = 19;
    endRow = inf;
end

%% Format for each line of text:
formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';

%% Error if incorrect type of file opened
token = "VoltCount.txt";
if ~contains(filename,token)
    error("File name"+newline+filename+newline+"must contain '"+token+"'");
end

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
textscan(fileID, '%[^\n\r]', startRow(1)-1, 'WhiteSpace', '', 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
    frewind(fileID);
    textscan(fileID, '%[^\n\r]', startRow(block)-1, 'WhiteSpace', '', 'ReturnOnError', false);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Allocate imported array to column variable names
VC_time = dataArray{:, 1};
ctr0 = dataArray{:, 2};
V_0 = dataArray{:, 3};
V_1 = dataArray{:, 4};
V_2 = dataArray{:, 5};
V_3 = dataArray{:, 6};
V_4 = dataArray{:, 7};
V_5 = dataArray{:, 8};
V_6 = dataArray{:, 9};
V_7 = dataArray{:, 10};
V_16 = dataArray{:, 11};
V_17 = dataArray{:, 12};
V_18 = dataArray{:, 13};
V_19 = dataArray{:, 14};
V_20 = dataArray{:, 15};
V_21 = dataArray{:, 16};
V_22 = dataArray{:, 17};
V_23 = dataArray{:, 18};
