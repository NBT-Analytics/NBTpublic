function physiosetObj = import(obj, varargin)
% import - Imports dimesimeter light measurements files
%
% 
% ## Notes:
%
%   * Compressed .gz files are supported.
%
% See also: dimesimeter


import pset.globals;
import mperl.split;
import physioset.physioset;
import physioset.event.event;
import misc.sizeof;
import misc.eta;
import pset.file_naming_policy;
import exceptions.*
import misc.decompress;
import io.dimesimeter.read;
import safefid.safefid;
import datestr2num.DateStr2Num;

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

%% Read the data file
if verbose,
    clear +misc/eta.m;
    fprintf([verboseLabel 'Reading %s...'], fileName);
end
% We ignore the button output
[data, time, hdr] = read(fileName);
if verbose,
    fprintf('[done]\n\n')
end

%% Read sensor information
if verbose,
    fprintf([verboseLabel 'Creating sensor array ...']);
end

isAct = ismember(hdr.label, 'act');

if any(isAct),
    sensorsAcc = sensors.accelerometer('Label', hdr.label(isAct));
    sensorsLight = sensors.light('Label', hdr.label(~isAct));
else
    sensorsAcc = [];
    sensorsLight = sensors.light('Label', hdr.label);
end

sens = sensors.mixed(sensorsLight, sensorsAcc);

% Keep ordering consistent with sensor ordering
data = [data(:, ~isAct) data(:, isAct)];
    
if verbose,
    fprintf('[done]\n\n');
end


%% Write the data values to disk
if verbose,
    fprintf('%sWriting data to %s ...', verboseLabel, newFileName);
end
fid = safefid.fopen(newFileName, 'w');
if fid < 1,
    error('Could not open %s for writing', newFileName);
end

nbSamples = size(data,1);

if nbSamples < 1,
    error('No data samples were found');
end

data  = data';
fid.fwrite(data(:), obj.Precision);

if verbose,
    fprintf('[done]\n\n');
end

%% Generate output object
if verbose,
    fprintf('%sGenerating a physioset object...', verboseLabel);
end

% Guess the sampling rate
k = floor(numel(time)/2)*2;
samplTimes = reshape(time(1:k), 2, k/2);
timeDiff = nan(1, k/2);
for i = 1:k/2
    timeDiff(i) = etime(datevec(samplTimes(2,i)), datevec(samplTimes(1,i)));
end
sampleRate = 1/mean(timeDiff);

recordTime = [datestr(time(1), 'yyyymmddTHHMMSS') '.000'];
startTime = DateStr2Num(recordTime, 300);

samplingTime = time;

physiosetArgs = construction_args_physioset(obj);
physiosetObj = physioset(newFileName, nb_sensors(sens), ...
    physiosetArgs{:}, ...
    'SamplingRate',     sampleRate, ...
    'Sensors',          sens, ...
    'StartTime',        startTime, ...
    'Header',           hdr, ...
    'SamplingTime',     samplingTime);

if verbose,
    fprintf('[done]\n\n');
end

%% Undoing stuff 

% Unset the global verbose
goo.globals.set('VerboseLabel', origVerboseLabel);

% Delete unzipped data file
if isZipped,
    delete(fileName);
end

end



