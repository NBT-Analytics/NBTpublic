function y = mean(a, dim)
% MEAN Average or mean value
%
%   Y = mean(A, DIM)
%
% See also: pset.pset

if nargin < 2 || isempty(dim), dim = 1; end

y = sum(a, dim);
y = y*(1/size(a,dim));