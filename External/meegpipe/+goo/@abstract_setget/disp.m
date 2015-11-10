function disp(obj)

import goo.disp_class_info;

disp_class_info(obj);

if numel(obj) < 2,
    disp_body(obj);
end

if numel(obj) == 1 && ~isempty(meta_props(obj))
    
    disp('Meta-properties:');
    
    fprintf('\n');
    
    disp_meta(obj);
    
    fprintf('\n');
    
end

end