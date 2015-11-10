function erpData = erp(obj, events, latencyRange, varargin)

import misc.process_arguments;
import misc.eta;

opt.baselinerange = [];

[~, opt] = process_arguments(opt, varargin);

if ~(isnumeric(events) && isvector(events)),
    ME = MException('pset.eegset:erp:InvalidArgument', ...
        ['The ''events'' argument must be a numeric vector or an ' ...
        'array of pset.event objects']);
    throw(ME);
end

firstSample = floor(latencyRange(1)*obj.SamplingRate);
lastSample  = ceil(latencyRange(2)*obj.SamplingRate);
sampleRange = firstSample:lastSample;

if ~isempty(opt.baselinerange),
    firstBaselineSample = floor(opt.baselinerange(1)*obj.SamplingRate);
    lastBaselineSample = floor(opt.baselinerange(2)*obj.SamplingRate);
else
    firstBaselineSample = firstSample;
    lastBaselineSample  = lastSample;
end
baselineSampleRange = firstBaselineSample:lastBaselineSample;

idx = repmat(events(:), 1, numel(sampleRange)) + ...
    repmat(sampleRange, numel(events), 1);

idxBaseline = repmat(events(:), 1, numel(baselineSampleRange)) + ...
    repmat(baselineSampleRange, numel(events), 1);

isOutOfRange = any(idx<1 | idx>size(obj,2),2);

idx(isOutOfRange, :) = [];
idxBaseline(isOutOfRange, :) = [];
events(isOutOfRange) = [];
erpData = nan(size(obj,1), numel(sampleRange));
for tsIter = 1:size(obj,1)
    S.type = '()';
    S.subs = {tsIter, idx'};
    data = subsref(obj, S);
    data = reshape(data, numel(sampleRange), numel(events))';
    S.subs = {tsIter, idxBaseline'};
    baselineData = subsref(obj, S);
    baselineData = reshape(baselineData, numel(baselineSampleRange), numel(events));
    erpData(tsIter,:) = mean(data - repmat(mean(baselineData)', 1, numel(sampleRange)));        
end



end