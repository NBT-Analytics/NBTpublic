function value = get_runtime(obj, varargin)
% GET_RUNTIME - Get runtime node parameter
%
% value = get_runtime(obj, param1, param2, ...)
%
% Where
%
% PARAM1, PARAM2, ... are the runtime parameter names (strings).
%
% VALUE is NaN if the given parameter does not exist (is not mentioned in
% the runtime .ini file). It is empty ([]) if the parameter exists but no
% value is assigned to it. Otherwise, it can be either a numeric array or a
% cell array of strings. 
%
% See also: +pset/+node/@abstract_node/get_runtime

if numel(varargin) > 1 && mod(numel(varargin), 2) && islogical(varargin{end}),
    % Force re-reading the config
    obj.RunTime_ = get_runtime_config(obj, true);
    varargin = varargin(1:end-1);
end
    
if isempty(obj.RunTime_),
    % The "true" means: force re-reading the config
    obj.RunTime_ = get_runtime_config(obj, true);
end

if exists(obj.RunTime_, varargin{1:2}),
    value = val(obj.RunTime_, varargin{:}, true);
else
    value = NaN;
end

end