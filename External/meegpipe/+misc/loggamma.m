function y = loggamma(n)
% LOGGAMMA - An alias such that loggamma(n) = log(gamma(n))

import misc.isnatural;
import misc.loggamma; 

if isnatural(n),
    y = sum(log(1:(n-1)));
else
    y = log(gamma(n));
    if isinf(y),
        % Just an approximation to the true value
        first = loggamma(max(1, floor(n)));
        last = loggamma(ceil(n));
        y = (n - floor(n))*(first-last) + first;
    end
end

end