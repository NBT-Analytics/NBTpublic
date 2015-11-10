function [status, msg] = make_tidy(obj, indentChar)



if nargin < 2 || isempty(indentChar),
    indentChar = '"  "';
end

[status, msg] = perl('+mperl/+xml/+tidy/make_tidy.pl', obj.Filename, indentChar);


end