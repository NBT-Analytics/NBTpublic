function mline = str2multiline(str, lineLength, prefix, postfix)
% STR2MULTILINE - Creates multiline string
%
% mline = str2multiline(str);
% mline = str2multiline(str, lineLength);
% mline = str2multiline(str, lineLength, prefix, postfix);
%
% Where
%
% STR is a string (a unidimensional char array)
%
% LINELENGTH is the number of characters per line. Default: 75.
%
% PREFIX is an optional string to precede each generated line. Default: ''
%
% POSTFIX is an optional string to follow each generated line. Default: ''
%
% See also: misc

% Documentation: pkg_misc_string.txt
% Description: Creates multiline string

import misc.quote;

if nargin < 2 || isempty(lineLength),
    lineLength = 75;
end

if nargin < 3 || isempty(prefix),
    prefix = '';
end

if nargin < 4 || isempty(postfix),
    postfix = '';
end

% ensure that there are no newlines already in str
str = [strrep(str, char(10), ' ') ' '];

lineLength = lineLength - numel(postfix) - numel(prefix);

% remove hyperlinks
str = regexprep(str, '<a href=".+?">(.+?)</a>', '$1');

regex = sprintf('(.{%d,%d})\\s+', 1, lineLength);

mline = regexprep(str, regex, [prefix '$1' postfix char(10)]);

mline(end) = [];


end