function obj = set_extra_labels(obj, varargin)

if nargin < 2 || isempty(varargin{1}),
    return;
end

if isnumeric(varargin{1}),    
    set(obj.ExtraLabels(varargin{1}), varargin{2:end});
else
    set(obj.ExtraLabels, varargin{:});
end

end