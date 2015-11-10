function obj = plot(obj, data, varargin)
% PLOT - Plots multidimensional time series
%
% plot(obj, data)
% plot(obj, data1, data2, data3, ...)
% plot(obj, data1, data2, ..., 'key', value, ...)
%
% Where
%
% DATA, DATA1, DATA2, ... are data matrices with N rows (channels) and K
% columns (samples). Alternatively, these can be pset.pset or
% pset.physioset objects.
%
%
% ## Accepted key/value pairs:
%
%       Events: A(n array of) pset.event object(s) or []. Default: []
%           Events to be plotted
%
% See also: plotter.eegplot,


if nargin < 2 || isempty(data),
    return;
end

%% Take care of multi-dataset case using recursion
dataCell    = cell(nargin-1, 1);
dataCell{1} = data;
count = 1;
while count <= numel(varargin) && isnumeric(varargin{count}),
    dataCell{count+1} = varargin{count};
    count = count + 1;
end
dataCell(count+1:end) = [];
varargin = varargin(count:end);

% Do some cleanup of the varargin
varargin(1:2:end) = cellfun(@(x) lower(x), varargin(1:2:end), ...
    'UniformOutput', false);

sensors = [];
toRemove = false(1, numel(varargin));
for i = 1:2:numel(varargin)
    % EEGLAB expects only lowercase
    varargin{i} = lower(varargin{i});
    switch varargin{i}
        case 'events',
            if isa(varargin{i+1}, 'physioset.event.event'),
                varargin{i+1} = eeglab(varargin{i+1});
            end
        case 'sensors'
            if isa(varargin{i+1}, 'sensors.sensors'),
                sensors = labels(varargin{i+1});
            end
            toRemove(i:i+1) = true;
        otherwise
            % do nothing
    end
end
varargin(toRemove) = [];

if count > 1, data = dataCell; end
if iscell(data),
    for i = 1:numel(dataCell)
        plot(obj, dataCell{i}, varargin{:});
    end
    
    return;
end


%% Is this a new or overlaying plot?
if isempty(obj.Figure),
    plot_new(obj, data, varargin{:});
else
    plot_overlay(obj, data, varargin{:});
end

if ~isempty(sensors),
    set_sensor_labels(obj, [], sensors);
end



end