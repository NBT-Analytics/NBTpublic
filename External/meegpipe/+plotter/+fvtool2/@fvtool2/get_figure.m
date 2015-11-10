function val = get_figure(h, varargin)

idx = h.Selection;
figH = h.FvtoolHandle;
val = cell(numel(idx));
for i = 1:numel(idx)   
    val{i} = get(figH(idx(i)), varargin{:});   
end

if numel(val) == 1,
    val = val{1};
end


end