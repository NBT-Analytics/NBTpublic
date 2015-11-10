function obj = backup_sensors(obj, sensObj)

if nargin < 2 || isempty(sensObj) || ~isa(sensObj, 'sensors.sensors'),
    obj.SensorsHistory = [obj.SensorsHistory;{obj.Sensors}]; 
else
    obj.SensorsHistory = [obj.SensorsHistory;{sensObj}];
end

end