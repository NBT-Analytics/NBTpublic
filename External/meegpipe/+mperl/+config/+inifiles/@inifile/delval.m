function status = delval(obj, section, parameter)
% NEWVAL - Assigns a new value to a parameter

import mperl.perl;

if nargin < 3 || isempty(parameter) || nargin < 2 || isempty(section),
    status = false;
    return;
end

if ~exists(obj, section, parameter),
    warning('mperl:config:infiles:inifile:delval:NotFound', ...
        'Parameter ''%s'' in section ''%s'' cannot be found in file ''%s''', ...
        section, parameter, obj.File);
end

check_file(obj);

status = '0';
count  = 0;
while ~strcmp(status, '1') && count < obj.MaxTries
    count = count + 1;
    status = perl('+mperl/+config/+inifiles/delval.pl', obj.File, ...
    section, parameter, obj.NewString{:});
    pause(obj.Pause);
end

if strcmpi(status, '1'),
    status = true;
    % Update the hash, if it exists
    if ~isempty(obj.HashObject),
        sectionHash = obj.HashObject(section);
        sectionHash = delete(sectionHash, parameter);
        
        obj.HashObject(section) = sectionHash;
        
    end
else
    status = false;
end



end