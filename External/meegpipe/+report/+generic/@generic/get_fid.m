function fid = get_fid(obj)

import mperl.file.spec.catfile;
import safefid.safefid;

fid = obj.FID;

if isa(fid, 'safefid.safefid') && ~fid.Valid,
    fileName = catfile(obj.RootPath, obj.FileName);
    % A quick and dirty fix. This should never happen, but it does due to a
    % bug hidden somewhere
    obj.FID = [];
    fid     = []; %#ok<NASGU>
    pause(1);
    fid = safefid.fopen(fileName, 'a+');
    fprintf(fid, '\n\n');
    obj.FID = fid;    
    if ~fid.Valid || ~obj.FID.Valid,
        error('Cannot open %s for writing', fileName);
    end
end

end