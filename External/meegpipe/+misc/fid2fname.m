function fname = fid2fname(fid)

try

if isa(fid, 'io.safefid') || isa(fid, 'safefid.safefid'),
    fname = fid.FileName;
elseif isnumeric(fid) && fid == 1,
    fname = NaN;
else
    fname = fopen(fid);
end
catch
    caca=5;
end

end