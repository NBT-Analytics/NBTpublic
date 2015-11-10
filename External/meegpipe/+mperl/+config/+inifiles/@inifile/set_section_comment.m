function status = set_section_comment(obj, section, varargin)
% SET_SECTION_COMMENT - Sets a comment for a given section

import mperl.perl;

varargin = cellfun(@(x) mperl.char(x), varargin, 'UniformOutput', false);

check_file(obj);

status = '0';
count  = 0;
while ~strcmp(status, '1') && count < obj.MaxTries
    count = count + 1;
    status = perl('+mperl/+config/+inifiles/set_section_comment.pl', obj.File, ...
        section, obj.NewString{:}, varargin{:});
    pause(obj.Pause);
end


if strcmpi(status, '1'),
    status = true;
else
    status = false;
end

end