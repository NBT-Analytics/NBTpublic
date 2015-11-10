function bool = isstring(x)
% ISSTRING - Returns true for strings and false otherwise
%
% bool = isstring(x)
%
% Where 
%
% BOOL is true if and only if X is a string (a vector of chars).
%
% See also: ischar, ismatrix, misc

% Description: Check whether a variable is a string
% Documentation: pkg_misc.txt

import misc.ismatrix;

bool = ischar(x) && ismatrix(x);