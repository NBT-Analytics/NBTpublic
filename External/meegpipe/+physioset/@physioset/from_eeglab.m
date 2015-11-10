function physObj = from_eeglab(str, varargin)
% FROM_EEGLAB - Physioset construction from EEGLAB structure
%
% import physioset.
% physObj = physioset.from_eeglab(str, 'key', value, ...)
%
% Where
%
% STR is an EEGLAB structure
%
% PHYSOBJ is a physioset object
%
%
% ## Accepted (optional) key/value pairs:
%
%       Filename : A valid file name (a string).
%           Default: ''
%           The name of the memory-mapped file to which the generated
%           physioset will be linked.
%
%       SensorClass : A cell array of strings.
%           Default: repmat({'eeg', str.nbchan, 1)
%           The classes of the data sensors. Valid types are: eeg, meg,
%           physiology
%
%
% ## References
%
% [1] EEGLAB: http://sccn.ucsd.edu/eeglab/
%
% See also: physioset.physioset, physioset.physioset.eeglab

import misc.process_arguments;
import physioset.physioset;
import pset.globals;
import physioset.event.event;
import physioset.event.std.trial_begin;
import physioset.import.matrix;

% Error checking
if ~isstruct(str) || ~isfield(str, 'data') || ...
        ~isfield(str, 'chanlocs'),
    ME = InvalidArgument('str', 'An EEGLAB struct is expected');
    throw(ME);
end

% Optional input arguments
opt.SensorClass  = {};
opt.FileName     = '';
[~, opt] = process_arguments(opt, varargin);

opt.FileName    = check_file_name(str, opt.FileName);
opt.SensorClass = check_sensor_class(str, opt.SensorClass);

[sensorArray, ordering] = sensors.eeglab_to_sensor_array(str, opt.SensorClass);

if ~isempty(str.data),
    str.data = str.data(ordering, :, :);
end

eventArray = event.from_eeglab(str.event);

% If it is an epoched dataset we need to add some extra events marking the
% onsets and durations of such epochs
if str.trials > 1,
   nbSamples = str.pnts*str.trials;
   trialEvents = trial_begin(1:str.pnts:nbSamples, 'Duration', str.pnts);
   eventArray = [eventArray(:); trialEvents(:)];
end

data = reshape(str.data, str.nbchan, str.pnts*str.trials);
importer = matrix(str.srate, ...
    'FileName',     opt.FileName, ...
    'Sensors',      sensorArray);
physObj  = import(importer, data);

set_name(physObj, str.setname);
add_event(physObj, eventArray);

% This is handy when converting back to EEGLAB format
str.data    = [];
str.icaact  = [];
set_meta(physObj, 'eeglab', str);

end


%
% Helper functions ########################################################
%

% Ensure that the pset file is valid
function newFileName = check_file_name(str, desiredFileName)
import misc.is_valid_filename;

fileExt = pset.globals.get.DataFileExt;

if nargin > 1 && ~isempty(desiredFileName) && is_valid_filename(desiredFileName),
    [path, name] = fileparts(desiredFileName);
    newFileName = mperl.file.spec.catfile(path, [name fileExt]);
    return;
end

if ~isempty(str.filepath),
   filePath = str.filepath;
else
   filePath = pset.session.instance.Folder;
end
setName = regexprep(str.setname, '[^\w]', '');
newFileName = mperl.file.spec.catfile(filePath, setName);
if ~is_valid_filename(newFileName)
    newFileName = pset.pset.file_naming_policy('Random');
end
[path, name] = fileparts(newFileName);
newFileName = mperl.file.spec.catfile(path, [name fileExt]);

end

% Check the consistency of the SensorClass parameter
function sensorClass = check_sensor_class(str, desiredSensorClass)

if ~iscell(desiredSensorClass), desiredSensorClass = {desiredSensorClass}; end
if nargin > 1 && ~isempty(desiredSensorClass)
    if numel(desiredSensorClass) == 1,
        sensorClass = repmat(desiredSensorClass, str.nbchan, 1);
        return;
    elseif numel(desiredSensorClass) ~= str.nbchan,
        error(['The number of elements of SensorClass (%d) does not match ' ...
               'the number of channels (%d)'], ...
               numel(desiredSensorClass), str.nbchan);
    end
end

sensorClass = repmat({'eeg'}, str.nbchan, 1);
end