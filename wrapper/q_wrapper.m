% update io with infos from DSPs etc
%desc.io.Fs = Fs;

% randomize parameter occurance orders
if randomized 
    Ovals = vals(randperm(numel(vals)));
else
	Ovals = vals;
end

if ~iscell(offsets)
	offsets = {offsets};
end

for v = 1:numel(Ovals)
    for s = 1:numel(offsets)
        for d = 1:numel(pulsedur)
            if randomized 
                ofs = offsets{s}(randperm(numel(offsets{s}))); 
            else
                ofs = offsets{s};
            end

            % Overwrite templatevalues with adjusted values
            desc.timings = deal_fields(desc.timings, 'offsets', ofs);
            desc.shapes = deal_fields(desc.shapes, {'Vvals', 'pulsedur'}, {Ovals(v), pulsedur(d)});

            % build stimulus
            [X, t] = stim_func_builder(desc, plotting);

            % Push to DSP/NI and trigger if that is not a test
            if trigger 
			multi_ao_load( mao, X );
			rc = multi_ao_trigger( mao ); 
            else
                disp('Dry run, no triggering!');
            end

            totaldur = ceil(size(X, 1)/Fs);
            if DEBUG disp(['Waiting ', num2str(totaldur+2), 's for end of stimulation.']); end
            pause(totaldur+2);
        end
    end
end
