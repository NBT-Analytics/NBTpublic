function home = my_music

import mperl.file.homedir.homedir;

obj = homedir;
home = obj.(mfilename);

end