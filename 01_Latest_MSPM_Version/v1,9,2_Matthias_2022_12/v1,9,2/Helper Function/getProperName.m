function [ answer ] = getProperName( ObjectName )
    answer{1} = '/';
    trial = 0;
    while regexp(answer{1},'[/\*:?"<>|]', 'once')
        if trial > 0
            msgbox(['You cannot have any of the following ' ...
                'characters [/\*:?"<>|] in a file name']);
        end
        trial = trial + 1;
        answer = inputdlg(['Enter a descriptive name for the ' ObjectName],...
            'Name(filename,title,etc...):',[1 50]);
        if isempty(answer{1})
            answer = '';
            return;
        end
    end
    answer = answer{1};
end

