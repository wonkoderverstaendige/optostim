% calibrate laser diode

% diode = 'LED';
diode = 'laser';
% diode = input('Diode name: ', 's');

% if coupled, divide the suggestion ranges by fixed value of eff.
coupled = false;

% close any existing serial connections
closeSerial;

% open serial connection to presumed port of Arduino
s = initSerial('COM3');

%%%%%% CALIBRATION PARAMETERS %%%%%%%%%

% update io with infos from DSPs etc
% desc.io.Fs = Fs;

if strcmp(lower(diode), 'laser')  || strcmp(lower(diode(1:2)), 'ld')
	% With lasers, never go over 40mA (~3.0V) unless you know what you do!
	ABSMAXVAL = 3;

	% Voltage range
	Ovals = [2.4];
	
	% 200ms is ok, short and barely enough for plateau
	pulsedur = [200];
	
	desc = load_template('full', 'calibration');
	% desc.io.outputchans = 10;
	desc.timings.offsets = 50;
	desc.timings.trainfreq = 2;
	desc.timings.traindur = 0.5;
	
	% Suggested values for ranges of PM30 in 0.5V steps, excluding 0
	suggranges(1:4) = 10; % 3 mW -> ignore the low crap
	suggranges(5:10) = 11; % 10 mW
	
	% Minimum value from which on to ask for a repetition if too low
	MINREPETITIONV = 1.6;  % ignore whole beginning for lasers!
	
	% Minimum plataeu level
	MINPLATEAULEVEL = 0.0;
	
	% tail of zeros to be left in seconds
	TRAILTIME = 0.1;
	
elseif strcmp(lower(diode), 'led') || strcmp(lower(diode(1:2)), 'd-')
	% With lasers, never go over 40mA (~3.0V) unless you know what you do!
	ABSMAXVAL = 5;

	% Suggested values for ranges of PM30 in 0.5V steps, excluding 0
	suggranges(1) = 10; % 3 mW
	suggranges(2:4) = 11;
	suggranges(5:10) = 12; % 10 mW
	
		% Voltage range
	Ovals = [4.5];
	% 200ms is ok, short and barely enough for plateau
	pulsedur = [400];
	
	desc = load_template('full', 'calibration');
	% desc.io.outputchans = 10;
	desc.timings.offsets = 50;
	desc.timings.trainfreq = 2;
	desc.timings.traindur = 0.5;

	% Minimum value from which on to ask for a repetition if too low
	MINREPETITIONV = 0.2;
	
	% Minimum plataeu level below which underflow
	MINPLATEAULEVEL = 0.0;
	
	% tail of zeros to be left in seconds
	TRAILTIME = 0.05;
end

% What annoys a noisy oyster? A noisy nose annoys an oyster.
beepstate = beep;
beep on;

plotting = false;

% possible ranges on PM30
% 10uW 30uW 100uW ..... 1W
[numranges, strranges, potranges, units] = rangesPM30;

% start Stimulation & record light intensity w/ Arduino
raw_power = zeros(numel(Ovals), numel(pulsedur));
raw_ranges = zeros(size(raw_power));

%initial range of light meter:
for sug = 1:numel(suggranges)
	if Ovals(1) >= sug/2
		suggestion = suggranges(sug);
	else
		suggestion = suggranges(1);
	end
end

range = selectPM30range(suggestion);
% range = 12;
	
