function fileName = def_filename(obj)
% DEF_FILENAME - Default report file name
%
% name = def_filename(obj)
%
% See also: abstract_generator

import mperl.file.spec.*;
import datahash.DataHash;

HASH_LENGTH = 4;
MAX_FILE_NAME_LENGTH = 40;

%% Path of the report
if ~isempty(get_rootpath(obj))
    path = obj.RootPath;
elseif ~isempty(obj.Parent),
    path = fileparts(obj.Parent);
else
    path = pset.session.instance.Folder;
end

%% Preferably, Filename should be based on report title
fileName = '';

if ~isempty(obj.Title),
    
    title = regexprep(lower(obj.Title), '[^\w]+', '-');
    title = strrep(title, '.', '-');
    if numel(title) < MAX_FILE_NAME_LENGTH,
        fileName = title;
    end
    
end

if isempty(fileName) || numel(fileName) > MAX_FILE_NAME_LENGTH,
    
    % Based on rootdir
    rDir = get_rootpath(obj);
    if ~isempty(rDir),
        dirs = splitdir(rDir);
        if numel(dirs{end} < 32),
            fileName = dirs{end};  
        end
    end
    
    randHash = DataHash(randn(1,1000));
    
    if isempty(fileName),                
        fileName = randHash(end-HASH_LENGTH:end);        
    elseif exist(fileName, 'file'),        
        fileName = [fileName '_' randHash(end-HASH_LENGTH:end)];        
    end
    
end

fileName = catfile(path, [fileName '.txt']);

fileName = rel2abs(fileName);

%% In Windows, we sometimes need to use extended path. See:
% http://msdn.microsoft.com/en-us/library/aa365247%28VS.85%29.aspx#maxpath
if ispc && numel(fileName) > 255,
    fileName = ['\\?\' fileName];
end





end