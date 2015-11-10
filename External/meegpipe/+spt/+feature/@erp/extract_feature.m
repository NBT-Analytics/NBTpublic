function [featVal, featName] = extract_feature(obj, ~, tSeries,  raw, varargin)

import misc.eta;
import misc.epoch_get;
import misc.epoch_align;

verboseLabel = get_verbose_label(obj);
verbose      = is_verbose(obj);

featVal = zeros(size(tSeries,1), 1);
featName = [];

if nargin < 4 || isempty(raw),
    sr = tSeries.SamplingRate;
    ev = get_event(tSeries);
else
    sr = raw.SamplingRate;
    ev = get_event(raw);
end

if isempty(ev),
    warning('feature:erp:NoEvents', ...
        'Could not create ERP: the provided physioset contains no events');
    return;
end

ev = select(obj.EventSelector, ev);

if isempty(ev),
    warning('feature:erp:NoEvents', ...
        'Could not create ERP: no ERP events were found in the physioset');
    return;
end

if ~isempty(obj.Offset),
    ev = set(ev, 'Offset', round(sr*obj.Offset));
end

if ~isempty(obj.Duration),
    ev = set(ev, 'Duration', ceil(sr*obj.Duration));
end

if ~isempty(obj.Filter),
    if verbose,
        fprintf([verboseLabel ...
            'Pre-filtering before computing terp features ...\n\n']);
    end
    if isa(tSeries, 'pset.mmappset'),
        tSeries = copy(tSeries);
    end
    if isa(obj.Filter, 'function_handle'),
        filtObj = obj.Filter(sr);
    else
        filtObj = obj.Filter;
    end
    
    tSeries = filter(filtObj, tSeries);
    
end

if is_verbose(obj),
    fprintf([verboseLabel 'Computing terp rank for %d time series...'], ...
        size(tSeries,1));
end

if verbose,
    tinit = tic;
    clear +misc/eta;
end

for tsIter = 1:size(tSeries,1)
    
    x = tSeries(tsIter, :);
    x = squeeze(epoch_get(x, ev));
    
    % To prevent division by zero later
    hasZeroVar = var(x) < eps;
    x(:, hasZeroVar) = [];
    
    x = x - repmat(mean(x), size(x,1), 1);
    x = x./repmat(sqrt(var(x)), size(x, 1), 1);
    % This is so slow that we can't afford it...
    %[~, trialCorr] = epoch_align(x', maxLag, false);
    
    count = 0;
    trialCorr = nan((size(x,2)^2-size(x,2))/2,1);
    for i = 1:size(x,2),
        for j = i+1:size(x,2)
            count = count + 1;
            trialCorr(count) = x(:,i)'*x(:,j);
        end
    end
    
    trialCorr = trialCorr/size(x,1);
    
    featVal(tsIter) = obj.CorrAggregationStat(trialCorr);
    
    if is_verbose(obj),
        eta(tinit, size(tSeries,1), tsIter);
    end
    
end

if is_verbose(obj),
    fprintf('[done]\n\n');
end

end