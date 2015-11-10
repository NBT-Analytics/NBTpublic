function [y, ca, cb] = unique(x, property)
% UNIQUE - Returns unique event property values
%
% values = unique(eventArray, property)
%
% Where
%
% EVENTARRAY is an array of pset.event objects
%
% PROPERTY is a valid property of the provided event objects
%
% VALUES is a cell array with the unique values of the specified
% properties, accross the events in array EVENTARRAY
%
%
% See also: pset.event

if nargin < 2 || isempty(property),
    property = 'Type';
end

value = get(x, property);

if ischar(value) || numel(value) == 1,
    y = value;
    return;
end

if isnumeric(value),
    [y, ca, cb] = unique(value);
    return;
end

if iscell(value) && all(cellfun(@(x) isnumeric(x), value)),
    value = cell2mat(value);    
    [y, ca, cb] = unique(value);
    return;
end

if iscell(value) && all(cellfun(@(x) ischar(x), value)) || ...
        all(cellfun(@(x) isnumeric(x) && numel(x)==1, value)),
    [y, ca, cb] = unique(value); 
    return;
end

% Try to convert all event types to strings
isNumber = cellfun(@(x) isnumeric(x) && numel(x)==1, value);
idx = find(isNumber);
for i = 1:numel(idx)
   value{idx(i)} = num2str(value{idx(i)}); 
end

if all(cellfun(@(x) ischar(x), value)),
    [y, ca, cb] = unique(value);
else
    error('Event types must be strings or numeric scalars');
end

end