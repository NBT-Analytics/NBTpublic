function [x, obj] = filter(obj, x, varargin)

import misc.signal2hankel;
import misc.eta;
import misc.process_arguments;

opt.SamplingRate = [];
[~, opt] = process_arguments(opt, varargin);

verbose = is_verbose(obj) && size(x,1) > 5;
verboseLabel = get_verbose_label(obj);


if verbose,
    fprintf( [verboseLabel, ...
        'tpca filtering of %d signals using delay embedding with %d lags...'], ...
        size(x,1), obj.Order);
end

if isa(obj.Order, 'function_handle'),
    if isa(x, 'physioset.physioset'),
        order = obj.Order(x.SamplingRate);
    elseif ~isempty(opt.SamplingRate),
        order = obj.Order(opt.SamplingRate);
    else
        error('Unknown data sampling rate');
    end
        
else
    order = obj.Order;
end

tinit = tic;
pca = obj.PCA;
pca = set_verbose(pca, false);
dim = ceil(order/2);
for i = 1:size(x,1),
    d   = signal2hankel(x(i,:), order);
    pca = learn(pca, d);
    d   = proj(pca, d);
    if ~isempty(obj.PCFilter),
        d   = filtfilt(obj.PCFilter, d);
    end
    d = bproj(pca, d);
    x(i,:) = d(dim,:);
    if verbose,
        eta(tinit, size(x, 1), i, 'remaintime', false);
    end
end

if verbose, fprintf('\n\n'); end

end