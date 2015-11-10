function ini = get_ini(obj)

import mperl.file.spec.catfile;
import misc.touch;

iniPath = get_rootpath(obj.Report);
ini = catfile(iniPath, strrep(get_name(obj), '.', '-'));
ini = [ini '.ini'];
if ~exist(ini, 'file'),
    touch(ini);
end

end