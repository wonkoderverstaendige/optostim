    function s = initSerial(port)
	
	if ~exist('port') || ~ischar(port)
		port = 'COM3';
	end
	
	% Initialize serial port
    s = serial(port);
    set(s,{'BaudRate', 'DataBits','StopBits'}, {57600, 8, 1}); 
    fopen(s);
    disp('Pausing a second for connection to settle... for whatever reason!');
    
	% FOR SOME F*** REASON IT TAKES ONE SECOND FOR THE CONNECTION TO SETTLE
    % SO THAT HANDSHAKING WORKS!
	pause(1);
    %s.ReadAsyncMode = 'continuous'; %default anyway