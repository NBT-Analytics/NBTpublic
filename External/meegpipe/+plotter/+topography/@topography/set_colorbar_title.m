function obj = set_colorbar_title(obj, varargin)


hT = get(obj.ColorBar, 'Title');
set(hT, varargin{:});

end