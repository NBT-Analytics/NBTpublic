function dirName = find_latest_dir(rootDir, fullPath)

import mperl.file.spec.catdir;
import mperl.file.spec.rel2abs;

if nargin < 2 || isempty(fullPath),
    fullPath = true;
end

dirNames = misc.dir(rootDir, '\d{6,}(_|-)\d+$');

if isempty(dirNames),
    dirName = '';
    return;
end

dirNames = sort(dirNames);
dirName = dirNames{end};

if fullPath,
    dirName = catdir(rel2abs(rootDir), dirName);
end


end