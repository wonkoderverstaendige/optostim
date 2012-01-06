function desc = struct_cell2array(desc)
    excepts = {'modes', 'template'};

    struct_names = fieldnames(desc);
 
    % Loop over io, timings, shapes, etc.
    for substruct = 1:numel(struct_names)
        curr_struct = desc.(struct_names{substruct});
        field_names = fieldnames(curr_struct);

        % Loop over channels
        for channel = 1:size(substruct, 2)
            for fields = 1:numel(field_names)
                if ~any(strcmp(field_names{fields}, excepts))
                    if iscell(curr_struct(channel).(field_names{fields}))
                        if DEBUG disp(['Cell2array in field ', field_names{fields}, ' channel ', num2str(channel)]); end
                        cells = curr_struct(channel).(field_names{fields});
                        curr_struct(channel).(field_names{fields}) = [cells{:}];
                    end
                end
            end
        end
        desc.(struct_names{substruct}) = curr_struct;
    end
end