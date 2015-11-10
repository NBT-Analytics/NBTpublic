function labels = orig_labels(obj)

labels = cell(nb_sensors(obj), 1);
count = 1;
for i = 1:numel(obj.Sensor)
    thisLabels = orig_labels(obj.Sensor{i});
    labels(count:count+numel(thisLabels)-1) = thisLabels(:);
    count = count + nb_sensors(obj.Sensor{i});
end

end