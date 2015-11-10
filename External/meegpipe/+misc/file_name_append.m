function outName = file_name_append(inName, txt)

[path, name, ext] = fileparts(inName);

outName = [path filesep name txt ext];

end