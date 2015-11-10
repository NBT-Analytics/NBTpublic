function value = get_sensor_labels(obj, varargin)

if nargin < 2 || isempty(varargin{1}),
    return;
end

if isnumeric(varargin{1}),    
    value = get(obj.SensorLabels(varargin{1}), varargin{2:end});
else
    value = get(obj.SensorLabels, varargin{:});
end

end