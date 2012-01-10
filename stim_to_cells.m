% Converts all stimuli of a channel into cells, irrespect the number of
% elements required for the stimulus. Allows omitting the cell notation
% when defining the stimuli.

function desc = stim_to_cells(desc)

fnames = fieldnames(desc);

% Loop over all fields of struct
for currfield = 1:numel(fnames)
    
    % Loop over channels
    for channel = 1:numel(desc)

        if ~iscell(desc(channel).(fnames{currfield}))
            desc(channel).(fnames{currfield}) = {desc(channel).(fnames{currfield})};
        end

    end
    
end
end
