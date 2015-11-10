function [evBad, rejIdx, samplIdx] = find_bad_epochs(obj, data, ev, rep)

import meegpipe.node.bad_epochs.criterion.rank.rank;

if nargin < 4, rep = []; end

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);


if verbose,
    
    fprintf([verboseLabel 'Rejecting epochs from %s...\n\n'], ...
        get_name(data));
    
end

% Configuration options
minRank = get_config(obj, 'Min');
maxRank = get_config(obj, 'Max');
minC    = get_config(obj, 'MinCard');
maxC    = get_config(obj, 'MaxCard');

[rankIndex, ev2] = compute_rank(obj, data, ev);

ev = ev2;
selected  = false(1, numel(ev));

if isa(minC, 'function_handle'),
    minC = minC(rankIndex);
end

if isa(maxC, 'function_handle'),
    maxC = maxC(rankIndex);
end

if isa(minRank, 'function_handle'),
    minRank = minRank(rankIndex);
end

if isa(maxRank, 'function_handle'),
    maxRank = maxRank(rankIndex);
end

% Min/Max criterion
if ~isempty(maxRank),
    selected(rankIndex > maxRank) = true;
end
if ~isempty(minRank),
    selected(rankIndex < minRank) = true;
end

% Minimum and maximum cardinality of the set of selected channels
if ~isempty(minRank) && minRank == -Inf
    rI2 = -rankIndex;
elseif ~isempty(maxRank) && maxRank == Inf,
    rI2 = rankIndex;
else
    rI2 = min(rankIndex - minRank, maxRank - rankIndex);
end
[~, order] = sort(rI2, 'ascend');

if minC > size(data,1),
    selected(1:end) = true;
elseif minC > 0 ,    
    selected(order(1:minC)) = true;
end
if maxC < numel(selected)
    selected(order(maxC+1:end)) =  false;
end

if verbose,
    fprintf([verboseLabel 'Selected %d epochs using %s\n\n'], ...
        sum(selected), class(obj));
end

evBad = ev(selected);

rejIdx = find(selected);

for i = 1:numel(evBad),
    evOnset  = evBad(i).Sample+evBad(i).Offset;
    samplIdx = evOnset:(evOnset+evBad(i).Duration-1);
    
    set_bad_sample(data, samplIdx);
end

if ~isempty(rep),
   rankStats = get_config(obj, 'RankPlotStats');
   rank.generate_rank_report(rep, rankIndex, rejIdx, minRank, maxRank, ...
       rankStats, data, ev);
end

end

