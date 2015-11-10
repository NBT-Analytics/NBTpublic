function [epochs, groupNames] = summary_epochs(epochLength, nbPoints, winrej, config)
% SUMMARY_EPOCHS - Returns a representative set of epoch definitions
%
% * This is a private function that is used by method plot()
%
%
% See also: pset.plotter.time.snapshots.plot


epochBegin  = (1:epochLength:nbPoints-epochLength)';
if isempty(epochBegin), epochBegin = 1; end
epochEnd    = epochBegin+epochLength-1;
epochs      = [epochBegin(:) epochEnd(:)];
% pick as many bad epochs as possible but no more than config.NbBadEpochs
isBad = false(size(epochs,1),1);
for badEpochItr = 1:size(winrej,1)
    isBad = isBad | ...
        ((winrej(badEpochItr,2) > epochBegin & ...
        winrej(badEpochItr,1) < epochBegin) | ...
        (winrej(badEpochItr,1) < epochEnd & ...
        winrej(badEpochItr,2) > epochEnd) | ...
        (winrej(badEpochItr,1) < epochBegin & ...
        winrej(badEpochItr,2) > epochEnd));
end

badEpochs   = epochs(isBad,:);
goodEpochs  = epochs(~isBad,:);
goodEpochs  = goodEpochs(randperm(size(goodEpochs,1)),:);
goodEpochs(config.NbGoodEpochs+1:end,:) = [];
badEpochs(config.NbBadEpochs+1:end,:)   = [];
[~, idx] = sort(goodEpochs(:,1));
goodEpochs = goodEpochs(idx,:);
epochs      = {goodEpochs; badEpochs};
nbChans     = numel(config.Channels);

if ~isempty(config.ChannelType) && numel(config.ChannelType) < 30,
    groupNames      = {...
        sprintf('Good epochs, %d%s chan(s) of type(s) %s, %d secs', nbChans, ...
        [' ' config.ChannelClass], config.ChannelType, config.WinLength); ...
        sprintf('Bad epochs, %d%s chan(s) of type(s) %s, %d secs', nbChans, ...
        [' ' config.ChannelClass], config.ChannelType, config.WinLength)};
else
    groupNames      = {...
        sprintf('Good epochs, %d%s chans, %d secs', nbChans, ...
        [' ' config.ChannelClass], config.WinLength); ...
        sprintf('Bad epochs, %d%s chans, %d secs', nbChans, ...
        [' ' config.ChannelClass], config.WinLength)};
end
isEmpty         = cellfun(@(x) isempty(x), epochs);
epochs(isEmpty) = [];
groupNames(isEmpty) = [];

end