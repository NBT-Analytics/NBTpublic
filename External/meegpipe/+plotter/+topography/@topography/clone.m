function hc = clone(h)

import plotter.get_ch_handles;
import plotter.topography.topography;

hc = topography(get_config(h));

if isempty(h.Figure),
    return;
end

hc.Figure = figure;

% Create a copy of the figure
copyobj(get(h.Figure, 'Children'), hc.Figure);


origH = get_ch_handles(h.Figure);
newH  = get_ch_handles(hc.Figure);

hc.Axes = newH(origH == h.Axes);
hc.Rim  = newH(origH == h.Rim);
set(hc.Figure, ...
    'Color',            get(h.Figure, 'Color'), ...
    'InvertHardCopy',   get(h.Figure, 'InvertHardCopy'));


end