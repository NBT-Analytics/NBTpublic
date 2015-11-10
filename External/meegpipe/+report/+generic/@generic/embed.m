function obj = embed(obj, target)

import misc.fid2fname;

set_rootpath(obj, get_rootpath(target));
set_fid(obj, get_fid(target));
set_level(obj, get_level(target) + 1);

end