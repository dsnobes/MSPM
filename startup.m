function startup()
    %{
    adds the necessary subdirectories of MSPM to MATLAB's PATH
    so that functions and code files can be called
    %}

    % Load in the paramaters file
if isfile('Config Files/parameters.mat')
    load('Config Files/parameters.mat', 'parameters')
    
    
    % Check if the save locations are valid and add location to path
    if isfolder(parameters.savelocation)
        addpath(genpath(parameters.savelocation));
    end
    
    if isfolder(parameters.runlocation)
        addpath(genpath(parameters.runlocation));
    end
    
end

% Add the files to the path
addpath(...
    genpath('Source Code'),...
    genpath('Test_Running'),...
    genpath('Config Files'),...
    genpath('Saved Files')...
    );
end