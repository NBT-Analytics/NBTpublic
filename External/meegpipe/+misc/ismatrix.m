function bool = ismatrix(varargin)
% ISMATRIX - Backwards compatibility of MATLAB's built-in ismatrix
%
% bool = ismatrix(x)
%
% Where
%
% BOOL is true if X is a numeric matrix and is false otherwise.
%
% See also: misc

% Description: Alternative to MATLAB's built-in ismatrix
% Documentaiton: pkg_misc.txt

if exist('ismatrix', 'builtin'),
    bool = builtin('ismatrix', varargin{:});
else
    dims = ndims(varargin{1});
    bool = (dims == 2 && all(dims > 0));
end

end