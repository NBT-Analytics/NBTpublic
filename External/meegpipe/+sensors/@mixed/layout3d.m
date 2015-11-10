function layout = layout3d(obj)

layout = nan(nb_sensors(obj),3);

sensorCount = 0;
for i = 1:numel(obj.Sensor)
   layout(sensorCount+1:sensorCount+nb_sensors(obj.Sensor{i}),:) = ...
       layout3d(obj.Sensor{i});
   sensorCount = sensorCount + nb_sensors(obj.Sensor{i});
end


end