function disp(obj)

import goo.disp_class_info;


disp_class_info(obj);

disp_body(obj);

cfg = get_config_handle(obj);

if ~isempty(cfg) && numel(fieldnames(cfg)) > 0,
    fprintf('\nNode configuration options:\n\n');
    disp_body(cfg);
end

crit = get_config(obj, 'Criterion');

if ~isempty(crit),
    fprintf('\nNode criterion properties:\n\n');
    
    if isa(crit, 'goo.configurable'),
        critCfg = get_config(crit);
        disp_body(critCfg);
    else
        warning('off', 'MATLAB:structOnObject');
        disp(struct(crit));
        warning('on', 'MATLAB:structOnObject');
    end
end

fprintf('\n');

end

