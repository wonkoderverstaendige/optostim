% calibrate laser diode

% With lasers, never go over 40mA (~3.0V) unless you know what you do!
ABSMAXVAL = 3;

% What annoys a noisy oyster? A noisy nose annoys an oyster.
beepstate = beep;
beep on;

% possible ranges on PM30
% 10uW 30uW 100uW ..... 1W
[numranges, strranges, potranges, units] = rangesPM30;

% close any existing serial connections
closeSerial;

% open serial connection to presumed port of Arduino
s = initSerial('COM3');

desc = load_template('full', 'calibration');
% desc.io.outputchans = 10;
desc.timings.offsets = 200;

% Ovals = [1:5];
% pulsedur = [1 5 10 20 50 100 200 500];
Ovals = [0:0.5:2.5];
pulsedur = [200];

% update io with infos from DSPs etc
% desc.io.Fs = Fs;

% start Stimulation & record light intensity w/ Arduino
lightpower = zeros(numel(Ovals), numel(pulsedur));
setranges = zeros(size(lightpower));

%initial range of light meter:
range = selectPM30range(0);

v = 1;
while v <= numel(Ovals)
        for d = 1:numel(pulsedur)

			redo = 0;
			
			%last second check
			if Ovals(v) > ABSMAXVAL
				error('Dude! Be careful when working with lasers! Value larger than MAX VOLTAGE!');
			end

            % Overwrite templatevalues with adjusted values
            desc.shapes = deal_fields(desc.shapes, {'Vvals', 'pulsedur'}, {Ovals(v), pulsedur(d)});

            % build stimulus
            [X, t] = stim_func_builder(desc, plotting);
			recdur = ceil(size(X, 1)/Fs);
			
            % Push to DSP/NI and record with Arduino
			[RecVals, RecTs] = RecordArduino(s, recdur, X, mao, 10);
			
			% for plateau detection and check for underflow
			[n, xout] = hist(RecVals, 4);

			% Check for overflows in current reading (RecArduino gives Voltage back, 1V == max)
			if any(RecVals >= 1);
				redo = input('OVERFLOW! Remeasure at higher range? [Y]/n ', 's');
				if isempty(redo) || any(strcmp(upper(redo), {'Y', 'YES'}))
					redo = 1;
				else
					redo = 0;
				end
			
			% underflow, higher might increase signal/noise ratio
			elseif max(xout) < 0.1
				redo = input('Value very low, redo at lower range? [Y]/n ', 's');
				if isempty(redo) || any(strcmp(upper(redo), {'Y', 'YES'}))
					redo = -1;
				else
					redo = 0;
				end
			end
			
			if redo ~= 0
				disp(range + redo);
				range = selectPM30range(range + redo);
			else
				% plateau detection
				[n2, xout2] = hist(RecVals(RecVals>xout(2)), 20);
				[sorted, order] = sort(n2, 'descend');
				plateau = xout2(order(1));
				platcorr = plateau*numranges(range)*1e3^potranges(range);
				fprintf( 1, '%0.2gV peak light power detected at: %0.2g %s\n', Ovals(v), platcorr, units{potranges(range)+1});
				% disp([num2str(Ovals(v)), 'V peak light power detected at: ', platstr, strranges{range}]);

				lightpower(v, d) = plateau;
				setranges(v, d) = range;
				
				% measure next value
				v = v + 1;
			end
			
			% % Predict overflows/"underflow" low in next reading
				% % notfirst			next value is higher 
			% if (v < numel(Ovals) && Ovals(v+1) > Ovals(v) && plateau >
			
			
			% end
					
			
        end
end

% Close serial connection, otherwise it causes errors to pop up
closeSerial(s);

%overlay plotting of both
figure(2); 
clf
hl1 = line([1:size(X,1)]/Fs, X, 'Color', 'k');
ax1 = gca;
set(ax1,'XColor','k','YColor','k', 'ylim', [0 5], 'xlim', [ 1 size(X, 1) ] / Fs)
% ylim( [ 0 5 ] )
% xlim( [ 1 size(X, 1) ] / Fs )

ax2 = axes('Position',get(ax1,'Position'),...
           'XAxisLocation','top',...
           'YAxisLocation','right',...
           'Color','none',...
           'XColor','r','YColor','r', ...
		   'xlim', [ 1 size(X, 1) ] / Fs);
		   
		   
hl2 = line(RecTs, RecVals*range, 'Color', 'r', 'Parent', ax2);

figure(3);
plot(


% switch beep back to whatever it was before
if strcmp(beepstate, 'off')
	beep off;
else
	beep on; %redundant, but whatever
end