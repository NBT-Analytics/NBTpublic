function nbSensors = nb_sensors(obj)

nbSensors = 0;
for i = 1:numel(obj.Sensor),
    nbSensors = nbSensors + nb_sensors(obj.Sensor{i});
end
end
