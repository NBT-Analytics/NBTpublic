function value = groups(obj)
% GROUPS - Returns a cell array with section names

import mperl.perl;
import mperl.split;

check_file(obj);

value = perl('+mperl/+config/+inifiles/groups.pl', obj.File, ...
    obj.NewString{:});

splittedValue = split(char(10), value);

if ~isempty(splittedValue), 
    value = splittedValue;
end
    
if isempty(value), value = []; end


end