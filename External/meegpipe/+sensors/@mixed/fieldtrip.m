function str = fieldtrip(obj)
% FIELDTRIP - Conversion to Fieldtrip structure

if nb_sensors(obj) < 1,
    str =[];
    return;
end

str = [];
for i = 1:numel(obj.Sensor)
    str = [str(:); fieldtrip(obj.Sensor{i})];
end

end