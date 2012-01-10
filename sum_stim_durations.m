% Sums up stimuli trainduration and offset duration for each stimulus.
% Returns vector with sum of traindur and offset in seconds for each
% stimulus

function stim_durations = sum_stim_durations(timings)

stim_durations = [];

for channel = 1:numel(timings)
    if ~(numel(timings(channel).traindur) == numel(timings(channel).offsets))
        error('Traindur and offsets must have same number elements!');
    end
    
    for stim = 1:numel(timings(channel).traindur)
        if DEBUG 
            disp([' Summing durs in channel ', num2str(channel), ' stim ', num2str(stim)]); 
            %disp(['  - class: ', class(timings(channel).offsets{stim}), ' is: ', num2str(timings(channel).offsets{stim})]);
        end
        
        td = timings(channel).traindur{stim};
        os = timings(channel).offsets{stim};
       
        if iscell(os)
            os = cell2mat(os);
            td = cell2mat(td);
        end
        
        stim_durations = [stim_durations (os/1000 + td)];
    end 

end    


end