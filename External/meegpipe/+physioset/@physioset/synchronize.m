function obj = synchronize(varargin)
% synchronize - Synchronize two or more physioset objects
%
% See: <a href="matlab:misc.md_help('+physioset/@physioset/synchronize.md')">misc.md_help(''+physioset/@physioset/synchronize.md'')</a>
%
% See also: timeseries, synchronize

import misc.sizeof;
import pset.file_naming_policy;
import safefid.safefid;
import misc.split_arguments;
import misc.process_arguments;
import misc.eta;
import misc.unique_filename;
import physioset.physioset;

verboseLabel = '(physioset.synchronize) ';

pObjCount = 1;
while pObjCount < nargin && isa(varargin{pObjCount+1}, 'physioset.physioset'),
    pObjCount = pObjCount + 1;
end
pObjArray = varargin(1:pObjCount);

if nargin > pObjCount,
    syncMethod = varargin{pObjCount+1};
    varargin = varargin(pObjCount+2:end);
else
    syncMethod = 'Uniform';
    varargin = {};
end

% Find out the max sampling rate
sr = max(cellfun(@(x) x.SamplingRate, pObjArray));
if strcmpi(syncMethod, 'uniform') && isempty(varargin),
    varargin = {'Interval', 1/sr};
end

[thisArgs, varargin] = split_arguments(...
    {'InterpMethod', 'FileNaming', 'FileName', 'Verbose'}, varargin);

opt.InterpMethod = 'linear';
opt.FileNaming   = 'inherit';
opt.FileName     = [];
opt.Verbose      = true;
[~, opt] = process_arguments(opt, thisArgs);

% Determine the names of the generated (imported) files
if isempty(opt.FileName),
    
    fileName    = get_datafile(pObjArray{1});
    newFileName = file_naming_policy(opt.FileNaming, fileName);
    dataFileExt = pset.globals.get.DataFileExt;
    newFileName = unique_filename([newFileName dataFileExt]);
    
else
    
    newFileName = opt.FileName;
    
end

% Get the sampling instants for the synchronized physioset
ts = cell(size(pObjArray));
for i = 1:numel(pObjArray)
    ts{i} = timeseries(pObjArray{i}(1,:), sampling_time(pObjArray{i}));
    ts{i}.TimeInfo.Units = 'seconds';
    ts{i}.TimeInfo.StartDate = get_time_origin(pObjArray{i});
end

% The first physioset will be used as reference
tsSync = ts{1};
iterNum = 0;
while (iterNum <= numel(ts))
    tsSyncTime = tsSync.Time;
    for i = 2:numel(pObjArray),
        [tsSync, ts{i}] = synchronize(tsSync, ts{i}, syncMethod, varargin{:});
    end
    if numel(tsSyncTime) == numel(tsSync.Time) && ...
            all(tsSyncTime == tsSync.Time),
        break;
    end
    tsSyncTime = tsSync.Time;
    iterNum = iterNum + 1;
end

% Convert tsSyncTime to absolute times
secsPerDay = 24*60*60;
tsSyncTime = tsSync.TimeInfo.StartDate+tsSyncTime/secsPerDay;

% Find out the dimensionality of the output physioset
dim = sum(cellfun(@(x) size(x,1), pObjArray));

% Chunk size in number of bytes
precision = pset.globals.get.Precision;
chunkSize = pset.globals.get.ChunkSize/(sizeof(precision)*dim);

% Interpolate chunk by chunk
count = 0;
tinit = tic;
fid = safefid(newFileName, 'w');
if opt.Verbose,
    fprintf([verboseLabel 'Writing synced data to %s ...'], newFileName);
end
while (count < numel(tsSyncTime)),
    % Interpolate this chunk
    first = count+1;
    last  = min(numel(tsSyncTime), count+chunkSize-1);
    if last > numel(tsSyncTime)-1000,
        last = numel(tsSyncTime);
    end
    thisTime = tsSyncTime(first:last);
    thisData = nan(dim, numel(thisTime));
    dimCount = 1;
    for i = 1:numel(pObjArray)
        [~, pTime] = get_sampling_time(pObjArray{i});
        for j = 1:size(pObjArray{i},1)
            % Interpolate jth dimension from ith physioset
            thisData(dimCount,:) = interp1(pTime, ...
                pObjArray{i}.PointSet(j,:), thisTime', opt.InterpMethod);
            dimCount = dimCount + 1;
        end
    end
    fid.fwrite(thisData(:), precision);
    if opt.Verbose,
        eta(tinit, last, numel(tsSyncTime));
    end
    count = last;
end
clear fid;

if opt.Verbose,
    fprintf('\n\n');
end

%% Generate the physioset object

sensArray = cell(size(pObjArray));
for i = 1:numel(pObjArray),
    sensArray{i} = sensors(pObjArray{i});
end
sensorsMixed = sensors.mixed(sensArray{:});

samplingTime = (tsSyncTime - tsSyncTime(1))*secsPerDay;
obj = physioset(newFileName, nb_sensors(sensorsMixed), ...
    'SamplingRate',     sr, ...
    'Sensors',          sensorsMixed, ...
    'StartTime',        tsSyncTime(1), ...
    'SamplingTime',     samplingTime);

% Add events
[~, firstTimeSync] = get_sampling_time(obj, 1);
[~, lastTimeSync] = get_sampling_time(obj, size(obj,2));
for i = 1:numel(pObjArray),
    evArray = get_event(pObjArray{i});
    for j = 1:numel(evArray),
        ev = evArray(j);
        % Find out if this event is within the synchronized range
        first = get_sample(ev)+get_offset(ev);
        last  = first+get_duration(ev)-1;
        [~, markerTime] = get_sampling_time(pObjArray{i}, first - ...
            get_offset(ev));
        [~, firstTime] = get_sampling_time(pObjArray{i}, first);
        [~, lastTime] = get_sampling_time(pObjArray{i}, last);
        if firstTime >= firstTimeSync && lastTime <= lastTimeSync,
            % Within range, so add it after modifying its timing properties
            beginSample = find(tsSyncTime >= firstTime, 1, 'first');
            markerSample = find(tsSyncTime >= markerTime, 1, 'first');
            endSample   = find(tsSyncTime <= lastTime, 1, 'last');
            ev.Sample = markerSample;
            ev.Duration = endSample-beginSample+1;
            ev.Offset = markerSample - beginSample;
            add_event(obj, ev);
        end
    end
end


end