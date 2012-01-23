% add path to rest of quick wrapper scripts
addpath('wrapper');
addpath('templates');
addpath('calibrations');
addpath('arduinomatlabdaq');

% Set prompt to updating timestamp - !!!Screws up autocomplete!!!
setPrompt('timestamp');

% io-specifics
n = 1e5; % maximum number of samples (initial - ignored later)
nchans = 5; % 5th channel is to start the RX6 in order to get a pulse at the beginning of each AO
Fs_init = 6000; % 6 kHz
maxvals = [ 5 5 5 5 5 ]; % for blue LEDs
mao = multi_ao_initiate( nchans, Fs_init, n, maxvals );
Fs = mao.Fs;

% enable/disable plotting before triggering.
plotting = true;

% enable triggering, set false to run dry tests
trigger = true;

% Randomization of sequences etc.
randomized = false;

