function physiosetObj = import(obj, varargin)
% IMPORT - Imports MFF files
%
% pObj = import(obj, fileName)
% pObjArray = import(obj, fileName1, fileName2, ...);
%
% ## Notes:
%
%   * Compressed .gz files are supported.
%
% See also: mff


import pset.globals;
import mperl.split;
import io.mff2.*
import physioset.physioset;
import physioset.event.event;
import misc.sizeof;
import misc.eta;
import pset.file_naming_policy;
import exceptions.*
import misc.decompress;
import physioset.event.std.epoch_begin;

if numel(varargin) == 1 && iscell(varargin{1}),
    varargin = varargin{1};
end

% Deal with the multi-file case
if nargin > 2
    physiosetObj = cell(numel(varargin), 1);
    for i = 1:numel(varargin)
        physiosetObj{i} = import(obj, varargin{i});
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


%% IMPORTANT: The BIOSIG toolbox includes its own version of str2double,
% which can slow down considerably mff data import. Therefore, we must get
% rid of the BIOSIG toolbox from the path. Another reason why BIOSIG should
% be within a package instead of polluting the global namespace
myPath = path;
if isunix
    myPath = split(':', myPath);
else
    myPath = split(';', myPath);
end
mustRemove = cellfun(@(x) ~isempty(strfind(x, 't200_FileAccess')), myPath);
if any(mustRemove),
    rmpath(myPath{mustRemove});
end

%% Read first block of file
if verbose,
    fprintf([verboseLabel 'Reading first data block of %s...'], ...
        fileName)
end
if ~exist(fileName, 'file'),
    [pathName, fileName] = fileparts(fileName);
    if exist([pathName filesep fileName], 'file')
        fileName = [pathName filesep fileName];
    else
        throw(InvalidArgValue('fileName', ...
            'Must be a valid (existing) file name'));
    end
end
[data, fs, fidBins] = read_data(fileName, 1, 1, [], true, false);
if ~iscell(data),
    data = {data};
end
if verbose,
    fprintf('[done]\n\n')
end

%% Read header
if verbose,
    fprintf([verboseLabel 'Reading header...']);
end
hdr = read_header(fileName);
if verbose,
    fprintf('[done]\n\n')
end
hdr.fs = fs;

% Size of a block in bytes
if ~iscell(data), data = {data}; end
blockSize = 0;
for i = 1:numel(data)
    blockSize = blockSize + sizeof(class(data{i}(1)))*numel(data{i});
end

% Number of blocks that are to be read in one time
maxMemoryChunk  = globals.get.LargestMemoryChunk;
nbBlocksPerRead = ceil(maxMemoryChunk/blockSize);

% Approximate number of blocks
lastPos = nan(1, numel(fidBins));
pos     = nan(1, numel(fidBins));
for i = 1:numel(fidBins)
    pos(i) = ftell(fidBins(i));
    fseek(fidBins(i), 0, 'eof');
    lastPos(i) = ftell(fidBins(i));
    fseek(fidBins(i), pos(i), 'bof');
end

%% Read sensor information
if verbose,
    fprintf([verboseLabel 'Reading sensor information...']);
end
[sens, fids, ext] = read_sensors(fileName);

% Fiducials
if ~isempty(fids),
    fidStr      = fids;
    fiducials   = mjava.hash;
    fiducials{fidStr.label{:}} = ...
        mat2cell(fidStr.loc, ones(size(fidStr.loc,1),1), 3);
else
    fiducials = [];
end

% Extra head surface points
if ~isempty(ext.label),
    extraStr    = ext;
    extra       = mjava.hash;
    extra{extraStr.label{:}} = ...
        mat2cell(extraStr.loc, ones(size(extraStr.loc,1),1), 3);
else
    extra = [];
end

eegSensors = sensors.eeg(...
    'Name',         hdr.signal{1}.sensorLayout, ...
    'Cartesian',    sens.loc, ...
    'OrigLabel',    sens.label, ...
    'Fiducials',    fiducials, ...
    'Extra',        extra);

% Read calibrations for eeg sensors
[gcal, ical] = read_cal(fileName);
eegSensors = set_meta(eegSensors, 'gcal', gcal);
eegSensors = set_meta(eegSensors, 'ical', ical);

