function varargout = colwise(varargin)

import misc.rowwise;

varargout = cell(size(varargin));

for i = 1:numel(varargout)
   varargout{i} = rowwise(varargin{i})'; 
end

end