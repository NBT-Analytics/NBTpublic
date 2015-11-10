function [sensorArray, idx] = sensor_groups(obj)

sensorArray = obj.Sensor;
idx = cell(size(sensorArray));
count = 0;
for i = 1:numel(sensorArray)
    idx{i} = count+1:count+nb_sensors(sensorArray{i});
    count = count+nb_sensors(sensorArray{i});
end

end