% For the given [desc struct], replaces the values of the [fields] with
% new [values] using deal()

function desc = deal_fields(desc, fields, values)

if ischar(fields)
    nfields = 1;
    fields = {fields};
else
    nfields = numel(fields);
end

if ~iscell(values)
    values = {values};
end

% not sufficient! Dealing values to structs is tricky business
for v = 1:nfields
    nchans = numel(desc);
    m = ceil(nchans/numel(values{v}));
    values{v} = repmat(values{v}, 1, m);

%     keyboard
    for channel = 1:nchans
            desc(channel).(fields{v}) = values{v}(channel);
    end
end