function home = my_data

import mperl.file.homedir.homedir;

obj = homedir;
home = obj.(mfilename);

end