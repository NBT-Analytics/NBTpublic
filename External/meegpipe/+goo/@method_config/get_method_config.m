function cfg = get_method_config(obj, varargin)

if isempty(varargin),
    cfg = obj.MethodConfig;
    return;
end

value = obj.MethodConfig(varargin{1});
if isempty(value),
    cfg = {};
    return;
end

if nargin < 3,
    cfg = cell(value);
    return; 
end

cfg = subset(value, varargin(2:end));

cfg = cell(cfg);


end
