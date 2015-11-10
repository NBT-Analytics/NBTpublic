function cfg = get_config(varargin)
% GET_CONFIG - Get user configuration options for package physioset

import mperl.config.inifiles.inifile;
import sensors.root_path;
import mperl.file.spec.catfile;

sysIni  = catfile(root_path, 'sensors.ini');
userIni = 'sensors.ini';

if exist(userIni, 'file'),
    cfg = inifile(which('sensors.ini'));
elseif exist(sysIni, 'file')    
    cfg = inifile(sysIni);
else
    error('No configuration file!');
end

if nargin < 1,
    return;
end

cfg = val(cfg, varargin{:});


end