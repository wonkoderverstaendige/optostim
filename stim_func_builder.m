% stim_func_builder - Optical stimulation Waveform Generator
%
% call:      X = STIM_FUNC_BUILDER( DESC, NOPLOT)
% 
% gets:
%           DESC struct with [io, timings, shapes] structs
% does:
%           return stim matrix and times elapsed to build/plot it
%
% call examples:
%
% 20-dec-11 Ronny
% wrapper for single_pulse() to allow independet
% stimuli on each channel/within trains (varying power, modes, freqs)

% revisions

% physical connections: 

% TO DO:
% - allow using calibration of channel/Volt/uWatt/PercentMax power values


function [X, build_times] = stim_func_builder( desc, noPlot )

% timing elapsed to build
build_time = tic;

% buffer size DSP/NI card? 10e5 gives 166 seconds at 6ksps! Good.
MAX_N_SAMPLES = 10e5;

% check/build input structs, load templates etc.
desc = stim_func_params(desc);

% All cells of numerical entries to arrays
% CRAP - screws up arrays for entries with multiple values (e.g. trapez)
%desc = struct_cell2array(desc);

io = desc.io;
timings = desc.timings;
shapes = desc.shapes;

% sum duration of stimulus length and offset from start, i.e. total length
stim_durations = sum_stim_durations(timings);

% longest stimulus defines matrix size
nsamples = ceil(max(stim_durations)*io.Fs);
if nsamples > MAX_N_SAMPLES
    disp(['Requested stimulus too long. Given: ', num2str(nsamples), ...
          '. Max: ', num2str(MAX_N_SAMPLES)]);
    return
end

if DEBUG
    disp('=== Recounting unresolved templates ===');

    disp(['Remaining templates in timings struct: ', ...
        num2str(count_templates(timings)), 10]);
    disp(['Remaining templates in shapes struct: ', ...
        num2str(count_templates(shapes)), 10]); 
end
    
nchans = size( io.outputchans, 2 );
if DEBUG disp(['Matrix size: ', num2str(nsamples), 'x', num2str(nchans)]); end

    % preallocate should be max(largest offset + duration)
    % preallocate an additional channel to get RX6 to activate???
X = zeros( nsamples, nchans);

    % loop over all requested channels
    if DEBUG disp('================= Building stimuli =================='); end
for i=1:nchans
    if DEBUG disp([' +  Channel: ', num2str(i)]); end
    
    % check type of mode, if char use directly, if cell/struct, use loop
    % if char, make cell, if cell, good to go
    if isa(shapes(i).modes, 'char')
        shapes(i).modes = {shapes(i).modes};
    end
    
    % Sanity checks    
    for stim = 1:size(shapes(i).modes, 2)
        
        % check if multiple stimuli modi)
        if ~isa( shapes(i).modes{stim}, 'char' )
            fprintf( 1, 'mode must be a string\n' )
            return
        end
    
        keyboard
        
        % build single stimulus
        % get pulse
        x = single_pulse(shapes(i).modes{stim}, shapes(i).pulsedur(stim), shapes(i).Vvals(stim), shapes(1).pulsefreq(stim), io.Fs);
        
        % fill up with zeros
        x = [x; zeros( io.Fs/timings(i).trainfreq(stim) - length(x), 1)];
        
        % repeat pulse with pulsefreq
        x = repmat( x, floor( timings(i).traindur(stim) * timings(i).trainfreq(stim)), 1 );
            
        % fill offset zeros, trailing zeros
        if DEBUG disp(size(x)); end
        x = [zeros(floor(timings(i).offsets(stim)/1000*io.Fs), 1); x];
        if DEBUG disp(size(x)); end
        x = [x; zeros(nsamples - length(x), 1)];
        if DEBUG disp(size(x)); end        
            
        % merge with final matrix
        % combine stimuli of channel, largest wins
        indx_vect = (x > X(:, i));
        X(indx_vect, i) = x(indx_vect);
    
    end
end

% trailing zeros
X(end+1, :) = 0;

    % time needed to build stimulation matrix
build_elapsed = toc(build_time);
disp(['Building took ', num2str(build_elapsed), 'ms.']);

    % plot stimulation matrix if not suppressed
if (~exist('noPlot', 'var') || ~noPlot)
    plot_elapsed = plot_stim(X, io.Fs)*1000;
    disp(['Plotting took ', num2str(plot_elapsed), 'ms.']);
end

    % return timings, may be required to time following stimuli
build_times = [build_elapsed plot_elapsed];

end