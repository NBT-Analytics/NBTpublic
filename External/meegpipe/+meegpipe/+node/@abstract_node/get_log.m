function fid = get_log(obj, filename)

import safefid.safefid;
import mperl.file.spec.catfile;

[~, name, ext] = fileparts(filename);

filename = catfile(get_full_dir(obj), [name ext]);

fid = safefid.fopen(filename, 'a+');

end