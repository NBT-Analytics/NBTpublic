function y = split(sep, str, noSep)
% SPLIT - Splits a string into a cell array of strings
%
% y = split(sep, str, noSep)
%
% Where
%
% STR is a char array.
%
% SEP is the separator character based on which the input string should be
% splitted.
%
% Y is a cell array that contains the portions of STR that are separated by
% separator SEP.
%
% NOSEP is a logical scalar. If set to true and the separator is not found
% in STR, then split() will return the input string, i.e. Y=STR. On the
% other hand, if NOSEP=false and the separator was not found with STR then
% split() will return an empty value.
%
% See also: join


if nargin < 3 || isempty(noSep),
    noSep = false;
end

idx = strfind(str, sep);

if isempty(idx),
    if noSep,
        y = str;
    else
        y = [];
    end
    
    return;
end

nSep = numel(sep);

y = cell(numel(idx)+1,1);
first = 1;
for i = 1:numel(idx)
   last = idx(i)-1;
   y{i} = str(first:last);
   first = last+1+nSep;
end
y{i+1} = str(first:end);
if isempty(y{end}), y = y(1:end-1); end


end