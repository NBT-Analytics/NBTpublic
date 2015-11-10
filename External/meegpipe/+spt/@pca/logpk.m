function y = logpk(eigVal)
% LOGPK - Auxiliary function for the computation of AIC and BIC criteria



eigVal = sort(eigVal, 'descend');
d = numel(eigVal);
y = nan(1, d);
for k = 1:(d-1)
   lognum = sum(log(eigVal(k+1:d)))*(1/(d-k));
   logden = log((1/(d-k)))+log(sum(eigVal(k+1:end)));
   y(k) = lognum - logden;
end
y(end) = y(end-1);



end