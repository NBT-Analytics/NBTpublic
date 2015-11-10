function load(obj)

import pset.globals;

headerExt = globals.evaluate.HdrFileExt;

files = dir(obj.Folder);

for i = 1:numel(files),
    [~, name, ext] = fileparts(files(i).name);
    if strcmpi(ext, headerExt),
        cmd = sprintf('load(''%s%s%s%s'', ''-mat'')', ...
            obj.Folder, filesep, name, headerExt);
        evalin('base', cmd);
    end
end


end