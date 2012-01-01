%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DIGITAL OUTPUTS
% train of 4 blue light pulses (1 per shank):
% set CS to dig out
[ rx6 freq rc ] = initiate_tdt( 'C:\TDT\RPvdsEx\eran\PulseTrainMouse.rcx', 25000, 'rx6' );

lag = 100; % ms
dur = 50; % ms
train_freq = 1; % Hz
train_dur = 10; % sec
mat0 = [ [ 0 : lag : lag * ( 4 - 1 ) ]' ones( 4, 1 ) * dur ];
mat = zeros( 12, 2 );
mat( 9 : 12, : ) = mat0;
set_tdt_params( rx6, { 'Pulse_Freq', 'Train_Dur' }, [ train_freq train_dur ] );
set_LED_params( rx6, mat );
if rx6.SoftTrg( 1 ) ~= 1, error( 'error triggering' ), end

% same but simultaneous
mat0 = mat;
mat0( :, 1 ) = 0;
set_LED_params( rx6, mat0 );
if rx6.SoftTrg( 1 ) ~= 1, error( 'error triggering' ), end

% single channel 5 Hz trains:
train_freq = 5; % Hz
train_dur = 5; % sec
set_tdt_params( rx6, { 'Pulse_Freq', 'Train_Dur' }, [ train_freq train_dur ] );
dur = 50;
dur = 10; %ms
mats = zeros( 12, 2, 4 );
mats( 9, 2, 1 ) = dur;
mats( 10, 2, 2 ) = dur;
mats( 11, 2, 3 ) = dur;
mats( 12, 2, 4 ) = dur;
shank = 1; set_LED_params( rx6, mats( :, :, shank ) ); if rx6.SoftTrg( 1 ) ~= 1, error( 'error triggering' ), end

% all different pairs; sequential; simultaeous
pmat = [ 1 2; 1 3; 1 4; 2 3; 2 4; 3 4 ];
mat0 = zeros( 12, 2 ); 
mat0( 9 : 12, 2 ) = 50;
for i = 1 : size( pmat )
	fprintf( 1, 'Pair %d x %d\n', pmat( i, 1 ), pmat( i, 2 ) )
	mat2 = zeros( 12, 2 );
	mat2( pmat( i, : ) + 8, : ) = mat0( pmat( i, : ) + 8, : );
	set_LED_params( rx6, mat2 );
	if rx6.SoftTrg( 1 ) ~= 1, error( 'error triggering' ), end
	pause( 11 )
end
fprintf( 1, 'Sequential\n' );
set_LED_params( rx6, mat );
if rx6.SoftTrg( 1 ) ~= 1, error( 'error triggering' ), end
pause( 11 )
fprintf( 1, 'Simultaneous\n' );
set_LED_params( rx6, mat0 );
if rx6.SoftTrg( 1 ) ~= 1, error( 'error triggering' ), end
pause( 11 )