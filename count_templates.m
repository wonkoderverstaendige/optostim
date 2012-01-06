% Check if given struct has templates field, and if so, if there are any
% non-empty entries
function ntemplates = count_templates(desc)

ntemplates = 0;
    names = fieldnames(desc);
    if any(strcmp('template', names))
        disp('--> Given struct has template field!');
        
        for chan = 1:size(desc, 2)
            if size(desc(chan).template, 2) > 1 && ~ischar(desc(chan).template)
                if DEBUG disp(['    Multiple entries! Channel: ', num2str(chan)]); end
                for stim = 1:size(desc(chan).template, 2)
                    ntemplates = ntemplates + ~isempty(desc(chan).template{stim});
                end
            else 
                if DEBUG disp(['    Single entry! Channel: ', num2str(chan)]); end
                ntemplates = ntemplates + ~isempty(desc(chan).template);
            end
        end
    end
end
