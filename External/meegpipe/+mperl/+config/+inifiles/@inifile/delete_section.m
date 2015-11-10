function status = delete_section(obj, section)
% DELETE_SECTION - Deletes a section from the config file

import mperl.perl;

if nargin < 2 || isempty(section),
    status = false;
    return;
end

check_file(obj);

status = '0';
count  = 0;
while ~strcmp(status, '1') && count < obj.MaxTries
    count = count + 1;
    status = perl('+mperl/+config/+inifiles/delete_section.pl', obj.File, ...
        section, obj.NewString{:});
    pause(obj.Pause);
end

if strcmpi(status, '1'),
    status = true;
    % Update the hash, if it exists
    if ~isempty(obj.HashObject),
        obj.HashObject = delete(obj.HashObject, section);
    end
else
    status = false;
end


end