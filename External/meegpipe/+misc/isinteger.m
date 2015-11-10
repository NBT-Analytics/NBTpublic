function y = isinteger(x)
% ISINTEGER - True for natural numeric arrays
%
% test = isinteger(x)
%
% Where
%
% X is a numeric array.
%
% TEST is true if all the elements of X are integer numbers. Otherwise,
% TEST is false.
%
%
% See also: isnatural



y = isinteger(x);
if y,
    return;
end


y = false;
if (isnumeric(x) && all(abs(x(:)-round(x(:)))<eps))
    y = true;
end


end