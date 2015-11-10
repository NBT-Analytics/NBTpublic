function C = cov_cell(data)
% cov_cell - Covariance of a set of data epochs stored as cell array

import misc.center;

n_p = 0;
n_dim = size(data{1} ,1);
for i = 1:numel(data)
    if size(data{i},1) ~= n_dim,
        error('misc:cov_cell:invalidDim', ...
            'The dimensionality of the epochs do not match.');
    end
    n_p = n_p + size(data{i},2);
end
S = nan(n_dim, n_p);
p_count = 1;
for i = 1:numel(data)
    S(:, p_count:p_count+size(data{i},2)-1) = data{i};
    p_count = p_count + size(data{i},2);
end
C = cov(center(S)');

end