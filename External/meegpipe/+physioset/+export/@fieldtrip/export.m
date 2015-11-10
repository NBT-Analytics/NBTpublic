function fName = export(obj, data, fName)
% export - Export physioset object to EEGLAB's .set file
%
% See also: export

import physioset.physioset;
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
ftripData = fieldtrip(data, 'BadDataPolicy', obj.BadDataPolicy); 

if isempty(fName),
   fName = obj.FileName;
end

if isempty(fName),
    fName = file_naming_policy(obj.FileNaming, get_datafile(data));
end

[path, name, ~] = fileparts(fName);
fName = catfile(path, [name '.mat']);

if verbose,
    fprintf([verboseLabel 'Exporting to %s.mat...'], catfile(path,name));
end
save(fName, 'ftripData');

if verbose
    fprintf('[done]\n\n');
end

%% Undoing stuff 

% Unset the global verbose
goo.globals.set('VerboseLabel', origVerboseLabel);

end