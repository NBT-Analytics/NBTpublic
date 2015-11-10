function obj = set_extra_markers(obj, varargin)

if nargin < 2 || isempty(varargin{1}),
    return;
end

if isnumeric(varargin{1}),    
    set(obj.ExtraMarkers(varargin{1}), varargin{2:end});
else
    set(obj.ExtraMarkers, varargin{:});
end

end