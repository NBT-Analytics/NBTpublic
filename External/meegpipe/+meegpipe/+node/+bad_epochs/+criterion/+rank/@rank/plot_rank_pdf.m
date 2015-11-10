function hFig = plot_rank_pdf(rankIndex, rejIdx, minRank, maxRank, rankStats)

import meegpipe.node.globals;

BAR_COLOR = [0.5 0.5 0.5];

visible = globals.get.VisibleFigures;

if visible,
    visibleStr = 'on';
else
    visibleStr = 'off';
end

hFig = figure('Visible', visibleStr);
[counts, centerVals] = hist(rankIndex, min(100, max(10, floor(0.1*numel(rankIndex)))));
bar(centerVals, counts, 'FaceColor', BAR_COLOR, 'EdgeColor', BAR_COLOR);
pdKernel = fitdist(rankIndex(:), 'Kernel');
minVal = prctile(rankIndex, 0.0001);
maxVal = prctile(rankIndex, 99.9999);
x = linspace(minVal, maxVal, 300);
pdfVals = pdf(pdKernel, x);
pdfVals = pdfVals*max(counts)/max(pdfVals);
hold on;plot(x, pdfVals, 'k', 'LineWidth', 2);

ylabel('# epochs');
xlabel('Epoch statistic');
axis tight;


% Make clear how many epochs were rejected
if ~isempty(rejIdx),
    rejRank = rankIndex(rejIdx);   
    binWidth = mean(diff(centerVals));
    rejCounts = histc(rejRank, ...
        [-Inf ...
        centerVals(2:end)-binWidth/2 ...
        Inf]);
    hold on;
    bar(centerVals, rejCounts(1:end-1), 'FaceColor', 'red', 'EdgeColor', 'red');    
end

% Add the min/max thresholds
if ~isempty(minRank) && minRank > -Inf,
    hold on;
    p1 = repmat(minRank, 1, 2);
    p2 = [min(counts) max(counts)];
    line(p1, p2, 'Color', 'red');
end

if ~isempty(maxRank) && maxRank < Inf,
    hold on;
    p1 = repmat(maxRank, 1, 2);
    p2 = [min(counts) max(counts)];
    line(p1, p2, 'Color',  'red');
end

% Plot user-provided stats to help pick the right threshold
if ~isempty(rankStats),
    statNames = keys(rankStats);
    statVal  = zeros(1, numel(statNames));
    pos = round(linspace(min(counts), max(counts), numel(statNames)+2));
    for i = 1:numel(statNames)
        stat = rankStats(statNames{i});
        statVal(i) = stat(rankIndex);
        if statVal(i) > minVal && statVal(i) < maxVal,
            hold on;
            p1 = repmat(statVal(i), 1, 2);
            p2 = [min(counts) max(counts)];
            line(p1, p2, 'Color', [0.2 0.2 0.2]);
        end
    end
    % Add the texts at the end to prevent the lines writing over them
    for i = 1:numel(statNames)
        if statVal(i) > minVal && statVal(i) < maxVal,
            text(statVal(i), pos(1+i), statNames{i}, ...
                'FontSize', 6, 'Rotation', 90);
        end
    end
end

end