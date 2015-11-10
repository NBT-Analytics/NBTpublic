function [path, fname, extension, version] = fileparts(name)
% Same as built-in but takes care of file names that contain dots

[path, fname, extension, version] = fileparts(name);


idx = strfind(extension, '.');
if length(idx)>1,
    fname = [fname extension(1:idx(end)-1)];
    extension = extension(idx(end):end);
end
    