% Take care of additional physiological sensors
if numel(hdr.signal) > 1,
    % Read PNS sensor information
    sens = read_pns_sensors(fileName);
    
    label = sens.name;
    unit  = sens.unit;
    
    % There could be multiplexed channels
    isMux = cellfun(@(x) ~isempty(regexp(x, 'Mux\s.+', 'once')), ...
        sens.name);
    
    muxIdx        = find(isMux);
    nbMux         = numel(muxIdx);
    muxSensors    = cell(1, nbMux);
    
    for i = 1:nbMux,
        
        muxTemplate = regexprep(label{muxIdx(i)}, '[^\s]+\s+([^\s]+$)', ...
            '$1');
        
        % Candidate MUX definition
        muxSensorsDef = ['sensors.mux.' muxTemplate];
        if ~isempty(regexp(which(muxSensorsDef), 'not found', 'once')),
            warning('MUX:UnknownMUX', ...
                'Could not find MUX definition for %s, using %s instead', ...
                muxTemplate, 'braintronics_tempmux_1012');
            muxSensorsDef = 'sensors.mux.braintronics_tempmux_1012';
        end
        
        muxSensors{i} = eval(muxSensorsDef);
        
    end
    
    label = label(~isMux);
    unit  = unit(~isMux);
    
    pnsIdx = setdiff(1:numel(sens.name), muxIdx);
    
    pnsSensors = sensors.physiology(...
        'Name',         hdr.signal{2}.pnsSetName, ...
        'Label',        label, ...
        'OrigLabel',    label, ...
        'PhysDim',      unit);
else
    pnsSensors = [];
    pnsIdx     = [];
    muxSensors = [];
    muxIdx     = [];
end

if ~isempty(pnsSensors),
    
    if ~isempty(muxSensors),
        umuxSensors = cellfun(@(x) x.UmuxSensors, muxSensors, ...
            'UniformOutput', false);
    else
        umuxSensors = {};
    end
    
    sensorsMixed = sensors.mixed(eegSensors, pnsSensors, umuxSensors{:});
    
else
    sensorsMixed = eegSensors;
end

if verbose,
    fprintf('[done]\n\n');
end

%% Read events
if verbose,
    fprintf([verboseLabel 'Reading events...']);
end
if obj.ReadEvents,
    evArray = read_events(fileName, hdr.fs, hdr.begin_time, hdr.epochs);
else
    evArray = [];
end
if verbose,
    if obj.ReadEvents,
        fprintf('[done]\n\n');
    else
        fprintf('[skipped]\n\n');
    end
end

if ~obj.ReadDataValues,
   physiosetObj = evArray;
   return;
end

%% Read data values
fid = fopen(newFileName, 'w');
if fid < 1,
    error('Could not open %s for writing', newFileName);
end

nbSamples = 0;
nbSensors = [];
try
    if verbose,
        fprintf('%sWriting data to %s...', verboseLabel, newFileName);
    end
    
    begBlock = 2;
    endBlock = begBlock + nbBlocksPerRead-1;
    
    tinit = tic;
    
    while any(cellfun(@(x) ~isempty(x), data)),
        % Re-sort the PNS sensors so that MUX sensors appear at the end
        % and unmultiplex any multiplexed data channel
        if ~isempty(muxIdx),
            umuxData = cell(numel(muxIdx), 1);
            for i = numel(muxIdx),
                umuxData{i} = unmultiplex(muxSensors{i}, ...
                    data{2}(muxIdx(i),:), hdr.fs);
            end
            tmp = data{2}(pnsIdx,:);
            
            if size(tmp, 1) == (nb_sensors(pnsSensors)+1) && ...
                    all(abs(tmp(end,:)) < eps),
                tmp(end,:) = [];
            end
            
            data{2} = [tmp; umuxData{:}];
        end
        
        if numel(data) > 1 && isempty(muxIdx)
            
            if  all(abs(data{2}(end,:)) < eps)
                % Last channel of PIB box is always zero->Remove it
                % VERY IMPORTANT: do not remove this line or this will lead to
                % the dimensionality of the sensor array differing from the
                % dimensionality of the data, which will break completely
                % method subsref() of the generated physioset
                %
                % Also important, do not do this if there are MUX channels. In
                % that case this is taken care of above.
                % Sometimes this is not necessary and that is why we check that
                % the PNS sensor array has one less sensor.
                data{2}(end,:) = [];
            end
            
            pnsSensors = subset(pnsSensors, 1:size(data{2}, 1));
            
            % Check dimensionality matches expectations
            nbMuxSensors = sum(cellfun(@(x) nb_sensors(x), muxSensors));
            if size(data{2},1) ~= nb_sensors(pnsSensors) + nbMuxSensors,
                error(['Data dimensionality does not match ' ...
                    'dimensionality of sensor array']);
            end
        end
        
        % Write data to disk
        data = cell2mat(data);
        if isempty(nbSensors),
            nbSensors = size(data,1);
        elseif size(data,1) ~= nbSensors,
            error('mff:DimMismatch', ...
                'Inconsistent data dimensionality');
        end
        nbSamples = nbSamples + size(data,2);
        fwrite(fid, data(:), obj.Precision);
        [data, ~, fidBins] = read_data(fileName, ...
            begBlock, endBlock, [], true, true);
        begBlock = begBlock + nbBlocksPerRead;
        endBlock = endBlock + nbBlocksPerRead;
        if ~iscell(data),
            data = {data};
        end
        if verbose,
            eta(tinit, lastPos(1), ftell(fidBins(1)));
        end
    end
    clear +io/+mff2/read_data; % Clear persistent block counter
    
