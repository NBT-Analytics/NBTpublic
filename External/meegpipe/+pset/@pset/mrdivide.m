function y = mrdivide(a,b)
% MRDIVIDE Slash or right divide
%
%   A/B is the matrix division of B into A
%
% See also: pset.pset

n_a = prod(size(a)); %#ok<*PSIZE>
n_b = prod(size(b));


if n_a == 1,
    y = a(1)./b;
    
elseif n_b == 1,
    y = a./b(1);
else
    error('mrdivide:notImplemented','Not implemented yet!');
end