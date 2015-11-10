function y = rdivide(a,b)
% RDIVIDE Right array divide
%
%   A./B denotes element-by-element division of two pset objects
%
% See also: pset.pset

% Easy way but inefficient...
y = times(a, power(b,-1));