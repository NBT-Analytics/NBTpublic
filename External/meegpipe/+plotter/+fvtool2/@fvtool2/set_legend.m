function set_legend(h, varargin)

idx = h.Selection;

for i = 1:numel(idx)
    
    thisLegend = findall(h.FvtoolHandle(idx(i)), 'Tag', 'legend');
    
    if ~isempty(thisLegend),
        set(thisLegend, varargin{:});
    end
    
end

end