function [repFolder, repFileFolder] = def_rootpath(obj, varargin)

import mperl.file.spec.catdir;

saveDir = get_save_dir(obj.Node_);
repFolder = [saveDir filesep 'remark'];
repFileFolder = [saveDir filesep 'remark_files'];

end