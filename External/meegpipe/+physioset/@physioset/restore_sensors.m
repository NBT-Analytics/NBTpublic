function obj = restore_sensors(obj, proj)

import datahash.DataHash;
import misc.obj2struct;

if isempty(obj.SensorsHistory),
    warning('physioset:NoSensorHistory', ...
        'There are not previous sensors to be restored');
    return;
end

% Look in the sensors history for a sensor array of the right dimensions
% and just pick the latest match. Simple but should work in most use-cases.
sensorsDim = proj.DimIn;
for i = numel(obj.SensorsHistory):-1:1
    if nb_sensors(obj.SensorsHistory{i}) == sensorsDim,
        obj.Sensors = obj.SensorsHistory{i};
        obj.SensorsHistory(i) = [];        
        break;
    end
end

end