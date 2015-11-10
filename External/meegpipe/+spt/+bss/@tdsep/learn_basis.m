function obj = learn_basis(obj, data, varargin)


import spt.bss.cor2;
import spt.bss.jdiag;
import physioset.event.class_selector;


X = data(:,:);
[n, T] = size(X);
% whitening & projection onto signal subspace
Sigma       = (X*X')/T;
Sigma       = (Sigma+Sigma')/2;
[U,D] 		= eig(Sigma);
[puiss,k]	= sort(diag(D));
rangeW		= 1:n;
scales		= sqrt(puiss(rangeW));
W           = diag(1./scales)  * U(1:n,k(rangeW))';
X           = W*X;


% compute correlation matrices
N = length(obj.Lag);
M = zeros(n, n*numel(obj.Lag));
for i=1:N,
    Sigma = cor2(X',obj.Lag(i));
    Sigma = (Sigma+Sigma')/2;
    M(:, (i-1)*n+1:i*n) = Sigma;
end

% joint diagonalization
Q = jdiag(M,0.00000001);
% compute mixing matrix
W=Q'*W;
A = pinv(W);

selection = 1:size(W,1);

obj.W = W;
obj.A = A;
obj.ComponentSelection = selection;
obj.DimSelection       = 1:size(data,1);

end