catch ME
    fclose(fid);
    if ~isempty(fidBins),
        for i = 1:numel(fidBins),
            fclose(fidBins(i));
        end
    end
    clear +io/+mff2/read_data; % Clear persistent block counter
    clear fid fidBins;
    rethrow(ME);
end
fclose(fid);
if ~isempty(fidBins),
    for i = 1:numel(fidBins),
        fclose(fidBins(i));
    end
end
clear fid fidBins;
if verbose,
    fprintf('\n\n');
end

%% Generate output object
if verbose,
    fprintf('%sGenerating a physioset object...', verboseLabel);
end
sampleRate = hdr.fs;

recordTime = hdr.begin_time;

mat = regexpi(recordTime, ...
    ['(?<year>\d{4}+)-(?<month>\d\d)-(?<day>\d\d)T', ...
    '(?<hours>\d\d):(?<mins>\d\d):(?<secs>\d\d).', ...
    '(?<dec>[^+]+)'], ...
    'names');
startTime = [mat.hours ':' mat.mins ':' mat.secs];
startDate = [mat.day '-' mat.month '-' mat.year];

% Map events
if ~isempty(evArray) && ~isempty(obj.EventMapping),
    evArray = type2class(evArray, obj.EventMapping);
end

% Create epoch events if there is more than one epoch in this file
samplingTime = linspace(0, nbSamples/fs, nbSamples);
if numel(hdr.epochs) > 1,
    epochEvents = repmat(epoch_begin, numel(hdr.epochs), 1);
    
    epochSampl = 1;
    for i = 1:numel(epochEvents)
        epochDur      = hdr.epochs(i).end_time-hdr.epochs(i).begin_time;
        epochDurSampl = round((epochDur/1e6)*fs);
        epochTime = parse_begin_time(hdr.begin_time);
        epochTime = addtodate(epochTime, ...
            round(hdr.epochs(i).begin_time*1e-6), ... 
            'millisecond');
        epochEvents(i) = set(epochEvents(1), ...
            'Sample',   epochSampl, ...
            'Time',     epochTime, ...
            'Duration', epochDurSampl);
        
        samplingTime(epochSampl:epochSampl+epochDurSampl-1) = ...
            linspace(hdr.epochs(i).begin_time*1e-9, ...
            hdr.epochs(i).end_time*1e-9, ...
            epochDurSampl);
        
        epochSampl = epochSampl + epochDurSampl;
        
    end
    
end

% hack to deal with broken .mff files in which the sensor info does not
% match the number of data channels actually available in the .bin files.
% If Netstation crashes it may fail to save the data from PIB into a .bin
% file and therefore the sensor information should be updated to take into
% account that the PIB box channels are missing

if nbSensors ~= nb_sensors(sensorsMixed),
   if nbSensors < nb_sensors(sensorsMixed),
   warning('mff:MismatchDimVsSensors', ...
       ['Number of sensors (%d) does not match number of channels (%d):', ...
       'Picking first %d sensors'], ...
       nb_sensors(sensorsMixed), nbSensors, nbSensors);
   sensorsMixed = subset(sensorsMixed, 1:nbSensors);
   else
      error('Number of sensors does not match number of data channels'); 
   end
end

psetArgs = construction_args_pset(obj);
physiosetArgs = construction_args_physioset(obj);
physiosetObj = physioset(newFileName, nb_sensors(sensorsMixed), ...
    psetArgs{:}, ...
    physiosetArgs{:}, ...
    'SamplingRate',     sampleRate, ...
    'Sensors',          sensorsMixed, ...
    'StartDate',        startDate, ...
    'StartTime',        startTime, ...
    'Event',            evArray, ...
    'Header',           hdr, ...
    'SamplingTime',     samplingTime);

if numel(hdr.epochs) > 1,
    add_event(physiosetObj, epochEvents);
end

if verbose,
    fprintf('[done]\n\n');
end

%% Undoing stuff

% Add BIOSIG back to the path
if any(mustRemove),
    addpath(myPath{mustRemove});
end

% Unset the global verbose
goo.globals.set('VerboseLabel', origVerboseLabel);

% Delete unzipped data file
if isZipped,
    delete(fileName);
end

end



