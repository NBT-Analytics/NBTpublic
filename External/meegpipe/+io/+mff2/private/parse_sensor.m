function [str, name] = parse_sensor(filename)

import mperl.split;

res = perl('+io/+mff2/private/parse_sensors.pl', filename);

sensors = split(char(10), res);

% Name of the sensor net
name = sensors{1};
sensors(1) = [];

str = struct('number', [], 'type', [], 'x', [], 'y', [], 'z', []);
str = repmat(str, numel(sensors), 1);

for i = 1:numel(sensors)
   thisSensor    = split(';',sensors{i}); 
   str(i).number = thisSensor{1};
   str(i).type   = thisSensor{2};
   str(i).x      = thisSensor{3};
   str(i).y      = thisSensor{4};
   str(i).z      = thisSensor{5};
end


end