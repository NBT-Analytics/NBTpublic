function status = add_section(obj, section)
% ADD_SECTION - Adds a section to the config file

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
    status = perl('+mperl/+config/+inifiles/add_section.pl', obj.File, ...
        section, obj.NewString{:});
    pause(obj.Pause);
end

if strcmpi(status, '1'),
    status = true;
    % Update the hash, if it exists
    if ~isempty(obj.HashObject),
        obj.HashObject(section) = [];
    end
else
    status = false;
end


end