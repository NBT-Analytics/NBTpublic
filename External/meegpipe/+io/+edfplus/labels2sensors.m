function sensorArray = labels2sensors(labels)
% LABELS2SENSORS - Convert sensor labels to sensors object
%
% Only two types of sensors will be considered: EEG and physiology
% (anything that is not EEG)
%
% See also: edfplus

import io.edfplus.signal_types;
import misc.strtrim;
import sensors.eeg;
import sensors.meg;
import sensors.physiology;
import sensors.mixed;

edfTypes = signal_types;


%% Extract sensor type and specification
regex1 = '^(?<type>[^\s]+)[.]*';
regex2 = '^(?<type>\w+)[.]*\s+(?<spec>\w+)';

type = cell(size(labels));
spec = cell(size(labels));
newLabels = cell(size(labels));

for i = 1:numel(labels)
    
    newLabels{i} = strtrim(labels{i});
    match1 = regexp(newLabels{i}, regex1, 'names');
    match2 = regexp(newLabels{i}, regex2, 'names');
    
    if isempty(match1) || ~ismember(match1.type, edfTypes),
        type{i} = 'Unknown';
        spec{i} = regexprep(newLabels{i}, '[^\w]+', '-');
    elseif isempty(match2),
        type{i} = match1.type;
        spec{i} = '';
    else
        type{i} = match1.type;
        spec{i} = match2.spec;
    end
    
    if isempty(spec{i}),
        tmp = type{i};
    else
        tmp = sprintf('%s %s', type{i}, spec{i});
    end
    
    %% Enforce unique labels
    count = 0;
    while ismember(tmp, newLabels(1:i-1)),
        count = count + 1;
        tmp = sprintf('%s %s %d', type{i}, spec{i}, count);
    end
    
    newLabels{i} = tmp;
    
end


%% Process EEG sensors
isEEG = cellfun(@(x) strcmp(x, 'EEG'), type);
eegSensors = eeg.guess_from_labels(newLabels(isEEG));

if any(~isEEG),
    
    if find(isEEG(:), 1, 'last') > find(~isEEG(:), 1, 'first'),
        error('Something is wrong');
    end
    
    physSensors = physiology(...
        'Label',        newLabels(~isEEG), ...
        'OrigLabel',    labels(~isEEG));    
else
    physSensors = [];
end

if isempty(physSensors) &&  ~isempty(eegSensors),
    sensorArray = eegSensors;
elseif isempty(eegSensors) && ~isempty(physSensors),
    sensorArray = physSensors;
else
    sensorArray = sensors.mixed(eegSensors, physSensors);
end

    

end