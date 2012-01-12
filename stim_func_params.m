function  desc = stim_func_params(desc) 

% TODO:
% - limit voltage values
% - Recursive loop until nothing changes anymore!!! - WHILE

% If desc is no struct but a string, load full stimulation protocol
if ischar(desc)
    if DEBUG disp(['    Loading full template: ', desc]); end
    desc = load_template('full', desc);
end

% Struct should have at least the three substructs: [io, timings, shapes]
if isstruct(desc) 
    
    % Check each substruct individually
    struct_names = fieldnames(desc);
    for substruct = 1:numel(struct_names)

        % IO PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if strcmp('io', struct_names{substruct})
            desc.(struct_names{substruct}) = check_io_struct(desc.(struct_names{substruct}));

        
        % TIMINGS AND SHAPES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        else
            desc.(struct_names{substruct}) = ...
                check_stimdesc_struct(  desc.(struct_names{substruct}), ...
                                        struct_names{substruct}, ...
                                        numel(desc.io.outputchans));
                                    
        end
    end
end