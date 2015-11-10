function [kopt, logpdk] = mibs(eigVal, n, varargin)
% MIBS - Minka Bayesian model Selection criterion [1,2]
%
% 
% ## References
% 
% [1] Minka, "Automatic Choice of Dimensionality for PCA", Advances in
%     Neural Information Processing Systems, 13, 598-604, 2001.
%
% [2] Kazianka and Pilz, "A Corrected Criterion for Selecting the Optimum
%     Number of Principal Components", Austrial Journal of Statistics 38
%     (3), 135-150, 2009. 
%


import misc.process_arguments;
import misc.loggamma;

opt.alpha   = 0.01;
[~, opt]    = process_arguments(opt, varargin);
alpha       = opt.alpha;

eigVal  = sort(eigVal, 'descend');
eigVal  = eigVal/max(eigVal);
origDim = numel(eigVal);
eigVal(eigVal < eps) = [];

d = numel(eigVal);
k = 1:(d-1);
N = n+1+alpha;
m = d.*k-k.*(k-1)/2;
lambda = (n.*eigVal + alpha)./(N-2); 

Asigma2 = (N*(d-k)-2)/2;
logALambda = k.*log(N/2-1);

sigma2 = nan(1, d);
for kIter = 1:(d-1)
    sigma2(kIter) = n*sum(eigVal((kIter+1):d))/(N*(d-kIter)-2);
end
sigma2(end) = eps;

logAu = zeros(1, numel(k));
for kIter = 1:(d-1)
    logAu(kIter) = m(kIter)*log(n);
    lambdaTilde = nan(1, d);
    lambdaTilde(1:kIter) = lambda(1:kIter);
    lambdaTilde((kIter+1):d) = sigma2((kIter+1):d);
    for i = 1:kIter
        tmp = 0;
        for j = (i+1):(d-1)
            tmp = tmp + log(lambdaTilde(j)^(-1)-lambdaTilde(i)^(-1))+...
                log(eigVal(i)-eigVal(j));
        end
        logAu(kIter) = logAu(kIter)+tmp;
    end
end

% Eq. 19
logck = nan(1, d-1);
for kIter = 1:(d-1)    
    lognum = (-d/2)*log(n)+(-(n-1)*d/2)*log(2*pi)+((kIter.*...
        (kIter-1-2*d))/4).*log(pi);
    logden = kIter*log(2)+loggamma((alpha+2)*...
        (d-kIter)/2-1)+kIter*loggamma(alpha/2);
    logfactor = (((alpha+2).*(d-kIter)-2)/2).*log((alpha.*(d-kIter))/2) + ...
        ((kIter*alpha)/2).*log(alpha/2);
    logfactor1 = lognum + logfactor - logden;
    logfactor2 = 0;
    for i = 1:kIter
        logfactor2 = logfactor2 + loggamma((d-i+1)/2);
    end
    logck(kIter) = logfactor1 + logfactor2;
end

% Eq. 18
logLambda = sum(lambda);

logpdk = k.*log(2)+logck+((-N/2)+1)*logLambda + ...
    ((-N.*(d-k)+2)/2).*log(sigma2(1:(d-1))) + ...
    (-(N*d)/2+k+1).*log(exp(1))+((m+k+1)/2).*log(2*pi)+...
    (-1/2)*(logAu+logALambda+log(Asigma2));

if any(diff(logpdk)>0),
    [~, kopt] = max(logpdk);
else
    kopt = origDim;
end
logpdk = [logpdk nan(1, origDim - numel(logpdk))];




end