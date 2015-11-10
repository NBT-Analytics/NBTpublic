function cfg = get_runtime_config(obj, forceRead)
% GET_RUNTIME_CONFIG - Get runtime configuration object
%
% cfg = get_runtime_config(obj)
%
% Where
%
% CFG is a mperl.config.inifiles.inifile object.
%
% See also: mperl.config.inifiles.inifile


import mperl.config.inifiles.inifile;
import mperl.file.spec.catfile;

if nargin < 2, 
    forceRead = false;
end

if forceRead || isempty(obj.RunTime_),
    iniFile = catfile(get_full_dir(obj), [get_name(obj) '.ini']);
    warning('off', 'inifile:CreatedIniFile');
    obj.RunTime_ = inifile(iniFile);
    warning('on', 'inifile:CreatedIniFile');
end

cfg = obj.RunTime_;


end