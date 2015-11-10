function y = join(expr, list)
% JOIN
%
% Joins a cell array of strings into a single string
%
%
% newStr = join(expr, list)
%
%
% where
%
% LIST is a cell array of strings
%
% EXPR is a expression to interleave each member of the list
%
% NEWSTR is the generated string
%
%
% See also: misc.split


if isempty(list),
    y = '';
    return;
end

if isnumeric(list) && isvector(list),
    list = num2cell(list);
end

if ischar(list),
    list = {list};
end

if isnumeric(list{1}),
    list{1} = num2str(list{1});
end
y = list{1};
for i = 2:numel(list)    
   if isnumeric(list{i}),
       list{i} = num2str(list{i});
   end
   y = [y expr list{i}];  %#ok<AGROW>
end



end