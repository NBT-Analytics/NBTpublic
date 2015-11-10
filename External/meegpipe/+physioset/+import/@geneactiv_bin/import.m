function physiosetObj = import(obj, varargin)
% import - Imports Geneactiv's .bin files
%
% ## Notes:
%
%   * Compressed .gz files are supported.
%
% See also: geneactiv_bin

import physioset.import.geneactiv_bin;
import pset.globals;
import mperl.split;
import physioset.physioset;
import physioset.event.event;
import misc.sizeof;
import misc.eta;
import pset.file_naming_policy;
import exceptions.*
import misc.decompress;
import io.geneactiv.read;
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
[data, time, hdr] = read(fileName, 'DataProps', 'Temperature');
xyz     = data(:, 1:3);
light   = data(:, 4);
temp    = data(:,6);
if verbose,
    fprintf('[done]\n\n')
end
hdr.info = geneactiv_bin.process_bin_header(hdr.info);

%% Read sensor information
if verbose,
    fprintf([verboseLabel 'Creating sensor array ...']);
end

sensorsAcc   = [];
sensorsLight = [];
sensorsTemp  = [];

if ~isempty(xyz) && ~all(xyz(:) < eps),
    sensorsAcc = sensors.accelerometer(...
        'Label', {'Acc X', 'Acc Y', 'Acc Z'}, ...
        'PhysDim', hdr.info.capabilities.accelerometer_units);
end

if ~isempty(light) && ~all(light(:) < eps),
    sensorsLight = sensors.light('Label', 'Light', ...
        'PhysDim', hdr.info.capabilities.light_meter_units);
end

if ~isempty(temp) && ~all(temp(:) < eps),
    tempUnit = hdr.info.capabilities.temperature_sensor_units;
    
    if ~isempty(strfind(tempUnit, 'C')),
        tempUnit = 'degC';
    else
        tempUnit = 'degF';
    end
    
    sensorsTemp = sensors.temp('Label', 'Temp', ...
        'PhysDim', tempUnit);
end

sens = sensors.mixed(sensorsAcc, sensorsLight, sensorsTemp);
    
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

nbSamples = max([size(xyz, 1), size(light, 1), size(temp,1)]);

if nbSamples < 1,
    error('No data samples were found');
end

data = [xyz light temp]';
fwrite(fid, data(:), obj.Precision);

if verbose,
    fprintf('[done]\n\n');
end

%% Generate output object
if verbose,
    fprintf('%sGenerating a physioset object...', verboseLabel);
end
sampleRate = hdr.info.fs;

recordTime = hdr.info.start_time;

mat = regexpi(recordTime, ...
    ['(?<year>\d{4}+)-(?<month>\d\d)-(?<day>\d\d)\s+', ...
    '(?<hours>\d\d):(?<mins>\d\d):(?<secs>\d\d):', ...
    '(?<dec>[^+]+)'], ...
    'names');

startTime = DateStr2Num([mat.year mat.month mat.day ...
    'T' mat.hours mat.mins mat.secs '.' mat.dec], 300);

samplingTime = time;

if ~strcmp(datestr(startTime, 'dd-mm-yyyy HH:MM:SS'), ...
        datestr(samplingTime(1), 'dd-mm-yyyy HH:MM:SS')),
    
   error('geneactiv_bin:Inconsistent', ...
       'Recording start time does not match first sampling instant');
   
end

% There might be a small delay between the official start time and the
% actual time of the first sample. We use the latter as the recording start
% time
startTime = samplingTime(1);

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



end



