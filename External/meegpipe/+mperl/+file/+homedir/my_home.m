function home = my_home

import mperl.file.homedir.homedir;

obj = homedir;
home = obj.(mfilename);

end