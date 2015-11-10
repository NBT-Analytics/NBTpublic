function y = isnatural(x)
% ISNATURAL - True for natural numeric arrays
%
% test = isnatural(x)
%
% Where
%
% X is a numeric array.
%
% TEST is true if all the elements of X are natural numbers. Otherwise,
% TEST is false.
%
% 
% See also: isinteger

import misc.isinteger;

y = false;
if (isinteger(x) && all(x(:) > 0))
    y = true;
end


end