function obj = set(obj, varargin)

import goo.get_cfg_class;

cfgClass = get_cfg_class(obj);

if nargin == 2 && isa(varargin{1}, cfgClass),
    obj.Config = varargin{1};
else
    obj.Config = set(obj.Config, varargin{:});
end


end