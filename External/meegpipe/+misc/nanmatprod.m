function z = nanmatprod(x, y)

idx1 = (sum(isnan(x), 1) < 1);
idx2= (sum(isnan(y),2) < 1);
idx = idx1(:) & idx2(:);

z = x(:, idx)*y(idx, :);


end