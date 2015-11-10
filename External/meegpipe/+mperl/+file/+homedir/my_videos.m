function home = my_videos

import mperl.file.homedir.homedir;

obj = homedir;
home = obj.(mfilename);

end