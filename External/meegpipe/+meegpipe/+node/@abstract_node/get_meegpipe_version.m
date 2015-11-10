function vers = get_meegpipe_version(obj)

import safefid.safefid;

fName = get_vers_file(obj);

if ~exist(fName, 'file'),
    vers = '';
    return; 
end

fid = safefid.fopen(fName, 'r');
vers = fgetl(fid);



end