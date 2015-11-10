function physObj = from_nbt(signalInfo, rawSignal, varargin)
% FROM_NBT - Construction from NBT structure
%
% import physioset.
% physObj = physioset.from_nbt(signalInfo, rawSignal, 'key', value, ...)
%
% Where
%
% SIGNALINFO is the Info structure corresponding to the raw data matrix
% RAWSIGNAL. See the documentation of the NBT toolbox for more information.
%
% PHYSOBJ is a physioset object
%
%
% ## Accepted (optional) key/value pairs:
%
%       Filename : A valid file name (a string). Default: ''
%           The name of the memory-mapped file to which the generated
%           physioset will be linked.
%
%       SensorClass : A cell array of strings
%           Default: repmat({'eeg', str.nbchan, 1)
%           The classes of the data sensors. Valid types are: eeg, meg,
%           physiology.
%
%
% ## References
%
% [1] The Neurophysiological Biomarker Toolbox (NBT): http://www.nbtwiki.net/
%
%
% See also: physioset.physioset, physioset.physioset.nbt

import misc.process_arguments;
import misc.is_valid_filename;
import mperl.file.spec.catfile;
import physioset.physioset;
import pset.globals;
import physioset.event.event;
import physioset.event.std.trial_begin;
import pset.pset;
import physioset.import.matrix;
import exceptions.*;
import pset.session;

check_input_arguments(signalInfo, rawSignal);

% The physioset constructor expects channels rowwise
if size(rawSignal, 1) > size(rawSignal, 2), rawSignal = rawSignal'; end

% Optional input arguments
opt.SensorClass  = {};
opt.FileName     = '';
[~, opt] = process_arguments(opt, varargin);

opt.FileName    = check_file_name(signalInfo, opt.FileName);
opt.SensorClass = check_sensor_class(size(rawSignal, 1), opt.SensorClass);

if isfield(signalInfo.Interface, 'EEG') && ...
        isfield(signalInfo.Interface.EEG, 'chanlocs'),
    hasEEGLAB = true;
    str = signalInfo.Interface.EEG;
    [sensorArray, ordering] = sensors.eeglab_to_sensor_array(str, ...
        opt.SensorClass);
    rawSignal = rawSignal(ordering, :);
    % dirty fix:
    eventArray = event.from_eeglab(str.event);
   
    % If it is an epoched dataset we need to add some extra events marking the
    % onsets and durations of such epochs
    if str.trials > 1,
        nbSamples = str.pnts*str.trials;
        trialEvents = trial_begin(1:str.pnts:nbSamples, 'Duration', str.pnts);
        eventArray = [eventArray(:); trialEvents(:)];
    end
else
    hasEEGLAB = false;
    sensorArray = sensors.eeg.dummy(size(rawSignal, 1));
    eventArray = [];
end

importer = matrix(signalInfo.converted_sample_frequency, ...
    'FileName',     opt.FileName, ...
    'Sensors',      sensorArray);
physObj  = import(importer, rawSignal);

set_name(physObj, signalInfo.file_name);
add_event(physObj, eventArray);

% This is handy when converting back to NBT format (or to EEGLAB format)
if hasEEGLAB,
    set_meta(physObj, 'eeglab', signalInfo.Interface.EEG);
end
set_meta(physObj, 'nbt', signalInfo);

end


%
% Helper functions ########################################################
%

function check_input_arguments(signalInfo, rawSignal)
import exceptions.*;
if ~isa(signalInfo, 'nbt_Info'),
    ME = InvalidArgument('signalInfo', ...
        'An NBT SignalInfo struct was expected');
    throw(ME);
end
if ~isnumeric(rawSignal)
    ME = InvalidArgument('rawSignal', ...
        'A numeric data matrix was expected');
    throw(ME);
end

end

% Ensure that the pset file is valid
function newFileName = check_file_name(str, desiredFileName)
import misc.is_valid_filename;

fileExt = pset.globals.get.DataFileExt;

if nargin > 1 && ~isempty(desiredFileName) && is_valid_filename(desiredFileName),
    [path, name] = fileparts(desiredFileName);
    newFileName = mperl.file.spec.catfile(path, [name fileExt]);
    return;
end

filePath = '';
if ~isempty(str.Interface) && isfield(str.Interface, 'EEG'),
   filePath = str.Interface.EEG.filepath;
end
if isempty(filePath)
   filePath = pset.session.instance.Folder;
end
[~, dataName] = fileparts(str.file_name); 
dataName = regexprep(dataName, '[^\w]', '');
newFileName = mperl.file.spec.catfile(filePath, dataName);
if ~is_valid_filename(newFileName)
    newFileName = pset.pset.file_naming_policy('Random');
end
[path, name] = fileparts(newFileName);
newFileName = mperl.file.spec.catfile(path, [name fileExt]);

end

% Check the consistency of the SensorClass parameter
function sensorClass = check_sensor_class(N, desiredSensorClass)

if ~iscell(desiredSensorClass), desiredSensorClass = {desiredSensorClass}; end
if nargin > 1 && ~isempty(desiredSensorClass)
    if numel(desiredSensorClass) == 1,
        sensorClass = repmat(desiredSensorClass, N, 1);
        return;
    elseif numel(desiredSensorClass) ~= N,
        error(['The number of elements of SensorClass (%d) does not match ' ...
               'the number of channels (%d)'], numel(desiredSensorClass), N);
    end
end

sensorClass = repmat({'eeg'}, N, 1);
end