% Check if given struct has templates field, and if so, if there are any
% non-empty entries
function ntemplates = count_templates(desc)

ntemplates = 0;
    names = fieldnames(desc);
    if any(strcmp('template', names))
        disp('--> Given struct has template field!');
        for chan = 1:numel(desc)
            if numel(desc(chan).template) > 1 && ~ischar(desc(chan).template)
                if DEBUG disp(['    Multiple entries? Channel: ', num2str(chan)]); end

                % only add entries with non-empty template field instead of
                % number elements in template cell!
                for stim = 1:numel(desc(chan).template)
                    ntemplates = ntemplates + ~isempty(desc(chan).template{stim});
                end
            else
                empty = isempty(desc(chan).template);
                ntemplates = ntemplates + empty;
                if DEBUG && empty disp(['    Sinlge empty entry! Channel: ', num2str(chan)]); end
                if DEBUG && ~empty disp(['    Single entry! Channel: ', num2str(chan)]); end
            end
        end
    end
end
