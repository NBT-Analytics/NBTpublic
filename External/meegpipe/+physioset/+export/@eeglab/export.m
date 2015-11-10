function fName = export(obj, data, fName)
% export - Export physioset object to EEGLAB's .set file
%
% See also: export

import physioset.physioset;
import misc.decompress;
import pset.file_naming_policy;
import pset.globals;
import mperl.file.spec.catfile;

if ~isa(data, 'physioset.physioset'),
    if ~iscell(data) && ...
            all(cellfun(@(x) isa(x, 'physioset.physioset'), data))
        error(['A physioset or a cell array of physiosets was expected ' ...
            'as second argument']);
    end
end

if iscell(data) && numel(data) == 1
    data = data{1};
end

if nargin < 3 || isempty(fName),
    fName = repmat({''}, 1, numel(data));
end

if iscell(fName) && numel(fName) == 1,
    fName = fName{1};
end


% Deal with the multi-newFileName case
if iscell(data)
    
    if ischar(fName),
        fName = {fName};
    end
    
    if numel(fName) == 1,
        fName = repmat(fName, 1, numel(data));
    end    
   
    for i = 1:numel(data)
        fName{i} = export(obj, data{i}, fName{i});
    end
    return;
    
end

% Default values of optional input arguments
verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);
origVerboseLabel = goo.globals.get.VerboseLabel;
goo.globals.set('VerboseLabel', verboseLabel);

% Convert to EEGLAB structure
EEG = eeglab(data, ...
    'BadDataPolicy',    obj.BadDataPolicy, ...
    'MemoryMapped',     obj.MemoryMapped); %#ok<NASGU>

if isempty(fName),
   fName = obj.FileName;
end

if isempty(fName),
    fName = file_naming_policy(obj.FileNaming, get_datafile(data));
end

[path, name, ~] = fileparts(fName);

if verbose,
    fprintf([verboseLabel 'Exporting to %s.set...'], [path name]);
end
cmd = sprintf(['pop_saveset(EEG, ''filepath'', ''%s'', ''filename'', ' ...
    '''%s'')'], path, name);
% To prevent EEGLAB to produce any output to the command window
evalc(cmd);

fName = catfile(path, [name '.set']);
if verbose
    fprintf('[done]');
end

%% Undoing stuff 

% Unset the global verbose
goo.globals.set('VerboseLabel', origVerboseLabel);


end