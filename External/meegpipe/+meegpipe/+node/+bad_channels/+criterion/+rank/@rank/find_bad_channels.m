function [rejIdx, rankIndex] = find_bad_channels(obj, data, rep)
% FIND_BAD_CHANNELS - Selects bad channels using an automatic criterion
%
% [rejIdx, rankIndex] = find_bad_channels(obj, data)
%
% Where
%
% REJIDX is a set of indices of bad channels
%
% RANKINDEX is a vector of rank index values associated to each channel.
%
% See also: meegpipe.node.bad_channels.criterion.rank

import meegpipe.node.bad_channels.criterion.rank.rank;

if nargin < 3, rep = []; end

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

if verbose,
    fprintf([verboseLabel 'Rejecting channels from %s...\n\n'], ...
        get_name(data));
end

% Configuration options
minRank = get_config(obj, 'Min');
maxRank = get_config(obj, 'Max');
minC    = get_config(obj, 'MinCard');
maxC    = get_config(obj, 'MaxCard');

rankIndex = compute_rank(obj, data);
selected  = false(1, size(data,1));

if isa(minC, 'function_handle'),
    minC = minC(rankIndex);
end

if isa(maxC, 'function_handle'),
    maxC = maxC(rankIndex);
end

if ~isempty(maxRank),
    
    if isa(maxRank, 'function_handle'),
        maxRank = maxRank(rankIndex);
    end
    
    selected(rankIndex > maxRank) = true;
end

if ~isempty(minRank),
    
    if isa(minRank, 'function_handle'),
        minRank = minRank(rankIndex);
    end
    
    selected(rankIndex < minRank) = true;
end

if ~isempty(minRank) && minRank == -Inf
    rI2 = -rankIndex;
elseif ~isempty(maxRank) && maxRank == Inf,
    rI2 = rankIndex;
else
    rI2 = min(rankIndex - minRank, maxRank - rankIndex);
end
[~, order] = sort(rI2, 'ascend');

nbSelected = numel(find(selected));

if minC > size(data,1),
    selected(1:end) = true;
elseif minC > nbSelected,
    selected(order(1:minC)) = true;
end
if maxC < nbSelected
    
    % The selected components
    idx = find(selected(order));
    
    selected(order(idx(maxC+1:end))) = false;
    
    %selected(order(maxC+1:end)) =  false;
end

if verbose,
    fprintf([verboseLabel 'Selected %d channels using %s\n\n'], ...
        sum(selected), class(obj));
end

rejIdx = find(selected);

if ~isempty(rep),
    rankStats = get_config(obj, 'RankPlotStats');
    rank.generate_rank_report(rep, data, rankIndex, rejIdx, minRank, ...
        maxRank, rankStats);
end

end

