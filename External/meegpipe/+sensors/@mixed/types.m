function sensorTypes = types(obj)

sensorTypes = cell(nb_sensors(obj), 1);
count = 0;
for i = 1:numel(obj.Sensor)
    thisSensors = obj.Sensor{i};
    sensorTypes(count+1:count+nb_sensors(thisSensors)) = ...
        types(thisSensors);
    count = count + nb_sensors(thisSensors);
end

end