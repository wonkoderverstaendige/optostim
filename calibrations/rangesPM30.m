function [numeric, strings, pots, units] = rangesPM30(entry)
exps = log10(1e-7):log10(1);
a = [10.^exps; 3*10.^exps];
numeric = a(1:end-1);
pots = abs(floor(floor(log10(numeric))/3));

% range strings
units = {'W', 'mW', 'µW', 'nW'};
for e = 1:numel(numeric)
	strings{e} = [num2str(numeric(e)*1e3^pots(e)), ' ', units{pots(e)+1}];
end

if exist('entry') && isnumeric(entry) && any(entry == 1:numel(numeric))
	numeric = numeric(entry);
	strings = {strings{entry}};
	pots = pots(entry);
end