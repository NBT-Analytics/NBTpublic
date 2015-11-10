function [x, obj] = filter(obj, x, d, varargin)

import misc.signal2hankel;
import misc.eta;


verbose = is_verbose(obj) && size(x,1) > 5;
verboseLabel = get_verbose_label(obj);

if obj.Order < 1,
    
    if verbose,
        fprintf( [verboseLabel, ...
            'Regression with order less than 1 -> nothing done...\n\n']);
    end
    return;
    
end

if verbose,
    fprintf( [verboseLabel, ...
        '%d-lag regression of %d ref. signals on %d signals...'], ...
        obj.Order, size(d,1), size(x,1));
end

% It's too slow to operate on the memory map directly
d = signal2hankel(d(:,:), obj.Order);

% Do a PCA to reduce dimensionality
if size(d, 1) > 2 && ~isempty(obj.PCA),
    pca = obj.PCA;
    pca = set_verbose(pca, false);
    pca = learn(pca, d);
    d = proj(pca, d);
end

tinit = tic;


for i = 1:size(x,1),
    x(i,:) = x(i,:) - (x(i,:)*pinv(d))*d;
    if verbose,
        eta(tinit, size(x, 1), i, 'remaintime', false);
    end
end

if verbose, fprintf('\n\n'); end

end