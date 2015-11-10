function y = regexp_match(obj, varargin)
% REGEXP_MATCH - Get value that regex-matches the provided key
%
% See also: hash


if numel(varargin) > 1,
    y = cell(size(varargin));
    for i = 1:numel(y)
        y{i} = regexp_match(obj, varargin{i});        
    end
    return;
end

keyStr = varargin{1};
regexList = keys(obj);

y = [];
for i = 1:numel(regexList)
   if ~isempty(regexp(keyStr, regexList{i}, 'once')),
       S.type = '()';
       S.subs = regexList(i);
       y = subsref(obj, S);
       break;
   end
end


end