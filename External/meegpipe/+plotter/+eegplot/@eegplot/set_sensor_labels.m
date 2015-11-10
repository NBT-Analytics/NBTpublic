function obj = set_sensor_labels(obj, idx, value)

import plotter.cell2ticks;

yTicks = get_sensor_labels(obj);

if ischar(yTicks),
    yTicks = {yTicks};
end

if nargin < 2 || isempty(idx),
    idx = 1:numel(yTicks);
    
elseif ~isnumeric(idx),
    
    % Probably the user forgot about the idx argument -> Fix it
    value = idx;
    idx = 1:numel(yTicks);    
    
end

%% Ensure that idx is a numeric array of indices
if iscell(idx),    
    [~, idx] = ismember(idx, yTicks);
elseif ischar(idx),   
    [~, idx] = ismember(idx, yTicks);
elseif isnumeric(idx),
    % do nothing
else
   error(['The IDX argument must be a numeric index, a string ' ...
       '(a channel label), or a cell array of channel labels']); 
end

%% Modify the relevant ticks
if ischar(value), value = {value}; end

yTicks(idx) = value;

%% Convert back to char array
yTicks = cell2ticks(yTicks);
% Use an empty tick label for the first tick: idiocransies of EEGLAB
yTicks = [repmat(' ', 1, size(yTicks,2)); yTicks];
set(obj.Axes, 'YTickLabel', yTicks);

end

