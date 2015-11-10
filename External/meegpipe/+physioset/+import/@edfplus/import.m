function pObj = import(obj, varargin)
% IMPORT - Imports EDF+ files
%
% pObj = import(obj, fileName)
%
% See also: edfplus


import physioset.event.event;
import misc.sizeof;
import io.edfplus.isedfplus;
import io.edfplus.read;
import pset.file_naming_policy;
import pset.globals;
import safefid.safefid;
import misc.eta;
import io.edfplus.labels2sensors;
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

if ~isempty(fileName) && ~isedfplus(fileName),
    warning('import:invalidFormat', ...
        'File ''%s'' is not a valid EDF+ file', fileName);
end

% Default values of optional input arguments
verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

% Determine the names of the generated (imported) files
if isempty(obj.FileName),
    
    newFileName = file_naming_policy(obj.FileNaming, fileName);
    dataFileExt = globals.get.DataFileExt;
    newFileName = [newFileName dataFileExt];
    
else
    
    newFileName = obj.FileName;
    
end

readEvents = obj.ReadEvents;

%% Read header
if verbose,
    fprintf([verboseLabel 'Reading header...']);
end

hdr = read(fileName, 'SignalType', obj.SignalType, 'verbose', false);
dateFormat  = globals.get.DateFormat;
timeFormat  = globals.get.TimeFormat;
startDate   = datestr(datenum(hdr.start_date, 'dd.mm.yy'), dateFormat);
startTime   = datestr(datenum(hdr.start_time, 'HH.MM.SS'), timeFormat);

if strcmpi(hdr.edfplus_type, 'edf+d'),
    error('edfplus:NotSupported', ...
        'Discontinuous EDF+ files are not supported')
end

% By default all channels carrying the desired signal types will be picked
if isempty(obj.Channels),
    channels = find(~hdr.is_annotation);
else
    channels = obj.Channels;
end

sr = max(hdr.sr(channels));

% Sensors information
if isempty(obj.Sensors)
    sensorArray = labels2sensors(hdr.label(channels));
else
    sensorArray = obj.Sensors;
end
% How to find the locations??

if verbose,
    fprintf(['\n\n' verboseLabel 'Done reading header\n\n']);
end

%% Read events
if readEvents
    
    if verbose,
        fprintf([verboseLabel 'Reading events...']);
    end
    
    if hdr.nrec > 10000,
        readAnnotVerbose = true;
        warning(['File has as many as %d records (%s seconds each). ' ...
            'It''s going to take a while ...'], hdr.nrec, num2str(hdr.dur));
    else
        readAnnotVerbose = verbose;
    end
    [~, ~, eventArray, samplTime] = read(fileName, ...
        'onlyannotations', true, 'hdr', hdr, 'verbose', readAnnotVerbose);
    
    if verbose,
        fprintf('[done]\n\n');
    end
    if ~isempty(eventArray),
        eventArray = event.from_tal(eventArray);
    end
    
else
    
    eventArray = [];
    samplTime = 0:hdr.dur:(hdr.dur*(hdr.nrec-1));
    
end

%% Read/write signal values
if verbose,
    fprintf([verboseLabel 'Writing data to binary file...']);
end

spr = max(hdr.spr(channels));

if ~isempty(obj.EpochStartTime) || ~isempty(obj.EpochEndTime),

    if isempty(obj.EpochStartTime),
        startTime = samplTime(1);
    else
        startTime = obj.EpochStartTime;
    end
    
    if isempty(obj.EpochEndTime),
        endTime = samplTime(end);
    else
        endTime = obj.EpochEndTime;
    end
    
    % Convert time range to records range
    recOnset     = samplTime(1:spr:end);
    obj.EpochStartRec = find(recOnset >= startTime, 1);
    
    if isempty(obj.EpochStartRec),
        startRec = hdr.nrec;
    else
        startRec = obj.EpochStartRec;
    end
    
    endRec = find(recOnset < endTime, 1, 'last');
    
    if isempty(endRec),
        endRec = hdr.nrec;
    end
    
    begSample = floor((startTime-recOnset(startRec))*sr)+1;
    endOffset = spr - min(ceil((endTime-recOnset(endRec))*sr), spr);
    
elseif ~isempty(obj.EpochStartRec) || ~isempty(obj.EpochEndRec),
    
    if isempty(obj.EpochStartRec),
        startRec = 1;
    else
        startRec = obj.EpochStartRec;
    end
    
    if isempty(obj.EpochEndRec),
        endRec = hdr.nrec;
    else
        endRec = obj.EpochEndRec;
    end
    
    begSample = 1;
    endOffset = 0;
    
else
    
    startRec  = 1;
    endRec    = hdr.nrec;
    begSample = 1;
    endOffset = 0;
    
end

ns = length(channels);
chunkSize = globals.get.ChunkSize;
chunkSize = floor(chunkSize/(sizeof(obj.Precision)*ns)); % in samples
chunkSize = floor(chunkSize/spr); % in data records

boundary = startRec:chunkSize:endRec;
if length(boundary)<2 || boundary(end) < endRec,
    boundary = [boundary,  endRec+1];
else
    boundary(end) = boundary(end)+1;
end

nbChunks = length(boundary) - 1;

fid = safefid(newFileName, 'w');

% First chunk
[~, dat] = read(fileName, ...
    'startRec', boundary(1), ...
    'endRec',   boundary(2)-1, ...
    'verbose',  false, ...
    'hdr',      hdr);

if nbChunks > 1,
    dat = dat(:, begSample:end);
else
    dat = dat(:, begSample:end-endOffset);
end
fwrite(fid, dat(:), obj.Precision);

% Middle chunks
tinit = tic;
for chunkItr = 2:(nbChunks-1)
    
    [~, dat] = read(fileName, ...
        'startRec', boundary(chunkItr),...
        'endRec',   boundary(chunkItr+1)-1, ...
        'verbose',  false, ...
        'hdr',      hdr);
    fwrite(fid, dat(:), obj.Precision);
    
    if verbose,
        eta(tinit, (nbChunks-1), chunkItr);
    end
    
end

% Last chunk
if nbChunks > 1,
    
    [~, dat] = read(fileName, ...
        'startRec',     boundary(nbChunks), ...
        'endRec',       boundary(nbChunks+1)-1, ...
        'verbose',      false, ...
        'hdr',          hdr);
    
    dat = dat(:, 1:end-endOffset);
    fwrite(fid, dat(:), obj.Precision);
    
end

if verbose,
    fprintf('[done]\n\n');
end


%% Generate the output physioset object
physiosetArgs = construction_args_physioset(obj);
pObj = physioset(newFileName, size(dat,1), physiosetArgs{:}, ...
    'StartDate',    startDate, 'StartTime', startTime, ...
    'Event',        eventArray, ...
    'Sensors',      sensorArray, ...
    'SamplingRate', max(hdr.sr), ...
    'Header',       hdr);


