function fileName = unique_filename(fileName, ignoreExt)

import datahash.DataHash;
import mperl.file.spec.catfile;
import misc.dir;

MAX_ITER    = 50;
HASH_LENGTH = 6;

if nargin < 2 || isempty(ignoreExt), ignoreExt = false; end

[path, name, origExt] = fileparts(fileName);

if isempty(path), path = pwd; end

% List of files in the same directory
fileList = dir(path);

if ignoreExt,
    ext = '';
    fileList = cellfun(@(x) regexprep(x, '\.\w*$', ''), fileList, ...
        'UniformOutput', false);
    fileList = unique(fileList);
else
    ext = origExt;
end

iter       = 0;
tmpName    = name;

while iter < MAX_ITER && ismember([tmpName ext], fileList),
    iter = iter + 1;
    hashVal = DataHash(randn(1,100));
    tmpName = [name '_' hashVal(1:HASH_LENGTH)]; 
end

if iter == MAX_ITER,
    error('I could not a unique file name based on stem: %s', fileName);
end

fileName = catfile(path, tmpName);
if numel(fileName) > 245,
    % Windows has problems handling long file names
    tmpName = DataHash(randn(1,100));
    tmpName = tmpName(1:HASH_LENGTH);
    fileName = catfile(path, tmpName);
end
if ~ignoreExt,
    fileName = [fileName origExt];
end

end