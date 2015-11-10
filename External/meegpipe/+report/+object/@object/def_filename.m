function fileName = def_filename(obj)
% DEF_FILENAME - Default report file name
%
% name = def_filename(obj)
%
% ## Notes:
% 
% * This method overrides the parent definition. The reason is that the
%   parent method will always generate a unique file name but, for object
%   reports, it is undesirable to do that when reporting on identical
%   objects (e.g. hashable objects with an identical hash code).
%
% See also: object

% Description: Default report file name
% Documentation: class_generic.txt

import mperl.file.spec.*;
import goo.pkgisa;
import datahash.DataHash;

HASH_LENGTH = 4;
MAX_LENGTH = 15;

%% Path of the report
if ~isempty(get_rootpath(obj))
    path = get_rootpath(obj);
elseif ~isempty(obj.Parent),
    path = fileparts(obj.Parent);
else
    path = pset.session.instance.Folder;
end

%% Preferably, Filename should be based on report title
if ~isempty(get_title(obj)),
    
    title = regexprep(lower(get_title(obj)), '[^\w]+', '-');
    fileName = strrep(title, '.', '-');
    
else
    
    % Based on rootdir
    rDir = get_rootpath(obj);
    if ~isempty(rDir),
        dirs = splitdir(rDir);
        fileName = dirs{end};
    else
        fileName = '';
    end    
    
end

if numel(fileName) > MAX_LENGTH,
    fileName = DataHash(rand(1,100));
    fileName = fileName(1:HASH_LENGTH);
end

%% Create a hash code identifying this collection of objects
objArray = obj.Objects;
if all(cellfun(@(x) pkgisa(x, 'hashable') || pkgisa(x, 'hashable_handle'), ...
        objArray)),
   
    hashCode = cellfun(@(x) get_hash_code(x), objArray, ...
        'UniformOutput', false);
    hashCode = DataHash(hashCode);
    
    if isempty(fileName),
        fileName = hashCode;
    else
        fileName = [fileName '_' hashCode(end-HASH_LENGTH:end)];
    end
    
end

%% Last resort: just use a random file name
if isempty(fileName),
    
    randHash = DataHash(randn(1,1000));
    fileName = randHash(end-HASH_LENGTH:end);
    
end

fileName = catfile(path, [fileName '.txt']);

fileName = rel2abs(fileName);

%% In Windows, we sometimes need to use extended path. See:
% DON'T DO THIS!
% http://msdn.microsoft.com/en-us/library/aa365247%28VS.85%29.aspx#maxpath
% if ispc && numel(fileName) > 255,
%     fileName = ['\\?\' fileName];
% end



end