function M = avg_matrix(obj)

M = @(x) eye(size(x,1)) - ...
    (1/size(x,1))*ones(size(x,1),1)*ones(1, size(x,1));

if nargin > 1 && isempty(obj),
    M = M(obj);
end

end