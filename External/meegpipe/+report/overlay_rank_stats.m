function overlay_rank_stats(rankIndex, minRank, maxRank, rankStats)
% OVERLAY_RANK_STATS - Overlays statistics over rank plot

% Plot the Min/Max thresholds
if ~isempty(minRank) && minRank > -Inf,
    hold on;
    plot(repmat(minRank, 1, numel(rankIndex)), 'r:');
end

if ~isempty(maxRank) && maxRank < Inf,
    hold on;
    plot(repmat(maxRank, 1, numel(rankIndex)), 'r:');
    
    
end

% Plot also user-provided stats to help pick the right threshold
if ~isempty(rankStats),
    statNames = keys(rankStats);
    statVal  = zeros(1, numel(statNames));
    pos = round(linspace(1, numel(rankIndex), numel(statNames)+2));
    for i = 1:numel(statNames)
        stat = rankStats(statNames{i});
        statVal(i) = stat(rankIndex);
        hold on;
        plot(repmat(statVal(i), 1, numel(rankIndex)), 'g');
    end
    % Add the texts at the end to prevent the lines writing over them
    for i = 1:numel(statNames)
        text(pos(1+i), statVal(i), statNames{i}, ...
            'FontSize', 6, 'BackgroundColor', 'white');
    end
end

% Add the texts at the end to prevent the lines writing over them
if ~isempty(minRank) && minRank > -Inf,
    text(max(1, pos(1)), minRank, 'Min', 'BackgroundColor', 'white');
end

if ~isempty(maxRank) && maxRank < Inf,
    text(max(1, pos(end)), maxRank, 'Max', 'BackgroundColor', 'white');
end

end