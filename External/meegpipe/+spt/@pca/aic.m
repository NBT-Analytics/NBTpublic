function [kopt, pk] = aic(eigVal, n)
% AIC - Akaike's Information Criterion

eigVal  = sort(eigVal, 'descend');
eigVal  = eigVal./max(eigVal);
dOrig   = numel(eigVal);

% Otherwise, we will run into log(0) below
eigVal(eigVal < eps) = [];

logpk = spt.pca.logpk(eigVal);
d = numel(eigVal);
k = 1:d;
pk = -2*n.*(d-k).*logpk + 2*k.*(2*d-k);

if all(diff(pk) > 0),
    % If monotonically increasing, better not to do anything
    kopt = numel(eigVal);
else
    [~, kopt] = min(pk);
end

pk = [pk NaN(1, dOrig-d)];

end