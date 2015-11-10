function obj = set_config(obj, varargin)

if nargin < 2, 
    return;
end

if nargin < 3 && isa(varargin{1}, 'goo.configurable'),
    obj.Config = clone(varargin{1});
    return;
end

obj.Config = set(obj.Config, varargin{:});

end