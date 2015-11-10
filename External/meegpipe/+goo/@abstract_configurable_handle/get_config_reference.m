function val = get_config_reference(obj, varargin)

if nargin < 2,
    val = obj.Config;
    return; 
end

val = get(obj.Config, varargin{:});

end