function value = group_members(obj, group)
% GROUP_MEMBERS - Returns a cell array with the members of a group

import mperl.perl;
import mperl.split;

if nargin < 2 || isempty(group),
    value = [];
    return;
end

check_file(obj);

value = perl('+mperl/+config/+inifiles/group_members.pl', obj.File, group, ...
    obj.NewString{:});

splittedValue = split(char(10), value);

if ~isempty(splittedValue), 
    value = splittedValue;
end
    
if isempty(value), value = []; end


end