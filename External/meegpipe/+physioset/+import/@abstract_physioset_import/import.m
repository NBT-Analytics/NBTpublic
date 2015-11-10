function pObj = import(obj, varargin)

import pset.file_naming_policy;
import pset.globals;
import physioset.physioset;

if numel(varargin) == 1 && iscell(varargin{1}),
    varargin = varargin{1};
end

% Deal with the multi-newFileName case
if nargin > 2
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

if isempty(goo.globals.get.VerboseLabel),
    goo.globals.set('VerboseLabel', verboseLabel);
    clearVerboseLabel = true;
else
    clearVerboseLabel = false;
end

% Determine the names of the generated (imported) files
if isempty(obj.FileName),
    psetFileName = file_naming_policy(obj.FileNaming, fileName);
    dataFileExt = globals.get.DataFileExt;
    psetFileName = [psetFileName dataFileExt];  
else
    psetFileName = obj.FileName;
end

if verbose,
    fprintf([verboseLabel 'Reading %s...\n\n'], fileName);
end
[sens, sr, hdr, ev, startTime, startDate, metaData] = ...
    read_file(obj, fileName, psetFileName, ...
    verbose, verboseLabel);
if isempty(startDate), startDate = datestr(now, globals.get.DateFormat); end
if isempty(startTime), startTime = datestr(now, globals.get.TimeFormat); end

if verbose,
    fprintf([verboseLabel 'Done reading %s\n\n'], fileName);
end

% Generate the output physioset object
if verbose,
    fprintf([verboseLabel 'Generating physioset object ...\n\n']);
end
physiosetArgs = construction_args_physioset(obj);

if ~isempty(obj.Sensors),
    sens = obj.Sensors;
end
pObj = physioset(psetFileName, nb_sensors(sens), physiosetArgs{:}, ...
    'StartDate',    startDate, 'StartTime', startTime, ...
    'Event',        ev, ...
    'Sensors',      sens, ...
    'SamplingRate', sr, ...
    'Header',       hdr, ...
    'Temporary',    obj.Temporary);
if verbose,
    fprintf([verboseLabel 'Done\n\n']);
end

if obj.ReadEvents && isempty(ev),
    
    [ev, metaEvs] = read_events(obj, fileName, pObj, verbose, verboseLabel);
    add_event(pObj, ev);
end

metaData = misc.struct2cell(metaData);
metaEvs  = misc.struct2cell(metaEvs);
meta = [metaData(:);metaEvs(:)];
set_meta(pObj, meta{:});

if clearVerboseLabel,
    goo.globals.set('VerboseLabel', '');
end

