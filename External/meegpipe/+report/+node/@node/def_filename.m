function fileName = def_filename(obj)
% DEF_FILENAME - Default report file name
%
% name = def_filename(obj)
%
% See also: node

% Description: Default report name
% Documentation: class_node.txt

import mperl.file.spec.catdir;
import mperl.file.spec.catfile;

path = get_rootpath(obj);

if isempty(path) && ~isempty(obj.Parent),
    path = fileparts(get_parent(obj));    
elseif isempty(path)
    path = pwd;
end

fileName = catfile(path, 'index.txt');

% DON'T DO THIS!
% In Windows, we sometimes need to use extended path. See:
% http://msdn.microsoft.com/en-us/library/aa365247%28VS.85%29.aspx#maxpath
% Not sure if this helps at all...
% if ispc && numel(fileName) > 255,
%     fileName = ['\\?\' fileName];
% end



end