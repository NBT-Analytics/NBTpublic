function value = get_fiducial_markers(obj, varargin)

if nargin < 2 || isempty(varargin{1}),
    return;
end

if isnumeric(varargin{1}),    
    value = get(obj.FiducialMarkers(varargin{1}), varargin{2:end});
else
    value = get(obj.FiducialMarkers, varargin{:});
end


end