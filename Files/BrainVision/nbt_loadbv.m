function EEG=nbt_loadbv(filewithpath)
[hdrfile,path] = strtok(filewithpath(end:-1:1),'/');

[EEG] = pop_loadbv(path(end:-1:1), hdrfile(end:-1:1));

end