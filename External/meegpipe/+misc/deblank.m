function s = deblank(s, value)
% DEBLANK Remove trailing separators
%
%   Y = DEBLANK(S, SEP) removes any trailing or starting separator
%   characters (SEP) from string S. Note that this differs from the
%   built-in DEBLANK function in that the latter removes only trailing
%   spaces.
%
% See also: misc/STRTRIM, STRTRIM, DEBLANK

if nargin < 2 || isempty(value), value = ' '; end

if isempty(s), return; end

if all(s == ' '),
    s = ' ';
    return;
end

nl = length(s);
remove = false(1,nl);
i = 1;
while i<=nl && s(i)==value,
    remove(i) = true;
    i = i + 1;
end
if remove(nl),
    s = '';
    return;
end
%s(remove) = [];
%nl = length(s);
%remove = false(1,nl);
j = 0;
while j<nl && s(end - j)==value,
    remove(end-j) = true;
    j = j + 1;
end
s(remove) = [];
