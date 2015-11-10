function ftripStruct = fieldtrip(varargin)
% fieldtrip - Conversion to Fieldtrip structure
%
% See: <a href="matlab:misc.md_help('+physioset/@physioset/fieldtrip.md')">misc.md_help(''+physioset/@physioset/fieldtrip.md'')</a>
%
%
% See also: eeglab

import physioset.event.event;
import physioset.deal_with_bad_data;
import misc.process_arguments;
import physioset.check_ftrip_consistency;

count = 0;
while count < numel(varargin) && ...
        isa(varargin{count+1}, 'physioset.physioset'),
    count = count + 1;
end

obj = varargin(1:count);

varargin = varargin(count+1:end);

opt.BadDataPolicy = 'reject';
[~, opt] = process_arguments(opt, varargin);

if numel(obj) > 1,
    % Merging multiple physiosets into a single ftrip structure
    ftripStruct = cell(size(obj));
    for i = 1:numel(obj)
        ftripStruct{i} = fieldtrip(obj{i}, varargin{:});
    end
    return;
end

obj = obj{1};

% Do something about the bad channels/samples
[didSelection, evIdx] = deal_with_bad_data(obj, opt.BadDataPolicy);

% Important to use method sensors here, instead of obj.Sensors. The
% latter does not have into account "data selections" and would break the
% code below.
sensorArray = sensors(obj);
if ~isempty(sensorArray),
    [group, groupIdx] = sensor_groups(sensorArray);
    if numel(group) > 1,
        ftripStruct = cell(numel(group),1);
        for i = 1:numel(group)
            select(obj, groupIdx{i});
            try
                ftripStruct{i} =  fieldtrip(obj, varargin{:});
            catch ME
                clear_selection(obj);
                rethrow(ME);
            end
            restore_selection(obj);
        end
        isEmpty = cellfun(@(x) isempty(x), ftripStruct);
        ftripStruct(isEmpty) = [];
        if numel(ftripStruct) == 1,
            ftripStruct = ftripStruct{1};
        end
        return;
    end
    if isa(sensorArray, 'sensors.eeg'),
        ftripStruct.elec  = fieldtrip(sensorArray);
        ftripStruct.label = orig_labels(sensorArray);
    elseif isa(sensorArray, 'sensors.meg'),
        ftripStruct.grad  = fieldtrip(sensorArray);
        ftripStruct.label = orig_labels(sensorArray);
    elseif isa(sensorArray, 'sensors.dummy'),
        % Use dummy EEG sensors
        warning('fieldtrip:UnsupportedSensorClass', ...
            ['Converting %s sensors into dummy EEG sensors. ' ...
            'Only MEG or EEG sensors are supported by Fieldtrip.'], ...
            class(obj.Sensors));
        sensorArray = sensors.eeg.dummy(nb_sensors(sensorArray));
        ftripStruct.elec  = fieldtrip(sensorArray);
        ftripStruct.label = orig_labels(sensorArray);
        
    else
        warning('fieldtrip:UnsupportedSensorClass', ...
            ['Cannot convert %s data to Fieldtrip format. ' ...
            'Only MEG or EEG sensors are supported by Fieldtrip.'], ...
            class(obj.Sensors));
        ftripStruct = [];
        restore_selection(obj);
        return;
    end
else
    % Assume EEG data by default
    ftripStruct.label = [];
    ftripStruct.elec  = [];
end

%% Take care of trial-based datasets (which contain trial_begin events)
if isempty(obj.Event),
    eventArray = obj.Event;
else
    eventArray = select(obj.Event, 'Type', ...
        get(physioset.event.std.trial_begin, 'Type'));
end
if numel(eventArray) < 2,
    ftripStruct.trial = {obj.PointSet(:,:)};
    ftripStruct.time  = {sampling_time(obj)};
    ftripStruct.sampleinfo = [1 size(obj.PointSet,2)];
else
    nTrials = numel(eventArray);
    
    if ~isempty(evIdx) && strcmpi(opt.BadDataPolicy, 'reject'),
        error(['Cannot use bad data policy ''reject'' in the presence ' ...
            'of bad data samples']);
    end
    
    ftripStruct.sampleinfo = nan(nTrials,2);
    tInfo = get_meta(eventArray(1), 'trialinfo');
    if ~isempty(tInfo),
        ftripStruct.trialinfo  = nan(nTrials, size(tInfo,2));
    end
    ftripStruct.time       = cell(1, nTrials);
    ftripStruct.trial      = cell(1, nTrials);
    for trialItr = 1:nTrials
        ev = eventArray(trialItr);
        begSample = ev.Sample + ev.Offset;
        endSample = begSample + ev.Duration - 1;
        ftripStruct.trial{trialItr} = obj.PointSet(:, begSample:endSample);
        
        % Samples corresponding to this trial
        trialTime  = sampling_time(obj);
        trialTime  = trialTime(begSample:endSample);     
        
        ftripStruct.time{trialItr}  = trialTime;

        thisSampleInfo = get_meta(ev, 'sampleinfo');
        if isempty(thisSampleInfo),
           thisSampleInfo = [ev.Sample + ev.Offset, ...
               ev.Sample + ev.Offset + ev.Duration];
        end
        ftripStruct.sampleinfo(trialItr,:) = thisSampleInfo;
        if ~isempty(tInfo),
            tInfo = get_meta(ev, 'trialinfo');
            ftripStruct.trialinfo(trialItr,:) = tInfo;
        end
    end
    if isfield(ftripStruct, 'trialinfo') && ...
            all(isnan(ftripStruct.trialinfo(:))),
        ftripStruct = rmfield(ftripStruct, 'trialinfo');
    end
end

ftripStruct.fsample = obj.SamplingRate;

% Other stuff that may be stored as physioset meta-properties
ftripStruct.cfg = get_meta(obj, 'cfg');
ftripStruct.hdr = get_meta(obj, 'hdr');

evArray = get_event(obj);
if ~isempty(evArray),
    evSelector = physioset.event.class_selector('Class', 'trial_begin');
    evArray = select(~evSelector, evArray);
end

if ~isempty(evArray)
    ftripStruct.cfg.event = fieldtrip(evArray);
end

% Undo temporary selections
if didSelection,
    restore_selection(obj);
    if ~isempty(evIdx),
        delete_event(obj, evIdx);
    end
end

end