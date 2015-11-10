function count = print_title(obj, title, level)
% PRINT_TITLE - Prints report title
%
% count = print_title(obj, title, level)
%
% Where
%
% TITLE is the report title to be printed (a string).
%
% LEVEL is level of the title. Use 1 for the highest level title and higher
% integer values for subtitles. By default LEVEL is set to 1.
%
% COUNT is the actual number of characters written to the report.
%
% See also: print_code, print_link, print_file_link

if nargin < 3 || isempty(level), level = get_level(obj); end

if nargin < 2 || isempty(title), title = get_title(obj); end

count = 0;

if isempty(title), return; end

if level == 1,
    count = fprintf(obj, '%s\n%s\n\n', title, repmat('=', 1, 10));
else
    hdr = repmat('#', 1, level);
    count = fprintf(obj, '%s %s\n\n', hdr, title);
end



end
