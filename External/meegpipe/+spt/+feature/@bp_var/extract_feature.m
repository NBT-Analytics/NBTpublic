function [featVal, featName] = extract_feature(obj, sptObj, tSeries, ...
    raw, varargin)

import misc.peakdet;
import misc.eta;
import goo.pkgisa;

featName = [];

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

goo.globals.set('Verbose', false);

featVal = nan(size(tSeries, 1), 1);

% The full back-projection matrix
A = bprojmat(sptObj, true);

if verbose,
    fprintf([verboseLabel 'Computing raw data variance ...']);
end
[~, emptySel] = select(obj.DataSelector, raw);
if emptySel,
    warning('bp_var:EmptySelection', ...
        'Cannot calculate BP variance on an empty set');
    return;
end

rawDataVar = var(raw, [], 2);
A = A(relative_dim_selection(raw), :);
restore_selection(raw);
if verbose,
    fprintf('[done]\n\n');
end

if verbose,
    fprintf([verboseLabel 'Computing channel statistics ...']);
end

% We ignore point selections for simplicity and speed!!! 
for i = 1:size(tSeries,1)
    featVal(i) = obj.AggregatingStat(A(:,i).^2, rawDataVar);
end

if verbose,
    fprintf('\n\n');
end

goo.globals.set('Verbose', verbose);

end