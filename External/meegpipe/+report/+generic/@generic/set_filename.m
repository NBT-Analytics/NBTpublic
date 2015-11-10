function set_filename(obj, fname)

import mperl.file.spec.*;

fname = rel2abs(fname);

fname = abs2rel(fname, get_rootpath(obj));

obj.FileName = fname;



end