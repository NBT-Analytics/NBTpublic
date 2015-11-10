function [kopt, pk] = mdl(eigVal, n)
% MDL - Minimum Description Length criterion

eigVal  = sort(eigVal, 'descend');
eigVal  = eigVal./max(eigVal);
dOrig   = numel(eigVal);

% Otherwise, we will run into log(0) below
eigVal(eigVal < eps) = [];

logpk = spt.pca.logpk(eigVal);

d = numel(eigVal);
k = 1:d;
pk = -n.*(d-k).*logpk + (k./2).*(2*d-k).*log(n);

[~, kopt] = min(pk); 

pk = [pk NaN(1, dOrig-d)];

end