function val = get_overlay_colors(obj)

origSelection = obj.Selection;
deselect(obj, []);
val = nan(nb_plots(obj),3);

for i = 1:nb_plots(obj),
    select(obj, i);
    val(i,:) = get_line_color(obj, 1);
end

obj.OverlaySelection = origSelection;

end