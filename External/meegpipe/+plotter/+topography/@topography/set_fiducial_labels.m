function obj = set_fiducial_labels(obj, varargin)

if nargin < 2 || isempty(varargin{1}),
    return;
end

if isnumeric(varargin{1}),    
    set(obj.FiducialLabels(varargin{1}), varargin{2:end});
else
    set(obj.FiducialLabels, varargin{:});
end

end