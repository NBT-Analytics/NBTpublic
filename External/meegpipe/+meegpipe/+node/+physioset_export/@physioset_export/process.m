function [data, fileName] = process(obj, data, varargin)

import mperl.file.spec.catfile;
import meegpipe.node.globals;
import misc.var2name;
import pset.session;
import mperl.cwd.abs_path;

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

savePath = globals.get.SavePath;

if isempty(savePath),
    savePath = get_full_dir(obj);
end


exporter = get_config(obj, 'Exporter');

if isempty(exporter.FileName)
    name = get_name(data);
    fileName = catfile(savePath, name);
    exporter.FileName = fileName;
elseif isempty(fileparts(exporter.FileName)),
    % no path in the FileName, assume savePath
    [~, name] = fileparts(exporter.FileName);
    exporter.FileName = catfile(savePath, name);
end

fileName = export(exporter, data);

if verbose,
    fprintf([verboseLabel 'Exported dataset ''%s'' to ''%s'' ...\n\n'], ...
        get_name(data), fileName);
end


end
