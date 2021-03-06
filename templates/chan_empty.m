function desc = chan_empty()
io = struct(   'Fs', {}, ...
                'inputchans', {}, ...
                'outputchans', {}, ...
                'animal', {}, ...
                'template', {});

timings = struct(   'trainfreq', {}, ...
                    'traindur', {}, ...
                    'offsets', {}, ...
                    'template', {});
                    
shapes = struct(    'modes', {}, ...
                    'Vvals', {}, ...
                    'pulsefreq', {}, ...
                    'pulsedur', {}, ...
                    'template', {});

desc = struct('io', io, 'timings', timings, 'shapes', shapes);