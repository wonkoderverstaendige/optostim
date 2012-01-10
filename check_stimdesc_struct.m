function desc = check_stimdesc_struct(desc, type)

    if DEBUG disp(['== Performing sloppy integrity check for struct type ', type]); end

    if ischar(desc)
        if DEBUG disp(['    Loading ', type', ' template: ', desc]); end
        desc = load_template(type, desc);

    elseif isstruct(desc)
        
        % loop over stimuli
        for chan = 1:size(desc, 2)
            
            % if channel has several stimuli, check them all            
            if ischar(desc(chan).template)
                nstim = 1;
            else
                nstim = size(desc(chan).template, 2);
            end
           
            if DEBUG disp(['  + Channel ', num2str(chan), ' has ', ...
                           num2str(nstim), ' template entries.']); end
            
           % This channel has multiple simultaneous stimuli
           if (nstim > 1) && (~ischar(desc(chan).template))

                % empty struct that will be filled/merged
                tmp = load_template(['chan_', type], 'empty');
                for m = 1:nstim
                    
                    % channel template a string
                    if ischar(desc(chan).template{m})
                        if DEBUG disp(['    - String: ', desc(chan).template{m}]); end
                        tmp(end+1) = load_template(['chan_', type], desc(chan).template);

                    % channel template a reference to other channel
                    elseif isnumeric(desc(chan).template{m}) && ~isempty(desc(chan).template{m})
                        
                        % Channel may not reference itself
                        if desc(chan).template{m} == chan
                            error('Channel template referencing itself. Stopped.');
                        end
                        
                        if DEBUG disp(['    - Using channel ', num2str(desc(chan).template{m}), ...
                            ' as template for channel ', num2str(chan)]); end
                        
                        tmp(end+1) = desc(round(desc(chan).template{m}));
                    
                    elseif isempty(desc(chan).template{m})
                        disp('    - Empty placeholder entry');
                    
                    else
                        error(['Faulty entry: ', char(desc(chan).template{m})]);

                    end
                end
                
                % Merge stimuli descriptions into one cell/channel, also
                % merge loaded stimuli with stimuli given without template
                
                if size(tmp, 1)
                    desc(chan) = merge_param_structs(tmp, desc(chan));
                end
                
            else
                    % channel template string
                if ischar(desc(chan).template)
                    if DEBUG disp(['    - Using string template entry: "', desc(chan).template, '"']); end
%                     keyboard
                    tmp = load_template(['chan_', type], desc(chan).template);
                    desc(chan) = tmp(1);
                end

                    % channel has template reference
                if isnumerictype(desc(chan).template)
                    if DEBUG disp(['    Using channel ', num2str(desc(chan).template), ...
                        ' as template for channel', num2str(chan)]); end
                    desc(chan) = desc(round(desc(chan)));
                end
                
            end
        disp(' ');      
        end
    else
        error(['Struct for ', type, ' has wrong format!']);

    end
    
    
end
    