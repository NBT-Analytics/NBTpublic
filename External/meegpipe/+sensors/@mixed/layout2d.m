function layout = layout2d(obj)

layout = nan(nb_sensors(obj),3);

sensorCount = 0;
for i = 1:numel(obj.Sensor)
   layout(sensorCount+1:sensorCount+nb_sensors(obj.Sensor{i}),:) = ...
       layout2d(obj.Sensor{i});
   sensorCount = sensorCount + nb_sensors(obj.Sensor{i});
end


end