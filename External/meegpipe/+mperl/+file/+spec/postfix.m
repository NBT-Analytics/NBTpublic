function fileOut = postfix(fileIn, str)
% POSTFIX - Appends a postfix to file name

import mperl.file.spec.postfix;
import mperl.file.spec.catdir;

if nargin < 1 || isempty(fileIn),
    fileOut = [];
    return;
end

if nargin < 2 || isempty(str),
    fileOut = fileIn;
    return;
end

if iscell(fileIn) && ~iscell(str),
    fileOut = cell(size(fileIn));
    for i = 1:numel(fileIn),
        fileOut{i} = postfix(fileIn{i}, str);
    end
    return;
elseif iscell(str) && ~iscell(fileIn),
    fileOut = cell(size(str));
    for i = 1:numel(str)
        fileOut{i} = postfix(fileIn, str{i});
    end
    return;
elseif ~ischar(fileIn) || ~ischar(str),
   ME = MException('file:spec:postfix:InvalidType', ...
       'Character arrays are expected as input arguments');
   throw(ME);
end

[path, name, ext] = fileparts(fileIn);
fileOut = catdir(path, [name str ext]);




end