v = 1;
next = '';
while isempty(next)
        for d = 1:numel(pulsedur)
			
			%last second check
			if Ovals(v) > ABSMAXVAL
				error('Dude! Be careful when working with lasers! Value larger than MAX VOLTAGE!');
			end

            % Overwrite templatevalues with adjusted values
            desc.shapes = deal_fields(desc.shapes, {'Vvals', 'pulsedur'}, {Ovals(v), pulsedur(d)});

            % build stimulus
            [X, t] = stim_func_builder(desc, false);
			
			% cut off trailing zeros except for short tail as buffer
			if Ovals(v) > 0
				X = X(1:(max(find(X~=0))+ceil(TRAILTIME*Fs)), :);
			end
			
			recdur = ceil(size(X, 1)/Fs);
			
            % Push to DSP/NI and record with Arduino
			[RecVals, RecTs] = RecordArduino(s, recdur, X, mao, plotting);
			
			% for plateau detection and check for underflow
			[n, xout] = hist(RecVals, 4);


			redo = 0;
			
			% Check for overflows in current reading (RecArduino gives Voltage back, 1V == max)
			if any(RecVals >= 1);
				redo = input(['OVERFLOW AT ', num2str(Ovals(v)), 'V! Remeasure at higher range? [Y]/n '], 's');
				if isempty(redo) || any(strcmp(upper(redo), {'Y', 'YES'}))
					redo = 1;
				else
					redo = 0;
				end
			
			% "under ranged", higher range might increase signal/noise ratio
			elseif max(xout) < MINPLATEAULEVEL && Ovals(v) > MINREPETITIONV
				redo = input(['Value for ', num2str(Ovals(v)), 'V under 0.1, redo at lower range? [Y]/n '], 's');
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
				fprintf( 1, '%0.2f %s - ', platcorr, units{potranges(range)+1});

				raw_power(v, d) = plateau;
				raw_ranges(v, d) = range;
				
				% measure next value
				% v = v + 1;
			end
			
			% % Predict overflows/"underflow" low in next reading
				% % notfirst			next value is higher 
			% if (v < numel(Ovals) && Ovals(v+1) > Ovals(v) && plateau >
			
			
			% end
					
		next = input('Next!');
        end
end

% Close serial connection, otherwise it causes errors to pop up
closeSerial(s);

% % overlay plotting of both
% figure(2); 
% clf
% hl1 = line([1:size(X,1)]/Fs, X, 'Color', 'k');
% ax1 = gca;
% set(ax1,'XColor','k','YColor','k', 'ylim', [0 5], 'xlim', [ 1 size(X, 1) ] / Fs)
% % ylim( [ 0 5 ] )
% % xlim( [ 1 size(X, 1) ] / Fs )

% ax2 = axes('Position',get(ax1,'Position'),...
           % 'XAxisLocation','top',...
           % 'YAxisLocation','right',...
           % 'Color','none',...
           % 'XColor','r','YColor','r', ...
		   % 'xlim', [ 1 size(X, 1) ] / Fs);
		   
		   
% hl2 = line(RecTs, RecVals*range, 'Color', 'r', 'Parent', ax2);

% if numel(Ovals) > 1
	
	% lightpower = raw_power.*numranges(raw_ranges)';

	%%Calculate linear between two values
	% dp = diff(smooth(lightpower));
	% [v, i] = max(diff(smooth(dp)));

	%%unitidx = max(potranges(raw_ranges))+1;
	% rangeidx = max(raw_ranges);
	
	% figure(3);
	% plot(Ovals, lightpower*1e3^potranges(rangeidx));
	% hold on;
	% plot([Ovals(i) Ovals(i)], ylim, '-r');
	% hold off;

	% ylabel(['Light power [', units{potranges(rangeidx)+1}, ']']);
	% xlabel('Volt');
	
	% end

 % if strcmp(upper(diode(1:2)), 'D-') || strcmp(uppder(diode(1:2)), 'ld')
	% attachnum = 0;
	% attachstr = '';
	% while exist(['calibrations/diodes/', upper(diode), '_', datestr(now, 1), attachstr, '.mat'], 'file')
		% if attachnum
			% attachstr = ['_', num2str(attachnum)];
		% end
		% attachnum = attachnum + 1;
	% end
	% filename = ['calibrations/diodes/', upper(diode), '_', datestr(now, 1), attachstr, '.mat'];
	% save(filename, 'RecVals', 'RecTs', 'lightpower', 'Ovals', 'raw_ranges', 'Fs', 'X', 'desc');
	% disp(['Saved as: ', filename]);
% end

% switch beep back to whatever it was before
if strcmp(beepstate, 'off')
	beep off;
else
	beep on; %redundant, but whatever
end