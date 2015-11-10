function val = get_config(obj, varargin)

if nargin < 2,
    val = clone(obj.Config);
    return; 
end

val = get(clone(obj.Config), varargin{:});


end