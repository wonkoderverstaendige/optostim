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

% ALL TIMINGS/SHAPES ENTRIES TO CELLS
io = desc.io;
timings = stim_to_cells(desc.timings);
shapes = stim_to_cells(desc.shapes);

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
    disp([10, '=== Recounting unresolved templates ===']);

    disp(['Remaining templates in timings struct: ', ...
        num2str(count_templates(timings)), 10]);
    disp(['Remaining templates in shapes struct: ', ...
        num2str(count_templates(shapes)), 10]); 
end
    
nchans = size( io.outputchans, 2 );
if DEBUG disp(['Zero-matrix size: ', num2str(nsamples), 'x', num2str(nchans), 10]); end

% preallocate should be max(largest offset + duration)
% preallocate an additional channel to get RX6 to activate???
X = zeros( nsamples, nchans);

    % loop over all requested channels
    if DEBUG disp('================= Building stimuli =================='); end

for i=1:nchans
    if DEBUG disp([' +  Channel: ', num2str(i)]); end
    
    % Sanity checks    
    for stim = 1:size(shapes(i).modes, 2)
        
        % check if multiple stimuli modi)
        if ~isa( shapes(i).modes{stim}, 'char' )
            fprintf( 1, 'mode must be a string\n' )
            return
        end
        
    % build single stimulus
        % get pulse
        x = single_pulse(shapes(i).modes{stim}, shapes(i).pulsedur{stim}, shapes(i).Vvals{stim}, shapes(1).pulsefreq{stim}, io.Fs);
        
        % fill up with zeros
        x = [x; zeros( ceil(io.Fs/timings(i).trainfreq{stim}) - length(x), 1)];
        
        % repeat pulse with pulsefreq
        x = repmat( x, floor( timings(i).traindur{stim} * timings(i).trainfreq{stim}), 1 );
            
        % fill offset zeros, trailing zeros
        ozs = zeros(floor(timings(i).offsets{stim}/1000*io.Fs), 1); 
        tzs = zeros(nsamples - (length(x)+length(ozs)), 1);
        x = [ozs; x; tzs];
   
            
        % merge with final matrix
        % combine stimuli of channel, largest wins
        indx_vect = (x > X(:, i));
        X(indx_vect, i) = x(indx_vect);
    
    end
end

% trailing zeros
X(end+1, :) = 0;

% pad with zeros for required empty channels (e.g. channel 5 to get RX6 to
% start
X=zero_pad_mat(X, io);

% time needed to build stimulation matrix
build_elapsed = toc(build_time);
disp(['Building took ', num2str(build_elapsed), 'ms.']);

% plot stimulation matrix if not suppressed
if (~exist('noPlot', 'var') || ~noPlot)
    plot_elapsed = plot_stim(X, io.Fs)*1000; %resample(X, 1, 1)
    disp(['Plotting took ', num2str(plot_elapsed), 'ms.']);
end

    % return timings, may be required to time following stimuli
build_times = [build_elapsed plot_elapsed];

end