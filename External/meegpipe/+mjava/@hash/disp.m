function disp(obj)
% DISP - Displays information about a @hash object

keys  = obj.Hashtable.keys();
count = 0;

if (keys.hasMoreElements())
    thisKey = keys.nextElement();
    if isnumeric(thisKey),
        thisKeyStr = num2str(thisKey);
    elseif ischar(thisKey)
        thisKeyStr = thisKey;
    else
        thisKeyStr = '?';
    end
    keyStr = sprintf('%s(%s %s), ', thisKeyStr, ...
        regexprep(num2str(obj.Dimensions.get(thisKey)'), '\s+', 'x'), ...
        char(obj.Class.get(thisKey)));
    count = count + 1;
else
    keyStr = '';
end

while(keys.hasMoreElements())
    thisKey = keys.nextElement();
    if isnumeric(thisKey),
        thisKeyStr = num2str(thisKey);
    elseif ischar(thisKey),
        thisKeyStr = thisKey;
    else
        thisKeyStr = '?';
    end
    thisKeyStr = sprintf('%s(%s %s), ', thisKeyStr, ...
        regexprep(num2str(obj.Dimensions.get(thisKey)'), '\s+', 'x'), ...
        char(obj.Class.get(thisKey)));
    keyStr = [keyStr thisKeyStr];  %#ok<AGROW>
    count = count + 1;
end

if numel(keyStr)>2, keyStr(end-1:end) = []; end

fprintf('%s =\n\n', inputname(1));
fprintf('\t<a href="matlab:help %s">%s</a> with %d keys\n\n', ...
    class(obj), class(obj), obj.Hashtable.size);
%keyStr = char(obj.Hashtable.toString());
if ~isempty(keyStr),
    fprintf('\tkey(value): %s\n\n', keyStr);
end




end