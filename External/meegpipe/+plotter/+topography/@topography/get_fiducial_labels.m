function value = get_fiducial_labels(obj, varargin)

if nargin < 2 || isempty(varargin{1}),
    return;
end

if isnumeric(varargin{1}),    
    value = get(obj.FiducialLabels(varargin{1}), varargin{2:end});
else
    value = get(obj.FiducialLabels, varargin{:});
end

if ~iscell(value),
    value = {value};
end


end