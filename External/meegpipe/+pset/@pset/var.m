function y = var(x, w, dim)
% VAR Variance
%
%   Y = var(X) normalizes by N-1, where N is the sample size.
%
%   Y = var(X,1) normalizes by N and produces the second order moment of
%   the sample about its mean.
%
%   Y = var(X, W) computes the variance using the weight vector W. The
%   length of W must equal the length of the dimension over which VAR
%   operates, and its elements must be nonnegative. var() normalizes W to
%   sum to one.
%
%   Y = var(X, W, DIM) takes the variance along the dimension DIM of X.
%
% See also: pset.MEAN, pset.COV

if nargin < 2 || isempty(w), w = 0; end
if nargin < 3 || isempty(dim), dim = 1; end

if dim > 2,
    error('pset:pset:var:invalidDim', ...
        'pset objects have only two dimensions.');
end
if length(w) > 1 && length(w) ~= size(x, dim),
    error('pset:pset:var:invalidWeights',...
        'The length of W must equal the length of the dimension over which var() operates.');
end
if length(w) < 2 && w ~= 0 && w ~= 1,
    error('pset:pset:var:invalidInput', ...
        'Second input parameter must be 0 or 1 or a vector of weights.');
end
if length(w) > 1 && any(w<0),
    error('pset:pset:var:invalidWeights', ...
        'The elements of the weight vector must be nonnegative.');
end

y = center(copy(x)).^2;
y.Writable = true;

if length(w) > 1,
    w = w./sum(w); 
elseif w == 1,
    % Normalize by N
    w = ones(1, size(x, dim))./size(x,dim);
else
    % Default behavior
    w = ones(1, size(x, dim))./(size(x,dim)-1);    
end

if dim == 1,    
   y = w*y;
else
    % accross columns
    y = y*w';    
end

s.type = '()';
s.subs = {':', ':'};
y = subsref(y, s);