% single_pulse   Pulseform generator
%
% call:     X = SINGLE_STIMULUS( MODE, DUR, VAL, FREQ, FS )
% 
% gets:     
%           MODE        Can be any of 'rect'; 'sine'; 'train'; 'rampUp';
%                       'rampDown'; 'triang'; 'trapez'; 'psine'; 'zap'
%           DUR         ms (may be overloaded - dur, peak_dur,...)
%           VAL         V
%           FREQ        Hz (may be overloaded - repetitions, freqs, ...)
%           FS          Hz {6000}
%
% does:             Generates single pulse without padding;
%                   'rect': rectangular pulse length [dur]
%                   'train': train of square pulses [traindur pulsedur]
%                   'sine': sine wave length [dur] at frequency [freq]
%                   'rampUp': linear ramp 0-[val] length [dur]
%                   'rampDown': linear ramp [val]-0 length [dur]
%                   'triang': triangular pulse with base length [dur]
%                   'psine': rect pulse with flanking half sine slopes,
%                   slopes add up to full sine wave dur [peak_dur slope_dur]
%                   'zap': linear chirp signal of [dur] over [startfreq endfreq]
%
% call examples:
%
% x = single_stimulus('train', [500 10], [4], [20], 6000);    % 0.5sec, 4V train of 10ms pulses at 20 Hz (i.e. 10 pulses overall)
% x = single_stimulus('rect', [500], [4], [20], 6000);    % 0.5sec, 4V rectangular pulse

% Based on func_ao by ES
% written by Ronny, 20-Dec-2011
% Revisions:
%

function x = single_pulse(mode, dur, val, freq, Fs)

% default arguments
nargs = nargin;
if nargs < 3 || isempty (val), val = 4; end
if nargs < 4 || isempty (freq), freq = []; end
if nargs < 5 || isempty (Fs), Fs = 6000; end

% convert ms to sec
dur = dur/1000;

% allocate space - NOT USED ATM!!!
% switch mode
%     case 'chirp'
%         pulse_dur = dur(1) * ( size( freq, 1 ) - 1 ) + sum( 1 ./ freq(:) * dur(2) );
%     otherwise
%         pulse_dur = sum(dur);
% end
% x = zeros( ceil( Fs * pulse_dur ), 1 );


% build pulses
switch mode
    case 'rect' % single pulse %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % dur = [dur]
        % freq = [];
        x = val * ones( Fs * dur, 1 );

    case 'sine' % sine waves %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % dur = [dur];
        % freq = freq;
        if freq > Fs / 2
            freq = Fs / 2;
            disp('Frequency limited to Nyquist frequency');
        end
        
        t = 1 / Fs : 1 / Fs : dur;
        x = sin( 2 * pi * freq * t( : ) - pi / 2 );
        x = val * ( x + 1 ) / 2;
    
    case 'train' % pulse train %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % dur = [trainlength pulsedur];
        % freq = [ freq ];
        if freq( 1 ) > Fs / 2
            freq( 1 ) = Fs / 2;
            disp('Frequency clipped to Nyquist frequency');
        end
        
        traindur = dur(1); pulsedur = dur(2);
        
        % check for overlong pulses
        lowdur = 1/freq - pulsedur;
        if lowdur <= 0
            disp('pulses overlap! Rectangular pulse');
            pulsedur = 1/freq;
            lowdur = 0;
        end 
        
        x = [val * ones( round( pulsedur * Fs ), 1 ); 
             zeros( round(lowdur*Fs), 1 ) ];
        x = repmat( x, floor( (traindur * freq) ), 1 );
    
    case 'rampUp' % ramp %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % dur = [ramp length(ms)]
        nramp = ceil ( dur * Fs) ;
        ramp = 1/nramp : 1/nramp : 1;
        x = val * ramp';

    case 'rampDown' % ramp %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % dur = [ramp length(ms)]
        nramp = ceil ( dur * Fs);
        ramp = 1-1/nramp : -1/nramp : 1/nramp;
        x = val * ramp';
        
        
    case 'triang' % triangular pulse %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % dur = [base width(ms)];
        x = val * [single_pulse('rampUp', dur*1000/2, 1, [], Fs); 
                   single_pulse('rampDown', dur*1000/2, 1, [], Fs)];
         
         
    case 'trapez' % trapezoid pulse %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % dur = [up plateau down(ms)]
        x = val * [single_pulse('rampUp', dur(1)*1000, 1, [], Fs); 
                   single_pulse('rect', dur(2)*1000, 1, [], Fs);
                   single_pulse('rampDown', dur(3)*1000, 1, [], Fs)];        
        
    case 'hsineUp' % half sine slope UP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % dur = [ halfsinewidth ];
        mfreq = 1/ dur; % 'morphological' frequency
        if mfreq > Fs / 2
            mfreq = Fs / 2;
            dur = 1/mfreq;
            disp('Up-half-sine capped to Nyquist frequency. Is now a ramp!');
        end
        
        t = 1 / Fs : 1 / Fs : dur;
        x = val(1) * (1 + sin( pi * mfreq * t(:) - pi / 2)) / 2;    
        
    case 'hsineDown' % half sine slope UP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % dur = [ halfsinewidth(ms) ];
        mfreq = 1/ dur; % 'morphological' frequency
        if mfreq > Fs / 2
            mfreq = Fs / 2;
            dur = 1/mfreq;
            disp('Down-alf-sine capped to Nyquist frequency. Is now a ramp!');
        end
        
        t = dur : -1 / Fs : 1 / Fs;
        x = val(1) * (1 + sin( pi * mfreq * t(:) - pi / 2)) / 2;
        
    case 'psine' % rect pulse with sine wave slopes %%%%%%%%%%%%%%%%%%%%%%%
        % duration = [ peak_dur sinewidth]; 
        peak_dur = dur( 1 );
        sine_dur = dur( 2 );
        
        x = val * [single_pulse('hsineUp', sine_dur*1000/2, 1, [], Fs);
                   ones( peak_dur * Fs, 1 );
                   single_pulse('hsineDown', sine_dur*1000/2, 1, [], Fs)];
                
    case 'zap' % sine wave of linear changing freq %%%%%%%%%%%%%%%%%%%%%%%%
        % duration = [duration]
        % freq = [start_freq, end_freq]
        t = (1/Fs : 1/Fs : dur)';
        x = sin( 2 * pi * ( ( freq(2) - freq(1) ) / ( 2 * t( end ) ) .* t .^ 2 + freq(1) .* t + 270 / 360  ) );
        x = val * ( x + 1 ) / 2;

    case 'chirp' % WORK IN PROGRESS IF AT ALL  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
         error('Chirp not supported yet (can be done with multiple offset sine waves?)');

    otherwise
        error( 'unknown input format for MODE' )
end

end