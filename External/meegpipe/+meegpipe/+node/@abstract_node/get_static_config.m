function cfg = get_static_config(obj)
% GET_PRIVATE_CONFIG - Get private confi

import mperl.config.inifiles.inifile;
import mperl.file.spec.catfile;

if isempty(obj.Static_),
    iniFile = catfile(get_full_dir(obj), ['.' get_name(obj) '-static.ini']);
    warning('off', 'inifile:CreatedIniFile');
    obj.Static_ = inifile(iniFile);
    warning('on', 'inifile:CreatedIniFile');
end

cfg = obj.Static_;




end
