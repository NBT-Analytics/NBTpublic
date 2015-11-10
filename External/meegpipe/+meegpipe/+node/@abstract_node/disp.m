function disp(obj)

import goo.disp_class_info;


disp_class_info(obj);

disp_body(obj);

cfg = get_config_handle(obj);

if ~isempty(cfg) && numel(fieldnames(cfg)) > 0,
    fprintf('\nNode configuration options:\n\n');
    disp_body(cfg);
end

if ~isempty(get_report(obj)),
    fprintf('\nNode report properties:\n\n');
    disp_body(get_report(obj));
end

fprintf('\n');

end