function h = set_xlabel(h, varargin)

idx = h.Selection;
figH = h.FvtoolHandle;
for i = 1:numel(idx)   
    thisAxes = findobj(figH(idx(i)), 'Tag', 'fvtool_axes_1');
    if ~isempty(thisAxes),
        thisTitle = get(thisAxes, 'XLabel');
        if ~isempty(thisTitle),
            set(thisTitle, varargin{:});
        end
    end
end

end