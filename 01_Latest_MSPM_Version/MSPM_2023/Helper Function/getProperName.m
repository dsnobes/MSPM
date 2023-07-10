% Displays a popup box to get a discriptive name for an object
function [ answer ] = getProperName( ObjectName, def)
    % Set answer to an invalid character to start the while loop
    answer{1} = '/';
    
    % Used to not show the illegal character dialog on the first loop
    trial = 0;
    % Check if there are illegal characters
    while regexp(answer{1},'[/\*:?"<>|]', 'once')
        % If there are show an error message and have the user try again
        if trial > 0
            msgbox(['You cannot have any of the following ' ...
                'characters [/\*:?"<>|] in a file name']);
        end
        trial = trial + 1;
        % Ask the user to enter a descriptive name
        if nargin == 2
            answer = inputdlg(['Enter a descriptive name for the ' ObjectName],...
                'Name(filename,title,etc...):',[1 200], def);
        else
            answer = inputdlg(['Enter a descriptive name for the ' ObjectName],...
                'Name(filename,title,etc...):',[1 200]);
        end
        
        % If the user does not enter a value, return an empty char array
        if isempty(answer{1})
            answer = '';
            return;
        end
    end
    % Remove the input text from the array and return as char array
    answer = answer{1};
end

