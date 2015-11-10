function [str, name] = parse_pns_sensor(filename)

import mperl.split;

res = perl('+io/+mff2/private/parse_pns_sensors.pl', filename);

sensors = split(char(10), res);

% Name of the sensor net
name = sensors{1};
sensors(1) = [];

str = struct('name', '', 'unit', '');
str = repmat(str, numel(sensors), 1);

for i = 1:numel(sensors)
   thisSensor = split(';',sensors{i}); 
   str(i).name      = thisSensor{1};
   if numel(thisSensor)>1,
       str(i).unit      = thisSensor{2};   
   end
end


end