function s = strtrim(s, value)
% STRTRIM Remove insignificant separator characters
%   S = STRTRIM(M, SEP) removes insignificant separator characters (SEP)
%   from string M.
%
% See also: misc/DEBLANK, STRTRIM, DEBLANK

if nargin < 2 || isempty(value), value = ' '; end

import misc.deblank;

% Remote trailing and heading separators
s = deblank(s, value);

is_sep = diff((s == value));

is_sep_end = find(is_sep == -1)-1;
is_sep_begin = find(is_sep == 1) + 1;

items2remove = false(size(s));
for i = 1:length(is_sep_end)
    items2remove(is_sep_begin(i):is_sep_end(i)) = true;
end
s(items2remove) = [];

