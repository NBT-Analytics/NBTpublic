function y = single(obj)
% SINGLE Convert pset object to numeric array with single precision
%
%   single(pset. converts pset object pset.into a single precision numeric
%   array.
%
% See also: pset.DOUBLE, pset.ISFLOAT, pset.ISNUMERIC

y = single(obj(:,:));

end