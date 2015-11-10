function h = set_title(h, varargin)

figH = h.FvtoolHandle;
idx = h.Selection;
for i = 1:numel(idx)   
    thisAxes = findobj(figH(idx(i)), 'Tag', 'fvtool_axes_1');
    if ~isempty(thisAxes),
        thisTitle = get(thisAxes, 'Title');
        if ~isempty(thisTitle),
            set(thisTitle, varargin{:});
        end
    end
end

end