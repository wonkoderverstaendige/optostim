% Performs VERY basic check on consitency of given input. Where necessary,
% loads templates.

% TODO:
% - get numbers of channels when desc is a template string

function desc = check_stimdesc_struct(desc, type, numchannels)

    % For now. Not sure how to resolve this.
    if nargin < 3
        numchannels = 1;
    end
    if DEBUG disp(['== Performing sloppy integrity check for struct type ', type]); end
    if DEBUG disp(['=> Number of channels: ', num2str(numchannels)]); end
    
    % Given template name instead of struct, meaning the whole thing
    % returns the full struct of given type. Repeat for n channels
    if ischar(desc)
        if DEBUG disp(['    Loading ', type', ' template: ', desc]); end
        desc = repmat(load_template(type, desc), 1, numchannels);
        
    elseif isstruct(desc)
        
        % matrix number stimuli
        num_all_stim = count_stims(desc);
        
        % loop over all channels
        for chan = 1:numel(desc)

            % Get number of stimuli of channel from size of template field
            nstim = max(num_all_stim(:, chan));
            ntemplates = count_templates(desc(chan));

            if DEBUG disp(['  + Channel ', num2str(chan), ' has ', ...
                           num2str(nstim), ' field entries.']); end

            if nstim > 1
                tmp = load_template(['chan_', type], 'empty');
                % This channel has multiple, possibly simultaneous stimuli
                for m = 1:nstim

                % CHANNEL TEMPLATE STRING (get template with that name)
                    if ischar(desc(chan).template{m})
                        if DEBUG disp(['    - String: ', desc(chan).template{m}]); end
                        
                        new = load_template(['chan_', type], desc(chan).template);

                % CHANNEL TEMPLATE NUMERIC (load that channel)
                    elseif isnumeric(desc(chan).template{m}) && ~isempty(desc(chan).template{m})

                        % Channel may not reference itself/channel outside
                        % number of existing channels
                        if desc(chan).template{m} == chan || ceil(desc(chan).template{m}) > numel(desc)
                            error(['Channel ', num2str(chan), ' stim ', num2str(m), ' template referencing invalid channel/itself.']);
                        end

                        if DEBUG disp(['    - Using channel ', num2str(desc(chan).template{m}), ...
                            ' as template for channel ', num2str(chan)]); end

                        new = desc(ceil(desc(chan).template{m}));

                % CHANNEL HAS NO TEMPLATE
                    elseif isempty(desc(chan).template{m})
                        if DEBUG disp('    - Empty, skipped.'); end

                    else
                        error(['Faulty entry channel ', num2str(chan), ...
                            ' in stimulus ', num2str(m), ': ', char(desc(chan).template{m})]);

                    end
                    
                    % Override template values where field of original
                    % entry not empty
                    if ~isempty(desc(chan).template{m})
                        fnames = fieldnames(new);
                        n = numel(tmp) + 1;
                        for nfield = 1:numel(fnames)
                            entry = desc(chan).(fnames{nfield}){m};
                            if ~isempty(entry) && ~strcmp(fnames{nfield}, 'template')
                                tmp(n).(fnames{nfield}) = entry;
                            else
                                tmp(n).(fnames{nfield}) = new.(fnames{nfield});
                            end
                        end
                    end
                    
                end

                % Merge stimuli descriptions into one cell/channel, also
                % merge loaded stimuli with already given stimuli descript.
                % Only merge fields that are empty in initial field
                if size(tmp, 1)
                    desc(chan) = merge_param_structs(tmp, desc(chan));
                end

                
                %
                %
                %
                % THIS PART IS WIP!!!
                %
                %
                %
                %
                
                
            else
                    % channel template string
                if ischar(desc(chan).template)
                    if DEBUG disp(['    - Using string template entry: "', desc(chan).template, '"']); end
            %                     keyboard
                    tmp = load_template(['chan_', type], desc(chan).template);
                    desc(chan) = tmp(1);
                end

                    % channel has template reference
                if isnumeric(desc(chan).template) && ~isempty(desc(chan).template)
                    if DEBUG disp(['    Using channel ', num2str(desc(chan).template), ...
                        ' as template for channel', num2str(chan)]); end
                    desc(chan) = desc(round(desc(chan)));
                end

            end
            if DEBUG disp(' '); end
        end
    else
        error(['Struct for ', type, ' has wrong format!']);

    end
    
    
end
    