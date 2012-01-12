% Returns the number of stimuli of each field in a matrix with channel as
% column, rows as fields
% number elements of non-char fields.
% Returns vector of number of stimuli for each channel [c1 c2 c3...]
function num = count_stims(desc)

if DEBUG disp('   > Checking for equal number stimuli entries per field/channel ...'); end

fnames = fieldnames(desc);
if ~ischar(fnames)
    nfields = numel(fnames);
else
    nfields = 1;
end

nchans = numel(desc);
num = zeros(nfields, nchans);

% Build matrix 
for channel = 1:nchans
    for field = 1:nfields
        if ~ischar(desc(channel).(fnames{field})) && ~isnumeric(desc(channel).(fnames{field}))
%             if numel(desc(channel).(fnames{field})) > num(field, channel)
                num(field, channel) = numel(desc(channel).(fnames{field}));
%             end
            if isempty(desc(channel).(fnames{field}))
                num(field, channel) = 1;
            end
        else
            num(field, channel) = 1;
        end
        
    end
end

% Check for channels with unequal amount of entries in their fields
equaln = min(num) - max(num);
if any(equaln)
    disp(equaln);
    error('Some fields have unequal amount of stimuli');
else
    if DEBUG 
        disp('   > OK')
        disp(num);
    end
end

end