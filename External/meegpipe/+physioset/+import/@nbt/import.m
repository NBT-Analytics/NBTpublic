function pObj = import(obj, varargin)
% IMPORT - Imports files in NBT format
%
%
% See also: physioset.import.nbt

import physioset.physioset;
import pset.file_naming_policy;
import pset.globals;
import mperl.file.spec.catfile;

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

% Determine the names of the generated (imported) files
if isempty(obj.FileName),   
    newFileName = file_naming_policy(obj.FileNaming, fileName);
    dataFileExt = globals.get.DataFileExt;
    newFileName = [newFileName dataFileExt];  
else  
    newFileName = obj.FileName;
end

[path, name, ext] = fileparts(fileName);
if isempty(regexp(name, '_info$', 'once')),
    % user provided the data file, not the info file
    infoFileName = catfile(path, [name '_info' ext]);
    dataFileName = fileName;
else
    dataFileName = catfile(path, [name(1:end-5) ext]);
    infoFileName = fileName;
end

nbtData = load(dataFileName);
fNames = fieldnames(nbtData);
if numel(fNames) > 1,
    error('Invalid format for file %s', dataFileName);
end
nbtData = nbtData.(fNames{1});

nbtInfo = load(infoFileName);
fNames = fieldnames(nbtInfo);
if numel(fNames) > 1,
    error('Invalid format for file %s', infoFileName);
end
nbtInfo = nbtInfo.(fNames{1});

if verbose,
    fprintf([verboseLabel 'Importing NBT file %s into %s ...\n\n'], ...
        infoFileName, newFileName);
end
pObj = physioset.physioset.from_nbt(nbtInfo, nbtData, ...
    'Filename', newFileName, 'SensorClass', obj.SensorClass);

if ~isempty(obj.Sensors),
    % Sensors property takes precedence over SensorClass
    set_sensors(pObj, obj.Sensors);
end

% Unset the global verbose
goo.globals.set('VerboseLabel', origVerboseLabel);

end