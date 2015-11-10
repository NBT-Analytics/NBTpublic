function home = my_pictures

import mperl.file.homedir.homedir;

obj = homedir;
home = obj.(mfilename);

end