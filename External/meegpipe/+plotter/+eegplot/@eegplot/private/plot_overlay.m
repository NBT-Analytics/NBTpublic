function obj = plot_overlay(obj, data, varargin)

import plotter.rnd_colors;

if size(data,1) ~= obj.NbDims,
    error('Number of rows does not match previous plots');
end

if obj.NbPoints ~= size(data,2),
    error('Number of columns does not match previous plots');
end

obj.Line{end+1} = ...
    copyobj(obj.Line{end}, get(obj.Line{end}(end), 'Parent'));

scaleVal = get_scale(obj);
scaleVal = scaleVal(end);
for i = 1:size(data,1)
    data(i,:) = (data(i,:) - mean(data(i,:))) + (size(data,1)-i+1)*scaleVal;
    xData = get(obj.Line{end}(i), 'XData');
    set(obj.Line{end}(i), 'YData', data(i,xData));
end
obj.ScaleVal = [obj.ScaleVal, scaleVal];

% Regenerate line colors
if prod(get(gcf, 'Color')) < 0.0001,
    background = 'dark';
else
    background = 'light';
end

% First line color returned by rnd_colors is for the main plot
lineColors = rnd_colors(nb_plots(obj), 'Background', background);

set_overlay_colors(obj, lineColors);


end