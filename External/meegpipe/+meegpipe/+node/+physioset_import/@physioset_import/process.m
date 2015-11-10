function [data, dataNew] = process(obj, data, varargin)

import mperl.file.spec.catfile;
import meegpipe.node.globals;
import misc.var2name;
import pset.session;
import mperl.cwd.abs_path;
import mperl.file.spec.rel2abs;

dataNew = [];

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

savePath = globals.get.SavePath;
ext      = globals.get.DataFileExt;

if isempty(savePath),
    savePath = session.instance.Folder;
end

if ischar(data),
    [~, name] = fileparts(data);
else
    name = var2name(data);
end

savePath = abs_path(savePath);

fileName = catfile(savePath, [name ext]);

importer = get_config(obj, 'Importer');

importer.FileName = fileName;

inputData = data;
data = import(importer, data);

if verbose,
    if ischar(inputData),
        fprintf([verboseLabel 'Imported dataset ''%s'' from ''%s''\n\n'], ...
            get_name(data), rel2abs(inputData));
    end
   
   fprintf([verboseLabel 'Dataset %s has %d channels and %d ' ...
       ' samples (%.1f seconds) ...\n\n'], ...
       get_name(data), size(data,1), size(data,2), ...
       size(data,2)/data.SamplingRate);
end

if ~isempty(obj.DataSelector),
    select(obj.DataSelector, data);
end


end
