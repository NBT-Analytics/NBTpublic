function idx = get_sensor_idx(obj, label)

idx = find(ismember(obj.Sensors(:,2), label));

end