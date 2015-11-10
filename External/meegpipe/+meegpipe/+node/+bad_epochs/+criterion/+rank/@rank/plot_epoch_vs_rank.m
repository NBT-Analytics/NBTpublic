function hFig = plot_epoch_vs_rank(rankIndex, rejIdx, minRank, maxRank, rankStats)

import rotateticklabel.rotateticklabel;
import meegpipe.node.globals;
import mperl.split;
import mperl.join;

SIZE_FACTOR = 2;

visible = globals.get.VisibleFigures;

if visible,
    visibleStr = 'on';
else
    visibleStr = 'off';
end

hFig = figure('Visible', visibleStr);
h = plot(rankIndex, 'ko-', 'LineWidth', globals.get.LineWidth);
set(h, 'MarkerSize', 3, ...
    'LineWidth', 1, ...
    'Color', [0.5 0.5 0.5], ...
    'MarkerFaceColor', 'black', ...
    'MarkerEdgeColor', 'black');

axis tight;
yLims    = get(gca, 'YLim');
yRange   = abs(diff(yLims));
yLims(1) = yLims(1) - 0.1*yRange;
yLims(2) = yLims(2) + 0.1*yRange;
set(gca, 'YLim', yLims);
set(gca, 'FontSize', 10);
ylabel('Epoch statistic');

% Make clear which channels were rejected
if ~isempty(rejIdx),
    hold on;
    h = plot(rejIdx, rankIndex(rejIdx), 'ro');
    set(h, 'MarkerFaceColor', 'red');
    
end

if ~isempty(rejIdx),
    
    % Set the figure XTicks (non-rejected/non-extreme channels)
    nonRejIdx = setdiff(1:numel(rankIndex), rejIdx(:));
    set(gca, 'XTick', nonRejIdx);
    
    if ~isempty(nonRejIdx),
        cellDims = ones(1, numel(nonRejIdx));
        XLabels = mat2cell(nonRejIdx(:), cellDims, 1);
        XLabels = cellfun(@(x) [num2str(x) '   '], XLabels, ...
            'UniformOutput', false);
        set(gca, 'XTickLabel', XLabels);
        th = rotateticklabel(gca, 90);
        
        fontSize = 12;
        
        if numel(rejIdx) > 1,
            fontSize = max(2, min(12, min(diff(nonRejIdx))*SIZE_FACTOR));
        end
        
        set(th, 'FontSize', fontSize);
    end
    
    % Place text labels over the points marking bad channels
    fontSize = 12;
    if numel(rejIdx) > 1,
        fontSize = max(2, min(12, min(diff(rejIdx))*SIZE_FACTOR));
    end
    
    if ~isempty(rejIdx),
        cellDims = ones(1, numel(rejIdx));
        sensLabels = mat2cell(rejIdx(:), cellDims, 1);
        for i = 1:numel(rejIdx),
            h = text(rejIdx(i), rankIndex(rejIdx(i)), [' ' sensLabels(i)]);
            set(h, 'Rotation', 90, 'FontSize', fontSize);
        end
    end
    
end

report.overlay_rank_stats(rankIndex, minRank, maxRank, rankStats);

end