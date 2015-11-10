function h = set_figure(h, varargin)

idx = h.Selection;
figH = h.FvtoolHandle;
for i = 1:numel(idx)   
    set(figH(idx(i)), varargin{:});
end


end