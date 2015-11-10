function value = exists(obj, section, parameter)
% EXISTS - Checks whether a parameter exists within a section


import mperl.perl;

if nargin < 3 || isempty(parameter) || nargin < 2 || isempty(section),
    value = false;
    return;
end

check_file(obj);

value = perl('+mperl/+config/+inifiles/exists.pl', obj.File, ...
    section, parameter, obj.NewString{:});

if strcmpi(value, '1'),
    value = true;
else
    value = false;
end

end