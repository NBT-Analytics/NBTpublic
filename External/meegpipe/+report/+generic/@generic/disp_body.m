function disp_body(obj)

disp_body@goo.abstract_configurable_handle(obj);
fprintf('%20s : %s\n',  'Title', obj.Title);
fprintf('%20s : %s\n',  'RootPath', obj.RootPath);
fprintf('%20s : %s\n',  'FileName', obj.FileName);
fprintf('%20s : %s\n',  'Parent', obj.Parent);
fprintf('%20s : %d\n',  'Level', obj.Level);


end