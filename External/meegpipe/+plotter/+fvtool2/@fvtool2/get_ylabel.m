function val = get_ylabel(h, varargin)

idx = h.Selection;
figH = h.FvtoolHandle;
val = cell(numel(idx));
for i = 1:numel(idx)   
    thisAxes = findobj(figH(idx(i)), 'Tag', 'fvtool_axes_1');
    if ~isempty(thisAxes),
        thisTitle = get(thisAxes, 'YLabel');
        if ~isempty(thisTitle),
            val{i} = get(thisTitle, varargin{:});
        end
    end
end

if numel(val) == 1,
    val = val{1};
end


end