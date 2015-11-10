function [rankVal, ev] = compute_rank(obj, data, ev)
% COMPUTE_RANK - Ranks bad epochs according to a simple statistic


import meegpipe.node.bad_epochs.bad_epochs;
import misc.eta;

verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

stat1 = get_config(obj, 'ChannelStat');
stat2 = get_config(obj, 'EpochStat');

if nargin < 3 || isempty(ev),
    warning('bad_epochs:NoEpochs', ...
        'There are no epochs in this data: nothing done!');
    rankVal = nan(1, numel(ev));
    return;
end

if verbose,
    fprintf([verboseLabel 'Computing epochs statistics...']);
    clear +misc/eta;
    tinit = tic;
end

statVal2 = nan(1, numel(ev));

for i = 1:numel(ev)
    
    dataEpoch = epoch_get(data, ev(i), false);
    
    if isempty(dataEpoch),
        continue; 
    end
    
    statVal1 = zeros(1, size(dataEpoch, 1));
    for j = 1:size(dataEpoch, 1)
        statVal1(j) = stat1(squeeze(dataEpoch(j, :)));
    end
    
    statVal2(i) = stat2(statVal1);  
    
    if verbose,
        eta(tinit, numel(ev), i);
    end
    
end

ev(isnan(statVal2)) = [];
statVal2(isnan(statVal2)) = [];


if verbose,
    clear +misc/eta;
    fprintf('\n\n');
end

rankVal = statVal2;

end

