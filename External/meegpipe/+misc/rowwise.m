function varargout = rowwise(varargin)
% ROWWISE - Ensure rowwise data samples in data matrix
%
%   [x, y, z, ...] = rowwise(x, y, z, ...)
%
%
% See also: misc

varargout = cell(1, nargin);
for i = 1:nargin
    if size(varargin{i}, 1) > size(varargin{i}, 2),
        varargout{i} = varargin{i}';
    end
end



end