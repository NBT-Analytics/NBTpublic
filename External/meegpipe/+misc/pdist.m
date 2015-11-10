function D = pdist(C, type)
% pdist - Formats a distance matrix according to the output of built-in
% function pdist. 
%
%   D = pdist(X)
%

if nargin < 2, type = 'distance'; end

if strcmpi(type, 'similarity')
    C(C<eps) = eps;
    C = 1./C;
elseif ~strcmpi(type, 'distance'),
    error('misc:pdist:invalidInput', ...
        'Second input argument must be either the string ''distance'' or the string ''similarity''.');
end

D = C(logical(tril(ones(size(C,1)), -1)))';



