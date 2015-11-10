function val = get_legend(h, varargin)

idx = h.Selection;
figH = h.FvtoolHandle;
val = cell(numel(idx));
for i = 1:numel(idx)   
   thisAxes = findobj(figH(idx(i)), 'Tag', 'fvtool_axes_1');
   if ~isempty(thisAxes),
       val{i} = get(legend(thisAxes), varargin{:});
   end
end

if numel(val) == 1,
    val = val{1};
end

end