function obj = copy_sensors_history(obj, otherObj)

if isa(otherObj, 'sensors.sensors'),
    obj.SensorsHistory = [obj.SensorsHistory {otherObj}];
else
    obj.SensorsHistory = otherObj.SensorsHistory;
end

end