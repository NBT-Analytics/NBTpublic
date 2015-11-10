function plot_bad_epochs(rep, rankIdx, rejIdx, minTh, maxTh, data, ev)

NB_CHANS  = 20;
NB_EPOCHS = 4;

%% Plot a few bad epochs
if isempty(ev) || isempty(rejIdx),
    return;
end

% Try to be smart about what channels to plot: plot those that should make
% it evident whether a bad epoch is bad

epochIdx = unique(ceil(linspace(1, numel(rejIdx), NB_EPOCHS)));
epochIdx = rejIdx(epochIdx);

chanIdx = pick_top_var_chans(data, ev(epochIdx), NB_CHANS);

generate_snapshots(rep, 'Sample Bad Epochs', epochIdx, chanIdx, data, ev);

%% Plot a few borderline cases
% sort the epochs according to how close they are to the rejection boundary
dist = min(abs(rankIdx - minTh), abs(rankIdx - maxTh));
[~, sortedEpochIdx] = sort(dist, 'ascend');

% Do not re-plot epochs that were already plotted when plotting bad epochs
sortedEpochIdx(ismember(sortedEpochIdx, epochIdx)) = [];

borderlineEpochIdx = sortedEpochIdx(1:min(NB_EPOCHS, numel(sortedEpochIdx)));

generate_snapshots(rep, 'Sample Borderline Epochs', borderlineEpochIdx, ...
    chanIdx, data, ev);

end

function chanIdx = pick_top_var_chans(data, ev, nbChans)

if nbChans >= size(data, 1),
    chanIdx = 1:size(data, 1);
    return;
end

topChans = nan(numel(ev), size(data,1));
for i = 1:numel(ev),
    thisEpoch = misc.epoch_get(data, ev(i));
    chanVar = var(thisEpoch, 1, 2);
    [~, idx] = sort(chanVar, 'descend');
    topChans(i, :) = idx';
end

chanIdx = nan(1, nbChans);
chanCount = 0;
for i = 1:numel(topChans),
   if ismember(topChans(i), chanIdx),        
       continue; 
   end
   chanCount = chanCount + 1;
   chanIdx(chanCount) = topChans(i);     
   if chanCount == nbChans,
       chanIdx = sort(chanIdx);
       return;
   end
end

end

function generate_snapshots(rep, titleStr, epochIdx, chanIdx, data, ev)

import mperl.join;

epochRanges     = nan(numel(epochIdx), 2);
plotEpochRanges = nan(numel(epochIdx), 2);

for i = 1:numel(epochIdx)
    epochRanges(i, 1) = get(ev(epochIdx(i)), 'Sample');
    epochRanges(i, 2) = epochRanges(i, 1) + ...
        get(ev(epochIdx(i)), 'Duration')-1;
    
    Delta = diff(epochRanges(i,:));
    plotEpochRanges(i, 1) = max(1, epochRanges(i,1)-Delta);
    plotEpochRanges(i, 2) = min(size(data,2), epochRanges(i,2)+Delta);
end

plotterObj = physioset.plotter.snapshots.new(...
    'Channels',     chanIdx, ...
    'NbGoodEpochs', 1, ...
    'NbBadEpochs',  0, ...
    'Epochs',       plotEpochRanges);

subRep = report.plotter.new(...
    'Plotter',     plotterObj, ...
    'Title',       'Sample bad epochs');

embed(subRep, rep);

print_title(rep, titleStr, get_level(rep) + 1);

print_paragraph(rep, 'Plotting epochs %s', join(',', epochIdx));

set_level(subRep, get_level(rep) + 2);

generate(subRep, data);


end