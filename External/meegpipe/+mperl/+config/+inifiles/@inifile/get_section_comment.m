function value = get_section_comment(obj, section, asArray)
% GET_SECTION_COMMENT - Gets section comments

%import mperl.perl;

import mperl.split;

check_file(obj);

value = perl('+mperl/+config/+inifiles/get_section_comment.pl', obj.File, ...
    section, obj.NewString{:});

if asArray,
    value = split(char(10), value);
end

if ischar(value) && asArray,
    value = {value};
end

if isempty(value), value = []; end

end