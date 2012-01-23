% Takes serial object s and either a duration in seconds as a scalar, or a matrix of values to throw at DSP

function [values, timestamps] = RecordArduino(s, recdur, X, mao)

	ADCREF = 1.1; % Internal reference ADC, 1.1V, 2.56V, 5V
    INTLOOP = 200; % amount of samples Arduino should take upon command
	
	if s.InputBufferSize < (2*INTLOOP)
		error('Too many loops for Arduino, would overrun serial connection input buffer');
	end

    if exist('X') && ~isempty(X)
		trigMAO = true;
		multi_ao_load( mao, X );
	else
		trigMAO = false;
	end
	
    progress = true;
    
    Tsettle = 0.005; % minimum settle time for Ardunio ADC = pause in loop!
    maxnvals = ceil(recdur/Tsettle); % maximum number values without any overhead
    idx = 1;
	
	% preallocate
    timestamps = zeros(maxnvals, 1);
    values = zeros(maxnvals, 1);
    tloop = zeros(maxnvals, 1);

    total = tic;
    tstart = clock;
    if progress textprogressbar(['Recording for ', num2str(recdur), ' seconds: ']); end
	
	figure(10);
	plot(values/1024*ADCREF);
	ylim([0 1]);
    
    while toc(total)/recdur <= 1
        eloop = tic;

		% trigger MAO after first value INTLOOP sized batch requested, should give baseline
		if trigMAO 
			rc = multi_ao_trigger( mao );
			trigMAO = false;
		end
        
		% send command and number of loops to run
        fwrite(s, INTLOOP);



		slice = idx:(idx+INTLOOP-1);
        if progress textprogressbar(toc(total)/recdur*100); end
        
		n = 0;
        
		%minimum time Arduino needs to complete sampling loop
		%pause(Tsettle * INTLOOP);
		plot(values/1024*ADCREF);
		ylim([0 1]);
		
        % wait for Arduino to write back the two bytes, [n] ms timeout!
        while get(s, 'BytesAvailable') < 2*INTLOOP && n < 100;
            pause(0.0005);
            n = n + 1;
        end
        
        nbytes = get(s, 'BytesAvailable');

        if nbytes == 2 * INTLOOP
            tmpBytes = fread(s, nbytes);
            values(slice) = bitshift(tmpBytes(2:2:(INTLOOP*2)), 8) ...
                            + tmpBytes(1:2:(INTLOOP*2-1));
        else
            if nbytes 
                disp(['Clearing ', num2str(nbytes), ' stuck bytes']);
                fread(s, nbytes); % clear (corrupted?) buffer
            end
            values(slice) = NaN;
        end
        
        if idx == 1
            t1 = 0;
        else
            t1 = timestamps(idx-1);
        end
        
        % linearly spaced timestamps
        t2 = etime(clock, tstart);
        timestamps(slice) = linspace(t1+(t2-t1)/INTLOOP, t2, INTLOOP);

        % average time to get values
        tloop(slice) = toc(eloop) / INTLOOP;
        
        if Tsettle-toc(eloop) > 0
            pause(Tsettle-toc(eloop));
        end

        idx = idx + INTLOOP;
    end
    
    if progress 
        textprogressbar(100);
        textprogressbar([' Done! ', 10, 'Recorded ', num2str(idx-1), '/',...
            num2str(maxnvals), ' values']); 
    end

    X = [values/1024*ADCREF timestamps tloop];

    % remove trailing zeros
    X((idx):end, :) = [];
	
	values = X(:, 1);
	timestamps = X(:, 2);
	delta = X(:, 3);
	
	plot(values);
	ylim([0 1]);
	
end


function textprogressbar(c)
% This function creates a text progress bar. It should be called with a 
% STRING argument to initialize and terminate. Otherwise the number correspoding 
% to progress in % should be supplied.
% INPUTS:   C   Either: Text string to initialize or terminate 
%                       Percentage number to show progress 
% OUTPUTS:  N/A
%
% Author: Paul Proteus (e-mail: proteus.paul (at) yahoo (dot) com)
% Version: 1.0
% Changes tracker:  29.06.2010  - First version
%
% Inspired by: http://blogs.mathworks.com/loren/2007/08/01/monitoring-progress-of-a-calculation/

% Initialization
persistent strCR;           %   Carriage return pesistent variable

% Vizualization parameters
strPercentageLength = 7;   %   Length of percentage string (must be >5)
strDotsMaximum      = 10;   %   The total number of dots in a progress bar

% Main 

if isempty(strCR) && ~ischar(c),
    % Progress bar must be initialized with a string
    error('The text progress must be initialized with a string');
elseif isempty(strCR) && ischar(c),
    % Progress bar - initialization
    fprintf('%s',c);
    strCR = -1;
elseif ~isempty(strCR) && ischar(c),
    % Progress bar  - termination
    strCR = [];  
    fprintf([c '\n']);
elseif isnumeric(c)
    % Progress bar - normal progress
    c = floor(c);
    percentageOut = [num2str(c) '%%'];
    percentageOut = [percentageOut repmat(' ',1,strPercentageLength-length(percentageOut)-1)];
    nDots = floor(c/100*strDotsMaximum);
    dotOut = ['[' repmat('.',1,nDots) repmat(' ',1,strDotsMaximum-nDots) ']'];
    strOut = [percentageOut dotOut];
    
    % Print it on the screen
    if strCR == -1,
        % Don't do carriage return during first run
        fprintf(strOut);
    else
        % Do it during all the other runs
        fprintf([strCR strOut]);
    end
    
    % Update carriage return
    strCR = repmat('\b',1,length(strOut)-1);
    
else
    % Any other unexpected input
    error('Unsupported argument type');
end

end
