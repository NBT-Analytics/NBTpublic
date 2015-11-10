function bool = is_valid_filename(name)
% IS_VALID_FILENAME - Tests whether a string is a valid file name
%
% test = is_valid_filename(name)
%
% Where
%
% NAME is a string with a filename (including full path)
% 
% TEST is true if NAME is a valid file name and false otherwise
% 
%
% See also: misc

% Documentation: pkg_misc.txt
% Description: Tests whether a filename is valid

bool = false;
if exist(name, 'file'),
    bool = true;
    return;
end

h = fopen(name, 'w');
if h < 0,
    return;
end
fclose(h);
delete(name);
bool = true;

end