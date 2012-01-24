function range = selectPM30range(suggested)

[numranges, strranges, potranges] = rangesPM30;

disp(nargin);
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
	for r = 1:numel(numranges)
		disp(['[', num2str(r), '] ', strranges{r}]);
    end
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