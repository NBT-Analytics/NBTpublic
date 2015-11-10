function outName = file_name_prepend(inName, txt)

[path, name, ext] = fileparts(inName);

outName = [path filesep txt name ext];

end