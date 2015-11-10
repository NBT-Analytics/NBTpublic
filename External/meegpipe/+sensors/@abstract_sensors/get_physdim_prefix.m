function [prefix, power] = get_physdim_prefix(obj)


import io.edfplus.signal_types;
import io.edfplus.dimension_prefixes;
import sensors.abstract_sensors

% Valid prefixes and corresponding powers
[validPrefix, validPower] = dimension_prefixes;

% What are the basic units of each sensor?
basicUnits = get_physdim_unit(obj);

physDim = get_physdim(obj);

% Guess the basic units of each sensor
prefix = cell(nb_sensors(obj), 1);
power  = zeros(nb_sensors(obj), 1);
for sensorItr = 1:nb_sensors(obj)
    % Pick the prefix for this sensor
    [mat, tmp] = regexpi(physDim{sensorItr}, ...
        ['(\w)' basicUnits{sensorItr} '$'], 'match', 'tokens');
    if ~isempty(mat) && ~isempty(mat{1}),
        % If there is any (valid) prefix, then save it to the output        
        validPrefixIdx = find(ismember(validPrefix, tmp{1}{1}));        
        
        if numel(validPrefixIdx) == 1,
            prefix(sensorItr) = validPrefix(validPrefixIdx);
            power(sensorItr)  = validPower(validPrefixIdx);
        else
            msg = sprintf(['Prefix %s in physical dimension %s is not ' ...
                'valid'], tmp{1}, physDim{sensorItr});
            InvalidPrefix = ...
                abstract_sensors.InvalidPropValue('Prefix', msg);
            throw(InvalidPrefix);
        end
        
    end
end



end