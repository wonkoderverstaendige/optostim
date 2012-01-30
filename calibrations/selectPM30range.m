function range = selectPM30range(suggested)

[numranges, strranges, potranges] = rangesPM30;

if nargin ~= 1
	suggested = 11; % 10 mW as standard value initially, safe value even with LED on
end

% initial range selection, has different qestion string
if suggested == 0
	qstring = 'Initial range on PM30? [';
	suggested = 11;
else
	qstring = 'Range on PM30? [';
end

range = ' ';
while ischar(range)
	for r = 0:ceil((numel(numranges)/3)-1)
		fstr = '';
		itemsperline = 4;
		for nline = 1:itemsperline;
			curridx = itemsperline*r + nline;
			
			if nline == itemsperline
				delim = '\n';
			else
				delim = ' | ';
			end
			
			if curridx < 10
				zfill = '0';
			else
				zfill = '';
			end
			
			if ~(curridx>numel(numranges))
				vs = regexp(strranges{curridx}, ' ', 'split');

				strvalue = [repmat(' ', 1, 3-length(vs{1})), vs{1} ];
				strunit = [repmat(' ', 1, 2-length(vs{2})), vs{2}];
							
				fstr = [fstr, zfill, num2str(curridx), ' - ', strvalue, ' ', strunit, delim];
			else
				% fstr = [fstr, delim];
			end
		end
		
		fprintf(fstr);
    end
	fprintf('\n');
	beep;
	range = input([qstring, strranges{suggested}, ' suggested]: ']);
	
	% select standard value/suggested value
	if isempty(range)
		range = suggested;
	end
	
	% selected value nonsense?
	if ~any(range == 1:numel(numranges))
		range = ' ';
	end
end