function path = stripname(pathStr)
% STRIPNAME - Strips the file name from a path
%
%
% newPath = stripname(path)
%
%
% Where
%
% PATH is the original path
%
% NEWPATH is the same as PATH but with the file name stripped
%
%
% 
% ## Notes:
%
% * This scripts is just a short-cut to the following combination:
%   [vol, dirs] = splitpath(pathStr);
%   newPath = catdir(vol, dirs);
%
%
%
% See also: filespec.splitpath


% (c) German Gomez-Herrero, german.gomezherrero@kasku.org

% Documentation: pkg_filespec.txt
% Description: Strip file names from the directory portion of a path

import mperl.file.spec.splitpath;
import mperl.file.spec.catdir;

[vol, dirs] = splitpath(pathStr);

if iscell(vol),
    path = cell(size(vol));
    for i = 1:numel(vol)
       path{i} = catdir(vol{i}, dirs{i}); 
    end
else
    path = catdir(vol, dirs);
end


end