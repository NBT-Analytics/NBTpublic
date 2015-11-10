function touch(filename)

if ~exist(filename, 'file'),
    path = fileparts(filename);
    if ~exist(path, 'dir'), mkdir(path); end
    fid = fopen(filename, 'w');
    fclose(fid);
end