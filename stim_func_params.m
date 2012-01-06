function  desc = stim_func_params(desc) %[io, timings, shapes]

% Loading templates:
%   For whole set (io, timings, shapes of all channels)
%       If io/timings/shapes is string
%   For single channel
%       If timings/shapes is struct, but a channel has template string
%   For single stimulus (tricky and clunky)
%       If timings/shapes is struct, template is struct, mode has template
%       string
%
% Use a channel as a template
%   If $template numerical, use same as channel $template


% TODO:
% - limit voltage values
% - allow overriding template values
% - Recursive loop until nothing changes anymore!!! - WHILE

% If desc is no struct but a string, load full stimulation protocol
if ischar(desc)
    if DEBUG disp(['    Loading full template: ', desc]); end
    desc = load_template('full', desc);
end

% If desc is a struct, it should have at least the three substructs:
% [io, timings, shapes]
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
                check_stimdesc_struct(desc.(struct_names{substruct}), ...
                struct_names{substruct});
        end
        
    end
    
    % TIMINGS PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     if ischar(timings)
%         if DEBUG disp(['Loading timings template: ', timings]); end
%         timings = load_template('timings', timings);
% 
%     elseif isstruct(timings)
%         % loop over stimuli
%         for chan = 1:size(timings, 2)
%             
%             % if channel has several stimuli, check them all            
%             if ischar(timings(chan).template)
%                 nstim = 1;
%             else
%                 nstim = size(timings(chan).template, 2);
%             end
%            
%             if DEBUG disp(['+ Channel ', num2str(chan), ...
%                            ' has ', ...
%                            num2str(nstim), ' template entries.']); end
%             if (nstim > 1) && (~ischar(timings(chan).template))
% 
%                 % empty struct that will be filled/merged
%                 tmp_timings = load_template('chan_timings', 'empty');
%                 for m = 1:nstim
%                     
%                     % channel template a string
%                     if ischar(timings(chan).template{m})
%                         if DEBUG disp(['  - String: ', timings(chan).template{m}]); end
%                         tmp_timings(end+1) = load_template('chan_timings', timings(chan).template);
% 
%                     % channel template a reference to other channel
%                     elseif isnumeric(timings(chan).template{m}) && ~isempty(timings(chan).template{m})
%                         
%                         % Channel may not reference itself
%                         if timings(chan).template{m} == chan
%                             error('Channel template referencing itself. Stopped.');
%                         end
%                         
%                         if DEBUG disp(['  - Using channel ', num2str(timings(chan).template{m}), ...
%                             ' as template for channel ', num2str(chan)]); end
%                         
%                         tmp_timings(end+1) = timings(round(timings(chan).template{m}));
%                     
%                     elseif isempty(timings(chan).template{m})
%                         disp('  - Empty placeholder entry');
%                     
%                     else
%                         disp(['Faulty entry: ', char(timings(chan).template{m})]);
%                         return
%                     end
%                 end
%                 
%                 % Merge stimuli descriptions into one cell/channel, also
%                 % merge loaded stimuli with stimuli given without template
%                 timings(chan) = merge_param_structs(tmp_timings, timings(chan));
%                 
%             else
%                     % channel template string
%                 if ischar(timings(chan).template)
%                     if DEBUG disp(['  - Using string template entry: "', timings(chan).template, '"']); end
% %                     keyboard
%                     tmp_timings = load_template('chan_timings', timings(chan).template);
%                     timings(chan) = tmp_timings(1);
%                 end
% 
%                     % channel has template reference
%                 if isnumerictype(timings(chan).template)
%                     if DEBUG disp(['Using channel ', num2str(timings(chan).template), ...
%                         ' as template for channel', num2str(chan)]); end
%                     timings(chan) = timings(round(timings(chan)));
%                 end
%                 
%             end
%         disp(' ');      
%         end
%     else
%         if DEBUG disp('Timings wrong format!'); end
%         return
% 
%     end

    % SHAPES PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    % limit values - CRAPPY WITH STRUCT!!!
%     MINVAL = -10;
%     MAXVAL = 10;
% 
%     if max([shapes) > MAXVAL
%         disp(['Some values limited to ', num2str(MAXVAL), 'V']);
%         val(val > MAXVAL) = MAXVAL;
%     end
%     if min(val) < MINVAL
%         disp(['Some values limited to ', num2str(MINVAL), 'V']);
%         val(val < MINVAL) = MINVAL;
%     end


end