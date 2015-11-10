function obj = set_method_config(obj, varargin)

import exceptions.*
import mperl.join;

if numel(varargin) == 1 && isa(varargin{1}, 'goo.method_config'),
    obj = goo.method_config(varargin{1});
    return;
elseif numel(varargin) == 1,
    throw(InvalidArgValue('varargin{1}', ...
        'Argument must be a goo.method_config object'));
end

if numel(varargin) > 2 && ~iscell(varargin{2}),
    varargin{2} = varargin(2:end);
    varargin(3:end) = [];
end


i = 1;
while i < numel(varargin)
    
    methodName = varargin{i};
    newCfg  = varargin{i+1};
    i       = i + 2;
    
    if isa(newCfg, 'goo.method_config'),
        newCfg = get_method_config(newCfg, methodName);
    end
    
    if isa(newCfg, 'mjava.hash')
        newCfg = cell(newCfg);
    end
    
    if isempty(obj.MethodConfig),
        % This should never happen, unless you are working with a physioset
        % that was generated in an old version of meegpipe. Keep it just in
        % case!
        obj.MethodConfig = mjava.hash;
    end
         
    methodCfg = obj.MethodConfig(methodName);
    
    if isempty(methodCfg), methodCfg = mjava.hash; end
  
    for j = 1:2:numel(newCfg)
       % Update existing configuration for this method
       methodCfg(newCfg{j}) = newCfg{j+1};
    end
   
    obj.MethodConfig(methodName) = methodCfg;
    
end

end