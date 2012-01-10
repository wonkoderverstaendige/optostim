function merged = merge_param_structs(desc, fulldesc)

% TODO:
%   - "deal" mixed cell/non-cell entries

% This function is necessary because I am too stupid to work with structs
% properly. It's a crutch, hardly working. Don't look too close at it, it
% might just fall apart.

names = fieldnames(desc);
nfields = numel(names);
nstims = numel(desc);

disp('    Parameter merge required!');

%###### UNWRAP ############################################################

% Check input struct for fields with cell entries (indicating a stim that
% is referenced to a template/channel again with multiple stimulations
for stim = 1:nstims
    has_cells = false;
    for field = 1:nfields
        if iscell(desc(stim).( names{field} )) %&& numel(desc{nstim}.( name{field})) > 1
            has_cells = true;
        end
    end
    
    % if any of the entries has cells, we want to resolve the struct to
    % non-cell entries only
    %%% FOR CONVENIENCE WE CURRENTLY ASSUME THAT IF ONE FIELD HAS CELLS,
    %%% ALL CELLS WILL HAVE CELLS -> would otherwise require more awkward
    %%% loops to check and deal()
    
    if has_cells
        disp(['       Stimulus ', num2str(stim), ' has cell entries...']);

        tmp = desc(stim);
        
        % removing the whole branch
        desc(stim) = [];

        % adding new entries for each substimulation
        for substim = 1:size(tmp.template, 2)
            entry = size(desc, 2) + 1;
            for field = 1:nfields
                desc(entry).(names{field}) = tmp.(names{field}){substim};
            end
        end
    end
end


%###### MERGE #############################################################

% empty struct of equal structure
merged = struct(desc(1));

% if given the full struct of the channel, append all stimuli with an empty
% template to [desc] to include them in the final structure
if nargin > 1 && isstruct(fulldesc)
    nstimfull = size(fulldesc.template, 2);
    tmp = struct;
    entry = 1;
    for n = 1:nstimfull
        if isempty(fulldesc.template{n});
            for i = 1:nfields
                tmp(entry).( names{i} ) = fulldesc.( names{i} ){n};
            end
            entry = size(tmp, 2) + 1;
        end
    end
    
    % if any stimuli have been copied merge them with the rest
    if entry > 1
        disp(['    Merging ', num2str(entry-1), ' entries...']);
        desc = [desc tmp];
    end
end

% Final merge
for i = 1:nfields
    merged.( names{i} ) = { desc(:).( names{i} ) };
end    

disp('        --> Done');
end