function keysCell = keys(obj)
% KEYS - Returns a cell array of keys
%
% 
% keysCell = keys(obj)
%
%
% Where
%
% OBJ is a hash object
%
% KEYSCELL is a cell array of hash keys
%
%
% See also: hash

keys = obj.Hashtable.keys();
count = 0;
keysCell = cell(1,100);
while (keys.hasMoreElements())
    count = count + 1;
    item = keys.nextElement();
    if ~isnumeric(item),
        keysCell{count} = char(item);
    else
        keysCell{count} = item;
    end        
end
keysCell(count+1:end) = [];


end