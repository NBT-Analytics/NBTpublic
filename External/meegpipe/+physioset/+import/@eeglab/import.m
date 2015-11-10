function pObj = import(obj, varargin)
% IMPORT - Imports EEGLAB .set files
%
% pObj = import(obj, fileName)
% pObjArray = import(obj, fileName1, fileName2, ...);
%
% ## Notes:
%
%   * Compressed .gz files are supported.
%
% See also: mff

import physioset.physioset;
import misc.decompress;
import pset.file_naming_policy;
import pset.globals;

misc.check_dependency('eeglab');

if numel(varargin) == 1 && iscell(varargin{1}),
    varargin = varargin{1};
end

% Deal with the multi-newFileName case
if numel(varargin) > 2
    pObj = cell(numel(varargin), 1);
    for i = 1:numel(varargin)
        pObj{i} = import(obj, varargin{i});
    end
    return;
end

fileName = varargin{1};

[fileName, obj] = resolve_link(obj, fileName);

% Default values of optional input arguments
verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);
origVerboseLabel = goo.globals.get.VerboseLabel;
goo.globals.set('VerboseLabel', verboseLabel);

% The input file might be zipped
[status, fileName] = decompress(fileName, 'Verbose', verbose);
isZipped = ~status;

% Determine the names of the generated (imported) files
if isempty(obj.FileName),
    
    newFileName = file_naming_policy(obj.FileNaming, fileName);
    dataFileExt = globals.get.DataFileExt;
    newFileName = [newFileName dataFileExt];
    
else
    
    newFileName = obj.FileName;
    
end

[path, name ext] = fileparts(fileName);

cmd = sprintf('EEG = pop_loadset(''filename'', ''%s'', ''filepath'', ''%s'')', ...
    [name ext], path);
evalc(cmd);
pObj = physioset.from_eeglab(EEG, ...
    'FileName', newFileName, 'SensorClass', obj.SensorClass);


%% Undoing stuff 

% Unset the global verbose
goo.globals.set('VerboseLabel', origVerboseLabel);

% Delete unzipped data file
if isZipped,
    delete(fileNameIn);
end


end