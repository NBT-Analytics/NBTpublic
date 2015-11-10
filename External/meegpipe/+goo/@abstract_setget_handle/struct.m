function str = struct(obj)

import goo.force_builtin;

% built-in properties
[~, props] = fieldnames(obj);
str = [];
for i = 1:numel(props)
    value = force_builtin(obj.(props{i}));    
    str.(props{i}) = value;
end

% meta-properties
str.Info = get_meta(obj);

end