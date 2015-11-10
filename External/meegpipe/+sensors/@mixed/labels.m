function labelsArray = labels(obj)

labelsArray = cell(nb_sensors(obj), 1);
count = 0;
for i = 1:numel(obj.Sensor)
    thisSensors = obj.Sensor{i};
    labelsArray(count+1:count+nb_sensors(thisSensors)) = ...
        labels(thisSensors);
    count = count + nb_sensors(thisSensors);
end

end