function fname = sanitize_filename(fname)



[path, name, ext] = fileparts(fname);

path = sanitize_path(path);
name = sanitize_name(name);
ext  = sanitize_ext(ext);

if ~isempty(path),
    fname = [path '/' name ext];
else
    fname = [name ext];
end


end

function path = sanitize_path(path)

OK_CHARS = 'a-zA-Z0-9 .,-_/';

path = strrep(path, '\', '/');
path = regexprep(path, '/{3,}', '/');
path = regexprep(path, '.+/{2,}', '');
path = regexprep(path, '\s+', '_');
path = regexprep(path, '([^/\.])\.+([^/\.]*)', '$1');
path = regexprep(path, sprintf('[^%s]', OK_CHARS), '');

end


function name = sanitize_name(name)

OK_CHARS = 'a-zA-Z0-9 ,-_';

name = regexprep(name, sprintf('[^%s]', OK_CHARS), ''); 
% This shouldnt be needed, but it is...
name = regexprep(name, '\^+', '');
% We don't want spaces
name = regexprep(name, '\s+', '_');
if isempty(name),
    [~, name] = fileparts(tempname);
end

end

function ext = sanitize_ext(ext)

OK_CHARS = 'a-zA-Z0-9 ,-_';

ext = regexprep(ext, sprintf('[^%s]', OK_CHARS), ''); 
if numel(ext) > 1,
    ext = ['.' ext];
else 
    ext = '';
end

end