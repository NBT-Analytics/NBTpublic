function [data, dataNew] = process(obj, data, varargin)

import mperl.file.spec.catfile;

dataNew = [];

fileName = get_config(obj, 'Filename');

filePath = get_config(obj, 'Path');

if isempty(filePath),
   if obj.Save,
       % To be stored in the node directory
       filePath = get_full_dir(obj, data);
   else
       filePath = get_tempdir(obj);
   end
end

if isempty(fileName)
    if obj.Save
        fileName = catfile(filePath, get_name(data));
    else
        [~, name] = fileparts(tempname);
        fileName = catfile(filePath, name);
    end
end

data = copy(data,    ...  
    'Path',         get_config(obj, 'Path'), ...
    'PostFix',      get_config(obj, 'PostFix'), ...
    'PreFix',       get_config(obj, 'PreFix'), ...
    'DataFile',     fileName, ...
    'Temporary',    ~obj.Save);

end