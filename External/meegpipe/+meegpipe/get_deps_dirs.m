function dirList = get_deps_dirs()

import mperl.file.spec.*;

cfg = meegpipe.get_config;
depList = group_members(cfg, 'matlab');
if ischar(depList) && ~isempty(depList), depList = {depList}; end

dirList = {};
for i = 1:numel(depList)
    
    uniqueFile = val(cfg, depList{i}, 'unique_mfile');    
    fullPathToFile = which(uniqueFile);
    if ~isempty(fullPathToFile),     
        depPath = fileparts(fullPathToFile);
        depPath = strrep(rel2abs(depPath), '\', '/');
        dirList = [dirList;{depPath}];
    end
    
end

end