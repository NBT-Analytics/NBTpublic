function val = delete(file)

if isunix,
    val = system(['rm -f ' file]);
else
    delete(file);
end


end