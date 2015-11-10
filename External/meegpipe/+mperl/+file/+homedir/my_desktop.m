function home = my_desktop

import mperl.file.homedir.homedir;

obj = homedir;
home = obj.(mfilename);

end