function unit = get_physdim_unit(obj)

import io.edfplus.signal_types;
import io.edfplus.dimension_prefixes;

% Accepted basic units for each signal type
signalTypes = types(obj);
physDim     = get_physdim(obj);
basicUnits  = cell(numel(signalTypes), 1);
for i = 1:numel(basicUnits),
   [~, basicUnits(i)] = signal_types(signalTypes{i});
end

% Find out the basic units of each sensor
unit = cell(nb_sensors(obj), 1);
for sensorItr = 1:nb_sensors(obj)
   for unitItr = 1:numel(basicUnits{sensorItr}),
      mat = regexpi(physDim{sensorItr}, ...
              ['.?' basicUnits{sensorItr}{unitItr} '$']); 
      if ~isempty(mat),
          unit{sensorItr} = basicUnits{sensorItr}{unitItr};         
      end
   end
end



end