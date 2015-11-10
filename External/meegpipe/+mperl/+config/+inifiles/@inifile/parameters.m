function value = parameters(obj, section)
% PARAMETERS - Returns a cell array with section parameters

import mperl.perl;
import mperl.split;

check_file(obj);

value = perl('+mperl/+config/+inifiles/parameters.pl', obj.File, section, ...
    obj.NewString{:});

if isempty(value), value = {}; return; end

splittedValue = split(char(10), value);

if ~isempty(splittedValue), 
    value = splittedValue;
end
    
if ischar(value), value = {value}; end



end