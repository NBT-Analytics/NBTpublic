function x = zero_mean(x, dim)

if nargin < 2, dim = 1; end

if dim == 2,
    x = x';
end

x = x - repmat(nanmean(x), size(x,1), 1);

if dim == 2,
    x = x';
end