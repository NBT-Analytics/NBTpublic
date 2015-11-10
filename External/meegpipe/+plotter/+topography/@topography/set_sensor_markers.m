function obj = set_sensor_markers(obj, varargin)

if nargin < 2 || isempty(varargin{1}),
    return;
end

if isnumeric(varargin{1}),    
    set(obj.SensorMarkers(varargin{1}), varargin{2:end});
else
    set(obj.SensorMarkers, varargin{:});
end

end