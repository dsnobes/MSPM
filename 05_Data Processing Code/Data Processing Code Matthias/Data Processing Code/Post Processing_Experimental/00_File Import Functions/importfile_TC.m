function [TC_time,TC_0,TC_1,TC_2,TC_3,TC_4,TC_5,TC_6,TC_7,TC_8,TC_9,...
    TC_10,TC_11,TC_12,TC_13,TC_14,TC_15] = importfile_TC(filename, startRow, endRow)

% Import numeric data from a text file as column vectors.
% Example:
% [TC_time,TC_0,TC_1,TC_2,TC_3,TC_4,TC_5,TC_6,TC_7,TC_8,TC_9,TC_10,TC_11,TC_12,TC_13,TC_14,TC_15] = importfile_TC('T:\Engineering\07_MATLAB Codes\06_Post Processing\00_File Import Functions\TH0_TC0_p0_L0.0_1_TC.txt',19, 2017);

%% Initialize variables.
delimiter = '\t';
if nargin<=2
    startRow = 19;
    endRow = inf;
end

%% Format for each line of text:
formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';

%% Error if incorrect type of file opened
token = "TC.txt";
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
TC_time = dataArray{:, 1};
TC_0 = dataArray{:, 2};
TC_1 = dataArray{:, 3};
TC_2 = dataArray{:, 4};
TC_3 = dataArray{:, 5};
TC_4 = dataArray{:, 6};
TC_5 = dataArray{:, 7};
TC_6 = dataArray{:, 8};
TC_7 = dataArray{:, 9};
TC_8 = dataArray{:, 10};
TC_9 = dataArray{:, 11};
TC_10 = dataArray{:, 12};
TC_11 = dataArray{:, 13};
TC_12 = dataArray{:, 14};
TC_13 = dataArray{:, 15};
TC_14 = dataArray{:, 16};
TC_15 = dataArray{:, 17};
