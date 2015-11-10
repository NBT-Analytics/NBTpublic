function value = get_colorbar_title(obj, varargin)

hT = get(obj.Colorbar, 'Title');
value = get(hT, varargin{:});

end