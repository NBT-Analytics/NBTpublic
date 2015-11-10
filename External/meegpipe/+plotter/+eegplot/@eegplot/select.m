function obj = select(obj, idx)

if isempty(idx),
    idx = 1:nb_plots(obj);
end

obj.OverlaySelection = idx;

end