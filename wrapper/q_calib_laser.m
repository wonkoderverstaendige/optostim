% calibrate laser diode

% close any existing serial connections
closeSerial;

% open serial connection to presumed port of Arduino
s = initSerial('COM3');

desc = load_template('full', 'calibration');
% desc.io.outputchans = 10;
desc.timings.offsets = 200;

% Ovals = [1:5];
% pulsedur = [1 5 10 20 50 100 200 500];
Ovals = [0.1:0.2:0.9];
pulsedur = [250];

% update io with infos from DSPs etc
% desc.io.Fs = Fs;

% start Stimulation & record light intensity w/ Arduino
for v = 1:numel(Ovals)
        for d = 1:numel(pulsedur)

            % Overwrite templatevalues with adjusted values
            desc.shapes = deal_fields(desc.shapes, {'Vvals', 'pulsedur'}, {Ovals(v), pulsedur(d)});

            % build stimulus
            [X, t] = stim_func_builder(desc, plotting);
			recdur = ceil(size(X, 1)/Fs);
			
            % Push to DSP/NI and record with Arduino
			[RecVals, RecTs] = RecordArduino(s, recdur, X, mao);
            
            % plateau detection
            [n, xout] = hist(RecVals, 4);
            [n2, xout2] = hist(RecVals(RecVals>xout(2)), 20);
            [sorted, order] = sort(n2, 'descend');
            plateau = xout2(order(1));
            disp([num2str(Ovals(v)), 'V peak light power detected at: ', num2str(plateau)]);

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

