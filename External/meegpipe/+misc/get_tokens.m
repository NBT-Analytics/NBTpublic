function y = get_tokens(value, token_sep)
% GET_TOKENS Breaks a string into a set of blank-separated tokens
%
%   Y = get_tokens(STRING, SEP) returns a cell array that contains a list
%   of tokens in STRING which are mutually separated using character SEP.
%   Non-meaningful blank spaces are removed.
%
% See also: misc/strtrim

import misc.strtrim;

value = strtrim(value, token_sep);
idx = [strfind(value, token_sep) length(value)+1];
y = cell(size(idx));
first = 1;
for i = 1:length(idx)
    last = idx(i)-1;
    %field_value = strtrim(value(first:last));
    y{i} = value(first:last);
    first = last+2;    
end