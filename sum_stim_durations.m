function stim_durations = sum_stim_durations(timings)

stim_durations = [];

for channel = 1:numel(timings)
    if ~(numel(timings(channel).traindur) == numel(timings(channel).offsets))
        error('Traindur and offsets must have same number elements!');
    end
    
    if numel(timings(channel).traindur) > 1
        for stim = 1:numel(timings(channel).traindur)
%             if DEBUG disp([' Working on channel ', num2str(channel), ' stim ', num2str(stim)]); end
            stim_durations = [stim_durations ([timings(channel).offsets{:}]/1000 + [timings(channel).traindur{:}])];
        end 
    else
%         if DEBUG disp([' Working on channel ', num2str(channel)]); end
        stim_durations = [stim_durations ([timings(channel).offsets]/1000 + [timings(channel).traindur])];
    end
end    


end