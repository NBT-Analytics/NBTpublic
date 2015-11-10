function save_hash(obj, nodeObj)

import misc.touch;
import mperl.file.spec.catfile;

hashPath = get_rootpath(obj);

nodeHash = get_hash(nodeObj);

touch(catfile(hashPath, [nodeHash '.hash']));

end