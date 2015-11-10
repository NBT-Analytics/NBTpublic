function y = split_regex(sep, str)
% split_regex - Split string into tokens using a regular expression
%
% ````matlab
% y = split_regex(sep, str)
% ````
% Where
%
% `sep` is a regular expression that matches the token separators.
%
% `str` is the string to be splitted.
%
% `y` is a cell array of strings.
%
% See also: mperl.split, mperl.join


pos = regexp(str, sep);

if isempty(pos),
    y = {};
    return;
end
  
y = cell(1, numel(pos) + 1);
y{1} = str(1:pos(1)-1);
for i = 2:numel(pos),
    y{i} = str(pos(i-1)+1:pos(i)-1);
end
y{end} = str(pos(end)+1:end);

end