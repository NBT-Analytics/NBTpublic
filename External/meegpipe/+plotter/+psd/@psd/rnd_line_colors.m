function h = rnd_line_colors(h)
% RND_LINE_COLORS - Randomize PSD line colors
%
%
%
% See also: plotter.psd.psd

import plotter.psd.psd;
import plotter.luminance;
import misc.ismatrix;
import plotter.rnd_colors;

if prod(get(h.Figure, 'Color')) < 0.001,
    background = 'dark';
else
    background = 'light';
end

n = size(h.Line,1);
newColors = rnd_colors(n, 'Background', background);

for i = 1:size(newColors, 1),   
   set_line(h, i, 'Color', newColors(i,:));
end

% Need to run this to redraw the line shadows, if any
set_transparency(h);


end

