function sensorPhysDim = get_physdim(obj)

sensorPhysDim = cell(nb_sensors(obj), 1);
count = 0;
for i = 1:numel(obj.Sensor)
    thisSensors = obj.Sensor{i};
    sensorPhysDim(count+1:count+nb_sensors(thisSensors)) = ...
        get_physdim(thisSensors);
    count = count + nb_sensors(thisSensors);
end

end