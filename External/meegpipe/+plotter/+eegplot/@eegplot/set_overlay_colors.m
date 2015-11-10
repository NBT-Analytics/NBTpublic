function obj = set_overlay_colors(obj, colors)

origSelection = obj.Selection;
deselect(obj, []);

for i = 1:nb_plots(obj),
    select(obj, i);
    set_line_color(obj, [], colors(i, :));
end

obj.OverlaySelection = origSelection;


end