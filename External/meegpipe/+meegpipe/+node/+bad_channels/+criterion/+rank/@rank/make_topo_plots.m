function hFig = make_topo_plots(sens, xvarLog, idx)

import meegpipe.node.globals;
import plotter.topography.topography;

visible = globals.get.VisibleFigures;

% Plot variance topography using a topography plotter object
topoPlotter = topography(...
    'Visible',   visible, ...
    'MapLimits', [min(xvarLog) max(xvarLog)]);

h = plot(topoPlotter, sens, xvarLog);

colorbar(h);

%set_colorbar_title(h, 'String', 'dB');

set_sensor_markers(h, 'Visible', 'on');

set_sensor_markers(h, idx, ...
    'Marker', 'o', ...
    'Color', 'red', ...
    'MarkerFaceColor', 'white', ...
    'MarkerSize',  6);

set_sensor_labels(h, idx, 'Visible', 'on');

set_sensor_labels(h, idx, 'Visible', 'on');

set_sensor_labels(h, idx, ...
    'FontWeight',       'bold', ...
    'Color',            'black', ...
    'EdgeColor',        'black', ...
    'BackgroundColor',  'white');

set_extra_labels(h, 'Visible', 'off');

set_extra_markers(h, 'Visible', 'off');

hFig = h;

end