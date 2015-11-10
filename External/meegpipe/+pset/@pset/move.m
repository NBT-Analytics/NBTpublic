function obj = move(obj, newName, varargin)

import misc.process_arguments;
import pset.globals;

opt.verbose = true;
opt.overwrite = false;
opt.stdout = 1;

[~, opt] = process_arguments(opt, varargin);

if ischar(opt.stdout),
    [path, name, ext] = fileparts(opt.stdout);
    if isempty(path),
        path = session.instance.Folder;
    end
    stdout = fopen([path filesep name ext], 'w');
else
    stdout = opt.stdout;
end

[pathNew, nameNew, extNew] = fileparts(newName);
[pathOld, nameOld] = fileparts(obj.DataFile);

if ~isempty(extNew) && ~strcmpi(extNew, globals.get.DataFileExt),
    warning('move:invalidFileExt', ...
        'Ignoring file extension ''%s''', extNew);
end

if isempty(pathNew),
    pathNew = pathOld;
end

fileNew = [pathNew filesep nameNew globals.get.DataFileExt];
fileNewHdr = [pathNew filesep nameNew globals.get.HdrFileExt];

if exist(fileNew, 'file') && opt.overwrite,
    delete(fileNew);
    headerFile = [pathNew filesep nameNew globals.get.HdrFileExt];
    if exist(headerFile, 'file'),
        delete(headerFile);
    end
elseif exist(fileNew, 'file'),
    ME = MException('move:invalidFile', ...
        ['File %s already exists. Use ''overwrite'' option to force ' ...
        'moving the file'], fileNew);
    throw(ME);
end

if opt.verbose,
    fprintf(stdout, '(move) Moving %s -> %s ...', nameOld, nameNew);
end
destroy_mmemmapfile(obj);
% For some stupid reason MATAB movefile refuses to just "rename" the file
% and instead copies it. So don't use it!
% movefile(obj.DataFile, fileNew);
if isunix,
    cmd = 'mv %s %s';
else
    cmd = 'move %s %s';
end
[status, res] = system(sprintf(cmd, obj.DataFile, fileNew));
if status > 0,
    error(res);
end
obj.DataFile = fileNew;
obj.HdrFile  = fileNewHdr;
make_mmemmapfile(obj);

if ~obj.Temporary,
    save(obj);
end
if opt.verbose,
    fprintf(stdout, '[done]\n');
end

if ischar(opt.stdout),
    fclose(stdout);
end


end