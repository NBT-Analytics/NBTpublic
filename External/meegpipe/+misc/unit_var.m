function x = unit_var(x, dim)

if nargin < 2, dim = 1; end

if dim == 2,
    x = x';
end

for i = 1:size(x,2)
   x(:,i) = x(:,i)./sqrt(nanvar(x(:,i))); 
end

if dim == 2,
    x = x';
end