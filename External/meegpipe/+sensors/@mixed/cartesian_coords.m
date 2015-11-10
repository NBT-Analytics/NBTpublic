function xyz = cartesian_coords(obj)

xyz = nan(nb_sensors(obj), 3);
count = 0;
for i = 1:numel(obj.Sensor)
    thisSensors = obj.Sensor{i};
    xyz(count+1:count+nb_sensors(thisSensors),:) = ...
        cartesian_coords(thisSensors);
    count = count + nb_sensors(thisSensors);
end

end