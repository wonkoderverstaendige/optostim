desc = load_template('full', 'calibration');

% update io with infos from DSPs etc
%desc.io.Fs = Fs;

% Should do twice (current, light) and three times for one second each
tmp_plotting = plotting;
plotting = false;

Ovals = [1.95:0.05:2.40];

for v = 1:numel(Ovals)
	% Overwrite templatevalues with adjusted values
	desc.shapes = deal_fields(desc.shapes, 'Vvals', Ovals(v));

	% build stimulus
	[X, t] = stim_func_builder(desc, plotting);

	% duration of stimulus for pauses
	totaldur = ceil(size(X, 1)/Fs);

	% Push to DSP/NI and trigger if that is not a test
	fprintf( 1, 'Testing %0.3gV run:', Ovals(v) )
	multi_ao_load( mao, X );
	
	for n = 1:2
		beep;
		pause;
		rc = multi_ao_trigger( mao );
		fprintf( 1, [' ', num2str(n)], Ovals(v) )
		pause(totaldur + 0.5);	
	end
	
	disp(' ');

end

plotting = tmp_plotting;