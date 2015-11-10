function hFig = make_rank_plots(sens, rankVal, rejIdx, minRank, ...
    maxRank, rankStats)

import rotateticklabel.rotateticklabel;
import meegpipe.node.globals;

SIZE_FACTOR = 2; 

visible = globals.get.VisibleFigures;

if visible,
    visibleStr = 'on';
else
    visibleStr = 'off';
end

hFig = figure('Visible', visibleStr);
h = plot(rankVal, 'ko-', 'LineWidth', globals.get.LineWidth);
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
set(gca, 'FontSize', 8);
ylabel('Rank index value');

% Make clear which channels were rejected
if ~isempty(rejIdx),
    hold on;
    h = plot(rejIdx, rankVal(rejIdx), 'ro');
    set(h, 'MarkerFaceColor', 'red');
end

th = prctile(rankVal, [5 90]);
extremeIdx = find(rankVal < th(1) | rankVal > th(2));

extremeIdx = setdiff(extremeIdx, rejIdx);

if ~isempty(rejIdx),
    % Set the figure XTicks (non-rejected/non-extreme channels)
    nonRejIdx = setdiff(1:numel(rankVal), [rejIdx(:);extremeIdx(:)]);
    set(gca, 'XTick', nonRejIdx);
    sensNonRej = subset(sens, nonRejIdx);
    
    if ~isempty(sensNonRej),
        XLabels = labels(sensNonRej);
        XLabels = cellfun(@(x) [x '   '], XLabels, 'UniformOutput', false);
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
        sensLabels = labels(subset(sens, rejIdx));
        for i = 1:numel(rejIdx),
            h = text(rejIdx(i), rankVal(rejIdx(i)), [' ' sensLabels(i)]);
            set(h, 'Rotation', 90, 'FontSize', fontSize);
        end
    end
end

% Place text labels over the extreme points
if ~isempty(extremeIdx),
    fontSize = 12;
    if numel(extremeIdx) > 1,
        fontSize = max(2, min(12, min(diff(extremeIdx))*SIZE_FACTOR));
    elseif numel(rejIdx) > 1,
        fontSize = max(2, min(12, min(diff(rejIdx))*SIZE_FACTOR));
    end

    if ~isempty(extremeIdx),
        sensLabels = labels(subset(sens, extremeIdx));
        for i = 1:numel(extremeIdx),
            h = text(extremeIdx(i), rankVal(extremeIdx(i)), [' ' sensLabels(i)]);
            set(h, 'Rotation', 90, 'FontSize', fontSize);
        end
    end    
end

report.overlay_rank_stats(rankVal, minRank, maxRank, rankStats);

end

