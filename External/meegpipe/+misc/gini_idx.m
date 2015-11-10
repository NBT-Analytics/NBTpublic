function y = gini_idx(x)

x = abs(x);
x = sort(x, 'ascend');
l1norm = sum(x);
N = length(x);
k = repmat((1:N)', 1, size(x,2));
y = 1-2*sum((x./repmat(l1norm, N,1)).*(N-k+1/2)/N);

end