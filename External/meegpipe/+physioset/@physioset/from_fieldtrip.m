function physObj = from_fieldtrip(str, varargin)
% FROM_FIELDTRIP - Construction from FIELDTRIP structure
%
% import physioset.
% obj = physioset.from_fieldtrip(str);
% obj = physioset.from_fieldtrip(str, 'key', value, ...)
%
% Where
%
% str is a Fieldtrip struct
%
% OBJ is an eegset object
%
%
% ## Accepted (optional) key/value pairs:
%
%       Filename : A valid file name (a string). Default: ''
%           The name of the memory-mapped file to which the generated
%           physioset will be linked.
%
%
% See also: from_pset, from_eeglab


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


%% Error checking
if ~isstruct(str) || ~isfield(str, 'fsample'),
    ME = InvalidArgument('str', 'A Fieldtrip struct is expected');
    throw(ME);
end


%% Optional input arguments
opt.FileName    = '';

[~, opt] = process_arguments(opt, varargin);

if isempty(opt.FileName),        
    filename = session.instance.tempname;
    if is_valid_filename(filename),
        opt.FileName = filename;
    end
end

if isempty(opt.FileName),
    opt.FileName = pset.file_naming_policy('Random');
elseif ~is_valid_filename(opt.FileName),
    error('The provided file name is not valid');
end

fileExt = globals.get.DataFileExt;
[path, name] = fileparts(opt.FileName);
opt.FileName = catfile(path, [name fileExt]);

%% Sensor information
if isfield(str, 'grad'),  
    sensorsObj = sensors.meg.from_fieldtrip(str.grad, str.label); 
elseif isfield(str, 'elec'),
    sensorsObj = sensors.eeg.from_fieldtrip(str.elec, str.label);
else
    warning('physioset:MissingSensorInformation', ...
        ['Fieldtrip structure does not contain sensor information:' ...
        'Assuming vanilla EEG sensors.']);
    sensorsObj = sensors.eeg('Label', str.label);  
end

% Create an event per trial
nEvents = numel(str.trial);
ev = repmat(event, nEvents, 1);
if isfield(str, 'cfg') && isfield(str.cfg, 'event'),
    % Events already existing in the fieldtrip structrure
    % If there are trials, then we need to fix the timings of these
    % events later
    origEv = event.from_fieldtrip(str.cfg.event);
    % Fall these events within any of the trials? If not, ignore them!
    inTrials = false(1, numel(origEv));
    evSample = get_sample(origEv);
    hasEvents = true;
else
    hasEvents = false;
end
durAll = 0;

for i = 1:numel(str.trial),
  offset = -find(str.time{i} >= 0, 1)+1;
  if offset>=0,
    offset = round(offset/str.fsample);
  end
  sample = -offset + 1 + durAll;
  dur    = size(str.time{i}, 2);
 
  thisEvent  = trial_begin(sample, ...  
    'Offset',       offset, ...
    'Duration',     dur);
  
  thisEvent = set_meta(thisEvent, ...
    'sampleinfo',   str.sampleinfo(i, :), ...
    'time',         str.time{i});
  
  if isfield(str, 'trialinfo')
    thisEvent = set_meta(thisEvent, ...
      'trialinfo', str.trialinfo(i, :));
  else
    thisEvent = set_meta(thisEvent, ...
      'trialinfo', []);
  end
    
  ev(i) = thisEvent;
  
  if hasEvents
      % Fix the timings of events that fall within the current trial
      inThisTrial = evSample >= str.sampleinfo(i,1) & evSample <= str.sampleinfo(i,2);
      
      origEv(inThisTrial) = set_sample(origEv(inThisTrial), ...
          get_sample(origEv(inThisTrial)) - str.sampleinfo(i,1) + 1 + durAll);
      
      % Keep track of the events that do fall within a trial
      inTrials(inThisTrial) = true;
  end
  
   durAll = durAll + dur;
  
end

if hasEvents,
    % Remove those events that do not fall within any trial
    origEv(~inTrials) = [];
end

data = [str.trial{:}];

%% Use the matrix importer to generate a physioset object
importer = matrix(str.fsample, ...
    'FileName',     opt.FileName, ...
    'Sensors',      sensorsObj);
physObj  = import(importer, data);

if isfield(str, 'name'),
    dataName = str.name;
else
    dataName = 'fieldtripdata';
end

set_name(physObj, dataName);

%% Take care of the time property
if isfield(str, 'time'),
    physObj.SamplingTime = [str.time{:}];
end

%% Take care of extra fields, unique to Fieldtrip
extraFields = {'cfg', 'hdr', 'sampleinfo', 'trialinfo'};
for i = 1:numel(extraFields),
  if isfield(str, extraFields{i})
    set_meta(physObj, extraFields{i}, str.(extraFields{i}));
  end
end

%% Add to the physioset the trial events and the data events
add_event(physObj, ev); 

if hasEvents,
    add_event(physObj, origEv);
end

end
