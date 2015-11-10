function varargout = get_chunk(obj, varargin)

import physioset.

if nargout == 1,
    varargout{1} = get_chunk(obj.PointSet, varargin{:});
elseif nargout == 2,
    [varargout{1} varargout{2}] = ...
        get_chunk(obj.PointSet, varargin{:});
else
    ME = physioset.InvalidNargout(...
        'At most two output arguments are allowed');
    throw(ME);
end
end