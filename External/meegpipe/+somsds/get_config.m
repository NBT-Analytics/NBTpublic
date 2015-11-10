function cfg = get_config(varargin)
% GET_CONFIG - Get user configuration options for EEGPIPE

import mperl.config.inifiles.inifile;
import somsds.root_path;
import mperl.file.spec.catfile;

sysIni  = catfile(root_path, 'somsds.ini');
userIni = 'somsds.ini';

if exist(userIni, 'file'),
    cfg = inifile(which('somsds.ini'));
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