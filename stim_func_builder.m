% stim_func_builder - Optical stimulation Waveform Generator
%
% call:      X = STIM_FUNC_BUILDER( io, timings, shapes, NOPLOT)
% 
% gets:
%
% does:
%
% call examples:
%
% 20-dec-11 Ronny
% wrapper for single_pulse() to allow independet
% stimuli on each channel/within trains (varying power, modes, freqs)

% revisions

% physical connections: 

% TO DO:
% - limit voltage values
% - allow using calibration of channel/Volt/uWatt/PercentMax power values
% - use of templates to load whole stimulation protocol
% - allow overriding template values

function X = stim_func_builder( io, timings, shapes, noPlot )

% arguments

    % Debug flag, various outputs/checkpoints
    DEBUG = true;
    
    % buffer size DSP/NI card? 10e5 gives nearly 3 minutes at 6ksps! Good.
    MAX_N_SAMPLES = 10e5;

    % limit values - CRAPPY WITH STRUCT!!!
%     MINVAL = -10;
%     MAXVAL = 10;
% 
%     if max([shapes) > MAXVAL
%         disp(['Some values limited to ', num2str(MAXVAL), 'V']);
%         val(val > MAXVAL) = MAXVAL;
%     end
%     if min(val) < MINVAL
%         disp(['Some values limited to ', num2str(MINVAL), 'V']);
%         val(val < MINVAL) = MINVAL;
%     end


% check input and get some paramters from ao
    % check if parameters specified or template requested
    
    if isstruct(io)
        if isempty( io.Fs ), io.Fs = 25000; end
        if isempty( io.inputchans ), io.inputchans = [1 2 3 4]; end % channel number
        if isempty( io.outputchans ), io.outputchans = [9 10 11 12]; end % channel number
        %if isempty( io.NCHANS ), io.NCHANS = 8; end
        %if isempty( io.duration ), io.duration = 1; end % seconds
        %if isempty( io.val ), io.val = 5; end % volts
        %if isempty( io.freq ), io.freq = 10; end % hz
        %if isempty( io.mode ), io.mode = 'rect'; end % string
    else
        if DEBUG disp('io no struct'); end
        return
    end
    
    if isstruct(timings)
        for i = 1:size(timings)
            if isstruct(timings(i))
                % assume ok
                if DEBUG disp('Assuming timings struct has proper shape'); end
            else
                if ischar(timings(i))
                    % load parameters for template
                    if DEBUG disp('Should load template here'); end
                else
                    if DEBUG disp('timings neither struct nor template name'); end
                end
            end
        end
    else
        if DEBUG disp('timings no struct'); end
        if ischar(timings)
            timings = load_template('timings', timings);
        end
        % Check if template exists, load template
        return
    end
    
    if isstruct(shapes)
        for i = 1:size(shapes)
            if isstruct(shapes(i))
                % assume ok
                if DEBUG disp('Assuming shapes struct has proper shape'); end
            else
                if ischar(shapes(i))
                    % load parameters for template
                    if DEBUG disp('Should load template here'); end
                else
                    if DEBUG disp('timings neither struct nor template name'); end
                end
            end
        end
    else
        if DEBUG disp('shapes no struct'); end
        % Check if template exists, load template
        return
    end
    
% boilerplates
stim_durations = [timings.offsets]/1000 + [timings.traindur];

% longest stimulus defines matrix size
nsamples = ceil( max( stim_durations ) * io.Fs );
if nsamples > MAX_N_SAMPLES
    disp('Requested stimulus too long:');
    disp(nsamples);
    return
end

nchans = size( io.outputchans, 2 );
if DEBUG disp([nsamples nchans]); end

% preallocate should be max(largest offset + duration)
% preallocate an additional channel to get RX6 to activate???
X = zeros( nsamples, nchans);

% loop over all requested channels
for i=1:nchans

    if DEBUG disp(['Channel: ', num2str(i)]); end
    
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
    % attach to matrix

end


% trailing zeros
X(end+1, :) = 0;


if (~exist('noPlot', 'var') || ~noPlot)
    elapsed = plot_stim(X, io.Fs)*1000;
    disp(['Plotting took ', num2str(elapsed), 'ms.']);
end

end