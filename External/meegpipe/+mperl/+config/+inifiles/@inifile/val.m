function value = val(obj, section, parameter, asArray)
% VAL - Fetches values from the config file

import mperl.perl;
import mperl.split;
import mperl.join;

if iscell(parameter),
    
    value = cell(1, numel(parameter));
    
    for i = 1:numel(parameter)
        value{i} = val(obj, section, parameter{i});
    end
    
    return;
    
end

if nargin < 4 || isempty(asArray),
    asArray = false;
end

if isempty(obj.HashObject),
    
    check_file(obj);
    
    args = obj.NewString;
    
    value = perl('+mperl/+config/+inifiles/val.pl', obj.File, ...
        section, parameter, args{:});
    
else
    
    value = obj.HashObject(section, parameter);
    
end

if ischar(value) && asArray && ~isempty(strfind(value, char(10))),
    
    value = split(char(10), value);
    
elseif iscell(value) && ~asArray,
    
    value = join(char(10), value);
    
end

if isempty(value),
    
    value = [];
    
elseif ischar(value) && asArray,
    
    value = {value};
    
end

if isempty(value), value = []; end


end