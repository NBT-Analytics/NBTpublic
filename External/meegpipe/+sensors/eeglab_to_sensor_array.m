function [sensorArray, ordering] = eeglab_to_sensor_array(str, sensorClass)

uTypes = unique(sensorClass);

% We need to ensure that same-type sensors are correlative
count = 0;
for i = 1:numel(uTypes)
    idx = find(ismember(sensorClass, uTypes{i}));
    ordering(count+1:count+numel(idx)) = idx;
    count = count + numel(idx);
end

sensorGroups = cell(1, numel(uTypes));
if ~isempty(str.chanlocs),
    for i = 1:numel(uTypes)
        chans = str.chanlocs(ismember(sensorClass, uTypes{i}));
        constructorName = sprintf('sensors.%s.from_eeglab', lower(uTypes{i}));
        sensorGroups{i} = feval(constructorName, chans);
    end
else
    for i = 1:numel(uTypes)
        nbSensors = numel(find(ismember(sensorClass, uTypes{i})));
        constructorName = sprintf('sensors.%s.dummy', lower(uTypes{i}));
        sensorGroups{i} = feval(constructorName, nbSensors);
    end
end
if numel(sensorGroups) > 1,
    sensorArray = sensors.mixed(sensorGroups{:});
else
    sensorArray = sensorGroups{1};
end

end
