function y = split(sep, str)
% SPLIT - Splits a string into a cell array of tokens
%
%
% tokCell = filespec.split(sep, str)
%
% Where
%
% SEP is a separator expression, e.g. ',', or char(10) to use the newline
% character as separator
%
% STR is the string to be broken into token
%
% TOKCELL is a cell array of token strings
%
%
% See also: filespec

% Documentation: pkg_filespec.txt
% Description: Splits a string into a cell array of tokens
idx = strfind(str, sep);

if isempty(idx),
    y = [];
    return;
end

y = cell(numel(idx)+1,1);
first = 1;
for i = 1:numel(idx)
   last = idx(i)-1;
   y{i} = str(first:last);
   first = last+2;
end
y{i+1} = str(first:end);
if isempty(y{end}), y = y(1:end-1); end


end