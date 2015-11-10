function value = section_exists(obj, section)
% SECTION_EXISTS - Checks whether a section exists

import mperl.perl

if nargin < 2 || isempty(section),
    
    value = false;
    return;
    
end

if isempty(obj.HashObject),
    
    check_file(obj);
    
    value = perl('+mperl/+config/+inifiles/section_exists.pl', obj.File, ...
        section, obj.NewString{:});
    
    if strcmpi(value, '1'),
        
        value = true;
        
    else
        
        value = false;
        
    end
    
else    
    
    value = ismember(section, keys(obj.HashObject));
    
end


end