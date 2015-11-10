function value = sections(obj)
% SECTIONS - Returns a cell array with section names

%import mperl.perl;

import mperl.split;

if isempty(obj.HashObject),
    
    check_file(obj);
    
    value = perl('+mperl/+config/+inifiles/sections.pl', obj.File, ...
        obj.NewString{:});
    
    splittedValue = split(char(10), value);
    
    if ~isempty(splittedValue),
        value = splittedValue;
    end
    
else
    
    value = keys(obj.HashObject);
    
end

    
if isempty(value), value = {}; end

if ischar(value), value = {value}; end

end