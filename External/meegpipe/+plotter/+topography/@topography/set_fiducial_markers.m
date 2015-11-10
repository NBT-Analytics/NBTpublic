function obj = set_fiducial_markers(obj, varargin)

if nargin < 2 || isempty(varargin{1}),
    return;
end

if isnumeric(varargin{1}),    
    set(obj.FiducialMarkers(varargin{1}), varargin{2:end});
else
    set(obj.FiducialMarkers, varargin{:});
end

end