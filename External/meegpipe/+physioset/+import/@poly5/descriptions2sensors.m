function sens = descriptions2sensors(descr)

eegSensLabels   = cell(1, floor(numel(descr)/2));
eegCount        = 0;
eegUnit         = '';
dummySensLabels = cell(1, floor(numel(descr)/2));
dummyCount      = 0;

isEEG = false(1, floor(numel(descr)/2));

for i = 1:floor(numel(descr)/2)
    spec = [descr((i-1)*2+1).SignalName '_' descr((i-1)*2+2).SignalName];
    if isempty(descr((i-1)*2+1).UnitName),
        % A sensor of some unknown type
        dummyCount = dummyCount + 1;
        dummySensLabels{dummyCount} = ['Unknown ' regexprep(spec, '[^\w]', '')];
    else
        eegCount = eegCount  + 1;
        isEEG(eegCount) = true;
        eegSensLabels{eegCount} = ['EEG ' regexprep(spec, '[^\w]', '')];
        if isempty(eegUnit),
            eegUnit = descr((i-1)*2+1).UnitName;
        elseif ~strcmp(eegUnit, descr((i-1)*2+1).UnitName),
            error('All EEG channels must contain data with the same units');
        end
    end
end

eegSensLabels(eegCount + 1:end) = [];
dummySensLabels(dummyCount + 1:end) = [];

diffVal = diff(isEEG);
if sum(abs(diffVal)) > 1,
    error('Channel modalities must be contiguous');
elseif max(diffVal) > 0,
    % dummy first, then EEG
    sens = sensors.mixed(...
        sensors.dummy(dummyCount, 'Label', dummySensLabels), ...
        sensors.eeg('Label', eegSensLabels, 'PhysDim', eegUnit));
elseif min(diffVal) < 0
    % EEG first
    sens = sensors.mixed(...
        sensors.eeg('Label', eegSensLabels, 'PhysDim', eegUnit), ...
        sensors.dummy(dummyCount, 'Label', dummySensLabels));
elseif all(isEEG),
    sens = sensors.eeg('Label', eegSensLabels, 'PhysDim', eegUnit);
else
    % All are dummy
    sens = sensors.dummy(dummyCount, 'Label', dummySensLabels);
end


end