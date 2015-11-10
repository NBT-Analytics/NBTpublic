function disp_body(obj)

import misc.any2str;

disp_body@report.generic.generic(obj);

fprintf('%20s : %s\n',  'Objects', any2str(obj.Objects));

end