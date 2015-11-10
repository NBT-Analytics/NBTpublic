function sensors = read_pns_sensors(filename)

import mperl.config.inifiles.inifile;

% might replace parse_sensor_info

orig = parse_pns_sensor(filename);

name   = cell(numel(orig), 1);
unit   = cell(numel(orig), 1);

for i = 1:numel(orig)
    sensorItr = orig(i);       
    name{i} = sensorItr.name;    
    unit{i} = sensorItr.unit;
end

sensors.name = name;
sensors.unit = unit;

end