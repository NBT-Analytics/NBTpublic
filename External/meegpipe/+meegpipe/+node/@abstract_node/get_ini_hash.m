function hs = get_ini_hash(obj)

import datahash.DataHash;
ini    = get_ini(obj);

fid = fopen(ini, 'r');
iniBin = fread(fid);
fclose(fid);
hs = DataHash(iniBin);

end