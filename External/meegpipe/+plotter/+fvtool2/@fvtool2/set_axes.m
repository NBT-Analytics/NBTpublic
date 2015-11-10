function set_axes(h, varargin)

idx = h.Selection;
figH = h.FvtoolHandle;
for i = 1:numel(idx)   
   thisAxes = findobj(figH(idx(i)), 'Tag', 'fvtool_axes_1');
   if ~isempty(thisAxes),
       set(thisAxes, varargin{:});
   end
end

end