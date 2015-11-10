function obj = learn_basis(obj, data)

obj.Samples = size(data, 2);

if isa(data, 'pset.mmappset'),
    obj.Cov = cov(data);
else
    obj.Cov = cov(data');
end

C = obj.Cov;
[V, D]              = eig(C);
Lambda              = diag(D);
[~, I]              = sort(diag(D), 'descend');
V                   = V(:,I);
sortedLambda        = Lambda(I);

obj.CovRank = rank(C);
V(:, obj.CovRank+1:end)         = [];
sortedLambda(obj.CovRank+1:end) = [];

if obj.Sphering,
    W = diag(sortedLambda.^(-.5))*V';
else
    W = diag(sortedLambda.^(.5))*V';
end

A = pinv(W);

% Compute model order selection criteria
critName = setdiff(keys(spt.pca.valid_criteria), 'NONE');
for critItr = 1:numel(critName)
    [kopt, critVal] = feval(['spt.pca.' lower(critName{critItr})], ...
        sortedLambda, obj.Samples);    
    obj.(upper(critName{critItr})) = critVal;
    obj.([upper(critName{critItr}) 'Order']) = kopt;
end

if ~strcmpi(obj.Criterion, 'NONE'),
    maxDim = min(size(W,1), obj.([upper(obj.Criterion) 'Order']));
else
    maxDim = size(W, 1);
end

if obj.MinSamplesPerParamRatio > 0,
    maxDim = min(maxDim, floor(sqrt(obj.Samples/obj.MinSamplesPerParamRatio)));
end

if isa(obj.MaxCard, 'function_handle'),
    maxCard = obj.MaxCard(Lambda);
else
    maxCard = obj.MaxCard;
end

maxDim = min(maxDim, maxCard);

maxDimVar = max_dim_var(sortedLambda, obj.RetainedVar);

maxDim = min(maxDim, maxDimVar);

maxDimCond = find(sortedLambda(1)./sortedLambda < obj.MaxCond, 1, 'last');

maxDim = min(maxDim, maxDimCond);

if isa(obj.MinCard, 'function_handle'),
    minCard = obj.MinCard(Lambda);
else
    minCard = obj.MinCard;
end

if size(W,1) < minCard,
    error(['Covariance matrix does not have enough rank to produce ' ...
        '%d components'], minCard);
end

nbDims = max(minCard, maxDim);

obj.Eigenvectors = V;
obj.Eigenvalues = sortedLambda;
obj.W = W;
obj.A = A;
obj.ComponentSelection = 1:nbDims;
obj.DimSelection = 1:size(data,1);


end



function maxDimVar = max_dim_var(sortedLambda, varTh)

% The abs() is needed to ensure that the maximum of cumVar is
% cumVar(end). Otherwise small (negative) numerical errors may cause
% troubles.
cumVar    = cumsum(abs(sortedLambda));
cumVar    = cumVar/cumVar(end);
maxDimVar = find(cumVar > varTh/100, 1, 'first');
if isempty(maxDimVar),
    maxDimVar = numel(sortedLambda);
end


end