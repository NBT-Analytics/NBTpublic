function obj = set_sensors(obj, value)

import exceptions.Inconsistent;
import exceptions.InvalidPropValue;

if nb_sensors(value) ~= size(obj, 1),
    throw(Inconsistent(...
        sprintf(['Number of provided sensors (%d) does not match number ' ...
        'of channels in physioset (%d)'], nb_sensors(value), obj.NbDims)));
end

if ~isempty(obj.DimSelection) && numel(obj.DimSelection) ~= obj.NbDims,
    throw(InvalidPropValue('Sensors', ...
        'Cannot set sensors to physioset with active selections'));
end

if ~isempty(obj.DimSelection),
    [~, I] = sort(obj.DimSelection, 'ascend');
    value = subset(value, I);   
end

obj.Sensors = value;

end