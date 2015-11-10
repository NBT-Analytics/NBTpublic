function obj = deselect(obj, idx)

if isempty(idx),
    idx = 1:nb_plots(obj);
end

obj.OverlaySelection = setdiff(obj.Selection, idx);

end