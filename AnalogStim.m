% 2011_12_01
% mice w/ buzsaki32sp + 4 LEDs 
% connected to Slave ports 1-4
% CS channels 9-12, inputs 0-3
% analog control  by AO 1-4 (RX5)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BIOLERPLATES
q_init; % startup, link to DSPs, set prompt to timestamp
q_close; % close link to RX/NI, reset prompt

%##########################  STIMULATION  #################################

%%%%  REGULAR PROTOCOL (rectangular pulses with variable offsetting)  %%%%%
% vals = [0.2:0.1:1.0 1.2:0.2:2.0 3:5];
vals = [0.3:0.2:1.1 ];
pulsedur = [1 5 10 20 50];
lag = 50;
offsets = {[0:(pulsedur+lag):3*(pulsedur+lag)], [0]};
q_regrect



%%%%%%%  OFFSETTING TRAPEZES (50+200 ms at various intensities)  %%%%%%%%%%%
vals = 0.3:0.2:1.1;
pulsedur = {[25 100 25], [25 100 0]};
lag = pulsedur{1}(1);

for factor = 0:3
	offsets = 0 : (sum(pulsedur{1})-factor*lag) : (3 * (sum(pulsedur{1})-factor*lag));
	q_trapez
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           PULSES OF VARIOUS INTENSITIES - SINGLE CHANNEL AT A TIME
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% a pulse train 10 ms pulses delivered at 5 Hz for 5 sec (25 pulses), with various intensities (e.g. 2.5V)

dur = 5; % sec
freq = 5;
%pulse_durations = [1 2.5 5 10 20]; % ms
pulse_durations = 50;
% thesevals = [ 0.6 1.2 2.4 4.8 ];
thesevals = [0.3 0.4 0.5 0.6 1 2];

for pulse_dur = pulse_durations
	for val = thesevals
		for shank = 1 : 4
			fprintf( 1, 'Pulse (%0.3gV, %0.3g ms) on shank %d\n', val, pulse_dur, shank )
			x = func_ao_dummy( Fs, nchans, dur, val, [ freq freq * pulse_dur / 1000 ], 'train', shank ); 
			multi_ao_load( mao, x );
			rc = multi_ao_trigger( mao );
			pause( dur + 1 );
		end
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               PULSES OF VARIOUS INTENSITIES - 
%       MULTIPLE CHANNELS WITH VARIOUS RELATIVE TIMING 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REGULAR PROTOCOL (50 ms at various intensities)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% short (50 ms) pulses:
pulse_dur = 50; % ms
train_dur = 10; % sec
train_freq = 1; % Hz
lag = 100; % ms

