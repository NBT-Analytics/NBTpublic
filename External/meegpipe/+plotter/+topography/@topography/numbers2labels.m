function numbers2labels(h)

labelH = h.SensorLabels;

for i = 1:numel(labelH),
   set_sensor_labels(h, i, 'String', h.Sensors{i,2});   
end



end