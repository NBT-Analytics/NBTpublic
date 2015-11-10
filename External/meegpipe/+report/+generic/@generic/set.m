function obj = set(obj, varargin)

import goo.get_cfg_class;
import misc.process_arguments;

cfgClass = get_cfg_class(obj);

if nargin == 2 && isa(varargin{1}, cfgClass),
    obj.Config = varargin{1};
else
    obj.Config = set(obj.Config, varargin{:});
    
    props = {'RootPath', 'FileName', 'Parent', 'FID', 'CloseFID', 'Level', ...
        'Title'};
    for i = 1:numel(props)
       opt.(props{i}) = obj.(props{i});
    end
    [~, opt] = process_arguments(opt, varargin);
    for i = 1:numel(props)
        obj.(props{i}) = opt.(props{i});
    end
    
end


end