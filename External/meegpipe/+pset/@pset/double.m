function y = double(obj)
% DOUBLE Convert pset object to numeric array with double precision
%
%   double(pset. converts pset object pset.into a double precision numeric
%   array.
%
% See also: pset.SINGLE, pset.ISFLOAT, pset.ISNUMERIC

if strcmpi(obj.Precision, 'double'),
    y = obj;
else
    y = double(obj(:,:));
end

end