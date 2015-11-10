function generate_index_report(rep, data, index, bndry)
% GENERATE_INDEX_REPORT - Generates report on chopping index values
%
% See also: chopper



import meegpipe.node.globals;
import mperl.file.spec.catfile;
import misc.unique_filename;
import plot2svg.plot2svg;
import rotateticklabel.rotateticklabel;
import inkscape.svg2png;

myGallery = clone(globals.get.Gallery);

visible = globals.get.VisibleFigures;

if visible,
    visibleStr = 'on';
else
    visibleStr = 'off';
end

figure('Visible', visibleStr);

plot(index, 'r', 'LineWidth', 1*globals.get.LineWidth);

hold on;
h = plot(find(bndry), index(bndry), 'ko');
set(h, 'MarkerFaceColor', 'black');

set(gca, 'YTick', []);

chopBegin = find(bndry(1:end-1));
set(gca, 'XTick', chopBegin);

nbChops = numel(chopBegin);
labels = num2cell(1:nbChops);

labels = cellfun(@(x,y) ['chop ' num2str(x)], labels, ...
    'UniformOutput', false);
set(gca, 'XTickLabel', labels);
th = rotateticklabel(gca, 90);
set(th, 'FontSize', 8);

ylabel('Chopping index (magnitude irrelevant)');

yLim = get(gca, 'YLim');

for i = 1:numel(chopBegin)
    x0 = chopBegin(i);
    if i == numel(chopBegin)
        x1 = size(data,2);
    else
        x1 = chopBegin(i+1);
    end
    if mod(i,2),
        color = [0.3 0.3 0.3];
    else
        color = [0.6 0.6 0.6];
    end
    h = patch([x0 x0 x1 x1], [yLim(1) yLim(2) yLim(2) yLim(1)], color);
    set(h, 'FaceAlpha', 0.2);
end

% Add texts with the sample numbers
for i = 1:numel(chopBegin),
    nSecs = num2str(round(chopBegin(i)/data.SamplingRate));
    h = text(chopBegin(i)+10, index(chopBegin(i))+0.05*range(index), nSecs);
    set(h, ...
        'BackgroundColor', 'white', ...
        'EdgeColor', 'black', ...
        'FontSize', 6, ...
        'Rotation', 90);
end


% Print to .svg and .png format
fileName = catfile(get_rootpath(rep), 'chopping-index.svg');
fileName = unique_filename(fileName);

caption = sprintf('Chopping idex value and identified chop boundaries');

%[path, name] = fileparts(fileName);

% For the thumbnails, we always need a .png
% But we cannot do this with -nodisplay because there is not any valid
% renderer for transparent figures -> MATLAB crashes badly
%if usejava('Desktop'),
%    print('-dpng', [catfile(path, name) '.png'], '-r600');
%end

evalc('plot2svg(fileName, gcf);');

% Use ALWAYS inkscape, it's more robust
svg2png(fileName);

close;

myGallery = add_figure(myGallery, fileName, caption);

%% Print a gallery
fprintf(rep, myGallery);

end