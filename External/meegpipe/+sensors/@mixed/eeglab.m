function str = eeglab(obj)
% EEGLAB - Conversion to EEGLAB structure

if nb_sensors(obj) < 1,
    str =[];
    return;
end

str = [];
for i = 1:numel(obj.Sensor)
    str = [str(:); eeglab(obj.Sensor{i})];
end

end