% sequential
mat_seq = [ [ 0 : lag : lag * ( 4 - 1 ) ]' ones( 4, 1 ) * pulse_dur ]; 
% simultaneous
mat_sim = [zeros( 4, 1) ones( 4, 1 ) * pulse_dur ]; 

t0 = clock;
% thesevals = [ 4.5 2.4 1.2 0.6 ]; % descending
thesevals = [ 0.3 0.6 1.2 2.4 4.5 ]; % ascending
% thesevals = 0.3 : 0.05 : 0.5; % focused low
% thesevals = 1.0 : 0.2 : 3.0; % focused high
% thesevals = 1.0 : 1.0 : 5.0; % focused very high
for vals = thesevals
	fprintf( 1, 'Sequential @ %0.3gV %0.3g ms (%0.3g)\n', vals, pulse_dur, etime( clock, t0 ) );
    x = dig2ana( mat_seq, Fs, train_freq, train_dur, vals );
	multi_ao_load( mao, x ); multi_ao_trigger( mao ); pause( train_dur + 1 )

	fprintf( 1, 'Simultaneous @ %0.3gV %0.3g ms (%0.3g)\n', vals, pulse_dur, etime( clock, t0 ) );

    X = zeros(train_dur*Fs, nchans);
    
    x_single = func_ao_dummy( Fs, 1, dur, val, [ freq freq * pulse_dur / 1000 ], 'train', shank ); 
    
    X = [X x_single];
    X = offset_chan_mat(X, mat_sim);
       
    %x = dig2ana( mat_sim, Fs, train_freq, train_dur, vals );
	multi_ao_load( mao, x ); multi_ao_trigger( mao ); pause( train_dur + 1 )
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FULL PROTOCOL (all pairs/sequential/simultaneous at a single intensity; 50 ms)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
thesevals = [ 0.4 0.5 0.6 1 2 3 4];
% thesevals = [4.0]; 
for vals = thesevals
    
    % long (400 ms) pulses:
    % pulse_dur = 400;
    % lag = 800;
    % train_freq = 0.25;
    % train_dur = 40;
    
    % short (50 ms) pulses:
    pulse_dur = 50; % ms
    train_dur = 10; % sec
    train_freq = 1; % Hz
    lag = 100; % ms
    
    pmat = [ 1 2; 1 3; 1 4; 2 3; 2 4; 3 4 ];
    mat0 = zeros( 12, 2 );
    mat0( 9 : 12, 2 ) = pulse_dur; % simultaneous
    mat1 = [ [ 0 : lag : lag * ( 4 - 1 ) ]' ones( 4, 1 ) * pulse_dur ];
    mat = zeros( 12, 2 );
    mat( 9 : 12, : ) = mat1; % sequential
    
    
    for i = 1 : size( pmat )
        fprintf( 1, 'Pair %d x %d @ %0.3gV, %0.3g ms\n', pmat( i, 1 ), pmat( i, 2 ), vals, pulse_dur )
        mat2 = zeros( 12, 2 );
        mat2( pmat( i, : ) + 8, : ) = mat0( pmat( i, : ) + 8, : );
        x = dig2ana( mat2( 9 : 12, : ), Fs, train_freq, train_dur, vals );
        multi_ao_load( mao, x );
        rc = multi_ao_trigger( mao );
        pause( train_dur + 1 )
    end
    
    fprintf( 1, 'Sequential @ %0.3gV, %0.3g ms\n', vals, pulse_dur );
    x = dig2ana( mat( 9 : 12, : ), Fs, train_freq, train_dur, vals );
    multi_ao_load( mao, x );
    rc = multi_ao_trigger( mao );
    pause( train_dur + 1 )
    
    fprintf( 1, 'Simultaneous @ %0.3gV, %0.3g ms\n', vals, pulse_dur );
    x = dig2ana( mat0( 9 : 12, : ), Fs, train_freq, train_dur, vals );
    multi_ao_load( mao, x );
    rc = multi_ao_trigger( mao );
    pause( train_dur + 1 )
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RAMPS OF VARIOUS INTENSITIES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% a train of 50 ms ramps delivered at 5 Hz for 5 sec (25 ramps), with various intensities (e.g. 2.5V)
% dur = 5; % sec
% freq = 5;
% val = 2.5; % 45 uW
% pulse_dur = 50; % ms
% shank = 1;
% x = func_ao_dummy( Fs, nchans, dur, val, [ freq freq * pulse_dur / 1000 ], 'ramp', shank ); 
% multi_ao_load( mao, x );
% rc = multi_ao_trigger( mao );

% loop over 4 shanks
dur = 10; % sec
freq = 1;
val = 1.0; % 
pulse_dur = 600; % ms
for shank = 1 : 4
    fprintf( 1, 'Ramp on shank %d @ %0.3gV, %0.3g ms\n', shank, val, pulse_dur );
	x = func_ao_dummy( Fs, nchans, dur, val, [ freq freq * pulse_dur / 1000 ], 'ramp', shank ); 
	multi_ao_load( mao, x );
	rc = multi_ao_trigger( mao );
	pause( dur + 1 );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SINE WAVES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% an 8 Hz sine wave
% dur = 5; % sec
% freq = 5;
% val = 2.5; 
% shank = 1;
% x = func_ao_dummy( Fs, nchans, dur, val, freq , 'sine', shank ); 
% multi_ao_load( mao, x );
% rc = multi_ao_trigger( mao );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ZAP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ZAP stimulus on shank 1
% flip CS ch1 to analog
% shank = 1;
% dur = 10;
% val = 4;
% F12 = [ 0 40 ];
% x = func_ao_dummy( Fs, nchans, dur, val, F12, 'zap', shank );
% multi_ao_load( mao, x );
% rc = multi_ao_trigger( mao );

% loop over shanks
nreps = 2;
dur = 10;
F12 = [ 0 40 ];
thesevals = [ 0.7 ];
for val = thesevals 
	for shank = 1 : 4
		fprintf( 1, 'Zap on shank %d @ %0.3gV', shank, val )
		x = func_ao_dummy( Fs, nchans, dur, val, F12, 'zap', shank );
		multi_ao_load( mao, x );
		for i = 1 : nreps
			rc = multi_ao_trigger( mao );
			pause( dur + 1 );
			fprintf( 1, ' d', i )
		end
		fprintf( 1, '\n' )
	end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% White Noise
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% shank = 1;
% meanWN = 3; % mean
% halfrangeWN = 2; % 3SDs
% L = load( 'E:\stim_protocols\WN_new.mat' );
% WN0 = L.WN;
% WN = meanWN + ( WN0 - mean( WN0 ) ) / std( WN0 ) * halfrangeWN / 3;
% x = zeros( size( L.WN, 1 ), nchans );
% x( :, shank ) = WN;

% figure( 1 ); 
% clf
% ah1 = axes( 'position', [ 0.13         0.51      0.65119      0.34116 ] );
% plot( [ 1 : size( x, 1 ) ] / Fs, x( :, shank ) )
% ylim( [ 0 5 ] )
% xlim( [ 1 size( x, 1 ) ] / Fs )
% subplot( 2, 1, 2 )
% ah2 = axes( 'position', [ 0.13         0.11      0.65119      0.34116 ] )
% imagesc( [ 1 : size( x, 1 ) ] / Fs, 1 : size( x, 2 ), x', [ 0 5 ] ), axis xy
% xlabel( 'Time (sec)' )
% colorbar

% multi_ao_load( mao, x );
% rc = multi_ao_trigger( mao );


% loop over all shanks
nreps = 5;
meanWN = 0.6; % mean
halfrangeWN = 0.4; % 3SDs
L = load( 'E:\stim_protocols\WN_new.mat' );
WN0 = L.WN;
WN = meanWN + ( WN0 - mean( WN0 ) ) / std( WN0 ) * halfrangeWN / 3;

shank = 1;
x = zeros( size( L.WN, 1 ), nchans );
x( :, shank ) = WN;

figure( 1 ); 
clf
ah1 = axes( 'position', [ 0.13         0.51      0.65119      0.34116 ] );
plot( [ 1 : size( x, 1 ) ] / Fs, x( :, shank ) )
ylim( [ 0 5 ] )
xlim( [ 1 size( x, 1 ) ] / Fs )
subplot( 2, 1, 2 )
%ah2 = axes( 'position', [ 0.13         0.11      0.65119      0.34116 ] )
imagesc( [ 1 : size( x, 1 ) ] / Fs, 1 : size( x, 2 ), x', [ 0 5 ] ), axis xy
xlabel( 'Time (sec)' )
colorbar

for shank = 1 : 4
	fprintf( 1, 'WN on shank %d', shank )
	x = zeros( size( L.WN, 1 ), nchans );
	x( :, shank ) = WN;
	multi_ao_load( mao, x );
	for i = 1 : nreps
		rc = multi_ao_trigger( mao );
		pause( size( L.WN, 1 ) / Fs + 1 );
		fprintf( 1, ' %d', i )
	end
	fprintf( 1, '\n' )
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LONG DURATION PULSES - CAREFUL!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dur = 10; % sec
freq = 1;

pulse_dur = 600;
thesevals = [ 0.4 0.6 0.8];
for val = thesevals
	for shank = 1 : 4
		fprintf( 1, 'Pulse (%0.3gV, %0.3g ms) on shank %d\n', val, pulse_dur, shank )
		x = func_ao_dummy( Fs, nchans, dur, val, [ freq freq * pulse_dur / 1000 ], 'train', shank ); 
		multi_ao_load( mao, x );
		rc = multi_ao_trigger( mao );
		pause( dur + 1 );
	end
end
