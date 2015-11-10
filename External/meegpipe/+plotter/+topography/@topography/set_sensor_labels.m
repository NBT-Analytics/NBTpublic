function obj = set_sensor_labels(obj, varargin)

if nargin < 2 || isempty(varargin{1}),
    return;
end


if isnumeric(varargin{1}),
    
    set(obj.SensorLabels(varargin{1}), varargin{2:end});
    
else
    
    set(obj.SensorLabels, varargin{:});
    
end


end