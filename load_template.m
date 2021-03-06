function template = load_template(type, name)
% io defines input and output parameters, channels used etc.
    % Fs - sampling freq DSP
    % inputchans - channels selected on CS
    % outputchans - output channels used on CS, necessary for calibration
% timings defines timings of pulses and trains
% shapes defines individual pulses

addpath('templates');

if ~ischar(type) error('Template type must be string'); end
if ~ischar(name) error('Template name must be string'); end
if DEBUG disp(['    Requested template type: ', type, '; name: ', name]); end


% FOR TESTING PURPOSES ONLY
if strcmp(name, 'empty')
    tmp = example_structs('empty');
else
    tmp = example_structs();
end

if strcmp(type, 'full')
    template = eval([type '_' name]);
    if DEBUG disp(['    - Loaded ', type, ' template: ', name]); end
end

subtypes = regexp(type, '_', 'split');

template = eval([subtypes{1} '_' name]);

if numel(subtypes) > 1
    template = template.(subtypes{2});
end

% % split template type string into level and the requested struct
% subtypes = regexp(type, '_', 'split');
% 
% if numel(subtypes) == 1
%     level = 'struct';
%     if DEBUG disp(['      Preparing to load ', type, ' ', level, ' template.']); end
% else
%     type = subtypes{2};
%     level = subtypes{1};
%     if DEBUG disp(['      Preparing to load ', type, ' template for a ', level, '.']); end
% end
% 
% if strcmp(level, 'full')
%     template = tmp;
%     if DEBUG disp(['    - Loaded ', type, ' ', level, ' template: ', name]); end
% elseif strcmp(level, 'chan')
%     template = tmp.(type);
%     if DEBUG disp(['    - Loaded ', type, ' ', level, ' template: ', name]); end 
% end

end